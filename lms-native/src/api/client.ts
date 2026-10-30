import { ENV } from '../config/env';
import { storageService } from '../services/storage';

export type UnauthorizedCallback = () => void;

class ApiClient {
  private baseUrl: string;
  private token: string | null = null;
  private unauthorizedListeners: UnauthorizedCallback[] = [];

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  setToken(token: string | null) {
    this.token = token;
    if (token) {
      storageService.setToken(token).catch(() => {});
    } else {
      storageService.removeToken().catch(() => {});
    }
  }

  getToken(): string | null {
    return this.token;
  }

  /**
   * Đăng ký callback khi nhận lỗi 401 Unauthorized
   */
  onUnauthorized(callback: UnauthorizedCallback): () => void {
    this.unauthorizedListeners.push(callback);
    return () => {
      this.unauthorizedListeners = this.unauthorizedListeners.filter((cb) => cb !== callback);
    };
  }

  private handleUnauthorized() {
    this.token = null;
    storageService.removeToken().catch(() => {});
    this.unauthorizedListeners.forEach((cb) => {
      try {
        cb();
      } catch (err) {
        console.warn('[ApiClient] Error in unauthorized listener:', err);
      }
    });
  }

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseUrl}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;

    // Khôi phục token từ storage nếu RAM chưa có
    if (!this.token) {
      const savedToken = await storageService.getToken();
      if (savedToken) {
        this.token = savedToken;
      }
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      ...(options.headers as Record<string, string>),
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15000);

    try {
      const response = await fetch(url, {
        ...options,
        headers,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (response.status === 401) {
        console.warn(`[ApiClient] 401 Unauthorized on ${endpoint}. Triggering logout interceptor.`);
        this.handleUnauthorized();
        throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }

      if (!response.ok) {
        let errorMessage = `HTTP Error ${response.status}: ${response.statusText}`;
        try {
          const errorData = await response.json();
          if (errorData?.message) {
            errorMessage = errorData.message;
          } else if (errorData?.error) {
            errorMessage = errorData.error;
          }
        } catch {
          // Response body was not JSON
        }
        throw new Error(errorMessage);
      }

      if (response.status === 204) {
        return {} as T;
      }

      return await response.json();
    } catch (error: any) {
      clearTimeout(timeoutId);
      if (error?.name === 'AbortError') {
        throw new Error('Yêu cầu hết thời gian chờ (Timeout 15s). Vui lòng thử lại.');
      }
      console.warn(`[ApiClient] Request to ${endpoint} failed:`, error?.message);
      throw error;
    }
  }

  get<T>(endpoint: string) {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  post<T>(endpoint: string, body?: any) {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  put<T>(endpoint: string, body?: any) {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  delete<T>(endpoint: string) {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }
}

export const apiClient = new ApiClient(ENV.API_BASE_URL);
