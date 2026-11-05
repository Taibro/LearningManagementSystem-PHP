import React, { ReactNode } from 'react';
import {
  TouchableOpacity,
  Text,
  ActivityIndicator,
  StyleSheet,
  ViewStyle,
  TextStyle,
  TouchableOpacityProps,
} from 'react-native';
import { Colors } from '../../constants/colors';
import { Shadows } from '../../constants/theme';

export type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'danger' | 'ghost';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface AppButtonProps extends TouchableOpacityProps {
  title: string;
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  style?: ViewStyle;
  textStyle?: TextStyle;
}

export const AppButton: React.FC<AppButtonProps> = ({
  title,
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  leftIcon,
  rightIcon,
  style,
  textStyle,
  ...rest
}) => {
  const getContainerStyle = (): ViewStyle => {
    switch (variant) {
      case 'secondary':
        return { backgroundColor: Colors.secondary, borderColor: Colors.secondary };
      case 'outline':
        return { backgroundColor: 'transparent', borderColor: Colors.primary, borderWidth: 1.5 };
      case 'danger':
        return { backgroundColor: Colors.danger, borderColor: Colors.danger };
      case 'ghost':
        return { backgroundColor: 'transparent', borderColor: 'transparent' };
      case 'primary':
      default:
        return { backgroundColor: Colors.primary, borderColor: Colors.primary };
    }
  };

  const getTextColor = (): string => {
    if (disabled) return Colors.textMuted;
    switch (variant) {
      case 'outline':
      case 'ghost':
        return Colors.primary;
      case 'secondary':
      case 'danger':
      case 'primary':
      default:
        return '#FFFFFF';
    }
  };

  const getSizeStyle = (): { container: ViewStyle; text: TextStyle } => {
    switch (size) {
      case 'sm':
        return {
          container: { paddingVertical: 8, paddingHorizontal: 14, borderRadius: 8 },
          text: { fontSize: 13, fontWeight: '600' },
        };
      case 'lg':
        return {
          container: { paddingVertical: 16, paddingHorizontal: 24, borderRadius: 14 },
          text: { fontSize: 16, fontWeight: '700' },
        };
      case 'md':
      default:
        return {
          container: { paddingVertical: 13, paddingHorizontal: 20, borderRadius: 12 },
          text: { fontSize: 14, fontWeight: '600' },
        };
    }
  };

  const sizeStyle = getSizeStyle();
  const textColor = getTextColor();

  return (
    <TouchableOpacity
      activeOpacity={0.8}
      disabled={disabled || loading}
      style={[
        styles.base,
        getContainerStyle(),
        sizeStyle.container,
        variant === 'primary' && Shadows.sm,
        disabled && styles.disabled,
        style,
      ]}
      {...rest}
    >
      {loading ? (
        <ActivityIndicator color={textColor} size="small" />
      ) : (
        <>
          {leftIcon && <>{leftIcon}</>}
          <Text style={[styles.text, sizeStyle.text, { color: textColor }, textStyle]}>
            {title}
          </Text>
          {rightIcon && <>{rightIcon}</>}
        </>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  text: {
    textAlign: 'center',
  },
  disabled: {
    opacity: 0.55,
  },
});

