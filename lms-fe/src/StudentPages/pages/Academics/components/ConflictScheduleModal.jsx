import React from 'react';

const DEFAULT_DAY_NAMES = ['', 'CN', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];

export default function ConflictScheduleModal({ conflicts, dayNames = DEFAULT_DAY_NAMES, onClose }) {
  if (!conflicts) return null;

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
      <div style={{ background: 'white', padding: 20, borderRadius: 8, width: 800 }}>
        <h3 style={{ margin: '0 0 20px 0' }}>DANH SÁCH LỊCH HỌC BỊ TRÙNG</h3>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13, marginBottom: 20 }}>
          <thead>
            <tr style={{ background: '#456bd9', color: 'white' }}>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Mã LHP</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Tên môn học</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Thứ</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Tiết</th>
            </tr>
          </thead>
          <tbody>
            {conflicts.length === 0 ? (
              <tr><td colSpan="4" style={{ padding: 20, textAlign: 'center' }}>Không tìm thấy lịch học trùng</td></tr>
            ) : conflicts.map(c => (
              <tr key={c.classId}>
                <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{c.classCode}</td>
                <td style={{ padding: 10, border: '1px solid #ddd' }}>{c.courseName}</td>
                <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{dayNames[c.dayOfWeek]}</td>
                <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>T{c.startPeriod} - T{c.endPeriod}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <div style={{ textAlign: 'right' }}>
          <button onClick={onClose} style={{ padding: '5px 20px', cursor: 'pointer' }}>Đóng</button>
        </div>
      </div>
    </div>
  );
}

