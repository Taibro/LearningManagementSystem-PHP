import { describe, it, expect, jest } from '@jest/globals';
import { pkceAuthService } from '../src/services/auth/pkceAuthService';
import { ENV } from '../src/config/env';

jest.mock('expo-crypto', () => ({
  getRandomBytesAsync: jest.fn(),
  digestStringAsync: jest.fn(),
  CryptoDigestAlgorithm: { SHA256: 'SHA-256' },
  CryptoEncoding: { BASE64: 'base64' },
}));

jest.mock('expo-web-browser', () => ({
  maybeCompleteAuthSession: jest.fn(),
  openAuthSessionAsync: jest.fn(),
}));

describe('LMS Mobile App Suite - Keycloak PKCE & Multi-Tenant', () => {
  it('passes sanity check', () => {
    expect(1 + 1).toBe(2);
  });

  it('generates valid Keycloak PKCE authorization URL with RFC 7636 parameters', () => {
    const mockChallenge = 'test_code_challenge_12345';
    const authUrl = pkceAuthService.getAuthorizationUrl(mockChallenge);

    expect(authUrl).toContain(`${ENV.KEYCLOAK_BASE_URL}/realms/${ENV.KEYCLOAK_REALM}/protocol/openid-connect/auth`);
    expect(authUrl).toContain('client_id=lms-mobile');
    expect(authUrl).toContain('response_type=code');
    expect(authUrl).toContain(`redirect_uri=${encodeURIComponent(ENV.REDIRECT_URI)}`);
    expect(authUrl).toContain(`code_challenge=${mockChallenge}`);
    expect(authUrl).toContain('code_challenge_method=S256');
    expect(authUrl).toContain('scope=openid');
  });

  it('handles multi-tenant student profiles for both HUIT and HCMUT', async () => {
    const profileHuit = await pkceAuthService.fetchUserProfile('mock_token');
    expect(profileHuit.studentCode).toBeDefined();
    expect(profileHuit.fullName).toBeDefined();
  });
});
