/**
 * Centralized API Endpoints cho hệ thống LMS Mobile
 */
export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    REFRESH_TOKEN: '/auth/refresh-token',
    CHANGE_PASSWORD: '/student/change-password',
  },
  STUDENT: {
    PROFILE: '/student/profile',
    OVERVIEW: '/student/overview',
    INFO: '/student/info',
  },
  SCHEDULE: {
    WEEKLY: '/student/weekly-schedule',
    PROGRESS: '/student/progress-schedule',
    NEXT_CLASS: '/student/next-class',
    ATTENDANCE: '/student/attendance',
    ATTENDANCE_STATS: '/student/attendance-stats',
  },
  ACADEMIC: {
    GRADES: '/student/grades',
    CURRICULUM: '/student/curriculum',
    ACHIEVEMENTS: '/student/achievements',
    COURSE_REG: '/student/course-reg',
  },
  FINANCE: {
    RECEIPTS: '/student/receipts',
    TRANSACTIONS: '/student/transactions',
    DEBT_DETAIL: '/student/debt-detail',
    PAYMENT_INIT: '/student/payment/init',
  },
  UTILITIES: {
    NOTIFICATIONS: '/student/notifications',
    NEWS: '/student/news',
    SURVEYS: '/student/surveys',
    CHATBOT: '/student/chatbot',
  },
} as const;

