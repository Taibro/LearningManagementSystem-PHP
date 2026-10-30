import { useState, useEffect, useCallback } from 'react';
import { storageService } from '../services/storage';

export type AppTheme = 'light' | 'dark';
export type AppLanguage = 'vi' | 'en';

export interface AppState {
  theme: AppTheme;
  language: AppLanguage;
  selectedSemesterId: string | null;
  unreadNotificationsCount: number;
}

// In-memory singleton state
let globalAppState: AppState = {
  theme: 'light',
  language: 'vi',
  selectedSemesterId: '2025-2026-HK2',
  unreadNotificationsCount: 3,
};

const listeners = new Set<() => void>();

const notifyListeners = () => {
  listeners.forEach((listener) => listener());
};

export const appStore = {
  getState: (): AppState => globalAppState,

  setTheme: (theme: AppTheme) => {
    globalAppState = { ...globalAppState, theme };
    storageService.setItem('lms_app_theme', theme).catch(() => {});
    notifyListeners();
  },

  setLanguage: (language: AppLanguage) => {
    globalAppState = { ...globalAppState, language };
    storageService.setItem('lms_app_language', language).catch(() => {});
    notifyListeners();
  },

  setSelectedSemesterId: (selectedSemesterId: string | null) => {
    globalAppState = { ...globalAppState, selectedSemesterId };
    notifyListeners();
  },

  setUnreadNotificationsCount: (unreadNotificationsCount: number) => {
    globalAppState = { ...globalAppState, unreadNotificationsCount };
    notifyListeners();
  },
};

/**
 * React hook để lắng nghe và tương tác với Global App Store
 */
export const useAppStore = () => {
  const [, setTick] = useState(0);

  useEffect(() => {
    const listener = () => setTick((t) => t + 1);
    listeners.add(listener);
    return () => {
      listeners.delete(listener);
    };
  }, []);

  const setTheme = useCallback((theme: AppTheme) => appStore.setTheme(theme), []);
  const setLanguage = useCallback((lang: AppLanguage) => appStore.setLanguage(lang), []);
  const setSelectedSemesterId = useCallback((id: string | null) => appStore.setSelectedSemesterId(id), []);
  const setUnreadNotificationsCount = useCallback((count: number) => appStore.setUnreadNotificationsCount(count), []);

  return {
    ...globalAppState,
    setTheme,
    setLanguage,
    setSelectedSemesterId,
    setUnreadNotificationsCount,
  };
};

