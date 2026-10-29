import axios from 'axios';
import { API_BASE_URL } from '../../config/apiConfig';

export const STUDENT_BASE_URL = `${API_BASE_URL}/student`;

// Tạo instance axios riêng cho Student Module thay vì dùng global axios
const apiClient = axios.create({
  baseURL: STUDENT_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor: Tự động đính kèm Bearer token vào mọi request
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor: Bắt mã lỗi 401 (Unauthorized) để dọn dẹp auth và chuyển về trang login
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      localStorage.removeItem('role');
      localStorage.removeItem('schoolId');
      if (!window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

// Giữ lại getHeaders để đảm bảo tính tương thích ngược cho các lời gọi cũ
export const getHeaders = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem('token')}`,
  },
});

export default apiClient;
