import React, { useEffect, useState } from 'react';
import { getScholarships } from '../../studentApi';

export default function Scholarships() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getScholarships()
      .then(data => {
        setRows(data);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  const formatMoney = (amount) =>
    amount != null ? Number(amount).toLocaleString('vi-VN') + ' đ' : '—';

  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{margin:0}}>Mức học bổng được xét</div>
      </div>
      <div className="card" style={{overflowX:'auto'}}>
        <table className="tbl">
          <tbody>
            <tr>
              <th>STT</th>
              <th>Học kỳ</th>
              <th style={{textAlign:'center'}}>GPA</th>
              <th style={{textAlign:'center'}}>Tín chỉ tích lũy</th>
              <th>Loại học bổng</th>
              <th style={{textAlign:'right'}}>Số tiền</th>
            </tr>
            {loading && <tr><td colSpan="6" style={{textAlign:'center',padding:'20px',color:'var(--text-light)'}}>Đang tải...</td></tr>}
            {!loading && rows.length === 0 && (
              <tr><td colSpan="6" style={{textAlign:'center',padding:'30px',color:'var(--text-light)'}}>Không có dữ liệu hiển thị</td></tr>
            )}
            {rows.map((r, i) => (
              <tr key={i}>
                <td>{i + 1}</td>
                <td>{r.semesterName}</td>
                <td style={{textAlign:'center',fontWeight:700,color:'var(--blue)'}}>{r.gpa != null ? Number(r.gpa).toFixed(2) : '—'}</td>
                <td style={{textAlign:'center'}}>{r.totalCredits ?? '—'}</td>
                <td style={{color:'var(--green)',fontWeight:600}}>{r.scholarshipType}</td>
                <td style={{textAlign:'right',fontWeight:700,color:'var(--orange)'}}>{formatMoney(r.scholarshipAmount)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}