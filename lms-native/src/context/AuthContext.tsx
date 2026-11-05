import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from 'react';
import { StudentProfile } from '../types/student.types';
import { storageService } from '../services/storage';
import { apiClient } from '../api/client';
import { studentApi } from '../api/studentApi';

export interface AuthContextType {
  user: StudentProfile | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  savedStudentCode: string;
  rememberMe: boolean;
  login: (studentCode: string, password: string, rememberMe?: boolean) => Promise<boolean>;
  logout: () => Promise<void>;
  updateProfile: (profile: Partial<StudentProfile>) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<StudentProfile | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [savedStudentCode, setSavedStudentCode] = useState<string>('');
  const [rememberMe, setRememberMe] = useState<boolean>(false);

  // Khôi phục session an toàn khi mở app
  const logout = useCallback(async () => {
    setToken(null);
    setUser(null);
    setIsAuthenticated(false);
    apiClient.setToken(null);
    await storageService.removeToken();
    await storageService.removeUser();
  }, []);

  const updateProfile = useCallback((updates: Partial<StudentProfile>) => {
    setUser((prev) => {
      if (!prev) return null;
      const updated = { ...prev, ...updates };
      storageService.setUser(updated).catch(() => {});
      return updated;
    });
  }, []);

  useEffect(() => {
    let isMounted = true;

    const restoreSession = async () => {
      try {
        const [savedCreds, savedToken, savedUser] = await Promise.all([
          storageService.getSavedStudentCode(),
          storageService.getToken(),
          storageService.getUser<StudentProfile>(),
        ]);

        if (isMounted) {
          if (savedCreds.rememberMe && savedCreds.studentCode) {
            setSavedStudentCode(savedCreds.studentCode);
            setRememberMe(true);
          }

          // Chỉ khi có token hợp lệ được lưu trong AsyncStorage mới cho phép đăng nhập
          if (savedToken && savedUser) {
            setToken(savedToken);
            apiClient.setToken(savedToken);
            setUser(savedUser);
            setIsAuthenticated(true);
          } else {
            // Chưa đăng nhập -> Buộc hiển thị màn hình Login
            setToken(null);
            setUser(null);
            setIsAuthenticated(false);
          }
        }
      } catch (err) {
        console.warn('[AuthProvider] Restore session error:', err);
        if (isMounted) {
          setIsAuthenticated(false);
        }
      } finally {
        if (isMounted) setIsLoading(false);
      }
    };

    restoreSession();

    // Đăng ký interceptor bắt lỗi 401 Unauthorized
    const unsubscribe = apiClient.onUnauthorized(() => {
      logout();
    });

    return () => {
      isMounted = false;
      unsubscribe();
    };
  }, [logout]);

  const login = useCallback(
    async (studentCode: string, password: string, remember: boolean = true): Promise<boolean> => {
      setIsLoading(true);
      try {
        const authData = await studentApi.login(studentCode, password);
        if (!authData || !authData.token) {
          return false;
        }

        const profile = authData.profile;
        const authToken = authData.token;

        setToken(authToken);
        setUser(profile);
        setIsAuthenticated(true);
        apiClient.setToken(authToken);

        await Promise.all([
          storageService.setToken(authToken),
          storageService.setUser(profile),
          storageService.saveStudentCode(studentCode, remember),
        ]);

        setSavedStudentCode(remember ? studentCode : '');
        setRememberMe(remember);
        return true;
      } catch (err) {
        console.warn('[AuthProvider] Login failed:', err);
        throw err;
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated,
        isLoading,
        savedStudentCode,
        rememberMe,
        login,
        logout,
        updateProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
