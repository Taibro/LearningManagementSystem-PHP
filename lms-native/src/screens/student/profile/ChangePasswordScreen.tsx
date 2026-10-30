import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { AppTextInput, AppButton, AppCard } from '../../../components/ui';
import { studentApi } from '../../../api/studentApi';
import { validatePassword } from '../../../utils';

interface Props {
  onBack: () => void;
}

export const ChangePasswordScreen: React.FC<Props> = ({ onBack }) => {
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const [oldError, setOldError] = useState('');
  const [newError, setNewError] = useState('');
  const [confirmError, setConfirmError] = useState('');

  const handleSubmit = async () => {
    setOldError('');
    setNewError('');
    setConfirmError('');

    if (!oldPassword) {
      setOldError('Vui lòng nhập mật khẩu hiện tại.');
      return;
    }

    const newValidation = validatePassword(newPassword);
    if (!newValidation.isValid) {
      setNewError(newValidation.message || 'Mật khẩu mới không hợp lệ.');
      return;
    }

    if (newPassword !== confirmPassword) {
      setConfirmError('Xác nhận mật khẩu mới không khớp.');
      return;
    }

    setLoading(true);
    try {
      const res = await studentApi.changePassword({
        currentPassword: oldPassword,
        newPassword,
        confirmPassword,
      });

      if (res.success) {
        Alert.alert('Thành công', res.message || 'Mật khẩu tài khoản đã được thay đổi thành công!', [
          { text: 'Đồng ý', onPress: onBack },
        ]);
      } else {
        Alert.alert('Thất bại', res.message || 'Không thể đổi mật khẩu. Vui lòng thử lại.');
      }
    } catch (err: any) {
      Alert.alert('Lỗi', err?.message || 'Đã xảy ra sự cố trong quá trình đổi mật khẩu.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <AppHeader title="Đổi mật khẩu" onBack={onBack} />

      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <AppCard variant="elevated" padding="lg" style={styles.card}>
          {/* Mật khẩu cũ */}
          <AppTextInput
            label="Mật khẩu hiện tại"
            placeholder="Nhập mật khẩu đang dùng"
            value={oldPassword}
            onChangeText={(txt) => {
              setOldPassword(txt);
              if (oldError) setOldError('');
            }}
            isPassword
            error={oldError}
          />

          {/* Mật khẩu mới */}
          <AppTextInput
            label="Mật khẩu mới"
            placeholder="Nhập mật khẩu mới (tối thiểu 6 ký tự)"
            value={newPassword}
            onChangeText={(txt) => {
              setNewPassword(txt);
              if (newError) setNewError('');
            }}
            isPassword
            error={newError}
          />

          {/* Xác nhận mật khẩu mới */}
          <AppTextInput
            label="Xác nhận mật khẩu mới"
            placeholder="Nhập lại mật khẩu mới"
            value={confirmPassword}
            onChangeText={(txt) => {
              setConfirmPassword(txt);
              if (confirmError) setConfirmError('');
            }}
            isPassword
            error={confirmError}
          />

          {/* Quy định mật khẩu */}
          <View style={styles.rulesBox}>
            <Text style={styles.rulesTitle}>Quy định bảo mật mật khẩu:</Text>
            <Text style={styles.ruleItem}>• Tối thiểu 6 ký tự trở lên.</Text>
            <Text style={styles.ruleItem}>• Nên kết hợp chữ hoa, chữ thường và chữ số.</Text>
            <Text style={styles.ruleItem}>• Tuyệt đối không chia sẻ mật khẩu cho người khác.</Text>
          </View>

          {/* Nút cập nhật */}
          <AppButton
            title={loading ? 'Đang cập nhật...' : 'Cập nhật mật khẩu mới'}
            onPress={handleSubmit}
            loading={loading}
            size="lg"
            variant="primary"
            style={styles.submitBtn}
          />
        </AppCard>
        </ScrollView>
      </KeyboardAvoidingView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  card: {
    backgroundColor: Colors.card,
    borderRadius: 20,
    padding: 18,
  },
  rulesBox: {
    backgroundColor: Colors.bg,
    borderRadius: 12,
    padding: 14,
    marginTop: 4,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  rulesTitle: {
    fontSize: 12,
    fontWeight: '700',
    color: Colors.textSecondary,
    marginBottom: 6,
  },
  ruleItem: {
    fontSize: 11,
    color: Colors.textMuted,
    lineHeight: 18,
  },
  submitBtn: {
    marginTop: 4,
  },
});


