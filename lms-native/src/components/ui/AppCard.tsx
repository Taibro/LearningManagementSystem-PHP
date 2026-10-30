import React, { ReactNode } from 'react';
import { View, StyleSheet, ViewStyle, ViewProps } from 'react-native';
import { Shadows } from '../../constants/theme';

export interface AppCardProps extends ViewProps {
  variant?: 'elevated' | 'outlined' | 'flat';
  padding?: 'none' | 'sm' | 'md' | 'lg';
  children: ReactNode;
  style?: ViewStyle;
}

export const AppCard: React.FC<AppCardProps> = ({
  variant = 'elevated',
  padding = 'md',
  children,
  style,
  ...rest
}) => {
  const getPadding = () => {
    switch (padding) {
      case 'none':
        return 0;
      case 'sm':
        return 10;
      case 'lg':
        return 20;
      case 'md':
      default:
        return 14;
    }
  };

  const getVariantStyle = () => {
    switch (variant) {
      case 'outlined':
        return styles.outlined;
      case 'flat':
        return styles.flat;
      case 'elevated':
      default:
        return [styles.elevated, Shadows.sm];
    }
  };

  return (
    <View style={[styles.base, getVariantStyle(), { padding: getPadding() }, style]} {...rest}>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  base: {
    backgroundColor: '#FFFFFF',
    borderRadius: 14,
  },
  elevated: {
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.03)',
  },
  outlined: {
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  flat: {
    backgroundColor: '#F8FAFC',
  },
});

