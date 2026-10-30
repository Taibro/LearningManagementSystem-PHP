import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/colors';
import { Shadows } from '../../constants/theme';
import { AppTextInput, AppButton, AppCard } from '../../components/ui';
import { useAuth } from '../../hooks/useAuth';
import { validateStudentCode, validatePassword } from '../../utils';
import { t } from '../../locales';

interface Props {
  onLoginSuccess?: () => void;
}

export const LoginScreen: React.FC<Props> = ({ onLoginSuccess }) => {
  const { login, savedStudentCode, rememberMe: initialRememberMe } = useAuth();

  const [studentCode, setStudentCode] = useState(savedStudentCode || '');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(initialRememberMe);
  const [loading, setLoading] = useState(false);
  const [codeError, setCodeError] = useState('');
  const [pwdError, setPwdError] = useState('');

  useEffect(() => {
    if (savedStudentCode) {
      setStudentCode(savedStudentCode);
      setRememberMe(true);
    }
  }, [savedStudentCode]);

  const handleLogin = async () => {
    setCodeError('');
    setPwdError('');

    const codeVal = validateStudentCode(studentCode);
    if (!codeVal.isValid) {
      setCodeError(codeVal.message || 'Mã sinh viên không hợp lệ');
      return;
    }

    const pwdVal = validatePassword(password);
    if (!pwdVal.isValid) {
      setPwdError(pwdVal.message || 'Mật khẩu không hợp lệ');
      return;
    }

    setLoading(true);
    try {
      const success = await login(studentCode.trim(), password, rememberMe);
      if (success) {
        onLoginSuccess?.();
      } else {
        Alert.alert('Đăng nhập thất bại', 'Mã sinh viên hoặc mật khẩu không chính xác.');
      }
    } catch (err: any) {
      const errorMsg = err?.message || 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.';
      Alert.alert('Lỗi đăng nhập', errorMsg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Top Header Logo */}
        <View style={styles.header}>
          <View style={styles.logoBadge}>
            <Text style={styles.logoText}>HUIT</Text>
          </View>
          <Text style={styles.schoolName}>{t('auth.schoolName')}</Text>
          <Text style={styles.portalTitle}>{t('auth.portalTitle')}</Text>
          <Text style={styles.portalSub}>{t('auth.portalSub')}</Text>
        </View>

        {/* Login Form Card */}
        <AppCard style={styles.card} variant="elevated" padding="lg">
          {/* School selector */}
          <Text style={styles.label}>{t('auth.campus')}</Text>
          <View style={styles.schoolBox}>
            <Ionicons name="business-outline" size={18} color={Colors.primary} style={{ marginRight: 8 }} />
            <Text style={styles.schoolBoxText}>Trường ĐH Công Thương TP.HCM (HUIT)</Text>
          </View>

          {/* Student code input */}
          <AppTextInput
            label={t('auth.studentCode')}
            placeholder="Nhập MSSV (ví dụ: 2001210001)"
            value={studentCode}
            onChangeText={(txt) => {
              setStudentCode(txt);
              if (codeError) setCodeError('');
            }}
            autoCapitalize="none"
            leftIcon={<Ionicons name="person-outline" size={18} color={Colors.textMuted} />}
            error={codeError}
          />

          {/* Password input */}
          <AppTextInput
            label={t('auth.password')}
            placeholder="Nhập mật khẩu tài khoản"
            value={password}
            onChangeText={(txt) => {
              setPassword(txt);
              if (pwdError) setPwdError('');
            }}
            isPassword
            leftIcon={<Ionicons name="lock-closed-outline" size={18} color={Colors.textMuted} />}
            error={pwdError}
          />

          {/* Remember me & Forgot */}
          <View style={styles.optionsRow}>
            <TouchableOpacity
              style={styles.rememberWrap}
              onPress={() => setRememberMe(!rememberMe)}
              activeOpacity={0.7}
            >
              <Ionicons
                name={rememberMe ? 'checkbox' : 'square-outline'}
                size={18}
                color={rememberMe ? Colors.primary : Colors.textMuted}
                style={{ marginRight: 6 }}
              />
              <Text style={styles.rememberText}>{t('auth.rememberMe')}</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={() =>
                Alert.alert(
                  t('auth.forgotPassword'),
                  'Vui lòng liên hệ phòng Công tác Sinh viên (phòng A104) hoặc hotline (028) 3816 1673 để được cấp lại mật khẩu.'
                )
              }
            >
              <Text style={styles.forgotText}>{t('auth.forgotPassword')}</Text>
            </TouchableOpacity>
          </View>

          {/* Submit button */}
          <AppButton
            title={loading ? 'Đang xác thực...' : t('auth.loginButton')}
            onPress={handleLogin}
            loading={loading}
            size="lg"
            variant="primary"
            style={styles.loginBtn}
          />
        </AppCard>

        {/* Footer Support Info */}
        <View style={styles.footer}>
          <Text style={styles.footerNote}>Hỗ trợ kỹ thuật: support@huit.edu.vn • (028) 3816 1673</Text>
          <Text style={styles.footerVer}>Phiên bản 1.0.0 (Enterprise Architecture)</Text>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 30,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
    marginBottom: 24,
  },
  logoBadge: {
    width: 64,
    height: 64,
    borderRadius: 16,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
    ...Shadows.md,
  },
  logoText: {
    color: '#FFFFFF',
    fontSize: 22,
    fontWeight: '800',
    letterSpacing: 1.5,
  },
  schoolName: {
    fontSize: 13,
    fontWeight: '700',
    color: Colors.primary,
    textAlign: 'center',
    letterSpacing: 0.5,
    marginBottom: 6,
  },
  portalTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: Colors.text,
    textAlign: 'center',
    marginBottom: 4,
  },
  portalSub: {
    fontSize: 13,
    color: Colors.textMuted,
    textAlign: 'center',
  },
  card: {
    marginBottom: 20,
  },
  label: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.textSecondary,
    marginBottom: 6,
  },
  schoolBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.primaryLight,
    paddingVertical: 12,
    paddingHorizontal: 14,
    borderRadius: 10,
    marginBottom: 16,
  },
  schoolBoxText: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.primary,
    flex: 1,
  },
  optionsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 4,
    marginBottom: 20,
  },
  rememberWrap: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  rememberText: {
    fontSize: 13,
    color: Colors.textSecondary,
  },
  forgotText: {
    fontSize: 13,
    color: Colors.primary,
    fontWeight: '600',
  },
  loginBtn: {
    marginTop: 4,
  },
  footer: {
    alignItems: 'center',
    marginTop: 10,
  },
  footerNote: {
    fontSize: 12,
    color: Colors.textMuted,
    textAlign: 'center',
    marginBottom: 4,
  },
  footerVer: {
    fontSize: 11,
    color: Colors.textLight,
  },
});
