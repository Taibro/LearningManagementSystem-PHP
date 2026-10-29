import React from 'react';

export default function TeacherInfoModal({ teacherName, onClose }) {
  if (!teacherName) return null;

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
      <div style={{ background: 'white', padding: 20, borderRadius: 8, width: 600 }}>
        <h3 style={{ borderBottom: '1px solid #eee', paddingBottom: 10, margin: '0 0 20px 0' }}>THÔNG TIN GIẢNG VIÊN</h3>
        <h2 style={{ color: 'orange', textAlign: 'center' }}>{teacherName.toUpperCase()}</h2>
        <div style={{ textAlign: 'center', marginTop: 30 }}>
          <button onClick={onClose} style={{ padding: '5px 20px', cursor: 'pointer' }}>Đóng</button>
        </div>
      </div>
    </div>
  );
}

