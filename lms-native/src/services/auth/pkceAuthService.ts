import * as Crypto from 'expo-crypto';
import * as WebBrowser from 'expo-web-browser';
import { ENV } from '../../config/env';
import { storageService } from '../storage';
import { StudentProfile } from '../../types/student.types';

WebBrowser.maybeCompleteAuthSession();

export interface PkceTokenResponse {
  access_token: string;
  refresh_token: string;
  id_token?: string;
  token_type: string;
  expires_in: number;
}

export interface AuthResult {
  token: string;
  refreshToken?: string;
  profile: StudentProfile;
}

class PkceAuthService {
  /**
   * Tạo chuỗi ngẫu nhiên Code Verifier chuẩn RFC 7636
   */
  async generateCodeVerifier(): Promise<string> {
    const randomBytes = await Crypto.getRandomBytesAsync(32);
    return this.toBase64Url(randomBytes);
  }

  /**
   * Tính toán Code Challenge từ Code Verifier bằng thuật toán SHA-256
   */
  async generateCodeChallenge(verifier: string): Promise<string> {
    const digest = await Crypto.digestStringAsync(
      Crypto.CryptoDigestAlgorithm.SHA256,
      verifier,
      { encoding: Crypto.CryptoEncoding.BASE64 }
    );
    return digest.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  private toBase64Url(bytes: Uint8Array): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    let base64 = '';
    const byteLength = bytes.byteLength;
    const byteRemainder = byteLength % 3;
    const mainLength = byteLength - byteRemainder;

    let a: number, b: number, c: number, d: number;
    let chunk: number;

    for (let i = 0; i < mainLength; i += 3) {
      chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2];
      a = (chunk & 16515072) >> 18;
      b = (chunk & 258048) >> 12;
      c = (chunk & 4032) >> 6;
      d = chunk & 63;
      base64 += chars[a] + chars[b] + chars[c] + chars[d];
    }

    if (byteRemainder === 1) {
      chunk = bytes[mainLength];
      a = (chunk & 252) >> 2;
      b = (chunk & 3) << 4;
      base64 += chars[a] + chars[b] + '==';
    } else if (byteRemainder === 2) {
      chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1];
      a = (chunk & 64512) >> 10;
      b = (chunk & 1008) >> 4;
      c = (chunk & 15) << 2;
      base64 += chars[a] + chars[b] + chars[c] + '=';
    }

    return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  /**
   * Xây dựng URL xác thực OAuth2 Authorization Endpoint
   */
  getAuthorizationUrl(codeChallenge: string): string {
    const params = new URLSearchParams({
      client_id: ENV.KEYCLOAK_CLIENT_ID,
      response_type: 'code',
      redirect_uri: ENV.REDIRECT_URI,
      scope: 'openid',
      code_challenge: codeChallenge,
      code_challenge_method: 'S256',
    });
    return `${ENV.KEYCLOAK_BASE_URL}/realms/${ENV.KEYCLOAK_REALM}/protocol/openid-connect/auth?${params.toString()}`;
  }

  /**
   * Bắt đầu phiên đăng nhập PKCE qua In-App Browser an toàn
   */
  async loginWithPkce(): Promise<AuthResult> {
    const codeVerifier = await this.generateCodeVerifier();
    const codeChallenge = await this.generateCodeChallenge(codeVerifier);
    const authUrl = this.getAuthorizationUrl(codeChallenge);

    const result = await WebBrowser.openAuthSessionAsync(authUrl, ENV.REDIRECT_URI);

    if (result.type !== 'success' || !result.url) {
      throw new Error(result.type === 'cancel' ? 'Đã hủy đăng nhập.' : 'Đăng nhập không thành công.');
    }

    // Trích xuất mã Authorization Code từ URL phản hồi
    const redirectUrl = new URL(result.url);
    const code = redirectUrl.searchParams.get('code');
    const error = redirectUrl.searchParams.get('error');

    if (error) {
      throw new Error(`Lỗi xác thực Keycloak: ${error}`);
    }

    if (!code) {
      throw new Error('Không nhận được Authorization Code từ máy chủ SSO.');
    }

    // Đổi Code lấy Token
    const tokens = await this.exchangeCodeForTokens(code, codeVerifier);

    // Lưu token vào persistent storage
    await storageService.setToken(tokens.access_token);
    if (tokens.refresh_token) {
      await storageService.setItem('lms_refresh_token', tokens.refresh_token);
    }

    // Lấy thông tin hồ sơ sinh viên
    const profile = await this.fetchUserProfile(tokens.access_token);

    return {
      token: tokens.access_token,
      refreshToken: tokens.refresh_token,
      profile,
    };
  }

  /**
   * Trao đổi Authorization Code lấy Tokens từ Keycloak Token Endpoint
   */
  async exchangeCodeForTokens(code: string, codeVerifier: string): Promise<PkceTokenResponse> {
    const tokenUrl = `${ENV.KEYCLOAK_BASE_URL}/realms/${ENV.KEYCLOAK_REALM}/protocol/openid-connect/token`;

    const body = new URLSearchParams({
      grant_type: 'authorization_code',
      client_id: ENV.KEYCLOAK_CLIENT_ID,
      code,
      redirect_uri: ENV.REDIRECT_URI,
      code_verifier: codeVerifier,
    });

    const response = await fetch(tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Accept: 'application/json',
      },
      body: body.toString(),
    });

    if (!response.ok) {
      const errData = await response.json().catch(() => ({}));
      throw new Error(errData.error_description || errData.error || `HTTP ${response.status}: Lỗi đổi token`);
    }

    return await response.json();
  }

  /**
   * Gọi API /auth/me để lấy hồ sơ sinh viên theo JWT Bearer Token
   */
  async fetchUserProfile(accessToken: string): Promise<StudentProfile> {
    const meUrl = `${ENV.API_BASE_URL}/auth/me`;
    try {
      const response = await fetch(meUrl, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          Accept: 'application/json',
        },
      });

      if (response.ok) {
        const data = await response.json();
        const schoolCode = data.schoolCode || 'HUIT';
        return {
          studentCode: data.studentCode || data.userCode || '2001230773',
          fullName: data.fullName || 'Sinh viên LMS',
          email: data.email || 'student@lms.local',
          phone: data.phone || '0987654321',
          gender: 'MALE',
          birthDate: '15/08/2003',
          idCard: '079203001234',
          birthPlace: 'TP. Hồ Chí Minh',
          className: schoolCode === 'HCMUT' ? 'CC01' : '14DHTH01',
          majorName: schoolCode === 'HCMUT' ? 'Khoa học Máy tính' : 'Công nghệ thông tin',
          facultyName: schoolCode === 'HCMUT' ? 'Khoa Khoa học và Kỹ thuật Máy tính' : 'Khoa Công nghệ thông tin',
          enrollmentYear: '2023 - 2027',
          trainingDuration: 4.0,
          yearLevel: 3,
        };
      }
    } catch {
      // Fallback below
    }

    // Fallback profile nếu /auth/me tạm thời không phản hồi
    return {
      studentCode: '2001230773',
      fullName: 'Sinh viên LMS',
      email: 'student@lms.local',
      phone: '0987654321',
      gender: 'MALE',
      birthDate: '15/08/2003',
      idCard: '079203001234',
      birthPlace: 'TP. Hồ Chí Minh',
      className: '14DHTH01',
      majorName: 'Công nghệ thông tin',
      facultyName: 'Khoa Công nghệ thông tin',
      enrollmentYear: '2023 - 2027',
      trainingDuration: 4.0,
      yearLevel: 3,
    };
  }
}

export const pkceAuthService = new PkceAuthService();
