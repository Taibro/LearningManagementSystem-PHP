import axios, { STUDENT_BASE_URL, getHeaders } from './client';

export const getWeeklySchedule = (date) => {
  const params = date ? { date } : {};
  return axios.get(`${STUDENT_BASE_URL}/weekly-schedule`, { ...getHeaders(), params }).then(res => res.data);
};

export const getProgressSchedule = (semesterId) => {
  const params = semesterId ? { semesterId } : {};
  return axios.get(`${STUDENT_BASE_URL}/progress-schedule`, { ...getHeaders(), params }).then(res => res.data);
};

export const getAttendance = () =>
  axios.get(`${STUDENT_BASE_URL}/attendance`, getHeaders()).then(res => res.data);

