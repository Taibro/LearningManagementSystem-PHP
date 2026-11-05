import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { EmptyState } from '../../../components/ui/EmptyState';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { AchievementItem } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const AchievementScreen: React.FC<Props> = ({ onBack }) => {
  const [achievements, setAchievements] = useState<AchievementItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    studentApi
      .getAchievements()
      .then(setAchievements)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  return (
    <View style={styles.container}>
      <AppHeader title="Thành tích & Khen thưởng" onBack={onBack} />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.banner}>
          <Ionicons name="medal-outline" size={36} color="#FFFFFF" />
          <Text style={styles.bannerTitle}>Bảng vàng danh dự</Text>
          <Text style={styles.bannerSub}>Chúc mừng những thành tích học tập và rèn luyện xuất sắc của bạn tại HUIT!</Text>
        </View>

        <Text style={styles.sectionTitle}>Danh sách khen thưởng & Học bổng ({achievements.length})</Text>

        {!loading && achievements.length === 0 ? (
          <EmptyState
            icon="trophy-outline"
            title="Chưa có thành tích"
            description="Tiếp tục phấn đấu trong học kỳ tới để ghi tên mình vào bảng vàng khen thưởng nhé!"
          />
        ) : (
          achievements.map((item) => (
            <View key={item.id} style={[styles.card, Shadows.sm]}>
              <View style={[styles.iconWrap, { backgroundColor: item.bg }]}>
                <Ionicons name={item.icon as any} size={24} color={item.color} />
              </View>

              <View style={styles.contentCol}>
                <Text style={styles.title}>{item.title}</Text>
                <Text style={styles.sem}>{item.semester}</Text>
                <Text style={styles.decision}>{item.decision}</Text>
                <View style={styles.rewardTag}>
                  <Text style={styles.rewardText}>Phần thưởng: {item.amount}</Text>
                </View>
              </View>
            </View>
          ))
        )}
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
  banner: {
    backgroundColor: '#D97706',
    borderRadius: 20,
    padding: 20,
    alignItems: 'center',
    marginBottom: 20,
  },
  bannerTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFFFFF',
    marginTop: 6,
    marginBottom: 4,
  },
  bannerSub: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.9)',
    textAlign: 'center',
    lineHeight: 16,
  },
  sectionTitle: {
    fontSize: 15,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 12,
  },
  card: {
    flexDirection: 'row',
    backgroundColor: Colors.card,
    borderRadius: 18,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  iconWrap: {
    width: 48,
    height: 48,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 14,
  },
  contentCol: {
    flex: 1,
  },
  title: {
    fontSize: 15,
    fontWeight: '700',
    color: Colors.text,
    lineHeight: 20,
  },
  sem: {
    fontSize: 12,
    color: Colors.primary,
    fontWeight: '600',
    marginTop: 3,
  },
  decision: {
    fontSize: 11,
    color: Colors.textMuted,
    marginTop: 2,
  },
  rewardTag: {
    alignSelf: 'flex-start',
    backgroundColor: '#FEFCE8',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
    marginTop: 8,
    borderWidth: 1,
    borderColor: '#FEF08A',
  },
  rewardText: {
    fontSize: 11,
    fontWeight: '700',
    color: '#854D0E',
  },
});


