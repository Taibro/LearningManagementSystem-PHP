import React, { useState, useRef, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Bell } from 'lucide-react';
import { FaHome } from "react-icons/fa";
import useNotifications from '../../../hooks/useNotifications';

export default function Topbar() {
  const [showDropdown, setShowDropdown] = useState(false);
  const dropdownRef = useRef(null);
  const navigate = useNavigate();
  const { unreadCount } = useNotifications('token');
  const rawSchoolName = localStorage.getItem('schoolName') || 'Đại học Công Thương TP.HCM';
  const schoolName = rawSchoolName.replace(/\n/g, ' ');
  const schoolShort = localStorage.getItem('schoolShortName') || 'HUIT';

  const userStr = localStorage.getItem('user');
  let fullName = 'Phan Sĩ Thịnh';
  let shortName = 'PT';
  if (userStr) {
    try {
      const userObj = JSON.parse(userStr);
      if (userObj.fullName) {
        fullName = userObj.fullName;
        const words = fullName.trim().split(' ');
        if (words.length >= 2) {
          shortName = words[0][0].toUpperCase() + words[words.length - 1][0].toUpperCase();
        } else {
          shortName = fullName.substring(0, 2).toUpperCase();
        }
      }
    } catch (e) {}
  }

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleLogout = () => {
    // localStorage.removeItem('token');
    navigate('/login');
  };
  return (
    <div className="topbar">
      <div className="logo-wrap">
        <div style={{width:'42px',height:'42px',background:'linear-gradient(135deg,#1a6fb5,#2e87d4)',borderRadius:'8px',display:'flex',alignItems:'center',justifyContent:'center',color:'white',fontWeight:800,fontSize:'14px',textAlign:'center',flexShrink:0}}>
          {schoolShort}
        </div>
        <div className="logo-text" style={{ color: '#0f172a', textTransform: 'uppercase', fontSize: '12px', maxWidth: '180px', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
          {schoolName}
        </div>
      </div>
      <div className="search-box">
        <svg width="14" height="14" fill="none" stroke="#94a3b8" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
        <input placeholder="Tìm kiếm..." />
      </div>
      <div className="topbar-right">
        <Link className="topbar-link" to="/dashboard"><FaHome />
 Trang chủ</Link>
        <Link className="topbar-link" to="/notifications">
          <Bell className="w-4 h-4 inline-block mr-2" /> Tin tức 
          {unreadCount > 0 && <span className="notif-badge">{unreadCount}</span>}
        </Link>
        
        <div className="user-chip-container" ref={dropdownRef} style={{position: 'relative'}}>
          <div 
            className="user-chip" 
            style={{textDecoration: 'none', color: 'inherit', cursor: 'pointer'}}
            onClick={() => setShowDropdown(!showDropdown)}
          >
            <div style={{width:'32px',height:'32px',borderRadius:'50%',background:'linear-gradient(135deg,#1a6fb5,#60a5fa)',display:'flex',alignItems:'center',justifyContent:'center',color:'white',fontSize:'13px',fontWeight:700}}>
              {shortName}
            </div>
            <span style={{fontSize:'13px',fontWeight:500}}>{fullName} ▾</span>
          </div>

          {showDropdown && (
            <div style={{
              position: 'absolute',
              top: '100%',
              right: 0,
              marginTop: '8px',
              width: '200px',
              background: 'white',
              boxShadow: '0 10px 25px rgba(0,0,0,0.1)',
              borderRadius: '8px',
              border: '1px solid #e2e8f0',
              overflow: 'hidden',
              zIndex: 1000
            }}>
              <Link to="/student-info" style={{display: 'block', padding: '12px 16px', color: '#475569', textDecoration: 'none', borderBottom: '1px solid #f1f5f9', fontSize: '13px'}} onClick={() => setShowDropdown(false)}>
                Thông tin cá nhân
              </Link>
              <Link to="/student-info" style={{display: 'block', padding: '12px 16px', color: '#475569', textDecoration: 'none', borderBottom: '1px solid #f1f5f9', fontSize: '13px'}} onClick={() => setShowDropdown(false)}>
                Đổi mật khẩu
              </Link>
              <div 
                onClick={handleLogout} 
                style={{display: 'block', padding: '12px 16px', color: '#ef4444', textDecoration: 'none', cursor: 'pointer', fontSize: '13px', fontWeight: '500'}}
              >
                Đăng xuất
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}