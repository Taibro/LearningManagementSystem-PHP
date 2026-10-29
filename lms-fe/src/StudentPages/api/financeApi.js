import axios, { STUDENT_BASE_URL, getHeaders } from './client';

export const getTuition = () =>
  axios.get(`${STUDENT_BASE_URL}/tuition`, getHeaders()).then(res => res.data);

export const getDebtDetail = (semesterId) => {
  const params = semesterId ? { semesterId } : {};
  return axios.get(`${STUDENT_BASE_URL}/debt-detail`, { ...getHeaders(), params }).then(res => res.data);
};

export const createPayment = (payload) => 
  axios.post(`${STUDENT_BASE_URL}/payment`, payload, getHeaders()).then(res => res.data);

export const getPayments = () =>
  axios.get(`${STUDENT_BASE_URL}/payments`, getHeaders()).then(res => res.data);

export const cancelPayment = (id) =>
  axios.post(`${STUDENT_BASE_URL}/payment/${id}/cancel`, {}, getHeaders()).then(res => res.data);

export const checkPaymentStatus = (id) =>
  axios.get(`${STUDENT_BASE_URL}/payment/${id}/check`, getHeaders()).then(res => res.data);

export const mockPaymentSuccess = (id) =>
  axios.post(`${STUDENT_BASE_URL}/payment/${id}/mock-success`, {}, getHeaders()).then(res => res.data);

export const getSemesters = () =>
  axios.get(`${STUDENT_BASE_URL}/semesters`, getHeaders()).then(res => res.data);

