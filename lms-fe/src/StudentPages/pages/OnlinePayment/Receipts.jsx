import React, { useEffect, useState } from 'react';
import { getPayments, cancelPayment } from '../../studentApi';

const fmt = (n) => n != null ? Number(n).toLocaleString('vi-VN') : '0';

export default function Receipts() {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [detailModal, setDetailModal] = useState(null);
  const [cancelModal, setCancelModal] = useState(null);

  const fetchList = () => {
    setLoading(true);
    getPayments().then(res => {
      setPayments(res);
      setLoading(false);
    }).catch(() => setLoading(false));
  };

  useEffect(() => {
    fetchList();
  }, []);

  const handleCancel = () => {
    if (!cancelModal) return;
    cancelPayment(cancelModal.id).then(() => {
      setCancelModal(null);
      fetchList();
    }).catch(err => {
      const msg = err.response?.data?.message || 'Lỗi hệ thống';
      alert('Lỗi khi hủy giao dịch: ' + msg);
    });
  };

  const getStatusNode = (status) => {
    switch (status) {
      case 'PENDING': return <span style={{ color: '#ea580c' }}>Đang xử lý</span>;
      case 'SUCCESS': return <span style={{ color: '#16a34a' }}>Thành công</span>;
      case 'CANCELLED': 
      case 'FAILED': return <span style={{ color: '#dc2626' }}>Đã hủy / Thất bại</span>;
      default: return <span>{status}</span>;
    }
  };

  const getIcon = (isTrue) => isTrue 
    ? <div style={{ display: 'inline-flex', width: 20, height: 20, borderRadius: '50%', background: '#22c55e', color: 'white', alignItems: 'center', justifyContent: 'center', fontSize: 10 }}>✓</div>
    : <div style={{ display: 'inline-flex', width: 20, height: 20, borderRadius: '50%', background: '#ef4444', color: 'white', alignItems: 'center', justifyContent: 'center', fontSize: 10 }}>✕</div>;

  return (
    <div className="page active">
      <div className="page-title-bar" style={{ borderBottom: '1px solid var(--border)', paddingBottom: 16 }}>
        <div className="page-title" style={{ margin: 0, color: '#33267c' }}>Phiếu thu</div>
        <button className="btn btn-blue" style={{ background: '#64748b' }}>
          <i className="fa-solid fa-sync" style={{ marginRight: 8 }}></i> Tiếp tục thanh toán
        </button>
      </div>

      <div style={{ background: '#fee2e2', border: '1px solid #fca5a5', padding: '12px 16px', color: '#b91c1c', borderRadius: 4, margin: '16px 0', fontSize: 13, fontWeight: 600 }}>
        ! LƯU Ý: NẾU GIAO DỊCH THỰC HIỆN KHÔNG THÀNH CÔNG VUI LÒNG CHỌN "HỦY" ĐỂ TIẾP TỤC THANH TOÁN
      </div>

      <div className="card">
        <table className="tbl" style={{ width: '100%', fontSize: 13 }}>
          <thead>
            <tr style={{ background: '#3b3b75', color: 'white' }}>
              <th style={{ textAlign: 'center', width: 50, background: '#3b3b75', color: 'white' }}>STT</th>
              <th style={{ background: '#3b3b75', color: 'white' }}>Mã đơn</th>
              <th style={{ background: '#3b3b75', color: 'white' }}>Nội dung thu</th>
              <th style={{ textAlign: 'right', background: '#3b3b75', color: 'white' }}>Số tiền (VNĐ)</th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>Ngày thanh toán</th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>Đã thanh toán</th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>Đã cập nhật công nợ</th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>Trạng thái giao dịch</th>
              <th style={{ width: 120, background: '#3b3b75', color: 'white' }}></th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan="9" style={{ textAlign: 'center', padding: 20 }}>Đang tải...</td></tr>}
            {!loading && payments.length === 0 && <tr><td colSpan="9" style={{ textAlign: 'center', padding: 20 }}>Chưa có giao dịch nào</td></tr>}
            
            {payments.map((p, i) => {
              const pDate = Array.isArray(p.paymentDate)
                ? new Date(p.paymentDate[0], p.paymentDate[1]-1, p.paymentDate[2], p.paymentDate[3], p.paymentDate[4], p.paymentDate[5]||0)
                : new Date(p.paymentDate);
              const dateStr = pDate.toLocaleDateString('vi-VN') + ' ' + pDate.toLocaleTimeString('vi-VN');
              const isSuccess = p.status === 'SUCCESS';

              return (
                <tr key={p.id}>
                  <td style={{ textAlign: 'center' }}>{i + 1}</td>
                  <td style={{ color: '#475569', fontSize: 12 }}>
                    {p.transactionCode.substring(0, 16)}<br/>
                    {p.transactionCode.substring(16)}
                  </td>
                  <td>Thu học phí</td>
                  <td style={{ textAlign: 'right', fontWeight: 600, color: '#334155' }}>{fmt(p.amount)}</td>
                  <td style={{ textAlign: 'center', color: '#64748b' }}>{dateStr}</td>
                  <td style={{ textAlign: 'center' }}>{getIcon(isSuccess)}</td>
                  <td style={{ textAlign: 'center' }}>{getIcon(isSuccess)}</td>
                  <td style={{ textAlign: 'center', fontWeight: 600 }}>{getStatusNode(p.status)}</td>
                  <td style={{ textAlign: 'center' }}>
                    <div style={{ display: 'flex', gap: 6, justifyContent: 'center' }}>
                      {p.status === 'PENDING' && (
                        <button 
                          style={{ background: 'white', border: '1px solid #cbd5e1', padding: '4px 12px', borderRadius: 4, cursor: 'pointer', fontSize: 12, color: '#64748b' }}
                          onClick={() => setCancelModal(p)}
                        >
                          Hủy
                        </button>
                      )}
                      <button 
                        style={{ background: 'white', border: '1px solid #cbd5e1', padding: '4px 12px', borderRadius: 4, cursor: 'pointer', fontSize: 12, color: '#2563eb' }}
                        onClick={() => setDetailModal(p)}
                      >
                        Chi tiết
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Cancel Confirm Modal */}
      {cancelModal && (
        <div style={{ position: 'fixed', inset: 0, background: '#0004', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 999 }}>
          <div style={{ background: 'white', borderRadius: 8, width: 400, overflow: 'hidden', boxShadow: '0 10px 40px #0003' }}>
            <div style={{ padding: 20, textAlign: 'center', borderBottom: '1px solid var(--border)' }}>
              <div style={{ fontWeight: 600, fontSize: 16, marginBottom: 16, color: '#334155' }}>Xác nhận hủy giao dịch</div>
              <div style={{ color: '#475569', fontSize: 13, marginBottom: 12 }}>Bạn có chắc chắn hủy giao dịch?</div>
              <div style={{ fontSize: 13, textAlign: 'left', background: '#f8fafc', padding: 12, borderRadius: 6 }}>
                <div>Mã giao dịch: <strong>{cancelModal.transactionCode}</strong></div>
                <div>Nội dung: <strong>Thu học phí - {fmt(cancelModal.amount)}</strong></div>
              </div>
            </div>
            <div style={{ display: 'flex', padding: 12, gap: 12, justifyContent: 'center', background: '#f8fafc' }}>
              <button 
                style={{ padding: '8px 32px', background: 'white', border: '1px solid #cbd5e1', borderRadius: 4, cursor: 'pointer', fontWeight: 600, color: '#475569' }}
                onClick={() => setCancelModal(null)}
              >Hủy</button>
              <button 
                style={{ padding: '8px 32px', background: '#2563eb', border: 'none', borderRadius: 4, cursor: 'pointer', fontWeight: 600, color: 'white' }}
                onClick={handleCancel}
              >Xác nhận</button>
            </div>
          </div>
        </div>
      )}

      {/* Detail Modal */}
      {detailModal && (
        <div style={{ position: 'fixed', inset: 0, background: '#0004', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 999 }}>
          <div style={{ background: 'white', borderRadius: 8, width: 600, overflow: 'hidden', boxShadow: '0 10px 40px #0003' }}>
            <div style={{ padding: '16px 20px', background: '#3b3b75', color: 'white', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ fontWeight: 600 }}>Chi tiết giao dịch {detailModal.transactionCode.substring(0, 8)}...</div>
              <div style={{ cursor: 'pointer' }} onClick={() => setDetailModal(null)}>✕</div>
            </div>
            <div style={{ padding: 20 }}>
              <table className="tbl" style={{ width: '100%', fontSize: 13 }}>
                <thead>
                  <tr style={{ background: '#f8fafc', color: '#1a6fb5' }}>
                    <th style={{ textAlign: 'center' }}>STT</th>
                    <th>Mã LHP</th>
                    <th>Tên môn học</th>
                    <th style={{ textAlign: 'center' }}>Số TC</th>
                    <th style={{ textAlign: 'right' }}>Số tiền (VNĐ)</th>
                  </tr>
                </thead>
                <tbody>
                  {(() => {
                    try {
                      const courses = JSON.parse(detailModal.courseData || '[]');
                      if (courses.length === 0) return <tr><td colSpan="5" style={{ textAlign: 'center', padding: 20 }}>Không có dữ liệu chi tiết</td></tr>;
                      return courses.map((c, i) => (
                        <tr key={i}>
                          <td style={{ textAlign: 'center' }}>{i + 1}</td>
                          <td style={{ color: '#1a6fb5' }}>{c.classCode}</td>
                          <td>{c.courseName}</td>
                          <td style={{ textAlign: 'center' }}>{c.credits}</td>
                          <td style={{ textAlign: 'right', fontWeight: 600 }}>{fmt(c.amount)}</td>
                        </tr>
                      ));
                    } catch (e) {
                      return <tr><td colSpan="5" style={{ textAlign: 'center' }}>Dữ liệu không hợp lệ</td></tr>;
                    }
                  })()}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
