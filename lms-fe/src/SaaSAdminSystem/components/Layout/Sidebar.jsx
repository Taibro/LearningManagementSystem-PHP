import React from 'react';
import { NavLink } from 'react-router-dom';

export default function Sidebar() {
  const navClass = ({ isActive }) => `nav-item ${isActive ? 'active' : ''}`;

  const handleLogout = () => {
    localStorage.removeItem('saas_token');
    localStorage.removeItem('saas_user');
    window.location.href = '/saas/login';
  };

  return (
    <aside className="sidebar flex flex-col">
      <div className="px-5 py-5 border-b" style={{ borderColor: 'var(--border)' }}>
        <div className="flex items-center gap-2 mb-1">
          <div className="w-7 h-7 rounded-lg flex items-center justify-center text-sm font-bold" style={{ background: 'var(--accent)' }}>E</div>
          <span className="font-syne font-bold text-base tracking-tight">EduSpace</span>
        </div>
        <span className="text-xs font-mono px-2 py-0.5 rounded" style={{ background: 'rgba(250,109,142,.12)', color: 'var(--accent2)' }}>SaaS Command Center</span>
      </div>

      <div className="px-3 py-4 flex-1">
        <p className="text-xs px-2 mb-2 font-mono tracking-widest" style={{ color: 'var(--muted)' }}>OVERVIEW</p>
        <NavLink to="/saas/dashboard" className={navClass}>
          <svg className="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h8m-8 6h16"/></svg>
          Dashboard
        </NavLink>
        <NavLink to="/saas/tenants" className={navClass}>
          <svg className="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0H5m9-7h-4"/></svg>
          Khách hàng (Tenant)
        </NavLink>
        <NavLink to="/saas/subscriptions" className={navClass}>
          <svg className="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
          Gói cước & Billing
        </NavLink>
        <NavLink to="/saas/plans" className={navClass}>
          <svg className="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/></svg>
          Quản lý Gói cước
        </NavLink>

        <p className="text-xs px-2 mt-5 mb-2 font-mono tracking-widest" style={{ color: 'var(--muted)' }}>MONITORING</p>
        <NavLink to="/saas/logs" className={navClass}>
          <svg className="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          Error Logs
        </NavLink>
        <NavLink to="/saas/audit" className={navClass}>
          <svg className="nav-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
          Audit Log
        </NavLink>
      </div>

      <div className="px-4 py-4 border-t" style={{ borderColor: 'var(--border)' }}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white" style={{ background: 'linear-gradient(135deg,var(--accent),var(--accent2))' }}>SA</div>
            <div>
              <p className="text-xs font-semibold" style={{ color: 'var(--text)' }}>Super Admin</p>
              <p className="text-xs" style={{ color: 'var(--muted)' }}>admin@eduspace.vn</p>
            </div>
          </div>
          <button 
            onClick={handleLogout} 
            title="Đăng xuất"
            style={{ padding: '6px', borderRadius: '6px', cursor: 'pointer', background: 'transparent', border: 'none', color: '#ef4444' }}
            onMouseOver={(e) => e.currentTarget.style.background = 'rgba(239, 68, 68, 0.1)'}
            onMouseOut={(e) => e.currentTarget.style.background = 'transparent'}
          >
            <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
          </button>
        </div>
      </div>
    </aside>
  );
}