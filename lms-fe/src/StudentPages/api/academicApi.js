import axios, { STUDENT_BASE_URL, getHeaders } from './client';

export const getCourseRegList = (semesterId, type = 'NORMAL') => {
  const params = { type };
  if (semesterId) params.semesterId = semesterId;
  return axios.get(`${STUDENT_BASE_URL}/course-reg`, { ...getHeaders(), params }).then(res => res.data);
};

export const registerCourse = (classId, type = 'NORMAL') =>
  axios.post(`${STUDENT_BASE_URL}/course-reg`, { classId, type }, getHeaders()).then(res => res.data);

export const getEnrolledClasses = (semesterId) => {
  const params = {};
  if (semesterId) params.semesterId = semesterId;
  return axios.get(`${STUDENT_BASE_URL}/course-reg/enrolled`, { ...getHeaders(), params }).then(res => res.data);
};

export const cancelCourseReg = (classId) =>
  axios.delete(`${STUDENT_BASE_URL}/course-reg/cancel`, { ...getHeaders(), params: { classId } }).then(res => res.data);

export const getSurveys = () =>
  axios.get(`${STUDENT_BASE_URL}/surveys`, getHeaders()).then(res => res.data);

export const submitSurvey = (payload) =>
  axios.post(`${STUDENT_BASE_URL}/surveys`, payload, getHeaders()).then(res => res.data);

