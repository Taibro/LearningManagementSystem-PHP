import React from 'react';

const DEFAULT_DAY_NAMES = ['', 'CN', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];

export default function ViewClassDetailModal({ classDetail, dayNames = DEFAULT_DAY_NAMES, onClose }) {
  if (!classDetail) return null;

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
      <div style={{ background: 'white', padding: '20px', borderRadius: 8, width: 850, boxShadow: '0 4px 15px rgba(0,0,0,0.2)' }}>
        <h3 style={{ margin: '0 0 20px 0', fontSize: 16 }}>CHI TIẾT LỚP HỌC ĐÃ ĐĂNG KÝ</h3>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13, marginBottom: 20 }}>
          <thead>
            <tr style={{ background: '#456bd9', color: 'white' }}>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>STT</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Lịch học</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Nhóm</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Phòng</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Dãy nhà</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Cơ sở</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Giảng viên</th>
              <th style={{ padding: 10, border: '1px solid #ddd' }}>Thời gian</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>1</td>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>
                LT - {dayNames[classDetail.dayOfWeek]} (T{classDetail.startPeriod} - T{classDetail.endPeriod})
              </td>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}></td>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{classDetail.roomNumber}</td>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{classDetail.building}</td>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>ĐHCT TP.HCM</td>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{classDetail.teacherName}</td>
              <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>06/07/2026 - 03/08/2026</td>
            </tr>
          </tbody>
        </table>
        <div style={{ textAlign: 'right' }}>
          <button onClick={onClose} style={{ padding: '6px 20px', border: '1px solid #ccc', background: 'white', borderRadius: 4, cursor: 'pointer' }}>Đóng</button>
        </div>
      </div>
    </div>
  );
}

