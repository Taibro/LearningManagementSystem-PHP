import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { useAuth } from '../../../hooks/useAuth';
import { CurriculumSemester } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const CurriculumScreen: React.FC<Props> = ({ onBack }) => {
  const { user } = useAuth();
  const [semesters, setSemesters] = useState<CurriculumSemester[]>([]);
  const [expandedSemester, setExpandedSemester] = useState<number>(1);

  useEffect(() => {
    studentApi.getCurriculum().then(setSemesters).catch(() => {});
  }, []);

  const majorName = user?.majorName || 'Công nghệ thông tin';
  const enrollmentYear = user?.enrollmentYear || '2023 - 2027';
  const totalCredits = semesters.reduce((sum, s) => sum + (s.totalCredits || 0), 0) || 151;

  const toggleSemester = (sem: number) => {
    setExpandedSemester(expandedSemester === sem ? 0 : sem);
  };

  return (
    <View style={styles.container}>
      <AppHeader title="Chương trình đào tạo khung" onBack={onBack} />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.bannerCard}>
          <Text style={styles.majorTitle}>Ngành: {majorName}</Text>
          <Text style={styles.majorSub}>Khóa tuyển sinh: {enrollmentYear} • Tổng số tín chỉ: {totalCredits} TC</Text>
        </View>

        {semesters.map((item) => {
          const isExpanded = expandedSemester === item.semester;
          return (
            <View key={item.semester} style={[styles.semCard, Shadows.sm]}>
              <TouchableOpacity
                style={styles.semHeader}
                onPress={() => toggleSemester(item.semester)}
                activeOpacity={0.7}
              >
                <View style={styles.semHeaderLeft}>
                  <View style={styles.semBadge}>
                    <Text style={styles.semBadgeText}>Học kỳ {item.semester}</Text>
                  </View>
                  <Text style={styles.semCreditsText}>{item.totalCredits} tín chỉ ({item.subjects.length} môn)</Text>
                </View>
                <Ionicons
                  name={isExpanded ? 'chevron-up' : 'chevron-down'}
                  size={20}
                  color={Colors.textSecondary}
                />
              </TouchableOpacity>

              {isExpanded && (
                <View style={styles.subjectList}>
                  {item.subjects.map((sub, idx) => (
                    <View key={sub.code} style={[styles.subItem, idx > 0 && styles.subItemBorder]}>
                      <View style={styles.subLeft}>
                        <View style={styles.subCodeRow}>
                          <Text style={styles.subCode}>{sub.code}</Text>
                          <View style={[styles.typeBadge, sub.type === 'Bắt buộc' ? styles.typeRequired : styles.typeElective]}>
                            <Text style={styles.typeText}>{sub.type}</Text>
                          </View>
                        </View>
                        <Text style={styles.subName}>{sub.name}</Text>
                      </View>

                      <View style={styles.subRight}>
                        <Text style={styles.creditsNum}>{sub.credits} TC</Text>
                        <View style={[styles.statusTag, sub.isCompleted ? styles.statusDone : styles.statusPending]}>
                          <Ionicons
                            name={sub.isCompleted ? 'checkmark-circle' : 'time-outline'}
                            size={12}
                            color={sub.isCompleted ? Colors.success : Colors.textMuted}
                            style={{ marginRight: 3 }}
                          />
                          <Text style={[styles.statusTagText, sub.isCompleted ? { color: Colors.success } : { color: Colors.textMuted }]}>
                            {sub.isCompleted ? 'Đã đạt' : 'Chưa học'}
                          </Text>
                        </View>
                      </View>
                    </View>
                  ))}
                </View>
              )}
            </View>
          );
        })}
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
  bannerCard: {
    backgroundColor: Colors.primary,
    borderRadius: 18,
    padding: 16,
    marginBottom: 16,
  },
  majorTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  majorSub: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.85)',
  },
  semCard: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    overflow: 'hidden',
  },
  semHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 14,
  },
  semHeaderLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  semBadge: {
    backgroundColor: Colors.primaryLight,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
  },
  semBadgeText: {
    fontSize: 13,
    fontWeight: '800',
    color: Colors.primary,
  },
  semCreditsText: {
    fontSize: 13,
    color: Colors.textSecondary,
    fontWeight: '500',
  },
  subjectList: {
    backgroundColor: '#F8FAFC',
    borderTopWidth: 1,
    borderTopColor: Colors.borderLight,
    paddingHorizontal: 14,
    paddingVertical: 6,
  },
  subItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
  },
  subItemBorder: {
    borderTopWidth: 1,
    borderTopColor: Colors.borderLight,
  },
  subLeft: {
    flex: 1,
    marginRight: 10,
  },
  subCodeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginBottom: 2,
  },
  subCode: {
    fontSize: 11,
    color: Colors.textMuted,
    fontWeight: '700',
  },
  typeBadge: {
    paddingHorizontal: 6,
    paddingVertical: 1,
    borderRadius: 6,
  },
  typeRequired: {
    backgroundColor: Colors.dangerLight,
  },
  typeElective: {
    backgroundColor: Colors.infoLight,
  },
  typeText: {
    fontSize: 9,
    fontWeight: '700',
    color: Colors.textSecondary,
  },
  subName: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.text,
  },
  subRight: {
    alignItems: 'flex-end',
  },
  creditsNum: {
    fontSize: 13,
    fontWeight: '700',
    color: Colors.primary,
    marginBottom: 4,
  },
  statusTag: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDone: {},
  statusPending: {},
  statusTagText: {
    fontSize: 10,
    fontWeight: '600',
  },
});



