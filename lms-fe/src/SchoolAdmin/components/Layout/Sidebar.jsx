import React from 'react';
import { NavLink } from 'react-router-dom';
import { BarChart, CalendarDays, Settings, User, DollarSign, ClipboardList, CheckCircle2, GraduationCap, School, Bell, AlertTriangle, MapPin, Landmark, Library, Receipt } from 'lucide-react';

export default function Sidebar() {
  const navClass = ({ isActive }) => `nav-item ${isActive ? 'active' : ''}`;
  
  // Lấy dữ liệu từ LocalStorage
  const adminName = localStorage.getItem('adminName') || 'Quản trị viên';
  const adminEmail = localStorage.getItem('adminEmail') || 'admin@huit.edu.vn';
  
  // Xác định thông tin trường
  const schoolShort = localStorage.getItem('schoolShortName') || 'HUIT';
  const rawSchoolName = localStorage.getItem('schoolName') || 'Đại học Công Thương TP.HCM';
  const schoolName = rawSchoolName.replace(/\n/g, ' ');
  
  // Nhuộm màu Sidebar thành Xanh HUIT đặc trưng nếu là HUIT
  const isHuit = schoolShort.toUpperCase() === 'HUIT';
  const sidebarStyle = isHuit ? { backgroundColor: '#0d3a82' } : {};
  const badgeStyle = isHuit ? { backgroundColor: '#ff9800', color: '#fff' } : {};

  return (
    <aside className="admin-sidebar" style={sidebarStyle}>
      <div className="logo-zone">
        <div className="logo-badge" style={badgeStyle}>{schoolShort}</div>
        <div>
          <div className="admin-logo-text">{schoolName}</div>
          <div className="logo-sub">Quản trị cơ sở đào tạo</div>
        </div>
      </div>
      <div className="nav-wrap">
        <div className="nav-section">
          <div className="nav-label">Tổng quan</div>
          <NavLink to="/dashboard" className={navClass}><span className="nav-icon">⬡</span> Dashboard</NavLink>
        </div>
        <div className="nav-section">
          <div className="nav-label">Cơ sở hạ tầng</div>
          <NavLink to="/branches" className={navClass}><span className="nav-icon"><MapPin className="w-4 h-4 inline-block mr-2" /></span> Cơ sở &amp; Phòng học</NavLink>
          <NavLink to="/departments" className={navClass}><span className="nav-icon"><Landmark className="w-4 h-4 inline-block mr-2" /></span> Khoa / Bộ môn</NavLink>
          <NavLink to="/semesters" className={navClass}><span className="nav-icon"><CalendarDays className="w-4 h-4 inline-block mr-2" /></span> Năm học &amp; Học kỳ</NavLink>
        </div>
        <div className="nav-section">
          <div className="nav-label">Học vụ</div>
          <NavLink to="/courses" className={navClass}><span className="nav-icon"><Library className="w-4 h-4 inline-block mr-2" /></span> Môn học</NavLink>
          <NavLink to="/classes" className={navClass}><span className="nav-icon"><GraduationCap className="w-4 h-4 inline-block mr-2" /></span> Lớp học <span className="nav-badge">3</span></NavLink>
          <NavLink to="/schedule" className={navClass}><span className="nav-icon"><CalendarDays className="w-4 h-4 inline-block mr-2" /></span> Lịch học</NavLink>
          <NavLink to="/exceptions" className={navClass}><span className="nav-icon"><AlertTriangle className="w-4 h-4 inline-block mr-2" /></span> Ngoại lệ lịch <span className="nav-badge warn">1</span></NavLink>
        </div>
        <div className="nav-section">
          <div className="nav-label">Nhân sự &amp; Học sinh</div>
          <NavLink to="/teachers" className={navClass}><span className="nav-icon">‍<School className="w-4 h-4 inline-block mr-2" /></span> Giảng viên <span className="nav-badge">3</span></NavLink>
          <NavLink to="/students" className={navClass}><span className="nav-icon">‍<GraduationCap className="w-4 h-4 inline-block mr-2" /></span> Sinh viên <span className="nav-badge">3</span></NavLink>
          <NavLink to="/users" className={navClass}><span className="nav-icon"><User className="w-4 h-4 inline-block mr-2" /></span> Tài khoản</NavLink>
        </div>
        <div className="nav-section">
          <div className="nav-label">Học tập</div>
          <NavLink to="/enrollments" className={navClass}><span className="nav-icon"><CheckCircle2 className="w-4 h-4 inline-block mr-2" /></span> Đăng ký học phần</NavLink>
          <NavLink to="/attendance" className={navClass}><span className="nav-icon"><ClipboardList className="w-4 h-4 inline-block mr-2" /></span> Điểm danh <span className="nav-badge danger">4</span></NavLink>
          <NavLink to="/grades" className={navClass}><span className="nav-icon"><BarChart className="w-4 h-4 inline-block mr-2" /></span> Kết quả &amp; Học bổng</NavLink>
        </div>
        <div className="nav-section">
          <div className="nav-label">Tài chính</div>
          <NavLink to="/tuition" className={navClass}><span className="nav-icon"><DollarSign className="w-4 h-4 inline-block mr-2" /></span> Học phí &amp; Công nợ</NavLink>
          <NavLink to="/payments" className={navClass}><span className="nav-icon"><Receipt className="w-4 h-4 inline-block mr-2" /></span> Phiếu thu</NavLink>
        </div>
        <div className="nav-section">
          <div className="nav-label">Hệ thống</div>
          <NavLink to="/notifications" className={navClass}><span className="nav-icon"><Bell className="w-4 h-4 inline-block mr-2" /></span> Thông báo <span className="nav-badge danger">12</span></NavLink>
          <NavLink to="/settings" className={navClass}><span className="nav-icon"><Settings className="w-4 h-4 inline-block mr-2" /></span> Cài đặt trường</NavLink>
        </div>
      </div>
      <div className="sidebar-bottom">
        <div className="user-chip">
          <div className="user-av">{adminName.charAt(0).toUpperCase()}</div>
          <div style={{overflow: 'hidden'}}>
            <div className="user-name" style={{whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis'}}>{adminName}</div>
            <div className="user-role" style={{whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis'}}>{adminEmail}</div>
          </div>
          <button 
            title="Đăng xuất"
            style={{marginLeft:'auto', flexShrink: 0, display: 'flex', alignItems: 'center', gap: '6px', background:'rgba(255,0,0,0.1)', color:'#ff6b6b', border:'1px solid rgba(255,0,0,0.2)', borderRadius:'6px', padding:'6px 10px', cursor:'pointer', fontWeight:'bold', fontSize: '12px'}}
            onClick={() => {
              localStorage.removeItem('token');
              localStorage.removeItem('adminToken');
              localStorage.removeItem('adminName');
              localStorage.removeItem('adminEmail');
              localStorage.removeItem('schoolId');
              window.location.href = '/login';
            }}
          >
            <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
            Đăng xuất
          </button>
        </div>
      </div>
    </aside>
  );
}
