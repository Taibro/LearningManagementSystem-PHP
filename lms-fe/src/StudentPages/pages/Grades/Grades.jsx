import React, { useEffect, useState } from 'react';
import { getGrades } from '../../studentApi';

export default function Grades() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getGrades()
      .then(data => { setRows(data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const grouped = rows.reduce((acc, row) => {
    const key = row.semesterName;
    if (!acc[key]) acc[key] = [];
    acc[key].push(row);
    return acc;
  }, {});

  const gradeColor = (total) => {
    if (!total) return undefined;
    if (total >= 8.5) return 'var(--green)';
    if (total >= 7.0) return 'var(--blue)';
    if (total >= 5.0) return 'var(--orange)';
    return 'var(--red)';
  };

  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{margin:0}}>Kết quả học tập</div>
      </div>

      {loading && <div style={{padding:'30px',textAlign:'center',color:'var(--text-light)'}}>Đang tải...</div>}

      {Object.entries(grouped).map(([sem, items]) => (
        <div key={sem} className="card" style={{marginBottom:'16px',overflowX:'auto'}}>
          <div style={{padding:'10px 16px',fontWeight:700,color:'var(--blue)',fontSize:'13px',borderBottom:'1px solid var(--border)'}}>
            {sem}
          </div>
          <table className="tbl" style={{minWidth:'700px'}}>
            <tbody>
              <tr>
                <th>STT</th>
                <th>Mã môn</th>
                <th>Tên môn học/học phần</th>
                <th>Mã lớp HP</th>
                <th style={{textAlign:'center'}}>Số TC</th>
                <th style={{textAlign:'center'}}>CC</th>
                <th style={{textAlign:'center'}}>GK</th>
                <th style={{textAlign:'center'}}>CK</th>
                <th style={{textAlign:'center'}}>Tổng</th>
                <th style={{textAlign:'center'}}>Xếp loại</th>
              </tr>
              {items.map((r, i) => (
                <tr key={i}>
                  <td>{i + 1}</td>
                  <td>{r.courseCode}</td>
                  <td>{r.courseName}</td>
                  <td>{r.classCode}</td>
                  <td style={{textAlign:'center'}}>{r.credits}</td>
                  <td style={{textAlign:'center'}}>{r.gradeAttendance ?? '—'}</td>
                  <td style={{textAlign:'center'}}>{r.gradeMidterm ?? '—'}</td>
                  <td style={{textAlign:'center'}}>{r.gradeFinal ?? '—'}</td>
                  <td style={{textAlign:'center',fontWeight:700,color:gradeColor(r.gradeTotal)}}>
                    {r.gradeTotal != null ? r.gradeTotal.toFixed(1) : '—'}
                  </td>
                  <td style={{textAlign:'center',fontWeight:600}}>
                    {r.gradeLetter || '—'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}

      {!loading && rows.length === 0 && (
        <div className="card"><div className="card-body" style={{textAlign:'center',color:'var(--text-light)',padding:'30px'}}>
          Chưa có dữ liệu điểm
        </div></div>
      )}
    </div>
  );
}