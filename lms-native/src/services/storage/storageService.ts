import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Tầng dịch vụ lưu trữ bền vững (Persistent Storage Service)
 * Sử dụng @react-native-async-storage/async-storage chuẩn doanh nghiệp
 * Hoạt động bền vững trên cả Android, iOS và Web (không bị mất khi tắt app).
 */

const STORAGE_KEYS = {
  TOKEN: 'lms_auth_token',
  USER: 'lms_auth_user',
  SAVED_STUDENT_CODE: 'lms_saved_student_code',
  REMEMBER_ME: 'lms_remember_me',
  THEME: 'lms_app_theme',
  LANGUAGE: 'lms_app_language',
} as const;

class StorageService {
  private memoryCache = new Map<string, string>();

  async getItem(key: string): Promise<string | null> {
    try {
      if (this.memoryCache.has(key)) {
        return this.memoryCache.get(key) ?? null;
      }
      const val = await AsyncStorage.getItem(key);
      if (val != null) {
        this.memoryCache.set(key, val);
        return val;
      }
      return null;
    } catch (e) {
      console.warn(`[StorageService] Failed to get ${key}:`, e);
      return this.memoryCache.get(key) ?? null;
    }
  }

  async setItem(key: string, value: string): Promise<void> {
    try {
      this.memoryCache.set(key, value);
      await AsyncStorage.setItem(key, value);
    } catch (e) {
      console.warn(`[StorageService] Failed to set ${key}:`, e);
    }
  }

  async removeItem(key: string): Promise<void> {
    try {
      this.memoryCache.delete(key);
      await AsyncStorage.removeItem(key);
    } catch (e) {
      console.warn(`[StorageService] Failed to remove ${key}:`, e);
    }
  }

  async clear(): Promise<void> {
    try {
      this.memoryCache.clear();
      await Promise.all([
        AsyncStorage.removeItem(STORAGE_KEYS.TOKEN),
        AsyncStorage.removeItem(STORAGE_KEYS.USER),
      ]);
    } catch (e) {
      console.warn('[StorageService] Failed to clear storage:', e);
    }
  }

  // --- Auth Helpers ---
  async getToken(): Promise<string | null> {
    return this.getItem(STORAGE_KEYS.TOKEN);
  }

  async setToken(token: string): Promise<void> {
    return this.setItem(STORAGE_KEYS.TOKEN, token);
  }

  async removeToken(): Promise<void> {
    return this.removeItem(STORAGE_KEYS.TOKEN);
  }

  async getUser<T>(): Promise<T | null> {
    const raw = await this.getItem(STORAGE_KEYS.USER);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as T;
    } catch {
      return null;
    }
  }

  async setUser<T>(user: T): Promise<void> {
    return this.setItem(STORAGE_KEYS.USER, JSON.stringify(user));
  }

  async removeUser(): Promise<void> {
    return this.removeItem(STORAGE_KEYS.USER);
  }

  async getSavedStudentCode(): Promise<{ studentCode: string; rememberMe: boolean }> {
    const studentCode = (await this.getItem(STORAGE_KEYS.SAVED_STUDENT_CODE)) || '';
    const rememberMeRaw = await this.getItem(STORAGE_KEYS.REMEMBER_ME);
    const rememberMe = rememberMeRaw === 'true';
    return { studentCode, rememberMe };
  }

  async saveStudentCode(studentCode: string, rememberMe: boolean): Promise<void> {
    await this.setItem(STORAGE_KEYS.REMEMBER_ME, String(rememberMe));
    if (rememberMe) {
      await this.setItem(STORAGE_KEYS.SAVED_STUDENT_CODE, studentCode);
    } else {
      await this.removeItem(STORAGE_KEYS.SAVED_STUDENT_CODE);
    }
  }
}

export const storageService = new StorageService();
export { STORAGE_KEYS };
