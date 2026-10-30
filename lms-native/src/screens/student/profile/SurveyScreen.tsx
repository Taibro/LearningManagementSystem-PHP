import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert, Linking } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { EmptyState } from '../../../components/ui/EmptyState';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { SurveyItem } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const SurveyScreen: React.FC<Props> = ({ onBack }) => {
  const [surveys, setSurveys] = useState<SurveyItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    studentApi
      .getSurveys()
      .then(setSurveys)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const handleStartSurvey = async (survey: SurveyItem) => {
    if (survey.isCompleted) {
      Alert.alert('Thông báo', 'Bạn đã hoàn thành phiếu khảo sát này trước đó.');
      return;
    }
    const url = 'https://portal.huit.edu.vn/khao-sat';
    const canOpen = await Linking.canOpenURL(url).catch(() => false);
    if (canOpen) {
      await Linking.openURL(url);
    } else {
      Alert.alert('Khảo sát trực tuyến', `Đang kết nối tới phiếu khảo sát: ${survey.title}`);
    }
  };

  return (
    <View style={styles.container}>
      <AppHeader title="Khảo sát sinh viên" onBack={onBack} />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.bannerBox}>
          <Text style={styles.bannerTitle}>Ý kiến phản hồi của sinh viên</Text>
          <Text style={styles.bannerSub}>Đóng góp ý kiến của bạn giúp Nhà trường không ngừng nâng cao chất lượng đào tạo và dịch vụ.</Text>
        </View>

        {!loading && surveys.length === 0 ? (
          <EmptyState
            icon="clipboard-outline"
            title="Chưa có khảo sát mới"
            description="Hiện tại bạn không có phiếu khảo sát nào cần thực hiện."
          />
        ) : (
          surveys.map((item) => (
            <View key={item.id} style={[styles.card, Shadows.sm]}>
              <View style={styles.cardHeader}>
                <View style={[styles.statusBadge, item.isCompleted ? styles.statusDone : styles.statusPending]}>
                  <Ionicons
                    name={item.isCompleted ? 'checkmark-circle' : 'time-outline'}
                    size={14}
                    color={item.isCompleted ? Colors.success : Colors.warning}
                    style={{ marginRight: 4 }}
                  />
                  <Text style={[styles.statusText, item.isCompleted ? { color: Colors.success } : { color: Colors.warning }]}>
                    {item.isCompleted ? 'Đã hoàn thành' : 'Chưa thực hiện'}
                  </Text>
                </View>

                <Text style={styles.deadlineText}>Hạn: {item.deadline}</Text>
              </View>

              <Text style={styles.title}>{item.title}</Text>

              <View style={styles.divider} />

              <TouchableOpacity
                style={[styles.actionBtn, item.isCompleted ? styles.btnDisabled : styles.btnActive]}
                onPress={() => handleStartSurvey(item)}
                activeOpacity={0.8}
              >
                <Text style={[styles.btnText, item.isCompleted ? styles.btnTextDisabled : styles.btnTextActive]}>
                  {item.isCompleted ? 'Xem lại câu trả lời' : 'Bắt đầu làm khảo sát'}
                </Text>
              </TouchableOpacity>
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
  bannerBox: {
    backgroundColor: Colors.primary,
    borderRadius: 18,
    padding: 16,
    marginBottom: 16,
  },
  bannerTitle: {
    fontSize: 15,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  bannerSub: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.85)',
    lineHeight: 16,
  },
  card: {
    backgroundColor: Colors.card,
    borderRadius: 18,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
  },
  statusDone: {
    backgroundColor: Colors.successLight,
  },
  statusPending: {
    backgroundColor: Colors.warningLight,
  },
  statusText: {
    fontSize: 11,
    fontWeight: '700',
  },
  deadlineText: {
    fontSize: 11,
    color: Colors.textMuted,
  },
  title: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
    lineHeight: 20,
  },
  divider: {
    height: 1,
    backgroundColor: Colors.borderLight,
    marginVertical: 12,
  },
  actionBtn: {
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    paddingVertical: 10,
  },
  btnActive: {
    backgroundColor: Colors.primary,
  },
  btnDisabled: {
    backgroundColor: Colors.borderLight,
  },
  btnText: {
    fontSize: 13,
    fontWeight: '700',
  },
  btnTextActive: {
    color: '#FFFFFF',
  },
  btnTextDisabled: {
    color: Colors.textSecondary,
  },
});



