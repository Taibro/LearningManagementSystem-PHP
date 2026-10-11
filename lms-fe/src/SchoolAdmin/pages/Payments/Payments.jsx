import React, { useState, useEffect } from 'react';
import { Receipt, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Payments() {
  const [payments, setPayments] = useState([]);
  const [toast, setToast] = useState(null);
  const [pModal, setPModal] = useState(false);

  const [currentPayment, setCurrentPayment] = useState({
    id: null, invoiceId: '', amount: '', paymentMethod: 'BANK_TRANSFER', paymentDate: new Date().toISOString().slice(0, 16), transactionCode: '', status: 'SUCCESS', note: ''
  });

  useEffect(() => {
    fetchPayments();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchPayments = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/payments`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setPayments(data);
      }
    } catch (error) {
      showToast('Lỗi tải danh sách phiếu thu!', 'error');
    }
  };

  const handleSavePayment = async () => {
    const method = currentPayment.id ? 'PUT' : 'POST';
    const url = currentPayment.id 
      ? `${API_BASE_URL}/school-admin/payments/${currentPayment.id}`
      : `${API_BASE_URL}/school-admin/payments`;

    const payload = {
      invoiceId: parseInt(currentPayment.invoiceId),
      amount: parseFloat(currentPayment.amount),
      paymentMethod: currentPayment.paymentMethod,
      transactionCode: currentPayment.transactionCode,
      paymentDate: currentPayment.paymentDate,
      status: currentPayment.status,
      note: currentPayment.note
    };

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast(currentPayment.id ? 'Cập nhật phiếu thu thành công!' : 'Tạo phiếu thu thành công!');
        setPModal(false);
        fetchPayments();
      } else {
        showToast('Lỗi khi lưu phiếu thu!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const openModal = (payment = null) => {
    setCurrentPayment(payment ? { 
      ...payment, 
      paymentDate: payment.paymentDate ? payment.paymentDate.slice(0, 16) : new Date().toISOString().slice(0, 16) 
    } : {
      id: null, invoiceId: '', amount: '', paymentMethod: 'BANK_TRANSFER', paymentDate: new Date().toISOString().slice(0, 16), transactionCode: '', status: 'SUCCESS', note: ''
    });
    setPModal(true);
  };

  const renderStatusBadge = (status) => {
    if (status === 'SUCCESS') return <span className="badge b-green">THÀNH CÔNG</span>;
    if (status === 'FAILED') return <span className="badge b-red">THẤT BẠI</span>;
    if (status === 'PENDING') return <span className="badge b-amber">ĐANG CHỜ</span>;
    return <span className="badge b-gray">{status}</span>;
  };

  const renderMethodBadge = (method) => {
    if (method === 'CASH') return <span className="badge b-green">TIỀN MẶT</span>;
    if (method === 'BANK_TRANSFER') return <span className="badge b-blue">CHUYỂN KHOẢN</span>;
    if (method === 'CREDIT_CARD') return <span className="badge b-purple">THẺ TÍN DỤNG</span>;
    if (method === 'E_WALLET') return <span className="badge b-amber">VÍ ĐIỆN TỬ</span>;
    return <span className="badge b-gray">{method}</span>;
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
          <div className="ph-title">Phiếu thu</div>
          <div className="ph-sub">Lịch sử giao dịch thanh toán</div>
        </div>
        <button className="btn btn-blue" onClick={() => openModal()}>+ Ghi nhận thanh toán</button>
      </div>

      <div className="card">
        {payments.length === 0 ? (
          <div className="card-body" style={{textAlign:'center', padding:'50px', color:'var(--muted)'}}>
            <div style={{fontSize:'48px', marginBottom:'12px'}}><Receipt className="w-4 h-4 inline-block mr-2" /></div>
            <div>Chưa có giao dịch thanh toán nào</div>
          </div>
        ) : (
          <table className="tbl">
            <thead>
              <tr>
                <th>Mã GD</th>
                <th>Mã Hóa đơn</th>
                <th>Sinh viên</th>
                <th>Số tiền thu</th>
                <th>Phương thức</th>
                <th>Ngày giờ</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {payments.map(p => (
                <tr key={p.id}>
                  <td style={{fontFamily:'monospace'}}>{p.transactionCode || `PT#${p.id}`}</td>
                  <td style={{color:'var(--muted)'}}>INV#{p.invoiceId}</td>
                  <td style={{fontWeight:600}}>{p.studentName || `SV ẩn danh`}</td>
                  <td style={{color:'var(--green)', fontWeight:700}}>+ {p.amount.toLocaleString('vi-VN')} đ</td>
                  <td>{renderMethodBadge(p.paymentMethod)}</td>
                  <td style={{fontSize:'12px', color:'var(--muted)'}}>
                    {new Date(p.paymentDate).toLocaleString('vi-VN')}
                  </td>
                  <td>{renderStatusBadge(p.status)}</td>
                  <td>
                    <button className="btn btn-ghost btn-xs" onClick={() => openModal(p)}>Sửa</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {pModal && (
        <div className="ov open">
          <div className="modal" style={{width:'460px'}}>
            <div className="modal-hd">
              <span className="modal-title">{currentPayment.id ? <><Receipt className="w-4 h-4 inline-block mr-2" /> Sửa Phiếu thu</> : <><Receipt className="w-4 h-4 inline-block mr-2" /> Ghi nhận Phiếu thu</>}</span>
              <button className="close-btn" onClick={() => setPModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="grid2">
                <div className="fg">
                  <label className="fl">ID Hóa đơn nợ</label>
                  <input type="number" className="fc" value={currentPayment.invoiceId} onChange={e => setCurrentPayment({...currentPayment, invoiceId: e.target.value})} placeholder="ID Invoice" />
                </div>
                <div className="fg">
                  <label className="fl">Số tiền thu (VNĐ)</label>
                  <input type="number" className="fc" value={currentPayment.amount} onChange={e => setCurrentPayment({...currentPayment, amount: e.target.value})} placeholder="1500000" />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Hình thức</label>
                  <select className="fc" value={currentPayment.paymentMethod} onChange={e => setCurrentPayment({...currentPayment, paymentMethod: e.target.value})}>
                    <option value="BANK_TRANSFER">Chuyển khoản</option>
                    <option value="CASH">Tiền mặt</option>
                    <option value="CREDIT_CARD">Thẻ tín dụng</option>
                    <option value="E_WALLET">Ví điện tử</option>
                  </select>
                </div>
                <div className="fg">
                  <label className="fl">Mã giao dịch (Txn)</label>
                  <input className="fc" value={currentPayment.transactionCode} onChange={e => setCurrentPayment({...currentPayment, transactionCode: e.target.value})} placeholder="MBBANK-1234..." />
                </div>
              </div>
              <div className="fg">
                <label className="fl">Thời gian thanh toán</label>
                <input type="datetime-local" className="fc" value={currentPayment.paymentDate} onChange={e => setCurrentPayment({...currentPayment, paymentDate: e.target.value})} />
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Trạng thái</label>
                  <select className="fc" value={currentPayment.status} onChange={e => setCurrentPayment({...currentPayment, status: e.target.value})}>
                    <option value="SUCCESS">Thành công</option>
                    <option value="PENDING">Đang chờ</option>
                    <option value="FAILED">Thất bại</option>
                  </select>
                </div>
                <div className="fg">
                  <label className="fl">Ghi chú</label>
                  <input className="fc" value={currentPayment.note} onChange={e => setCurrentPayment({...currentPayment, note: e.target.value})} placeholder="Ghi chú thêm..." />
                </div>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setPModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSavePayment}><Save className="w-4 h-4 inline-block mr-2" /> Xác nhận thu tiền</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
