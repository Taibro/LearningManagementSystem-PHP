import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';

const ProtectedRoute = () => {
  // Kiểm tra xem token hoặc thông tin user có tồn tại trong localStorage không
  const token = localStorage.getItem('saas_token');

  // Nếu không có token, điều hướng về trang đăng nhập
  if (!token) {
    return <Navigate to="/saas/login" replace />;
  }

  // Nếu đã đăng nhập, cho phép truy cập các route con
  return <Outlet />;
};

export default ProtectedRoute;
