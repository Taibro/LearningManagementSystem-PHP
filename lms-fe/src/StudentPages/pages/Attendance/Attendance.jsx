import React, { useEffect, useState } from 'react';
import { getAttendance } from '../../studentApi';

export default function Attendance() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getAttendance()
      .then(data => { setRows(data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  // Group theo semester
  const grouped = rows.reduce((acc, row) => {
    const key = row.semesterName;
    if (!acc[key]) acc[key] = [];
    acc[key].push(row);
    return acc;
  }, {});

  const totalPermission = rows.reduce((s, r) => s + (r.absentWithPermission || 0), 0);
  const totalNoPermission = rows.reduce((s, r) => s + (r.absentWithoutPermission || 0), 0);

  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{margin:0}}>Thông tin điểm danh</div>
      </div>
      <div className="card">
        <table className="tbl">
          <tbody>
            <tr>
              <th>STT</th>
              <th>Mã lớp học phần</th>
              <th>Tên môn học/học phần</th>
              <th>TC</th>
              <th>Số tiết vắng có phép</th>
              <th>Số tiết vắng không phép</th>
              <th>Đi trễ</th>
            </tr>
            {loading && (
              <tr><td colSpan="7" style={{textAlign:'center',padding:'20px',color:'var(--text-light)'}}>Đang tải...</td></tr>
            )}
            {!loading && Object.entries(grouped).map(([sem, items]) => (
              <React.Fragment key={sem}>
                <tr className="section-row"><td colSpan="7">{sem}</td></tr>
                {items.map((r, i) => (
                  <tr key={i}>
                    <td>{i + 1}</td>
                    <td>{r.classCode}</td>
                    <td>{r.courseName}</td>
                    <td>{r.credits}</td>
                    <td style={{textAlign:'center'}}>{r.absentWithPermission || 0}</td>
                    <td style={{textAlign:'center',color: r.absentWithoutPermission > 0 ? 'var(--red)' : undefined, fontWeight: r.absentWithoutPermission > 0 ? 700 : undefined}}>
                      {r.absentWithoutPermission || 0}
                    </td>
                    <td style={{textAlign:'center'}}>{r.late || 0}</td>
                  </tr>
                ))}
              </React.Fragment>
            ))}
            {!loading && rows.length > 0 && (
              <tr style={{background:'#f0f6ff'}}>
                <td colSpan="4" style={{textAlign:'center',fontWeight:700,color:'var(--blue)'}}>TỔNG:</td>
                <td style={{textAlign:'center',fontWeight:700,color:'var(--blue)'}}>{totalPermission}</td>
                <td style={{textAlign:'center',fontWeight:700,color:'var(--red)'}}>{totalNoPermission}</td>
                <td></td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}