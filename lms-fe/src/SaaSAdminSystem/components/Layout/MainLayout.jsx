import React, { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Topbar from './Topbar';

export default function MainLayout() {
  const [toasts, setToasts] = useState([]);

  // Hàm tạo Toast dùng chung cho toàn bộ các trang bên trong
  const addToast = (icon, msg, type = 'blue') => {
    const id = Date.now();
    setToasts(prev => [...prev, { id, icon, msg, type }]);
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 3200);
  };

  return (
    <div className="saas-portal">
      {/* Gọi Component Menu Bên Trái */}
      <Sidebar />
      
      {/* Khu vực nội dung chính */}
      <main className="main-content">
        {/* Gọi Component Tiêu Đề Trên Cùng */}
        <Topbar />
        
        {/* Nơi hiển thị các trang con (Dashboard, Tenants...) */}
        <div className="page-content">
          <Outlet context={{ addToast }} />
        </div>
      </main>

      {/* HỆ THỐNG TOAST NỔI GÓC DƯỚI */}
      <div className="fixed bottom-6 right-6 z-[200] flex flex-col gap-2">
        {toasts.map(t => (
          <div key={t.id} className="flex items-center gap-3 px-4 py-3 rounded-xl shadow-2xl animate-[fadeIn_0.3s_ease]" style={{ background: 'var(--surface)', border: `1px solid var(--border)`, borderLeft: `3px solid ${t.type === 'green' ? '#6dfac2' : '#6dc2fa'}` }}>
            <span className="text-lg">{t.icon}</span>
            <p className="text-sm font-semibold">{t.msg}</p>
          </div>
        ))}
      </div>
    </div>
  );
}