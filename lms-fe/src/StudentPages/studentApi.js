import axios from 'axios';
import { API_BASE_URL } from '../config/apiConfig';


const BASE_URL = `${API_BASE_URL}/student`;

// Lấy token từ localStorage (được lưu khi login)
const getHeaders = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem('token')}`,
  },
});

// ── PROFILE ─────────────────────────────────────────────────────────────────
export const getProfile = () =>
  axios.get(`${BASE_URL}/profile`, getHeaders()).then(res => res.data);

export const updateProfile = (payload) =>
  axios.put(`${BASE_URL}/profile`, payload, getHeaders()).then(res => res.data);

// ── WEEKLY SCHEDULE ──────────────────────────────────────────────────────────
// date: chuỗi 'YYYY-MM-DD' (tùy chọn, mặc định là tuần hiện tại)
export const getWeeklySchedule = (date) => {
  const params = date ? { date } : {};
  return axios.get(`${BASE_URL}/weekly-schedule`, { ...getHeaders(), params }).then(res => res.data);
};

// ── PROGRESS SCHEDULE ────────────────────────────────────────────────────────
// semesterId: số nguyên (tùy chọn, 0 = tất cả HK)
export const getProgressSchedule = (semesterId) => {
  const params = semesterId ? { semesterId } : {};
  return axios.get(`${BASE_URL}/progress-schedule`, { ...getHeaders(), params }).then(res => res.data);
};

// ── GRADES ───────────────────────────────────────────────────────────────────
export const getGrades = () =>
  axios.get(`${BASE_URL}/grades`, getHeaders()).then(res => res.data);

// ── ATTENDANCE ───────────────────────────────────────────────────────────────
export const getAttendance = () =>
  axios.get(`${BASE_URL}/attendance`, getHeaders()).then(res => res.data);

// ── CONDUCT ──────────────────────────────────────────────────────────────────
export const getConduct = () =>
  axios.get(`${BASE_URL}/conduct`, getHeaders()).then(res => res.data);

// ── TUITION ──────────────────────────────────────────────────────────────────
export const getTuition = () =>
  axios.get(`${BASE_URL}/tuition`, getHeaders()).then(res => res.data);

export const getDebtDetail = (semesterId) => {
  const params = semesterId ? { semesterId } : {};
  return axios.get(`${BASE_URL}/debt-detail`, { ...getHeaders(), params }).then(res => res.data);
};

export const createPayment = (payload) => 
  axios.post(`${BASE_URL}/payment`, payload, getHeaders()).then(res => res.data);

export const getPayments = () =>
  axios.get(`${BASE_URL}/payments`, getHeaders()).then(res => res.data);

export const cancelPayment = (id) =>
  axios.post(`${BASE_URL}/payment/${id}/cancel`, {}, getHeaders()).then(res => res.data);

export const checkPaymentStatus = (id) =>
  axios.get(`${BASE_URL}/payment/${id}/check`, getHeaders()).then(res => res.data);

export const mockPaymentSuccess = (id) =>
  axios.post(`${BASE_URL}/payment/${id}/mock-success`, {}, getHeaders()).then(res => res.data);


// ── SEMESTERS (cho dropdown) ──────────────────────────────────────────────────
export const getSemesters = () =>
  axios.get(`${BASE_URL}/semesters`, getHeaders()).then(res => res.data);


// ── NOTIFICATIONS ────────────────────────────────────────────────────────────
export const getNotifications = () =>
  axios.get(`${BASE_URL}/notifications`, getHeaders()).then(res => res.data);

// ── SURVEYS ──────────────────────────────────────────────────────────────────
export const getSurveys = () =>
  axios.get(`${BASE_URL}/surveys`, getHeaders()).then(res => res.data);

export const submitSurvey = (payload) =>
  axios.post(`${BASE_URL}/surveys`, payload, getHeaders()).then(res => res.data);

// ── COURSE REGISTRATION ───────────────────────────────────────────────────────
// type: 'NORMAL' | 'RETAKE' | 'IMPROVE'
export const getCourseRegList = (semesterId, type = 'NORMAL') => {
  const params = { type };
  if (semesterId) params.semesterId = semesterId;
  return axios.get(`${BASE_URL}/course-reg`, { ...getHeaders(), params }).then(res => res.data);
};

export const registerCourse = (classId, type = 'NORMAL') =>
  axios.post(`${BASE_URL}/course-reg`, { classId, type }, getHeaders()).then(res => res.data);

export const getEnrolledClasses = (semesterId) => {
  const params = {};
  if (semesterId) params.semesterId = semesterId;
  return axios.get(`${BASE_URL}/course-reg/enrolled`, { ...getHeaders(), params }).then(res => res.data);
};

export const cancelCourseReg = (classId) =>
  axios.delete(`${BASE_URL}/course-reg/cancel`, { ...getHeaders(), params: { classId } }).then(res => res.data);

// ── SCHOLARSHIPS ──────────────────────────────────────────────────────────────
export const getScholarships = () =>
  axios.get(`${BASE_URL}/scholarships`, getHeaders()).then(res => res.data);
