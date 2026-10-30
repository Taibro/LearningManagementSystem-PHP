import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { SkeletonLoader } from '../../../components/ui/SkeletonLoader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { StudentProfile } from '../../../types/student.types';

interface Props {
  onNavigate: (screen: string) => void;
  onLogout: () => void;
}

export const ProfileScreen: React.FC<Props> = ({ onNavigate, onLogout }) => {
  const [profile, setProfile] = useState<StudentProfile | null>(null);

  useEffect(() => {
    studentApi.getProfile().then(setProfile).catch(() => {});
  }, []);

  const getInitials = (name: string) => {
    const parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[parts.length - 2][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.slice(0, 2).toUpperCase();
  };

  const handleLogoutConfirm = () => {
    Alert.alert('Đăng xuất', 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?', [
      { text: 'Hủy', style: 'cancel' },
      { text: 'Đăng xuất', style: 'destructive', onPress: onLogout },
    ]);
  };

  if (!profile) {
    return (
      <View style={styles.container}>
        <AppHeader title="Hồ sơ cá nhân" />
        <View style={{ padding: 16 }}>
          <SkeletonLoader height={140} borderRadius={20} style={{ marginBottom: 16 }} />
          <SkeletonLoader height={60} borderRadius={14} style={{ marginBottom: 12 }} />
          <SkeletonLoader height={60} borderRadius={14} style={{ marginBottom: 12 }} />
          <SkeletonLoader height={60} borderRadius={14} style={{ marginBottom: 12 }} />
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <AppHeader title="Hồ sơ cá nhân" />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Profile Header Card */}
        <View style={[styles.headerCard, Shadows.md]}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{getInitials(profile.fullName)}</Text>
          </View>
          <Text style={styles.nameText}>{profile.fullName}</Text>
          <Text style={styles.mssvText}>MSSV: {profile.studentCode}</Text>
          <View style={styles.classBadge}>
            <Text style={styles.classBadgeText}>{profile.className} • {profile.majorName}</Text>
          </View>
          <View style={styles.statusBadge}>
            <View style={styles.statusDot} />
            <Text style={styles.statusText}>Đang theo học (Năm {profile.yearLevel})</Text>
          </View>
        </View>

        {/* Group 1: Học tập */}
        <Text style={styles.groupTitle}>HỌC TẬP & ĐÀO TẠO</Text>
        <View style={[styles.menuCard, Shadows.sm]}>
          <TouchableOpacity style={styles.menuItem} onPress={() => onNavigate('student_info')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#EFF6FF' }]}>
              <Ionicons name="person-outline" size={20} color={Colors.primary} />
            </View>
            <Text style={styles.menuLabel}>Thông tin sinh viên chi tiết</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>

          <View style={styles.menuDivider} />

          <TouchableOpacity style={styles.menuItem} onPress={() => onNavigate('grades')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#F0FDF4' }]}>
              <Ionicons name="school-outline" size={20} color={Colors.success} />
            </View>
            <Text style={styles.menuLabel}>Kết quả học tập (Xem điểm)</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>

          <View style={styles.menuDivider} />

          <TouchableOpacity style={styles.menuItem} onPress={() => onNavigate('curriculum')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#FEF2F2' }]}>
              <Ionicons name="book-outline" size={20} color={Colors.danger} />
            </View>
            <Text style={styles.menuLabel}>Chương trình đào tạo khung</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>

          <View style={styles.menuDivider} />

          <TouchableOpacity style={styles.menuItem} onPress={() => onNavigate('conduct')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#FEFCE8' }]}>
              <Ionicons name="ribbon-outline" size={20} color="#CA8A04" />
            </View>
            <Text style={styles.menuLabel}>Điểm rèn luyện</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>
        </View>

        {/* Group 2: Tài chính */}
        <Text style={styles.groupTitle}>TÀI CHÍNH & HỌC PHÍ</Text>
        <View style={[styles.menuCard, Shadows.sm]}>
          <TouchableOpacity style={styles.menuItem} onPress={() => onNavigate('receipt')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#ECFEFF' }]}>
              <Ionicons name="receipt-outline" size={20} color={Colors.cyan} />
            </View>
            <Text style={styles.menuLabel}>Phiếu thu học phí</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>

          <View style={styles.menuDivider} />

          <TouchableOpacity style={styles.menuItem} onPress={() => onNavigate('transactions')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#FFF7ED' }]}>
              <Ionicons name="swap-horizontal-outline" size={20} color={Colors.orange} />
            </View>
            <Text style={styles.menuLabel}>Lịch sử giao dịch trực tuyến</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>
        </View>

        {/* Group 3: Cài đặt */}
        <Text style={styles.groupTitle}>BẢO MẬT & HỆ THỐNG</Text>
        <View style={[styles.menuCard, Shadows.sm]}>
          <TouchableOpacity style={styles.menuItem} onPress={() => onNavigate('change_password')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#F5F3FF' }]}>
              <Ionicons name="key-outline" size={20} color={Colors.purple} />
            </View>
            <Text style={styles.menuLabel}>Đổi mật khẩu tài khoản</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>

          <View style={styles.menuDivider} />

          <TouchableOpacity style={styles.menuItem} onPress={() => Alert.alert('Hỗ trợ', 'Hotline hỗ trợ sinh viên HUIT: (028) 3816 1673 - Email: ctsv@huit.edu.vn')} activeOpacity={0.7}>
            <View style={[styles.menuIcon, { backgroundColor: '#F1F5F9' }]}>
              <Ionicons name="help-circle-outline" size={20} color={Colors.textSecondary} />
            </View>
            <Text style={styles.menuLabel}>Trợ giúp & Hướng dẫn</Text>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>
        </View>

        {/* Logout Button */}
        <TouchableOpacity style={styles.logoutBtn} onPress={handleLogoutConfirm} activeOpacity={0.8}>
          <Ionicons name="log-out-outline" size={20} color={Colors.danger} style={{ marginRight: 8 }} />
          <Text style={styles.logoutText}>Đăng xuất khỏi tài khoản</Text>
        </TouchableOpacity>

        <Text style={styles.versionText}>LMS HUIT Mobile v1.0.0 (Expo SDK 58)</Text>
      </ScrollView>
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
    paddingBottom: 110,
  },
  headerCard: {
    backgroundColor: Colors.card,
    borderRadius: 22,
    padding: 20,
    alignItems: 'center',
    marginBottom: 20,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  avatar: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 3,
    borderColor: Colors.primaryLight,
    marginBottom: 12,
  },
  avatarText: {
    fontSize: 24,
    fontWeight: '800',
    color: '#FFFFFF',
  },
  nameText: {
    fontSize: 19,
    fontWeight: '800',
    color: Colors.text,
  },
  mssvText: {
    fontSize: 13,
    color: Colors.textMuted,
    marginTop: 2,
    fontWeight: '600',
  },
  classBadge: {
    backgroundColor: '#F1F5F9',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
    marginTop: 8,
  },
  classBadgeText: {
    fontSize: 12,
    color: Colors.textSecondary,
    fontWeight: '600',
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.successLight,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
    marginTop: 8,
  },
  statusDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: Colors.success,
    marginRight: 6,
  },
  statusText: {
    fontSize: 11,
    fontWeight: '700',
    color: Colors.success,
  },
  groupTitle: {
    fontSize: 12,
    fontWeight: '800',
    color: Colors.textMuted,
    marginBottom: 8,
    marginLeft: 4,
    letterSpacing: 0.5,
  },
  menuCard: {
    backgroundColor: Colors.card,
    borderRadius: 18,
    paddingHorizontal: 14,
    marginBottom: 18,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
  },
  menuIcon: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  menuLabel: {
    flex: 1,
    fontSize: 14,
    fontWeight: '600',
    color: Colors.text,
  },
  menuDivider: {
    height: 1,
    backgroundColor: Colors.borderLight,
  },
  logoutBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Colors.dangerLight,
    borderRadius: 16,
    paddingVertical: 14,
    borderWidth: 1,
    borderColor: 'rgba(239, 68, 68, 0.2)',
    marginTop: 8,
  },
  logoutText: {
    color: Colors.danger,
    fontSize: 14,
    fontWeight: '700',
  },
  versionText: {
    textAlign: 'center',
    fontSize: 11,
    color: Colors.textMuted,
    marginTop: 16,
  },
});



