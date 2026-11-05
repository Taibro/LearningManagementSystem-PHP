import { ENV } from '../config/env';
import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants';
import {
  mockStudentProfile,
  mockStudentOverview,
  mockNextClass,
  mockWeeklySchedule,
  mockSemesterSummaries,
  mockConductScores,
  mockTransactions,
  mockReceipts,
  mockNewsList,
  mockSurveys,
  mockCurriculumSemesters,
  mockAttendanceCourses,
  mockAchievements,
} from '../data/mockData';
import {
  StudentProfile,
  StudentOverview,
  ScheduleItem,
  SemesterSummary,
  ConductScore,
  Transaction,
  Receipt,
  NewsItem,
  SurveyItem,
  CurriculumSemester,
  AttendanceCourseStat,
  AchievementItem,
} from '../types/student.types';

export const studentApi = {
  login: async (studentCode: string, password: string): Promise<{ token: string; profile: StudentProfile }> => {
    if (ENV.USE_MOCK_DATA) {
      await new Promise((resolve) => setTimeout(resolve, 350));
      if (password === 'wrong') {
        throw new Error('Mật khẩu không chính xác.');
      }
      return {
        token: `mock_jwt_token_${studentCode}_${Date.now()}`,
        profile: { ...mockStudentProfile, studentCode },
      };
    }
    return await apiClient.post<{ token: string; profile: StudentProfile }>(API_ENDPOINTS.AUTH.LOGIN, {
      studentCode,
      password,
    });
  },

  changePassword: async (payload: {
    currentPassword: string;
    newPassword: string;
    confirmPassword: string;
  }): Promise<{ success: boolean; message: string }> => {
    if (ENV.USE_MOCK_DATA) {
      await new Promise((resolve) => setTimeout(resolve, 350));
      if (payload.currentPassword === 'wrong') {
        throw new Error('Mật khẩu hiện tại không chính xác.');
      }
      return { success: true, message: 'Đổi mật khẩu thành công!' };
    }
    return await apiClient.put<{ success: boolean; message: string }>(
      API_ENDPOINTS.AUTH.CHANGE_PASSWORD,
      payload
    );
  },

  getProfile: async (): Promise<StudentProfile> => {
    if (ENV.USE_MOCK_DATA) return mockStudentProfile;
    return await apiClient.get<StudentProfile>(API_ENDPOINTS.STUDENT.PROFILE);
  },

  getOverview: async (): Promise<StudentOverview> => {
    if (ENV.USE_MOCK_DATA) return mockStudentOverview;
    return await apiClient.get<StudentOverview>(API_ENDPOINTS.STUDENT.OVERVIEW);
  },

  getNextClass: async (): Promise<ScheduleItem | null> => {
    if (ENV.USE_MOCK_DATA) return mockNextClass;
    return await apiClient.get<ScheduleItem | null>(API_ENDPOINTS.SCHEDULE.NEXT_CLASS);
  },

  getSchedule: async (): Promise<ScheduleItem[]> => {
    if (ENV.USE_MOCK_DATA) return mockWeeklySchedule;
    return await apiClient.get<ScheduleItem[]>(API_ENDPOINTS.SCHEDULE.WEEKLY);
  },

  getAttendanceCourses: async (): Promise<AttendanceCourseStat[]> => {
    if (ENV.USE_MOCK_DATA) return mockAttendanceCourses;
    return await apiClient.get<AttendanceCourseStat[]>(API_ENDPOINTS.SCHEDULE.ATTENDANCE_STATS);
  },

  getGrades: async (): Promise<SemesterSummary[]> => {
    if (ENV.USE_MOCK_DATA) return mockSemesterSummaries;
    return await apiClient.get<SemesterSummary[]>(API_ENDPOINTS.ACADEMIC.GRADES);
  },

  getConductScores: async (): Promise<ConductScore[]> => {
    if (ENV.USE_MOCK_DATA) return mockConductScores;
    return await apiClient.get<ConductScore[]>('/student/conduct');
  },

  getTransactions: async (): Promise<Transaction[]> => {
    if (ENV.USE_MOCK_DATA) return mockTransactions;
    return await apiClient.get<Transaction[]>(API_ENDPOINTS.FINANCE.TRANSACTIONS);
  },

  getReceipts: async (): Promise<Receipt[]> => {
    if (ENV.USE_MOCK_DATA) return mockReceipts;
    return await apiClient.get<Receipt[]>(API_ENDPOINTS.FINANCE.RECEIPTS);
  },

  getNews: async (): Promise<NewsItem[]> => {
    if (ENV.USE_MOCK_DATA) return mockNewsList;
    return await apiClient.get<NewsItem[]>(API_ENDPOINTS.UTILITIES.NEWS);
  },

  getSurveys: async (): Promise<SurveyItem[]> => {
    if (ENV.USE_MOCK_DATA) return mockSurveys;
    return await apiClient.get<SurveyItem[]>(API_ENDPOINTS.UTILITIES.SURVEYS);
  },

  getCurriculum: async (): Promise<CurriculumSemester[]> => {
    if (ENV.USE_MOCK_DATA) return mockCurriculumSemesters;
    return await apiClient.get<CurriculumSemester[]>(API_ENDPOINTS.ACADEMIC.CURRICULUM);
  },

  getAchievements: async (): Promise<AchievementItem[]> => {
    if (ENV.USE_MOCK_DATA) return mockAchievements;
    return await apiClient.get<AchievementItem[]>(API_ENDPOINTS.ACADEMIC.ACHIEVEMENTS);
  },
};
