import React, { useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
} from 'react-native';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { AppBadge, EmptyState } from '../../../components/ui';
import { useAcademicResults } from '../../../hooks/useAcademicResults';
import { useRefresh } from '../../../hooks/useRefresh';
import { formatScore } from '../../../utils';
import { SubjectGrade } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const AcademicResultScreen: React.FC<Props> = ({ onBack }) => {
  const {
    overview,
    semesters,
    currentSemester,
    selectedSemesterIndex,
    setSelectedSemesterIndex,
    refreshResults,
  } = useAcademicResults();

  const { refreshing, onRefresh } = useRefresh(refreshResults);

  const getGradeBadgeVariant = (letter?: string): 'success' | 'info' | 'warning' | 'danger' => {
    if (letter?.startsWith('A')) return 'success';
    if (letter?.startsWith('B')) return 'info';
    if (letter?.startsWith('C')) return 'warning';
    return 'danger';
  };

  const renderSubjectItem = useCallback(
    ({ item: sub }: { item: SubjectGrade }) => {
      const badgeVariant = getGradeBadgeVariant(sub.letterGrade);

      return (
        <View style={[styles.subjectCard, Shadows.sm]}>
          <View style={styles.subHeader}>
            <View style={styles.subLeft}>
              <Text style={styles.subCode}>
                {sub.subjectCode} • {sub.credits} tín chỉ
              </Text>
              <Text style={styles.subName}>{sub.subjectName}</Text>
            </View>
            {sub.letterGrade ? (
              <AppBadge label={sub.letterGrade} variant={badgeVariant} size="md" />
            ) : null}
          </View>

          <View style={styles.scoreRow}>
            <View style={styles.scoreCol}>
              <Text style={styles.scoreLabel}>Quá trình / GK</Text>
              <Text style={styles.scoreVal}>{formatScore(sub.midterm)}</Text>
            </View>
            <View style={styles.scoreCol}>
              <Text style={styles.scoreLabel}>Cuối kỳ</Text>
              <Text style={styles.scoreVal}>{formatScore(sub.final)}</Text>
            </View>
            <View style={styles.scoreCol}>
              <Text style={styles.scoreLabel}>Tổng kết</Text>
              <Text style={[styles.scoreVal, { color: Colors.primary, fontWeight: '800' }]}>
                {formatScore(sub.average)}
              </Text>
            </View>
          </View>
        </View>
      );
    },
    []
  );

  const renderHeader = () => (
    <View>
      {/* Overview Banner */}
      {overview && (
        <View style={[styles.overviewCard, Shadows.md]}>
          <Text style={styles.overviewTitle}>Tổng kết quá trình đào tạo</Text>
          <View style={styles.gpaGrid}>
            <View style={styles.gpaCol}>
              <Text style={styles.gpaValue}>{overview.gpa4.toFixed(2)}</Text>
              <Text style={styles.gpaLabel}>GPA (Hệ 4)</Text>
            </View>
            <View style={styles.gpaDivider} />
            <View style={styles.gpaCol}>
              <Text style={styles.gpaValue}>{overview.gpa10.toFixed(2)}</Text>
              <Text style={styles.gpaLabel}>Điểm TB (Hệ 10)</Text>
            </View>
            <View style={styles.gpaDivider} />
            <View style={styles.gpaCol}>
              <Text style={styles.gpaValue}>{overview.creditsAccumulated}</Text>
              <Text style={styles.gpaLabel}>Tín chỉ tích lũy</Text>
            </View>
          </View>

          <View style={styles.subStatsRow}>
            <Text style={styles.subStatText}>• Năm đào tạo: Năm thứ {overview.yearLevel}</Text>
            <Text style={styles.subStatText}>• Tín chỉ nợ: {overview.creditsDebt}</Text>
            <Text style={styles.subStatText}>• Cần tích lũy: {overview.creditsRequired} TC</Text>
          </View>
        </View>
      )}

      {/* Semester Filter Tabs */}
      <Text style={styles.sectionTitle}>Bảng điểm theo học kỳ</Text>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.semScroll}>
        {semesters.map((sem, idx) => {
          const isSelected = selectedSemesterIndex === idx;
          return (
            <TouchableOpacity
              key={sem.semesterLabel}
              style={[styles.semTab, isSelected && styles.semTabActive]}
              onPress={() => setSelectedSemesterIndex(idx)}
              activeOpacity={0.7}
            >
              <Text style={[styles.semTabText, isSelected && styles.semTabTextActive]}>
                {sem.semesterLabel}
              </Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

      {/* Semester Stats Bar */}
      {currentSemester && (
        <View style={styles.semSummaryBar}>
          <View style={styles.semSummaryItem}>
            <Text style={styles.semSummaryLabel}>Điểm TB học kỳ</Text>
            <Text style={styles.semSummaryValue}>{currentSemester.gpa.toFixed(2)}</Text>
          </View>
          <View style={styles.semSummaryItem}>
            <Text style={styles.semSummaryLabel}>Điểm rèn luyện</Text>
            <Text style={[styles.semSummaryValue, { color: Colors.warning }]}>
              {currentSemester.conductScore}
            </Text>
          </View>
          <View style={styles.semSummaryItem}>
            <Text style={styles.semSummaryLabel}>Xếp loại</Text>
            <Text style={[styles.semSummaryValue, { color: Colors.success }]}>
              {currentSemester.classification}
            </Text>
          </View>
        </View>
      )}
    </View>
  );

  const renderEmpty = () => (
    <EmptyState
      icon="school-outline"
      title="Chưa có điểm môn học"
      description="Điểm các học phần thuộc học kỳ này đang được cập nhật."
    />
  );

  return (
    <View style={styles.container}>
      <AppHeader title="Kết quả học tập" onBack={onBack} />

      <FlatList
        data={currentSemester?.subjects || []}
        keyExtractor={(item) => item.subjectCode}
        renderItem={renderSubjectItem}
        ListHeaderComponent={renderHeader}
        ListEmptyComponent={renderEmpty}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        initialNumToRender={6}
        maxToRenderPerBatch={10}
        windowSize={5}
        removeClippedSubviews
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={[Colors.primary]} />
        }
      />
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
  overviewCard: {
    backgroundColor: Colors.primary,
    borderRadius: 20,
    padding: 20,
    marginBottom: 20,
  },
  overviewTitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.85)',
    fontWeight: '600',
    marginBottom: 16,
    textAlign: 'center',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  gpaGrid: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  gpaCol: {
    flex: 1,
    alignItems: 'center',
  },
  gpaValue: {
    fontSize: 26,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 2,
  },
  gpaLabel: {
    fontSize: 11,
    color: 'rgba(255,255,255,0.8)',
    fontWeight: '600',
  },
  gpaDivider: {
    width: 1,
    height: 36,
    backgroundColor: 'rgba(255,255,255,0.2)',
  },
  subStatsRow: {
    backgroundColor: 'rgba(0,0,0,0.15)',
    borderRadius: 12,
    paddingVertical: 10,
    paddingHorizontal: 12,
    flexDirection: 'row',
    justifyContent: 'space-around',
    flexWrap: 'wrap',
    gap: 6,
  },
  subStatText: {
    fontSize: 11,
    color: '#FFFFFF',
    fontWeight: '500',
  },
  sectionTitle: {
    fontSize: 15,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 12,
  },
  semScroll: {
    gap: 8,
    paddingBottom: 12,
  },
  semTab: {
    paddingHorizontal: 14,
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
    fontSize: 12,
    fontWeight: '700',
    color: Colors.textSecondary,
  },
  semTabTextActive: {
    color: '#FFFFFF',
  },
  semSummaryBar: {
    flexDirection: 'row',
    backgroundColor: Colors.card,
    borderRadius: 14,
    paddingVertical: 12,
    paddingHorizontal: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    justifyContent: 'space-between',
  },
  semSummaryItem: {
    alignItems: 'center',
  },
  semSummaryLabel: {
    fontSize: 11,
    color: Colors.textMuted,
    marginBottom: 4,
    fontWeight: '600',
  },
  semSummaryValue: {
    fontSize: 16,
    fontWeight: '800',
    color: Colors.primary,
  },
  subjectCard: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  subHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  subLeft: {
    flex: 1,
    paddingRight: 8,
  },
  subCode: {
    fontSize: 11,
    color: Colors.textSecondary,
    fontWeight: '600',
    marginBottom: 2,
  },
  subName: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
  },
  scoreRow: {
    flexDirection: 'row',
    backgroundColor: Colors.bg,
    borderRadius: 10,
    paddingVertical: 10,
    paddingHorizontal: 12,
    justifyContent: 'space-around',
  },
  scoreCol: {
    alignItems: 'center',
  },
  scoreLabel: {
    fontSize: 11,
    color: Colors.textMuted,
    marginBottom: 2,
    fontWeight: '500',
  },
  scoreVal: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
  },
});


