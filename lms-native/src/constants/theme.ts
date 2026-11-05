import { StyleSheet, Platform } from 'react-native';

export const Shadows = StyleSheet.create({
  sm: {
    ...Platform.select({
      ios: {
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 2,
      },
      android: {
        elevation: 1,
      },
      web: {
        boxShadow: '0 1px 3px 0 rgba(15, 23, 42, 0.06)',
      } as any,
    }),
  },
  md: {
    ...Platform.select({
      ios: {
        shadowColor: '#4F46E5',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.08,
        shadowRadius: 12,
      },
      android: {
        elevation: 3,
      },
      web: {
        boxShadow: '0 4px 16px -2px rgba(79, 70, 229, 0.08), 0 2px 6px -2px rgba(15, 23, 42, 0.04)',
      } as any,
    }),
  },
  lg: {
    ...Platform.select({
      ios: {
        shadowColor: '#4F46E5',
        shadowOffset: { width: 0, height: 10 },
        shadowOpacity: 0.15,
        shadowRadius: 24,
      },
      android: {
        elevation: 6,
      },
      web: {
        boxShadow: '0 10px 25px -3px rgba(79, 70, 229, 0.15), 0 4px 6px -4px rgba(15, 23, 42, 0.1)',
      } as any,
    }),
  },
});

