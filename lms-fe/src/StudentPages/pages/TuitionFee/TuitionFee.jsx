import React, { useEffect, useState } from 'react';
import { getDebtDetail, getSemesters } from '../../studentApi';

const fmt = (n) => n != null ? Number(n).toLocaleString('vi-VN') : '0';

export default function TuitionFee() {
  const [rows, setRows] = useState([]);
  const [semesters, setSemesters] = useState([]);
  const [semId, setSemId] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getSemesters().then(setSemesters).catch(console.error);
  }, []);

  useEffect(() => {
    setLoading(true);
    getDebtDetail(semId || 0)
      .then(data => {
        setRows(data || []);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, [semId]);

  // Group by semester
  const groups = {};
  rows.forEach(r => {
    if (!groups[r.semesterName]) groups[r.semesterName] = [];
    groups[r.semesterName].push(r);
  });

  const sumPaid = rows.reduce((s, r) => s + Number(r.soTienNop || 0), 0);
  const sumDebt = rows.reduce((s, r) => s + (Number(r.mucNop || 0) - Number(r.soTienNop || 0)), 0);

  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{ margin: 0 }}>Tra cứu công nợ</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 13 }}>Học kỳ</span>
          <select
            className="form-ctrl"
            style={{ width: 220 }}
            value={semId}
            onChange={e => setSemId(e.target.value)}
          >
            <option value="">Tất cả</option>
            {semesters.map(s => (
              <option key={s.id} value={s.id}>{s.name}</option>
            ))}
          </select>
          <button className="btn btn-blue" style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <span>🖨</span> In công nợ
          </button>
        </div>
      </div>

      <div style={{ fontWeight: 600, marginBottom: 8, fontSize: 13, color: '#334155' }}>Khoản thu khác</div>
      <div className="card" style={{ overflowX: 'auto', marginBottom: 24 }}>
        <table className="tbl" style={{ width: '100%', fontSize: 12 }}>
          <thead>
            <tr style={{ background: '#f8fafc', color: '#1a6fb5' }}>
              <th style={{ textAlign: 'center' }}>STT</th>
              <th>Năm học</th>
              <th>Tên đợt</th>
              <th>Mã khoản thu khác</th>
              <th>Tên khoản thu khác</th>
              <th style={{ textAlign: 'right' }}>Mức nộp</th>
              <th style={{ textAlign: 'center' }}>Bắt buộc</th>
              <th style={{ textAlign: 'center' }}>Ngày nộp</th>
              <th style={{ textAlign: 'right' }}>Số tiền nộp</th>
              <th style={{ textAlign: 'right' }}>Công nợ</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td colSpan="10" style={{ textAlign: 'center', padding: 24, color: '#94a3b8' }}>
                Không có dữ liệu khoản thu khác
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      {/* Tabs placeholder matching the image style slightly */}
      <div className="tabs" style={{ marginBottom: 12 }}>
        <div className="tab-btn active">Học phí</div>
        <div className="tab-btn">Môn học đăng ký</div>
        <div className="tab-btn">Danh sách khấu trừ</div>
      </div>

      <div className="card" style={{ overflowX: 'auto' }}>
        <table className="tbl" style={{ minWidth: 1600, fontSize: 12 }}>
          <thead>
            <tr style={{ background: '#f8fafc', color: '#1a6fb5', whiteSpace: 'nowrap' }}>
              <th style={{ textAlign: 'center' }}>STT</th>
              <th>Đợt</th>
              <th>Mã</th>
              <th>Mã LHP</th>
              <th>Nội dung</th>
              <th style={{ textAlign: 'center' }}>Số TC</th>
              <th style={{ textAlign: 'right' }}>Mức phí ban đầu</th>
              <th style={{ textAlign: 'right' }}>% Miễn giảm</th>
              <th style={{ textAlign: 'right' }}>Số tiền miễn giảm</th>
              <th style={{ textAlign: 'right' }}>Mức nộp</th>
              <th style={{ textAlign: 'center' }}>Trạng thái ĐK</th>
              <th style={{ textAlign: 'center' }}>Ngày nộp</th>
              <th style={{ textAlign: 'right' }}>Số tiền nộp</th>
              <th style={{ textAlign: 'right' }}>Khấu trừ (+)</th>
              <th style={{ textAlign: 'right' }}>Trừ nợ (-)</th>
              <th style={{ textAlign: 'right' }}>Công nợ</th>
              <th style={{ textAlign: 'center' }}>Trạng thái</th>
              <th style={{ textAlign: 'center' }}>Không truy cứu công nợ</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="18" style={{ textAlign: 'center', padding: 32 }}>Đang tải dữ liệu...</td></tr>
            ) : rows.length === 0 ? (
              <tr><td colSpan="18" style={{ textAlign: 'center', padding: 32 }}>Không có dữ liệu công nợ</td></tr>
            ) : (
              Object.keys(groups).map((semName) => {
                const groupRows = groups[semName];
                const semPaid = groupRows.reduce((s, r) => s + Number(r.soTienNop || 0), 0);
                const semTotal = groupRows.reduce((s, r) => s + Number(r.mucNop || 0), 0);
                
                return (
                  <React.Fragment key={semName}>
                    {/* Header Group */}
                    <tr style={{ background: '#fcfcfc' }}>
                      <td colSpan="18" style={{ fontWeight: 600, color: '#475569', borderBottom: '1px solid #e2e8f0' }}>
                        ▾ Đợt: {semName}
                      </td>
                    </tr>
                    {/* Rows */}
                    {groupRows.map((r, i) => {
                      const congNo = Number(r.mucNop || 0) - Number(r.soTienNop || 0);
                      return (
                        <tr key={`${r.classCode}-${i}`} style={{ whiteSpace: 'nowrap' }}>
                          <td style={{ textAlign: 'center', color: '#64748b' }}>{i + 1}</td>
                          <td style={{ color: '#64748b' }}>{r.semesterName}</td>
                          <td style={{ color: '#64748b' }}>{r.courseCode}</td>
                          <td style={{ color: '#1a6fb5' }}>{r.classCode}</td>
                          <td style={{ minWidth: 200 }}>{r.courseName}</td>
                          <td style={{ textAlign: 'center' }}>{r.credits}</td>
                          <td style={{ textAlign: 'right' }}>{fmt(r.mucNop)}</td>
                          <td style={{ textAlign: 'right' }}>0</td>
                          <td style={{ textAlign: 'right' }}>0</td>
                          <td style={{ textAlign: 'right', fontWeight: 600, color: '#334155' }}>{fmt(r.mucNop)}</td>
                          <td style={{ textAlign: 'center', color: '#64748b' }}>Đăng ký mới</td>
                          <td style={{ textAlign: 'center', color: '#64748b' }}>{r.paidDate || ''}</td>
                          <td style={{ textAlign: 'right' }}>{fmt(r.soTienNop)}</td>
                          <td style={{ textAlign: 'right' }}>0</td>
                          <td style={{ textAlign: 'right' }}>0</td>
                          <td style={{ textAlign: 'right', fontWeight: 600, color: congNo > 0 ? 'var(--red)' : '#334155' }}>
                            {fmt(congNo)}
                          </td>
                          <td style={{ textAlign: 'center' }}>
                            {r.isPaid === 1 ? (
                              <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 20, height: 20, borderRadius: '50%', background: '#22c55e', color: 'white', fontSize: 10 }}>✓</div>
                            ) : (
                              <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 20, height: 20, borderRadius: '50%', background: '#ef4444', color: 'white', fontSize: 10 }}>✕</div>
                            )}
                          </td>
                          <td style={{ textAlign: 'center' }}>
                            <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 20, height: 20, borderRadius: '50%', background: '#ef4444', color: 'white', fontSize: 10 }}>✕</div>
                          </td>
                        </tr>
                      );
                    })}
                    {/* Footer Group */}
                    <tr style={{ background: '#f8fafc', fontWeight: 600 }}>
                      <td colSpan="5"></td>
                      <td style={{ textAlign: 'center' }}>{groupRows.reduce((s, r) => s + (r.credits || 0), 0)}</td>
                      <td style={{ textAlign: 'right' }}>{fmt(semTotal)}</td>
                      <td></td>
                      <td></td>
                      <td style={{ textAlign: 'right' }}>{fmt(semTotal)}</td>
                      <td colSpan="2"></td>
                      <td style={{ textAlign: 'right' }}>{fmt(semPaid)}</td>
                      <td></td>
                      <td></td>
                      <td style={{ textAlign: 'right', color: semTotal - semPaid > 0 ? 'var(--red)' : 'inherit' }}>
                        {fmt(semTotal - semPaid)}
                      </td>
                      <td colSpan="2"></td>
                    </tr>
                  </React.Fragment>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {/* FOOTER SUMMARY */}
      <div style={{ 
        display: 'flex', justifyContent: 'space-between', padding: '16px 20px', 
        background: '#fffcf5', border: '1px solid #ffedd5', borderRadius: 8,
        fontSize: 13, fontWeight: 600 
      }}>
        <div style={{ color: '#ea580c' }}>
          Tổng nộp học phí: {fmt(sumPaid)}
        </div>
        <div style={{ color: '#ea580c' }}>
          Tổng nộp khoản thu khác: 0
        </div>
        <div style={{ color: '#ea580c' }}>
          Tổng công nợ học phí: {fmt(sumDebt)} {sumDebt > 0 && '(Thiếu tiền)'}
        </div>
        <div style={{ color: '#ea580c' }}>
          Tổng công nợ thu khác: 0
        </div>
      </div>
    </div>
  );
}