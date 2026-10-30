import { useState, useEffect, useCallback, useMemo } from 'react';
import { studentApi } from '../api/studentApi';
import { ScheduleItem } from '../types/student.types';

export interface DayOption {
  label: string;
  date: string;
  fullDate: string;
}

export const getWeekDays = (baseDate?: Date): DayOption[] => {
  const current = baseDate ? new Date(baseDate) : new Date();
  const day = current.getDay(); // 0 is Sunday, 1 is Monday
  const diffToMonday = day === 0 ? -6 : 1 - day;
  const monday = new Date(current);
  monday.setDate(current.getDate() + diffToMonday);

  const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  return labels.map((label, index) => {
    const d = new Date(monday);
    d.setDate(monday.getDate() + index);
    const dayStr = String(d.getDate()).padStart(2, '0');
    const monthStr = String(d.getMonth() + 1).padStart(2, '0');
    const yearStr = d.getFullYear();
    return {
      label,
      date: `${dayStr}/${monthStr}`,
      fullDate: `${yearStr}-${monthStr}-${dayStr}`,
    };
  });
};

export const DEFAULT_WEEK_DAYS: DayOption[] = getWeekDays();

export const useSchedule = () => {
  const [scheduleList, setScheduleList] = useState<ScheduleItem[]>([]);
  const [selectedDayIndex, setSelectedDayIndex] = useState(0);
  const [loading, setLoading] = useState(true);

  const fetchSchedule = useCallback(async () => {
    setLoading(true);
    try {
      const data = await studentApi.getSchedule();
      setScheduleList(data);
    } catch (err) {
      console.warn('[useSchedule] Failed to fetch schedule:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchSchedule();
  }, [fetchSchedule]);

  const days = useMemo(() => {
    if (scheduleList.length > 0 && scheduleList[0].date) {
      const firstDate = new Date(scheduleList[0].date);
      if (!isNaN(firstDate.getTime())) {
        return getWeekDays(firstDate);
      }
    }
    return getWeekDays();
  }, [scheduleList]);

  const selectedDate = days[selectedDayIndex]?.fullDate || '';

  const filteredSchedule = useMemo(() => {
    return scheduleList.filter((item) => item.date === selectedDate);
  }, [scheduleList, selectedDate]);

  return {
    scheduleList,
    filteredSchedule,
    selectedDayIndex,
    setSelectedDayIndex,
    days,
    selectedDate,
    loading,
    refreshSchedule: fetchSchedule,
  };
};

