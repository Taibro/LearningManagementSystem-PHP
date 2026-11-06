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
  Modal,
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

interface SchoolOption {
  id: number;
  code: string;
  name: string;
  shortName: string;
  displayName: string;
  defaultPlaceholder: string;
  supportPhone: string;
  supportEmail: string;
}

const SCHOOL_OPTIONS: SchoolOption[] = [
  {
    id: 1,
    code: 'HUIT',
    name: 'Trường ĐH Công Thương TP.HCM (HUIT)',
    shortName: 'HUIT',
    displayName: 'TRƯỜNG ĐẠI HỌC CÔNG THƯƠNG TP.HCM',
    defaultPlaceholder: 'Nhập MSSV (ví dụ: 2001230773, 2001216302)',
    supportPhone: '(028) 3816 1673',
    supportEmail: 'support@huit.edu.vn',
  },
  {
    id: 2,
    code: 'HCMUT',
    name: 'Trường ĐH Bách Khoa TP.HCM (HCMUT)',
    shortName: 'HCMUT',
    displayName: 'TRƯỜNG ĐẠI HỌC BÁCH KHOA TP.HCM',
    defaultPlaceholder: 'Nhập MSSV (ví dụ: 2001220001)',
    supportPhone: '(028) 3864 7256',
    supportEmail: 'support@hcmut.edu.vn',
  },
];

