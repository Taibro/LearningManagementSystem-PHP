import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/colors';
import { Shadows } from '../../constants/theme';

export interface FeatureItem {
  id: string;
  label: string;
  icon: keyof typeof Ionicons.glyphMap;
  color: string;
  bgColor: string;
  action: string;
}

interface Props {
  onFeaturePress: (action: string) => void;
}

export const FunctionSection: React.FC<Props> = ({ onFeaturePress }) => {
  const features: FeatureItem[] = [
    { id: '1', label: 'Xem điểm', icon: 'school-outline', color: '#2563EB', bgColor: '#EFF6FF', action: 'grades' },
    { id: '2', label: 'Lịch học', icon: 'calendar-outline', color: '#EA580C', bgColor: '#FFF7ED', action: 'schedule' },
    { id: '3', label: 'Thành tích', icon: 'trophy-outline', color: '#D97706', bgColor: '#FFFBEB', action: 'achievement' },
    { id: '4', label: 'CT đào tạo', icon: 'book-outline', color: '#DC2626', bgColor: '#FEF2F2', action: 'curriculum' },
    { id: '5', label: 'Học phí', icon: 'wallet-outline', color: '#059669', bgColor: '#ECFDF5', action: 'tuition' },
    { id: '6', label: 'Phiếu thu', icon: 'receipt-outline', color: '#0891B2', bgColor: '#ECFEFF', action: 'receipt' },
    { id: '7', label: 'TK điểm danh', icon: 'checkbox-outline', color: '#7C3AED', bgColor: '#F5F3FF', action: 'attendance_stats' },
    { id: '8', label: 'Rèn luyện', icon: 'ribbon-outline', color: '#CA8A04', bgColor: '#FEFCE8', action: 'conduct' },
    { id: '9', label: 'Tin tức', icon: 'newspaper-outline', color: '#3B82F6', bgColor: '#EFF6FF', action: 'news' },
    { id: '10', label: 'Khảo sát', icon: 'bar-chart-outline', color: '#0D9488', bgColor: '#F0FDFA', action: 'survey' },
    { id: '11', label: 'Trò chuyện', icon: 'chatbubbles-outline', color: '#4F46E5', bgColor: '#EEF2FF', action: 'chatbot' },
    { id: '12', label: 'Tất cả', icon: 'apps-outline', color: '#475569', bgColor: '#F1F5F9', action: 'all_features' },
  ];

  return (
    <View style={styles.container}>
      <View style={styles.headerRow}>
        <Text style={styles.sectionTitle}>Tiện ích sinh viên</Text>
        <TouchableOpacity onPress={() => onFeaturePress('all_features')}>
          <Text style={styles.seeAllText}>Xem tất cả</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.grid}>
        {features.map((item) => (
          <TouchableOpacity
            key={item.id}
            style={styles.gridItem}
            onPress={() => onFeaturePress(item.action)}
            activeOpacity={0.7}
          >
            <View style={[styles.iconWrap, { backgroundColor: item.bgColor }, Shadows.sm]}>
              <Ionicons name={item.icon} size={24} color={item.color} />
            </View>
            <Text style={styles.itemLabel} numberOfLines={2}>
              {item.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: 22,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
    paddingHorizontal: 4,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: Colors.text,
  },
  seeAllText: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.primary,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -6,
  },
  gridItem: {
    width: '25%',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 4,
  },
  iconWrap: {
    width: 52,
    height: 52,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 6,
  },
  itemLabel: {
    fontSize: 11,
    fontWeight: '600',
    color: Colors.textSecondary,
    textAlign: 'center',
    lineHeight: 14,
  },
});

