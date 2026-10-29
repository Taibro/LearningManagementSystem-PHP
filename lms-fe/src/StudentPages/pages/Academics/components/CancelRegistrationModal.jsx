import React from 'react';

export default function CancelRegistrationModal({ targetClass, onConfirm, onClose }) {
  if (!targetClass) return null;

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
      <div style={{ background: 'white', padding: 30, borderRadius: 8, width: 450, textAlign: 'center', boxShadow: '0 4px 15px rgba(0,0,0,0.2)' }}>
        <div style={{ width: 60, height: 60, borderRadius: '50%', border: '2px solid orange', color: 'orange', fontSize: 40, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 15px auto' }}>!</div>
        <h3 style={{ margin: '0 0 10px 0', fontSize: 18, color: '#333' }}>HỦY ĐĂNG KÝ</h3>
        <p style={{ color: '#666', fontSize: 14, marginBottom: 25 }}>Bạn muốn hủy đăng ký lớp học [{targetClass.courseName}] ?</p>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 10 }}>
          <button onClick={() => onConfirm(targetClass)} style={{ padding: '8px 25px', background: '#456bd9', color: 'white', border: 'none', borderRadius: 4, cursor: 'pointer', fontWeight: 'bold' }}>OK</button>
          <button onClick={onClose} style={{ padding: '8px 25px', background: '#d32f2f', color: 'white', border: 'none', borderRadius: 4, cursor: 'pointer', fontWeight: 'bold' }}>Cancel</button>
        </div>
      </div>
    </div>
  );
}

