import React, { useState, useEffect } from 'react';
import { Info, Star } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Grades() {
  const [grades, setGrades] = useState([]);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    fetchGrades();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchGrades = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/grades`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setGrades(data);
      }
    } catch (error) {
      showToast('Lỗi tải danh sách kết quả học tập!', 'error');
    }
  };

  return (
    <div className="page" style={{ position: 'relative' }}>

      {toast && (
        <div style={{
          position: 'fixed', top: '20px', right: '20px', zIndex: 9999,
          padding: '12px 20px', borderRadius: '4px', color: '#fff',
          boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
          background: toast.type === 'success' ? '#4caf50' : '#f44336'
        }}>
          {toast.msg}
        </div>
      )}

      <div className="ph">
        <div>
          <div className="ph-title">Kết quả &amp; Học bổng</div>
          <div className="ph-sub">GPA · Rèn luyện · Học bổng theo học kỳ</div>
        </div>
      </div>
      
      <div className="card mb4">
        <div className="filter-bar">
          <select className="fc" style={{maxWidth:'200px'}}>
            <option>Tất cả học kỳ</option>
          </select>
          <select className="fc" style={{maxWidth:'180px'}}>
            <option>Tất cả lớp học phần</option>
          </select>
          <button className="btn btn-blue btn-sm">Xem</button>
        </div>
      </div>
      
      <div className="card">
        <table className="tbl">
          <thead>
            <tr>
              <th>MSSV</th>
              <th>Sinh viên</th>
              <th>GPA HK</th>
              <th>TC tích lũy</th>
              <th>Điểm RL</th>
              <th>Xếp loại RL</th>
              <th>Học bổng</th>
            </tr>
          </thead>
          <tbody>
            {grades.map(g => (
              <tr key={g.id}>
                <td style={{fontWeight:700, color:'var(--blue)'}}>{g.studentCode}</td>
                <td>{g.studentName || 'Chưa cập nhật tên'}</td>
                <td>
                  <span style={{fontWeight:700, color: g.gpa >= 3.2 ? 'var(--green)' : 'inherit'}}>
                    {g.gpa != null ? g.gpa : '—'}
                  </span>
                </td>
                <td>{g.creditsEarned != null ? g.creditsEarned : '—'}</td>
                <td>{g.conductScore != null ? g.conductScore : '—'}</td>
                <td>
                  {g.conductGrade === 'XuatSac' ? <span className="badge b-purple">Xuất sắc</span> :
                   g.conductGrade === 'Tot' ? <span className="badge b-blue">Tốt</span> : 
                   g.conductGrade === 'Kha' ? <span className="badge b-green">Khá</span> : 
                   g.conductGrade != null ? <span className="badge b-gray">{g.conductGrade}</span> : '—'}
                </td>
                <td>
                  {g.scholarshipAmount > 0 ? (
                    <div>
                      <div style={{fontSize:'12px', color:'var(--amber)', fontWeight:600}}><Star className="w-4 h-4 inline-block mr-2" /> {g.scholarshipName}</div>
                      <div style={{fontSize:'11px'}}>{g.scholarshipAmount.toLocaleString('vi-VN')} đ</div>
                    </div>
                  ) : '—'}
                </td>
              </tr>
            ))}
            {grades.length === 0 && <tr><td colSpan="7" style={{textAlign:'center'}}>Chưa có dữ liệu kết quả học tập</td></tr>}
          </tbody>
        </table>
        <div style={{padding:'14px 20px', background:'#eff6ff', fontSize:'12px', color:'var(--muted)', borderTop:'1px solid var(--border)'}}>
          <Info className="w-4 h-4 inline-block mr-2" /> Điểm và học bổng được tổng hợp tự động từ các môn học trong kỳ.
        </div>
      </div>
    </div>
  );
}
