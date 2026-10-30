import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/colors';
import { Shadows } from '../../constants/theme';
import { ScheduleItem } from '../../types/student.types';

interface Props {
  nextClass: ScheduleItem | null;
  onAttendancePress: () => void;
}

export const CurrentClassCard: React.FC<Props> = ({ nextClass, onAttendancePress }) => {
  if (!nextClass) {
    return (
      <View style={[styles.card, Shadows.sm, styles.noClassCard]}>
        <View style={styles.noClassHeader}>
          <Ionicons name="sunny-outline" size={24} color={Colors.warning} />
          <Text style={styles.noClassTitle}>Hôm nay bạn không có lịch học</Text>
        </View>
        <Text style={styles.noClassSub}>
          Tận hưởng thời gian nghỉ ngơi hoặc xem lại bài vở chuẩn bị cho tiết học tới nhé!
        </Text>
      </View>
    );
  }

  return (
    <View style={[styles.card, Shadows.md]}>
      {/* Top Banner Tag */}
      <View style={styles.topRow}>
        <View style={styles.statusBadge}>
          <View style={styles.pulseDot} />
          <Text style={styles.statusText}>LỚP HỌC HÔM NAY</Text>
        </View>
        <View style={styles.typeBadge}>
          <Text style={styles.typeText}>
            {nextClass.type === 'theory'
              ? 'Lý thuyết'
              : nextClass.type === 'online'
              ? 'Trực tuyến'
              : 'Thực hành'}
          </Text>
        </View>
      </View>

      {/* Subject Title */}
      <Text style={styles.subjectName}>{nextClass.subjectName}</Text>
      <Text style={styles.classCode}>Mã lớp: {nextClass.classCode}</Text>

      {/* Info details */}
      <View style={styles.divider} />

      <View style={styles.infoRow}>
        <Ionicons name="time-outline" size={16} color={Colors.primary} />
        <Text style={styles.infoText}>{nextClass.period}</Text>
      </View>

      <View style={styles.infoRow}>
        <Ionicons name="location-outline" size={16} color={Colors.primary} />
        <Text style={styles.infoText} numberOfLines={1}>{nextClass.room}</Text>
      </View>

      <View style={styles.infoRow}>
        <Ionicons name="person-outline" size={16} color={Colors.primary} />
        <Text style={styles.infoText}>Giảng viên: {nextClass.lecturer}</Text>
      </View>

      {/* Action button */}
      <TouchableOpacity style={styles.checkinBtn} onPress={onAttendancePress} activeOpacity={0.8}>
        <Ionicons name="qr-code-outline" size={18} color="#FFFFFF" style={{ marginRight: 8 }} />
        <Text style={styles.checkinText}>Điểm danh ngay</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.card,
    borderRadius: 20,
    padding: 18,
    marginBottom: 20,
  },
  noClassCard: {
    paddingVertical: 18,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  noClassHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 6,
  },
  noClassTitle: {
    fontSize: 15,
    fontWeight: '700',
    color: Colors.text,
  },
  noClassSub: {
    fontSize: 13,
    color: Colors.textMuted,
    lineHeight: 18,
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.primaryLight,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  pulseDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: Colors.primary,
    marginRight: 6,
  },
  statusText: {
    fontSize: 11,
    fontWeight: '800',
    color: Colors.primary,
    letterSpacing: 0.5,
  },
  typeBadge: {
    backgroundColor: Colors.borderLight,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  typeText: {
    fontSize: 11,
    fontWeight: '600',
    color: Colors.textSecondary,
  },
  subjectName: {
    fontSize: 17,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 4,
  },
  classCode: {
    fontSize: 12,
    color: Colors.textMuted,
    fontWeight: '500',
  },
  divider: {
    height: 1,
    backgroundColor: Colors.borderLight,
    marginVertical: 12,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 8,
  },
  infoText: {
    fontSize: 13,
    color: Colors.textSecondary,
    fontWeight: '500',
  },
  checkinBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Colors.primary,
    paddingVertical: 12,
    borderRadius: 12,
    marginTop: 6,
  },
  checkinText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
  },
});
