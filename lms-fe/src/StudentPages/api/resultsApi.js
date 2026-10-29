import axios, { STUDENT_BASE_URL, getHeaders } from './client';

export const getGrades = () =>
  axios.get(`${STUDENT_BASE_URL}/grades`, getHeaders()).then(res => res.data);

export const getConduct = () =>
  axios.get(`${STUDENT_BASE_URL}/conduct`, getHeaders()).then(res => res.data);

export const getScholarships = () =>
  axios.get(`${STUDENT_BASE_URL}/scholarships`, getHeaders()).then(res => res.data);

