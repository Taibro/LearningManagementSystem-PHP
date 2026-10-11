import React, { useEffect, useState } from 'react';
import { getConduct } from '../../studentApi';

export default function ConductScore() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getConduct()
      .then(data => { setRows(data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const gradeColor = (grade) => {
    if (!grade) return undefined;
    if (grade.includes('Xuất sắc')) return 'var(--green)';
    if (grade.includes('Tốt')) return 'var(--blue)';
    if (grade.includes('Khá')) return 'var(--orange)';
    return 'var(--red)';
  };

  return (
    <div className="page active">
      <div className="page-title">Kết quả rèn luyện</div>
      <div className="card" style={{overflowX:'auto'}}>
        <table className="tbl">
          <tbody>
            <tr>
              <th>Học kỳ</th>
              <th style={{textAlign:'center'}}>GPA</th>
              <th style={{textAlign:'center'}}>Tín chỉ tích lũy</th>
              <th style={{textAlign:'center'}}>Điểm rèn luyện</th>
              <th style={{textAlign:'center'}}>Xếp loại</th>
            </tr>
            {loading && <tr><td colSpan="5" style={{textAlign:'center',padding:'20px',color:'var(--text-light)'}}>Đang tải...</td></tr>}
            {!loading && rows.length === 0 && (
              <tr><td colSpan="5" style={{textAlign:'center',padding:'30px',color:'var(--text-light)'}}>Chưa có dữ liệu</td></tr>
            )}
            {rows.map((r, i) => (
              <tr key={i}>
                <td>{r.semesterName}</td>
                <td style={{textAlign:'center',fontWeight:700,color:'var(--blue)'}}>{r.gpa != null ? Number(r.gpa).toFixed(2) : '—'}</td>
                <td style={{textAlign:'center'}}>{r.creditsEarned ?? '—'}</td>
                <td style={{textAlign:'center',fontWeight:700,color:'var(--orange)'}}>{r.conductScore ?? '—'}</td>
                <td style={{textAlign:'center',fontWeight:600,color:gradeColor(r.conductGrade)}}>{r.conductGrade || '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}