export const LoginScreen: React.FC<Props> = ({ onLoginSuccess }) => {
  const { login, loginWithPkce, savedStudentCode, rememberMe: initialRememberMe } = useAuth();

  const [selectedSchool, setSelectedSchool] = useState<SchoolOption>(SCHOOL_OPTIONS[0]);
  const [showSchoolModal, setShowSchoolModal] = useState(false);
  const [studentCode, setStudentCode] = useState(savedStudentCode || '');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(initialRememberMe);
  const [loading, setLoading] = useState(false);
  const [pkceLoading, setPkceLoading] = useState(false);
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

    // Nếu người dùng không nhập thông tin, tự động mở luồng PKCE SSO
    if (!studentCode.trim() && !password) {
      handlePkceLogin();
      return;
    }

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
      const trimmedCode = studentCode.trim();
      let targetSchool = selectedSchool;
      if (trimmedCode.startsWith('200122') || trimmedCode.toLowerCase().includes('hcmut')) {
        targetSchool = SCHOOL_OPTIONS.find((s) => s.code === 'HCMUT') || selectedSchool;
      } else if (trimmedCode.startsWith('200121') || trimmedCode.startsWith('200123') || trimmedCode.toLowerCase().includes('huit')) {
        targetSchool = SCHOOL_OPTIONS.find((s) => s.code === 'HUIT') || selectedSchool;
      }
      if (targetSchool.code !== selectedSchool.code) {
        setSelectedSchool(targetSchool);
      }

      const success = await login(trimmedCode, password, rememberMe, targetSchool.code);
      if (success) {
        onLoginSuccess?.();
      } else {
        const msg = 'Mã sinh viên hoặc mật khẩu không chính xác.';
        if (Platform.OS === 'web') {
          window.alert(msg);
        } else {
          Alert.alert('Đăng nhập thất bại', msg);
        }
      }
    } catch (err: any) {
      const errorMsg = err?.message || 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.';
      if (Platform.OS === 'web') {
        window.alert(errorMsg);
      } else {
        Alert.alert('Lỗi đăng nhập', errorMsg);
      }
    } finally {
      setLoading(false);
    }
  };

  const handlePkceLogin = async () => {
    setPkceLoading(true);
    try {
      const success = await loginWithPkce();
      if (success) {
        onLoginSuccess?.();
      }
    } catch (err: any) {
      if (err?.message?.includes('hủy') || err?.message?.includes('cancel')) {
        return;
      }
      const errorMsg = err?.message || 'Không thể đăng nhập qua Keycloak SSO.';
      if (Platform.OS === 'web') {
        window.alert(errorMsg);
      } else {
        Alert.alert('Lỗi xác thực SSO', errorMsg);
      }
    } finally {
      setPkceLoading(false);
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
            <Text style={styles.logoText}>{selectedSchool.shortName}</Text>
          </View>
          <Text style={styles.schoolName}>{selectedSchool.displayName}</Text>
          <Text style={styles.portalTitle}>{t('auth.portalTitle')}</Text>
          <Text style={styles.portalSub}>{t('auth.portalSub')}</Text>
        </View>

        {/* Login Form Card */}
        <AppCard style={styles.card} variant="elevated" padding="lg">
          {/* School selector */}
          <Text style={styles.label}>{t('auth.campus')}</Text>
          <TouchableOpacity
            style={styles.schoolBox}
            onPress={() => setShowSchoolModal(true)}
            activeOpacity={0.7}
          >
            <Ionicons name="business-outline" size={18} color={Colors.primary} style={{ marginRight: 8 }} />
            <Text style={styles.schoolBoxText} numberOfLines={1}>
              {selectedSchool.name}
            </Text>
            <Ionicons name="chevron-down" size={16} color={Colors.primary} />
          </TouchableOpacity>

          {/* Student code input */}
          <AppTextInput
            label={t('auth.studentCode')}
            placeholder={selectedSchool.defaultPlaceholder}
            value={studentCode}
            onChangeText={(txt) => {
              setStudentCode(txt);
              if (codeError) setCodeError('');
              const trimmed = txt.trim();
              if (trimmed.startsWith('200122') || trimmed.toLowerCase().includes('hcmut')) {
                const bk = SCHOOL_OPTIONS.find((s) => s.code === 'HCMUT');
                if (bk && selectedSchool.code !== 'HCMUT') setSelectedSchool(bk);
              } else if (trimmed.startsWith('200121') || trimmed.startsWith('200123') || trimmed.toLowerCase().includes('huit')) {
                const huit = SCHOOL_OPTIONS.find((s) => s.code === 'HUIT');
                if (huit && selectedSchool.code !== 'HUIT') setSelectedSchool(huit);
              }
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
                  `Vui lòng liên hệ phòng Công tác Sinh viên hoặc hotline ${selectedSchool.supportPhone} để được cấp lại mật khẩu.`
                )
              }
            >
              <Text style={styles.forgotText}>{t('auth.forgotPassword')}</Text>
            </TouchableOpacity>
          </View>

          {/* Unified Primary Login Button */}
          <AppButton
            title={loading ? 'Đang xác thực...' : pkceLoading ? 'Đang kết nối Keycloak...' : t('auth.loginButton')}
            onPress={handleLogin}
            loading={loading || pkceLoading}
            size="lg"
            variant="primary"
            style={styles.loginBtn}
          />
        </AppCard>

        {/* Footer Support Info */}
        <View style={styles.footer}>
          <Text style={styles.footerNote}>
            Hỗ trợ kỹ thuật: {selectedSchool.supportEmail} • {selectedSchool.supportPhone}
          </Text>
          <Text style={styles.footerVer}>Phiên bản 1.0.0 (Enterprise Architecture)</Text>
        </View>
      </ScrollView>

      {/* School Picker Modal */}
      <Modal
        visible={showSchoolModal}
        transparent
        animationType="fade"
        onRequestClose={() => setShowSchoolModal(false)}
      >
        <TouchableOpacity
          style={styles.modalOverlay}
          activeOpacity={1}
          onPress={() => setShowSchoolModal(false)}
        >
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Chọn Cơ Sở Đào Tạo</Text>
              <TouchableOpacity onPress={() => setShowSchoolModal(false)}>
                <Ionicons name="close" size={22} color={Colors.textSecondary} />
              </TouchableOpacity>
            </View>

            {SCHOOL_OPTIONS.map((item) => {
              const isSelected = item.code === selectedSchool.code;
              return (
                <TouchableOpacity
                  key={item.code}
                  style={[styles.modalItem, isSelected && styles.modalItemSelected]}
                  onPress={() => {
                    setSelectedSchool(item);
                    setShowSchoolModal(false);
                    setCodeError('');
                    setPwdError('');
                  }}
                  activeOpacity={0.7}
                >
                  <View style={styles.modalItemLeft}>
                    <View style={[styles.modalItemBadge, isSelected && styles.modalItemBadgeSelected]}>
                      <Text style={[styles.modalItemBadgeText, isSelected && styles.modalItemBadgeTextSelected]}>
                        {item.shortName}
                      </Text>
                    </View>
                    <View style={styles.modalItemInfo}>
                      <Text style={[styles.modalItemName, isSelected && styles.modalItemNameSelected]}>
                        {item.name}
                      </Text>
                      <Text style={styles.modalItemSub}>Mã trường: {item.code}</Text>
                    </View>
                  </View>
                  {isSelected && (
                    <Ionicons name="checkmark-circle" size={20} color={Colors.primary} />
                  )}
                </TouchableOpacity>
              );
            })}
          </View>
        </TouchableOpacity>
      </Modal>
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
    width: 68,
    height: 68,
    borderRadius: 18,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
    ...Shadows.md,
  },
  logoText: {
    color: '#FFFFFF',
    fontSize: 20,
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
    borderWidth: 1,
    borderColor: '#DBEAFE',
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
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  modalContent: {
    width: '100%',
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
    ...Shadows.lg,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  modalTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: Colors.text,
  },
  modalItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 12,
    paddingHorizontal: 12,
    borderRadius: 10,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: 'transparent',
  },
  modalItemSelected: {
    backgroundColor: Colors.primaryLight,
    borderColor: '#93C5FD',
  },
  modalItemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  modalItemBadge: {
    width: 44,
    height: 44,
    borderRadius: 10,
    backgroundColor: '#F1F5F9',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  modalItemBadgeSelected: {
    backgroundColor: Colors.primary,
  },
  modalItemBadgeText: {
    fontSize: 12,
    fontWeight: '700',
    color: Colors.textSecondary,
  },
  modalItemBadgeTextSelected: {
    color: '#FFFFFF',
  },
  modalItemInfo: {
    flex: 1,
  },
  modalItemName: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 2,
  },
  modalItemNameSelected: {
    color: Colors.primary,
    fontWeight: '700',
  },
  modalItemSub: {
    fontSize: 11,
    color: Colors.textMuted,
  },
});
