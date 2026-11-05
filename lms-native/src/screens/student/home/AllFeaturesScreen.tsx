import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';

interface Props {
  onBack: () => void;
  onNavigate: (screen: string) => void;
}

export const AllFeaturesScreen: React.FC<Props> = ({ onBack, onNavigate }) => {
  const groups = [
    {
      title: 'HỌC TẬP & KẾT QUẢ',
      items: [
        { label: 'Kết quả học tập (Xem điểm)', icon: 'school-outline', color: '#2563EB', bg: '#EFF6FF', action: 'grades' },
        { label: 'Lịch học theo tuần / ngày', icon: 'calendar-outline', color: '#EA580C', bg: '#FFF7ED', action: 'schedule' },
        { label: 'Chương trình đào tạo khung', icon: 'book-outline', color: '#DC2626', bg: '#FEF2F2', action: 'curriculum' },
        { label: 'Thành tích & Khen thưởng', icon: 'trophy-outline', color: '#D97706', bg: '#FFFBEB', action: 'achievement' },
        { label: 'Thống kê điểm danh', icon: 'checkbox-outline', color: '#7C3AED', bg: '#F5F3FF', action: 'attendance_stats' },
        { label: 'Đánh giá điểm rèn luyện', icon: 'ribbon-outline', color: '#CA8A04', bg: '#FEFCE8', action: 'conduct' },
      ],
    },
    {
      title: 'TÀI CHÍNH & HỌC PHÍ',
      items: [
        { label: 'Thanh toán học phí trực tuyến', icon: 'wallet-outline', color: '#059669', bg: '#ECFDF5', action: 'tuition' },
        { label: 'Tra cứu phiếu thu học phí', icon: 'receipt-outline', color: '#0891B2', bg: '#ECFEFF', action: 'receipt' },
        { label: 'Lịch sử giao dịch ngân hàng', icon: 'swap-horizontal-outline', color: '#F97316', bg: '#FFF7ED', action: 'transactions' },
      ],
    },
    {
      title: 'DỊCH VỤ SINH VIÊN & HỆ THỐNG',
      items: [
        { label: 'Hồ sơ thông tin sinh viên', icon: 'person-outline', color: '#2563EB', bg: '#EFF6FF', action: 'student_info' },
        { label: 'Trợ lý AI HUIT', icon: 'sparkles-outline', color: '#4F46E5', bg: '#EEF2FF', action: 'chatbot' },
        { label: 'Tin tức & Thông báo mới', icon: 'newspaper-outline', color: '#3B82F6', bg: '#EFF6FF', action: 'news' },
        { label: 'Khảo sát chất lượng đào tạo', icon: 'bar-chart-outline', color: '#0D9488', bg: '#F0FDFA', action: 'survey' },
        { label: 'Đổi mật khẩu tài khoản', icon: 'key-outline', color: '#8B5CF6', bg: '#F5F3FF', action: 'change_password' },
      ],
    },
  ];

  return (
    <View style={styles.container}>
      <AppHeader title="Tất cả chức năng" onBack={onBack} />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {groups.map((group) => (
          <View key={group.title} style={styles.groupContainer}>
            <Text style={styles.groupTitle}>{group.title}</Text>
            <View style={[styles.card, Shadows.sm]}>
              {group.items.map((item, idx) => (
                <TouchableOpacity
                  key={item.label}
                  style={[styles.itemRow, idx > 0 && styles.itemBorder]}
                  onPress={() => onNavigate(item.action)}
                  activeOpacity={0.7}
                >
                  <View style={[styles.iconWrap, { backgroundColor: item.bg }]}>
                    <Ionicons name={item.icon as any} size={20} color={item.color} />
                  </View>
                  <Text style={styles.itemLabel}>{item.label}</Text>
                  <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
                </TouchableOpacity>
              ))}
            </View>
          </View>
        ))}
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
    paddingBottom: 40,
  },
  groupContainer: {
    marginBottom: 20,
  },
  groupTitle: {
    fontSize: 12,
    fontWeight: '800',
    color: Colors.textMuted,
    marginBottom: 8,
    marginLeft: 4,
    letterSpacing: 0.5,
  },
  card: {
    backgroundColor: Colors.card,
    borderRadius: 18,
    paddingHorizontal: 14,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  itemRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
  },
  itemBorder: {
    borderTopWidth: 1,
    borderTopColor: Colors.borderLight,
  },
  iconWrap: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  itemLabel: {
    flex: 1,
    fontSize: 14,
    fontWeight: '600',
    color: Colors.text,
  },
});



