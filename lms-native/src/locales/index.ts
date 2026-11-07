import vi from './vi.json';
import en from './en.json';
import { appStore } from '../store/useAppStore';

export const translations = { vi, en };


export const t = (path: string): string => {
  const currentLang = appStore.getState().language || 'vi';
  const dict = translations[currentLang] || vi;

  const parts = path.split('.');
  let current: any = dict;

  for (const part of parts) {
    if (current && typeof current === 'object' && part in current) {
      current = current[part];
    } else {
      return path;
    }
  }

  return typeof current === 'string' ? current : path;
};

