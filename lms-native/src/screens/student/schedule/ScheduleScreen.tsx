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
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { EmptyState, AppBadge } from '../../../components/ui';
import { useSchedule } from '../../../hooks/useSchedule';
import { useRefresh } from '../../../hooks/useRefresh';
import { ScheduleItem } from '../../../types/student.types';

interface Props {
  onBack?: () => void;
}

export const ScheduleScreen: React.FC<Props> = ({ onBack }) => {
  const {
    filteredSchedule,
    selectedDayIndex,
    setSelectedDayIndex,
    days,
    refreshSchedule,
  } = useSchedule();

  const { refreshing, onRefresh } = useRefresh(refreshSchedule);

  const getTypeBadgeVariant = (type?: string): 'info' | 'warning' | 'primary' => {
    switch (type) {
      case 'online':
        return 'info';
      case 'practice':
        return 'warning';
      default:
        return 'primary';
    }
  };

  const getTypeLabel = (type?: string) => {
    switch (type) {
      case 'online':
        return 'Trực tuyến';
      case 'practice':
        return 'Thực hành';
      default:
        return 'Lý thuyết';
    }
  };

  const renderScheduleItem = useCallback(
    ({ item }: { item: ScheduleItem }) => {
      const badgeVariant = getTypeBadgeVariant(item.type);
      const badgeLabel = getTypeLabel(item.type);

      return (
        <View style={[styles.scheduleCard, Shadows.sm]}>
          <View style={styles.cardHeader}>
            <AppBadge label={badgeLabel} variant={badgeVariant} size="sm" />
            <Text style={styles.periodText}>{item.period}</Text>
          </View>

          <Text style={styles.subjectTitle}>{item.subjectName}</Text>
          <Text style={styles.classCodeText}>Lớp học phần: {item.classCode}</Text>

          <View style={styles.divider} />

          <View style={styles.metaRow}>
            <Ionicons name="location-outline" size={16} color={Colors.primary} />
            <Text style={styles.metaText}>{item.room}</Text>
          </View>

          <View style={styles.metaRow}>
            <Ionicons name="person-outline" size={16} color={Colors.primary} />
            <Text style={styles.metaText}>Giảng viên: {item.lecturer}</Text>
          </View>
        </View>
      );
    },
    []
  );

  const renderHeader = () => {
    const dayLabel = selectedDayIndex === 6 ? 'Chủ Nhật' : `Thứ ${selectedDayIndex + 2}`;
    return (
      <View style={styles.dateHeaderRow}>
        <Text style={styles.dateHeaderText}>
          Lịch học {dayLabel} ({days[selectedDayIndex]?.date})
        </Text>
        <Text style={styles.countBadge}>{filteredSchedule.length} lớp học</Text>
      </View>
    );
  };

  const renderEmpty = () => (
    <EmptyState
      icon="cafe-outline"
      title="Không có lịch học"
      description="Bạn không có tiết học nào trong ngày này. Hãy nghỉ ngơi hoặc tự học nhé!"
      style={styles.emptyWrap}
    />
  );

  const renderFooter = () => (
    <View style={styles.legendCard}>
      <Text style={styles.legendTitle}>Ghi chú loại lịch học:</Text>
      <View style={styles.legendRow}>
        <View style={[styles.legendDot, { backgroundColor: Colors.indigo }]} />
        <Text style={styles.legendText}>Lý thuyết</Text>
        <View style={[styles.legendDot, { backgroundColor: Colors.warning, marginLeft: 16 }]} />
        <Text style={styles.legendText}>Thực hành</Text>
        <View style={[styles.legendDot, { backgroundColor: Colors.info, marginLeft: 16 }]} />
        <Text style={styles.legendText}>Trực tuyến</Text>
      </View>
    </View>
  );

  return (
    <View style={styles.container}>
      <AppHeader title="Lịch học & Lịch thi" onBack={onBack} />

      {/* Week Selector Bar */}
      <View style={styles.weekBar}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.weekScroll}>
          {days.map((day, idx) => {
            const isSelected = selectedDayIndex === idx;
            return (
              <TouchableOpacity
                key={day.fullDate}
                style={[styles.dayCard, isSelected && styles.dayCardActive]}
                onPress={() => setSelectedDayIndex(idx)}
                activeOpacity={0.7}
              >
                <Text style={[styles.dayLabel, isSelected && styles.dayLabelActive]}>{day.label}</Text>
                <Text style={[styles.dayDate, isSelected && styles.dayDateActive]}>{day.date}</Text>
                {isSelected && <View style={styles.activeDot} />}
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>

      {/* Virtualized Schedule FlatList */}
      <FlatList
        data={filteredSchedule}
        keyExtractor={(item) => item.id}
        renderItem={renderScheduleItem}
        ListHeaderComponent={renderHeader}
        ListEmptyComponent={renderEmpty}
        ListFooterComponent={renderFooter}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
        initialNumToRender={5}
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
  weekBar: {
    backgroundColor: Colors.card,
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: Colors.borderLight,
  },
  weekScroll: {
    paddingHorizontal: 16,
    gap: 10,
  },
  dayCard: {
    width: 58,
    height: 70,
    borderRadius: 16,
    backgroundColor: Colors.bg,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  dayCardActive: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  dayLabel: {
    fontSize: 12,
    fontWeight: '700',
    color: Colors.textMuted,
    marginBottom: 4,
  },
  dayLabelActive: {
    color: '#FFFFFF',
  },
  dayDate: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.text,
  },
  dayDateActive: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  activeDot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: '#FFFFFF',
    marginTop: 4,
  },
  listContent: {
    padding: 16,
    paddingBottom: 40,
  },
  dateHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
  },
  dateHeaderText: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
  },
  countBadge: {
    fontSize: 12,
    fontWeight: '600',
    color: Colors.primary,
    backgroundColor: Colors.primaryLight,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 10,
  },
  scheduleCard: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  periodText: {
    fontSize: 13,
    fontWeight: '700',
    color: Colors.primary,
  },
  subjectTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 4,
  },
  classCodeText: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginBottom: 12,
  },
  divider: {
    height: 1,
    backgroundColor: Colors.borderLight,
    marginBottom: 12,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 6,
  },
  metaText: {
    fontSize: 13,
    color: Colors.textSecondary,
    fontWeight: '500',
  },
  emptyWrap: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    marginBottom: 14,
  },
  legendCard: {
    backgroundColor: Colors.card,
    borderRadius: 14,
    padding: 14,
    marginTop: 10,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  legendTitle: {
    fontSize: 12,
    fontWeight: '700',
    color: Colors.textSecondary,
    marginBottom: 8,
  },
  legendRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  legendDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 6,
  },
  legendText: {
    fontSize: 12,
    color: Colors.textSecondary,
    fontWeight: '500',
  },
});


