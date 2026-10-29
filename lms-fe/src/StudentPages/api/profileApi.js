import axios, { STUDENT_BASE_URL, getHeaders } from './client';

export const getProfile = () =>
  axios.get(`${STUDENT_BASE_URL}/profile`, getHeaders()).then(res => res.data);

export const updateProfile = (payload) =>
  axios.put(`${STUDENT_BASE_URL}/profile`, payload, getHeaders()).then(res => res.data);

export const changePassword = (payload) =>
  axios.put(`${STUDENT_BASE_URL}/change-password`, payload, getHeaders()).then(res => res.data);

export const getNotifications = () =>
  axios.get(`${STUDENT_BASE_URL}/notifications`, getHeaders()).then(res => res.data);
