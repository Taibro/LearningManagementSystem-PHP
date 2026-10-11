import React, { useEffect, useState } from 'react';
import { getProgressSchedule } from '../../studentApi';

const DAY_NAMES = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

export default function ProgressSchedule() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [semesterId, setSemesterId] = useState('');

  const load = (sid) => {
    setLoading(true);
    getProgressSchedule(sid || undefined)
      .then(data => { setRows(data); setLoading(false); })
      .catch(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const formatDate = (d) => d ? new Date(d).toLocaleDateString('vi-VN') : '';
  const typeLabel  = (t) => t === 'REGULAR' ? 'Lý thuyết' : t === 'LAB' ? 'Thực hành' : t || '';

  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{margin:0}}>Lịch học, lịch thi theo tiến độ</div>
        <div style={{display:'flex',alignItems:'center',gap:'8px'}}>
          <button className="btn btn-blue btn-sm" onClick={() => load(semesterId)}>Xem lịch</button>
        </div>
      </div>
      <div className="card" style={{overflowX:'auto'}}>
        <table className="tbl" style={{minWidth:'900px'}}>
          <tbody>
            <tr>
              <th>STT</th>
              <th>Mã học phần</th>
              <th>Tên môn học</th>
              <th>Số TC</th>
              <th>Thứ</th>
              <th>Tiết</th>
              <th>Loại lịch</th>
              <th>Phòng</th>
              <th>Bắt đầu</th>
              <th>Kết thúc</th>
              <th>Giảng viên</th>
            </tr>
            {loading && <tr><td colSpan="11" style={{textAlign:'center',padding:'20px',color:'var(--text-light)'}}>Đang tải...</td></tr>}
            {!loading && rows.length === 0 && (
              <tr><td colSpan="11" style={{textAlign:'center',padding:'30px',color:'var(--text-light)'}}>Không có dữ liệu</td></tr>
            )}
            {rows.map((r, i) => (
              <tr key={i}>
                <td>{i + 1}</td>
                <td>{r.courseCode}</td>
                <td>{r.courseName}</td>
                <td style={{textAlign:'center'}}>{r.credits}</td>
                <td>{r.dayOfWeek ? DAY_NAMES[r.dayOfWeek] : '—'}</td>
                <td style={{textAlign:'center'}}>{r.startPeriod} – {r.endPeriod}</td>
                <td>{typeLabel(r.sessionType)}</td>
                <td>{r.roomName || '—'}</td>
                <td>{formatDate(r.startDate)}</td>
                <td>{formatDate(r.endDate)}</td>
                <td>{r.teacherName || '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}