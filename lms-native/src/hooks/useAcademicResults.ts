import { useState, useEffect, useCallback } from 'react';
import { studentApi } from '../api/studentApi';
import { StudentOverview, SemesterSummary } from '../types/student.types';

export const useAcademicResults = () => {
  const [overview, setOverview] = useState<StudentOverview | null>(null);
  const [semesters, setSemesters] = useState<SemesterSummary[]>([]);
  const [selectedSemesterIndex, setSelectedSemesterIndex] = useState(0);
  const [loading, setLoading] = useState(true);

  const fetchResults = useCallback(async () => {
    setLoading(true);
    try {
      const [overviewData, gradesData] = await Promise.all([
        studentApi.getOverview(),
        studentApi.getGrades(),
      ]);
      setOverview(overviewData);
      setSemesters(gradesData);
    } catch (err) {
      console.warn('[useAcademicResults] Failed to fetch grades:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchResults();
  }, [fetchResults]);

  const currentSemester = semesters[selectedSemesterIndex] || null;

  return {
    overview,
    semesters,
    currentSemester,
    selectedSemesterIndex,
    setSelectedSemesterIndex,
    loading,
    refreshResults: fetchResults,
  };
};

