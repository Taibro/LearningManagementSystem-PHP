import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './saas.css';

// Import cấu trúc Layout đã tách rời
import MainLayout from './components/Layout/MainLayout';
import SaaSAdminLogin from './pages/Login/SaaSAdminLogin';
import ProtectedRoute from './components/ProtectedRoute';

// Import Pages
import Dashboard from './pages/Dashboard/Dashboard';
import Tenants from './pages/Tenants/Tenants';
import Subscriptions from './pages/Subscriptions/Subscriptions';
import Plans from './pages/Plans/Plans';
import SystemLogs from './pages/SystemLogs/SystemLogs';
import Audit from './pages/Audit/Audit';

export default function AppSaaS() {
  return (
    <Router future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <Routes>
        {/* Đi vào link gốc -> Mở màn hình Login */}
        <Route path="/" element={<Navigate to="/saas/login" replace />} />
        
        {/* Trang Login độc lập */}
        <Route path="/saas/login" element={<SaaSAdminLogin />} />

        {/* Các trang quản trị được bảo vệ */}
        <Route element={<ProtectedRoute />}>
          {/* Khung giao diện chính chứa Sidebar và Topbar */}
          <Route path="/saas" element={<MainLayout />}>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="tenants" element={<Tenants />} />
            <Route path="subscriptions" element={<Subscriptions />} />
            <Route path="plans" element={<Plans />} />
            <Route path="logs" element={<SystemLogs />} />
            <Route path="audit" element={<Audit />} />
          </Route>
        </Route>
        
        {/* Bắt lỗi URL gõ sai */}
        <Route path="*" element={<Navigate to="/saas/dashboard" replace />} />
      </Routes>
    </Router>
  );
}