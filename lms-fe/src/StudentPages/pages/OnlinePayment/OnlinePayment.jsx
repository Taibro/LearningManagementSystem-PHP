import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getDebtDetail, getSemesters, createPayment, getPayments } from '../../studentApi';

const fmt = (n) => n != null ? Number(n).toLocaleString('vi-VN') : '0';

const BANKS = [
  { id: 'sacombank', name: 'Sacombank', logo: 'https://cdn.haitrieu.com/wp-content/uploads/2022/01/Logo-Sacombank.png' },
  { id: 'agri', name: 'Agribank', logo: 'https://cdn.haitrieu.com/wp-content/uploads/2022/01/Logo-Agribank-V.png' },
  { id: 'vcb', name: 'Vietcombank', logo: 'https://cdn.haitrieu.com/wp-content/uploads/2022/02/Logo-Vietcombank.png' },
  { id: 'ocb', name: 'OCB', logo: 'https://cdn.haitrieu.com/wp-content/uploads/2022/02/Logo-OCB.png' },
];

export default function OnlinePayment() {
  const navigate = useNavigate();
  const [rows, setRows] = useState([]);
  const [semesters, setSemesters] = useState([]);
  const [semId, setSemId] = useState('');
  const [loading, setLoading] = useState(true);
  const [checked, setChecked] = useState({});
  const [bank, setBank] = useState('');
  const [qrModal, setQrModal] = useState(null); // { transactionCode, amount, paymentId, profile }
  const [timeLeft, setTimeLeft] = useState(1800); // 30 mins

  useEffect(() => {
    getSemesters().then(setSemesters).catch(() => {});
    // Assuming student info is in localStorage for demo
  }, []);

  useEffect(() => {
    setLoading(true);
    Promise.all([getDebtDetail(semId || 0), getPayments()])
      .then(([debtData, payments]) => {
        const pendingPayments = payments.filter(p => p.status === 'PENDING');
        let lockedClassCodes = new Set();
        pendingPayments.forEach(p => {
          try {
            const courseData = JSON.parse(p.courseData || '[]');
            courseData.forEach(c => lockedClassCodes.add(c.classCode));
          } catch (e) {}
        });

        const filteredDebt = (debtData || []).filter(r => !lockedClassCodes.has(r.classCode));
        setRows(filteredDebt);
        setChecked({});
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, [semId]);

  // Timer for QR
  useEffect(() => {
    let timer;
    if (qrModal && timeLeft > 0) {
      timer = setInterval(() => setTimeLeft(prev => prev - 1), 1000);
    }
    return () => clearInterval(timer);
  }, [qrModal, timeLeft]);

  const unpaid = rows.filter(r => r.isPaid === 0);

  const toggleAll = (val) => {
    const next = {};
    unpaid.forEach((r, idx) => { next[`${r.classCode}-${idx}`] = val; });
    setChecked(next);
  };

  const allChecked = unpaid.length > 0 && unpaid.every((r, idx) => checked[`${r.classCode}-${idx}`]);
  const selectedRows = unpaid.filter((r, idx) => checked[`${r.classCode}-${idx}`]);
  const totalSelected = selectedRows.reduce((s, r) => s + (Number(r.mucNop || 0) - Number(r.soTienNop || 0)), 0);

  const handlePay = async () => {
    if (!bank) { alert('Vui lòng chọn ngân hàng thanh toán.'); return; }
    if (!selectedRows.length) { alert('Vui lòng chọn ít nhất một khoản.'); return; }
    
    // Tạo Giao dịch
    try {
      const payload = {
        semesterId: semId || (unpaid.length > 0 ? unpaid[0].semesterId : 0),
        paymentMethod: bank === 'vcb' ? 'VISA' : 'BANK_TRANSFER',
        totalAmount: totalSelected,
        courses: selectedRows.map(r => ({
          classCode: r.classCode,
          courseCode: r.courseCode,
          courseName: r.courseName,
          credits: r.credits,
          amount: Number(r.mucNop || 0) - Number(r.soTienNop || 0)
        }))
      };
      const res = await createPayment(payload);
      
      setQrModal({
        paymentId: res.id,
        transactionCode: res.transactionCode,
        amount: totalSelected,
        bankName: BANKS.find(b => b.id === bank).name
      });
      setTimeLeft(1798); // ~30 mins
    } catch (err) {
      alert('Lỗi khi tạo giao dịch.');
    }
  };

  const closeQR = () => {
    if (qrModal) {
      navigate(`/payment-processing/${qrModal.paymentId}`);
    }
  };

  const handleDownloadQR = () => {
    if (!qrModal) return;
    const qrUrl = `https://img.vietqr.io/image/vcb-1041516278-compact2.png?amount=1000&addInfo=${qrModal.transactionCode}&accountName=PHAN%20SI%20THINH`;
    
    // Create an invisible anchor tag to trigger download
    fetch(qrUrl)
      .then(response => response.blob())
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.style.display = 'none';
        a.href = url;
        a.download = `QR_ThanhToan_${qrModal.transactionCode}.png`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
      })
      .catch(err => console.error('Lỗi khi tải QR:', err));
  };

  // Secret trick for Demo
  const handleSecretDemoSuccess = () => {
    if (!qrModal) return;
    // Call the force-success API
    fetch(`http://localhost:8080/api/student/payment/${qrModal.paymentId}/force-success`)
      .then(res => {
        if(res.ok) {
           // Close QR modal, which will navigate to PaymentProcessing, which will then see SUCCESS
           closeQR();
        }
      });
  };

  useEffect(() => {
    const handleKeyDown = (e) => {
      // Secret shortcut: Shift + S
      if (e.shiftKey && (e.key === 'S' || e.key === 's') && qrModal) {
        handleSecretDemoSuccess();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [qrModal]);

  return (
    <div className="page active">
      <div className="page-title-bar" style={{ borderBottom: '1px solid var(--border)', paddingBottom: 16 }}>
        <div className="page-title" style={{ margin: 0, color: '#33267c' }}>Thanh toán trực tuyến</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 13 }}>Đợt</span>
          <select
            className="form-ctrl"
            style={{ width: 180 }}
            value={semId}
            onChange={e => setSemId(e.target.value)}
          >
            <option value="">Tất cả</option>
            {semesters.map(s => (
              <option key={s.id} value={s.id}>{s.name}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="card" style={{ marginTop: 16 }}>
        <table className="tbl" style={{ width: '100%', fontSize: 13 }}>
          <thead>
            <tr style={{ background: '#3b3b75', color: 'white' }}>
              <th style={{ width: 40, textAlign: 'center', background: '#3b3b75' }}>
                <input
                  type="checkbox"
                  checked={allChecked}
                  onChange={e => toggleAll(e.target.checked)}
                  disabled={unpaid.length === 0}
                />
              </th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>STT</th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>Mã</th>
              <th style={{ background: '#3b3b75', color: 'white' }}>Nội dung thu</th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>Tín chỉ</th>
              <th style={{ textAlign: 'center', background: '#3b3b75', color: 'white' }}>Bắt buộc</th>
              <th style={{ textAlign: 'right', background: '#3b3b75', color: 'white' }}>Số tiền (VNĐ)</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr><td colSpan="7" style={{ textAlign: 'center', padding: 28 }}>Đang tải...</td></tr>
            )}
            {!loading && unpaid.length === 0 && (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: 32 }}>Không có dữ liệu</td>
              </tr>
            )}
            {unpaid.map((r, i) => {
              const debt = Number(r.mucNop || 0) - Number(r.soTienNop || 0);
              const key = `${r.classCode}-${i}`;
              return (
                <tr key={key} style={{ cursor: 'pointer', background: checked[key] ? '#eff6ff' : 'white' }} onClick={() => setChecked(prev => ({ ...prev, [key]: !prev[key] }))}>
                  <td style={{ textAlign: 'center' }} onClick={e => e.stopPropagation()}>
                    <input
                      type="checkbox"
                      checked={!!checked[key]}
                      onChange={e => setChecked(prev => ({ ...prev, [key]: e.target.checked }))}
                    />
                  </td>
                  <td style={{ textAlign: 'center' }}>{i + 1}</td>
                  <td style={{ textAlign: 'center', color: '#1a6fb5' }}>{r.courseCode}</td>
                  <td style={{ color: '#475569' }}>{r.courseName}</td>
                  <td style={{ textAlign: 'center' }}>{r.credits}</td>
                  <td style={{ textAlign: 'center' }}>
                    <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 18, height: 18, borderRadius: '50%', background: '#22c55e', color: 'white', fontSize: 10 }}>✓</div>
                  </td>
                  <td style={{ textAlign: 'right', fontWeight: 600, color: '#334155' }}>{fmt(debt)}</td>
                </tr>
              );
            })}
            {!loading && unpaid.length > 0 && (
              <tr style={{ background: '#f8fafc' }}>
                <td colSpan="6" style={{ textAlign: 'right', fontWeight: 600, color: '#475569' }}>Tổng thanh toán:</td>
                <td style={{ textAlign: 'right', fontWeight: 700, color: '#334155' }}>{fmt(totalSelected)}</td>
              </tr>
            )}
          </tbody>
        </table>

        {/* Ghi chú */}
        <div style={{ padding: '16px 20px', fontSize: 13, lineHeight: 1.8, color: '#334155', borderTop: '1px solid var(--border)', background: '#fdfdfd' }}>
          <div>1. Để thanh toán trực tuyến qua ngân hàng <strong style={{ color: '#ea580c' }}>thẻ ATM</strong> phải đăng ký <strong style={{ color: '#ea580c' }}>Thanh toán online</strong>.</div>
          <div>2. Vui lòng kiểm tra <strong style={{ color: '#ea580c' }}>HẠN MỨC THẺ</strong> trước khi thanh toán</div>
          <div>3. Xem hướng dẫn thanh toán <span style={{ color: '#2563eb', cursor: 'pointer' }}>tại đây</span></div>
          <div>4. Để hủy giao dịch chờ gạch nợ, vui lòng bấm <span style={{ color: '#2563eb', cursor: 'pointer' }}>vào đây</span>.</div>
          <div>5. Khuyến cáo thanh toán qua <strong style={{ color: '#ea580c' }}>QR-Code</strong>, thẻ ATM nội địa.</div>
        </div>

        {/* Ngân hàng & Thanh toán */}
        <div style={{ borderTop: '1px solid var(--border)', background: '#fbfbfb', padding: '20px' }}>
          <div style={{ fontWeight: 600, color: '#475569', marginBottom: 16 }}>Chọn ngân hàng thanh toán</div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
              {BANKS.map(b => (
                <div
                  key={b.id}
                  onClick={() => setBank(b.id)}
                  style={{
                    cursor: 'pointer',
                    border: bank === b.id ? `2px solid #ea580c` : '1px dashed #cbd5e1',
                    borderRadius: 6, padding: '8px 16px',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    width: 120, height: 48, background: 'white',
                  }}
                >
                  <img src={b.logo} alt={b.name} style={{ maxHeight: 24, maxWidth: '100%' }} />
                </div>
              ))}
            </div>
            <button
              style={{
                background: '#ea580c', color: 'white', border: 'none',
                padding: '12px 32px', fontSize: 14, fontWeight: 600,
                borderRadius: 4, cursor: 'pointer', height: 48
              }}
              onClick={handlePay}
            >
              THANH TOÁN
            </button>
          </div>
        </div>
      </div>

      {/* Modal QR Code */}
      {qrModal && (
        <div style={{ position: 'fixed', inset: 0, background: '#0008', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 9999, padding: '20px' }}>
          <div style={{ background: 'white', borderRadius: 8, padding: '20px', width: 450, maxHeight: '90vh', overflowY: 'auto', boxShadow: '0 20px 60px #0004', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            <div style={{ fontWeight: 600, fontSize: 15, marginBottom: 8, color: '#334155', textAlign: 'center' }}>
              Quét bằng ứng dụng ngân hàng để thanh toán
            </div>
            <div style={{ fontSize: 13, marginBottom: 16 }}>
              Giao dịch hết hạn sau <strong style={{ background: '#ef4444', color: 'white', padding: '2px 4px', borderRadius: 2 }}>{Math.floor(timeLeft / 60)}</strong> : <strong style={{ background: '#ef4444', color: 'white', padding: '2px 4px', borderRadius: 2 }}>{(timeLeft % 60).toString().padStart(2, '0')}</strong>
            </div>

            <div style={{ border: '2px solid #ef4444', borderRadius: 12, padding: 20, position: 'relative', marginBottom: 16 }}>
              {/* Fake corner markers */}
              <div style={{ position: 'absolute', top: -2, left: -2, width: 20, height: 20, borderTop: '4px solid #ef4444', borderLeft: '4px solid #ef4444' }} />
              <div style={{ position: 'absolute', top: -2, right: -2, width: 20, height: 20, borderTop: '4px solid #ef4444', borderRight: '4px solid #ef4444' }} />
              <div style={{ position: 'absolute', bottom: -2, left: -2, width: 20, height: 20, borderBottom: '4px solid #ef4444', borderLeft: '4px solid #ef4444' }} />
              <div style={{ position: 'absolute', bottom: -2, right: -2, width: 20, height: 20, borderBottom: '4px solid #ef4444', borderRight: '4px solid #ef4444' }} />
              
              <div 
                style={{ textAlign: 'center', marginBottom: 8, fontWeight: 700, color: '#0f172a', fontSize: 18, cursor: 'default' }}
                onDoubleClick={handleSecretDemoSuccess}
              >
                VIET<span style={{ color: '#ef4444' }}>QR</span> / MoMo
              </div>
              <img 
                src={`https://img.vietqr.io/image/vcb-1041516278-compact2.png?amount=1000&addInfo=${qrModal.transactionCode}&accountName=PHAN%20SI%20THINH`} 
                alt="QR Code" 
                style={{ width: '100%', height: 'auto', borderRadius: 8 }} 
              />
              <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', marginTop: 8 }}>
                <img src="https://cdn.haitrieu.com/wp-content/uploads/2022/10/Logo-Napas.png" alt="Napas" style={{ height: 20 }} />
                <span style={{ marginLeft: 8, fontSize: 12, fontWeight: 600, color: '#2563eb' }}>Quét bằng MoMo hoặc App Ngân hàng</span>
              </div>
            </div>

            <table style={{ width: '100%', fontSize: 13, marginBottom: 20 }}>
              <tbody>
                <tr><td style={{ color: '#64748b', paddingBottom: 4 }}>Mã tra cứu:</td><td style={{ textAlign: 'right', fontWeight: 600, color: '#334155', paddingBottom: 4 }}>{qrModal.transactionCode} 📋</td></tr>
                <tr><td style={{ color: '#64748b', paddingBottom: 4 }}>Ngân hàng:</td><td style={{ textAlign: 'right', fontWeight: 600, color: '#334155', paddingBottom: 4 }}>{qrModal.bankName}</td></tr>
                <tr><td style={{ color: '#64748b', paddingBottom: 4 }}>Tên tài khoản:</td><td style={{ textAlign: 'right', fontWeight: 600, color: '#334155', paddingBottom: 4 }}>PHAN SI THINH</td></tr>
                <tr><td style={{ color: '#64748b', paddingBottom: 4 }}>Số tiền thực tế:</td><td style={{ textAlign: 'right', fontWeight: 700, color: '#ea580c', fontSize: 15, paddingBottom: 4 }}>{fmt(qrModal.amount)} VNĐ</td></tr>
                <tr><td style={{ color: '#64748b', paddingBottom: 4 }}>Số tiền Demo (Thử nghiệm):</td><td style={{ textAlign: 'right', fontWeight: 700, color: '#16a34a', fontSize: 15, paddingBottom: 4 }}>1.000 VNĐ</td></tr>
                <tr><td style={{ color: '#64748b' }}>Mã GD:</td><td style={{ textAlign: 'right', fontWeight: 600, color: '#334155' }}>{qrModal.transactionCode}</td></tr>
              </tbody>
            </table>

            <div style={{ display: 'flex', gap: 12 }}>
              <button 
                onClick={handleDownloadQR}
                style={{ background: '#1e3a8a', color: 'white', border: 'none', padding: '8px 24px', borderRadius: 4, fontWeight: 600, cursor: 'pointer' }}
              >
                Tải QR-Code
              </button>
              <button style={{ background: 'white', color: '#475569', border: '1px solid #cbd5e1', padding: '8px 24px', borderRadius: 4, fontWeight: 600, cursor: 'pointer' }} onClick={closeQR}>
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}