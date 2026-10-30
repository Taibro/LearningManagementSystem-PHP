import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet } from 'react-native';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { ConductScore } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const ConductScreen: React.FC<Props> = ({ onBack }) => {
  const [conductList, setConductList] = useState<ConductScore[]>([]);
  const [selectedIndex, setSelectedIndex] = useState(0);

  useEffect(() => {
    studentApi.getConductScores().then(setConductList).catch(() => {});
  }, []);

  const currentConduct = conductList[selectedIndex];

  return (
    <View style={styles.container}>
      <AppHeader title="Điểm rèn luyện" onBack={onBack} />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Semester Selector */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.semScroll}>
          {conductList.map((c, idx) => {
            const isSelected = selectedIndex === idx;
            return (
              <TouchableOpacity
                key={c.semester}
                style={[styles.semTab, isSelected && styles.semTabActive]}
                onPress={() => setSelectedIndex(idx)}
                activeOpacity={0.7}
              >
                <Text style={[styles.semTabText, isSelected && styles.semTabTextActive]}>{c.semester}</Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>

        {currentConduct && (
          <>
            {/* Score Banner */}
            <View style={[styles.scoreBanner, Shadows.md]}>
              <View style={styles.scoreCircle}>
                <Text style={styles.scoreNum}>{currentConduct.totalScore}</Text>
                <Text style={styles.scoreMax}>/ 100 đ</Text>
              </View>
              <View style={styles.scoreInfo}>
                <Text style={styles.scoreSem}>{currentConduct.semester}</Text>
                <View style={styles.classBadge}>
                  <Text style={styles.classBadgeText}>Xếp loại: {currentConduct.classification}</Text>
                </View>
                <Text style={styles.statusNote}>Đã hoàn tất đánh giá và xét duyệt cấp Khoa</Text>
              </View>
            </View>

            {/* Criteria Breakdown */}
            <Text style={styles.sectionTitle}>Chi tiết 5 tiêu chí đánh giá</Text>
            {currentConduct.details.map((item, idx) => {
              const percent =
                item.maxScore > 0
                  ? Math.min(100, Math.max(0, (item.achievedScore / item.maxScore) * 100))
                  : 0;
              return (
                <View key={item.title} style={[styles.criteriaCard, Shadows.sm]}>
                  <View style={styles.critHeader}>
                    <Text style={styles.critIndex}>Tiêu chí {idx + 1}</Text>
                    <Text style={styles.critScore}>
                      <Text style={{ color: Colors.primary, fontWeight: '800' }}>{item.achievedScore}</Text> / {item.maxScore} điểm
                    </Text>
                  </View>
                  <Text style={styles.critTitle}>{item.title}</Text>

                  {/* Progress */}
                  <View style={styles.progressBarBg}>
                    <View style={[styles.progressBarFill, { width: `${percent}%` }]} />
                  </View>
                </View>
              );
            })}
          </>
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
  semScroll: {
    gap: 10,
    marginBottom: 16,
  },
  semTab: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: Colors.card,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  semTabActive: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  semTabText: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.textSecondary,
  },
  semTabTextActive: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  scoreBanner: {
    backgroundColor: Colors.card,
    borderRadius: 20,
    padding: 18,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  scoreCircle: {
    width: 84,
    height: 84,
    borderRadius: 42,
    backgroundColor: Colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  scoreNum: {
    fontSize: 28,
    fontWeight: '800',
    color: Colors.primary,
  },
  scoreMax: {
    fontSize: 10,
    color: Colors.primary,
    fontWeight: '600',
  },
  scoreInfo: {
    flex: 1,
  },
  scoreSem: {
    fontSize: 13,
    fontWeight: '700',
    color: Colors.text,
  },
  classBadge: {
    alignSelf: 'flex-start',
    backgroundColor: Colors.successLight,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
    marginVertical: 4,
  },
  classBadgeText: {
    fontSize: 12,
    fontWeight: '800',
    color: Colors.success,
  },
  statusNote: {
    fontSize: 11,
    color: Colors.textMuted,
  },
  sectionTitle: {
    fontSize: 15,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 12,
  },
  criteriaCard: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 14,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  critHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  critIndex: {
    fontSize: 11,
    fontWeight: '700',
    color: Colors.textMuted,
    textTransform: 'uppercase',
  },
  critScore: {
    fontSize: 13,
    color: Colors.textSecondary,
    fontWeight: '600',
  },
  critTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
    marginBottom: 8,
  },
  progressBarBg: {
    height: 6,
    backgroundColor: Colors.borderLight,
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: Colors.primary,
    borderRadius: 3,
  },
});



