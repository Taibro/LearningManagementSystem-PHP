import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getPayments, mockPaymentSuccess } from '../../studentApi';

const fmt = (n) => n != null ? Number(n).toLocaleString('vi-VN') : '0';

export default function PaymentProcessing() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [payment, setPayment] = useState(null);
  const [loading, setLoading] = useState(true);
  const [timeLeft, setTimeLeft] = useState(600); // 10 mins
  const [verifying, setVerifying] = useState(false);

  const fetchPayment = () => {
    getPayments().then(list => {
      const p = list.find(x => x.id === Number(id));
      setPayment(p);
      setLoading(false);
    }).catch(() => setLoading(false));
  };

  useEffect(() => {
    fetchPayment();
  }, [id]);

  useEffect(() => {
    let timer;
    if (payment?.status === 'PENDING' && timeLeft > 0) {
      timer = setInterval(() => {
        setTimeLeft(prev => prev - 1);
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [payment, timeLeft]);

  const handleCheckPayment = () => {
    if (window.confirm('Bạn xác nhận đã chuyển khoản thành công? (Tính năng Demo)')) {
      setVerifying(true);
      mockPaymentSuccess(id).then(() => {
        fetchPayment();
        setVerifying(false);
      }).catch(err => {
        setVerifying(false);
        alert(err.response?.data?.message || 'Có lỗi xảy ra.');
      });
    }
  };

  if (loading) return <div style={{ padding: 40, textAlign: 'center' }}>Đang tải...</div>;
  if (!payment) return <div style={{ padding: 40, textAlign: 'center' }}>Không tìm thấy giao dịch</div>;

  const isPending = payment.status === 'PENDING';
  const isSuccess = payment.status === 'SUCCESS';
  
  // Format dates: paymentDate is array from backend like [2026, 5, 30, 18, 25, 0]
  const pDate = Array.isArray(payment.paymentDate) 
    ? new Date(payment.paymentDate[0], payment.paymentDate[1]-1, payment.paymentDate[2], payment.paymentDate[3], payment.paymentDate[4], payment.paymentDate[5]||0)
    : new Date(payment.paymentDate);

  const dateStr = pDate.toLocaleDateString('vi-VN') + ' ' + pDate.toLocaleTimeString('vi-VN');

  return (
    <div style={{ display: 'flex', justifyContent: 'center', padding: '40px 20px', background: '#f1f5f9', minHeight: '100vh' }}>
      
      <div style={{ width: 500, background: 'white', borderRadius: 12, boxShadow: '0 10px 40px #0001', overflow: 'hidden', position: 'relative' }}>
        {/* Background Watermark/Pattern */}
        <div style={{ position: 'absolute', inset: 0, opacity: 0.05, backgroundImage: 'url("https://www.transparenttextures.com/patterns/cubes.png")', pointerEvents: 'none' }} />

        <div style={{ padding: '32px 32px 16px', textAlign: 'center' }}>
          <div style={{ 
            width: 56, height: 56, borderRadius: '50%', background: isPending ? '#fbbf24' : isSuccess ? '#22c55e' : '#ef4444',
            color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, margin: '0 auto 16px',
            boxShadow: '0 4px 12px #0002'
          }}>
            {isPending ? '⏱' : isSuccess ? '✓' : '✕'}
          </div>
          <div style={{ color: isPending ? '#d97706' : isSuccess ? '#16a34a' : '#dc2626', fontWeight: 700, fontSize: 16, marginBottom: 8, letterSpacing: 1 }}>
            {isPending ? 'GIAO DỊCH ĐANG XỬ LÝ!' : isSuccess ? 'GIAO DỊCH THÀNH CÔNG!' : 'GIAO DỊCH ĐÃ HỦY!'}
          </div>
          <div style={{ fontSize: 32, fontWeight: 800, color: '#0f172a' }}>
            {fmt(payment.amount)}
          </div>
          <div style={{ fontSize: 13, color: '#64748b' }}>Số tiền thanh toán</div>
        </div>

        <div style={{ padding: '24px 32px' }}>
          <table style={{ width: '100%', fontSize: 14, lineHeight: 2.2 }}>
            <tbody>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Mã giao dịch:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>{payment.transactionCode}</td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b', verticalAlign: 'top' }}>Trạng thái:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: isPending ? '#d97706' : isSuccess ? '#16a34a' : '#dc2626', maxWidth: 200 }}>
                  {isPending ? 'Giao dịch đang được xử lý... Vui lòng đợi sau khoảng thời gian tối đa 10 phút!' : isSuccess ? 'Thành công' : 'Đã hủy'}
                </td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Ngày thực hiện:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>{dateStr}</td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Ngày thanh toán:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>{isSuccess ? dateStr : ''}</td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Ngân hàng:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>
                  {payment.paymentMethod === 'VISA' ? 'VIETCOMBANK' : payment.paymentMethod}
                </td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Mã sinh viên:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>2001216301</td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Tên sinh viên:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>Phan Sĩ Thịnh</td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Lớp học:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>14DHTH05</td>
              </tr>
              <tr style={{ borderBottom: '1px dashed #e2e8f0' }}>
                <td style={{ color: '#64748b' }}>Khoa:</td>
                <td style={{ textAlign: 'right', fontWeight: 500, color: '#334155' }}>Khoa Công nghệ thông tin</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div style={{ padding: '0 32px 32px' }}>
          <button 
            style={{ width: '100%', background: '#4f46e5', color: 'white', padding: '14px 0', border: 'none', borderRadius: 8, fontWeight: 600, fontSize: 15, cursor: 'pointer', boxShadow: '0 4px 12px #4f46e544' }}
            onClick={() => navigate('/online-payment')}
          >
            Thực hiện giao dịch khác
          </button>
          
          {isPending && (
            <div style={{ marginTop: 16, textAlign: 'center' }}>
              <button 
                onClick={handleCheckPayment}
                disabled={verifying}
                style={{ 
                  background: verifying ? '#94a3b8' : '#22c55e', 
                  color: 'white', 
                  padding: '12px 0', 
                  border: 'none', 
                  borderRadius: 8, 
                  fontWeight: 600, 
                  fontSize: 15, 
                  cursor: verifying ? 'wait' : 'pointer', 
                  width: '100%', 
                  boxShadow: '0 4px 12px #22c55e44' 
                }}
              >
                {verifying ? 'Đang kiểm tra...' : 'Tôi đã chuyển khoản thành công'}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
