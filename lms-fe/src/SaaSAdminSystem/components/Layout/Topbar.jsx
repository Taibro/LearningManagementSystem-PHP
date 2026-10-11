import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';

export default function Topbar() {
  const location = useLocation();
  const [time, setTime] = useState(new Date().toLocaleTimeString('vi-VN'));

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date().toLocaleTimeString('vi-VN')), 1000);
    return () => clearInterval(timer);
  }, []);

  const getPageInfo = () => {
    switch (location.pathname) {
      case '/saas/dashboard': return { title: 'Dashboard', sub: 'Tổng quan hệ thống EduSpace · Cập nhật realtime' };
      case '/saas/tenants': return { title: 'Quản lý Khách hàng (Tenant)', sub: 'Danh sách tất cả trường / trung tâm đang thuê EduSpace' };
      case '/saas/subscriptions': return { title: 'Gói cước & Billing', sub: 'Hoá đơn và lịch sử thanh toán phần mềm' };
      case '/saas/plans': return { title: 'Quản lý Gói cước', sub: 'Cấu hình các gói cước SaaS' };
      case '/saas/logs': return { title: 'Error Logs', sub: 'Nhật ký lỗi toàn hệ thống' };
      case '/saas/audit': return { title: 'Audit Log', sub: 'Theo dõi thay đổi bất thường' };
      default: return { title: 'Command Center', sub: 'Hệ thống quản trị trung tâm' };
    }
  };

  const { title, sub } = getPageInfo();

  return (
    <div className="flex items-center justify-between mb-6">
      <div>
        <h1 className="font-syne font-bold text-xl tracking-tight">{title}</h1>
        <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{sub}</p>
      </div>
      <div className="flex items-center gap-3">
        <div className="text-xs font-mono px-3 py-1.5 rounded-lg" style={{ background: 'var(--surface2)', color: 'var(--muted)' }}>
          🕐 {time}
        </div>
        
      </div>
    </div>
  );
}