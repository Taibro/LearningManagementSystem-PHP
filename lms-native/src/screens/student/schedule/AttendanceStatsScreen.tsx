import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { AttendanceCourseStat } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const AttendanceStatsScreen: React.FC<Props> = ({ onBack }) => {
  const [courses, setCourses] = useState<AttendanceCourseStat[]>([]);

  useEffect(() => {
    studentApi.getAttendanceCourses().then(setCourses).catch(() => {});
  }, []);

  const totalSessions = courses.reduce((acc, c) => acc + c.total, 0);
  const totalAttended = courses.reduce((acc, c) => acc + c.attended, 0);
  const totalExcused = courses.reduce((acc, c) => acc + c.excused, 0);
  const totalAbsent = courses.reduce((acc, c) => acc + c.absent, 0);
  const overallRate = totalSessions > 0 ? ((totalAttended / totalSessions) * 100).toFixed(1) : '100';

  return (
    <View style={styles.container}>
      <AppHeader title="Thống kê chuyên cần" onBack={onBack} />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Banner Tổng kết */}
        <View style={[styles.banner, Shadows.md]}>
          <Text style={styles.bannerLabel}>Tỷ lệ chuyên cần trung bình HK2</Text>
          <Text style={styles.bannerVal}>{overallRate}%</Text>
          <Text style={styles.bannerSub}>Đủ điều kiện dự thi 100% các học phần đã đăng ký</Text>
        </View>

        {/* Breakdown bar */}
        <View style={styles.summaryBox}>
          <View style={styles.summaryItem}>
            <Text style={styles.summaryNum}>{totalSessions}</Text>
            <Text style={styles.summaryText}>Tổng số buổi</Text>
          </View>
          <View style={styles.summaryItem}>
            <Text style={[styles.summaryNum, { color: Colors.success }]}>{totalAttended}</Text>
            <Text style={styles.summaryText}>Có mặt</Text>
          </View>
          <View style={styles.summaryItem}>
            <Text style={[styles.summaryNum, { color: Colors.warning }]}>{totalExcused}</Text>
            <Text style={styles.summaryText}>Có phép</Text>
          </View>
          <View style={styles.summaryItem}>
            <Text style={[styles.summaryNum, { color: Colors.danger }]}>{totalAbsent}</Text>
            <Text style={styles.summaryText}>Vắng</Text>
          </View>
        </View>

        <Text style={styles.sectionTitle}>Tỷ lệ chi tiết theo từng môn học ({courses.length})</Text>
        {courses.map((s) => (
          <View key={s.code} style={[styles.card, Shadows.sm]}>
            <View style={styles.cardTop}>
              <View style={styles.cardTopLeft}>
                <Text style={styles.subCode}>{s.code}</Text>
                <Text style={styles.subjectName}>{s.name}</Text>
              </View>
              <Text style={[styles.percentText, s.percent >= 90 ? styles.colorGreen : styles.colorYellow]}>
                {s.percent}%
              </Text>
            </View>

            <View style={styles.barBg}>
              <View style={[styles.barFill, { width: `${s.percent}%`, backgroundColor: s.percent >= 90 ? Colors.success : Colors.warning }]} />
            </View>

            <View style={styles.cardBottom}>
              <Text style={styles.botText}>Tổng: {s.total} buổi</Text>
              <Text style={styles.botText}>• Có mặt: {s.attended}</Text>
              {s.excused > 0 && <Text style={[styles.botText, { color: Colors.warning }]}>• Phép: {s.excused}</Text>}
              <Text style={[styles.botText, s.absent > 0 && { color: Colors.danger, fontWeight: '700' }]}>
                • Vắng: {s.absent}
              </Text>
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
  banner: {
    backgroundColor: Colors.primary,
    borderRadius: 20,
    padding: 20,
    alignItems: 'center',
    marginBottom: 14,
  },
  bannerLabel: {
    fontSize: 13,
    color: 'rgba(255, 255, 255, 0.85)',
  },
  bannerVal: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFFFFF',
    marginVertical: 4,
  },
  bannerSub: {
    fontSize: 11,
    color: 'rgba(255, 255, 255, 0.8)',
    textAlign: 'center',
  },
  summaryBox: {
    flexDirection: 'row',
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 14,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    justifyContent: 'space-around',
  },
  summaryItem: {
    alignItems: 'center',
  },
  summaryNum: {
    fontSize: 18,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 2,
  },
  summaryText: {
    fontSize: 11,
    color: Colors.textMuted,
    fontWeight: '600',
  },
  sectionTitle: {
    fontSize: 15,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 12,
  },
  card: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 14,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  cardTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  cardTopLeft: {
    flex: 1,
    marginRight: 8,
  },
  subCode: {
    fontSize: 10,
    fontWeight: '700',
    color: Colors.primary,
    textTransform: 'uppercase',
  },
  subjectName: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
    marginTop: 2,
  },
  percentText: {
    fontSize: 14,
    fontWeight: '800',
  },
  colorGreen: {
    color: Colors.success,
  },
  colorYellow: {
    color: Colors.warning,
  },
  barBg: {
    height: 6,
    backgroundColor: Colors.borderLight,
    borderRadius: 3,
    overflow: 'hidden',
    marginBottom: 8,
  },
  barFill: {
    height: '100%',
    borderRadius: 3,
  },
  cardBottom: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  botText: {
    fontSize: 12,
    color: Colors.textMuted,
  },
});


