import React, { useState, useEffect } from 'react';
import { DollarSign, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Tuition() {
  const [invoices, setInvoices] = useState([]);
  const [toast, setToast] = useState(null);

  const [iModal, setIModal] = useState(false);
  const [currentInvoice, setCurrentInvoice] = useState({
    id: null, studentId: '', semesterId: '', totalAmount: '', dueDate: new Date().toISOString().split('T')[0], status: 'UNPAID'
  });

  useEffect(() => {
    fetchInvoices();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchInvoices = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/tuition-invoices`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setInvoices(data);
      }
    } catch (error) {
      showToast('Lỗi tải danh sách hóa đơn!', 'error');
    }
  };

  const handleSaveInvoice = async () => {
    const method = currentInvoice.id ? 'PUT' : 'POST';
    const url = currentInvoice.id 
      ? `${API_BASE_URL}/school-admin/tuition-invoices/${currentInvoice.id}`
      : `${API_BASE_URL}/school-admin/tuition-invoices`;

    const payload = {
      studentId: parseInt(currentInvoice.studentId),
      semesterId: parseInt(currentInvoice.semesterId),
      totalAmount: parseFloat(currentInvoice.totalAmount),
      dueDate: currentInvoice.dueDate,
      status: currentInvoice.status
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
        showToast(currentInvoice.id ? 'Cập nhật thành công!' : 'Tạo hóa đơn thành công!');
        setIModal(false);
        fetchInvoices();
      } else {
        showToast('Lỗi khi lưu hóa đơn!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const openModal = (invoice = null) => {
    setCurrentInvoice(invoice ? { ...invoice } : {
      id: null, studentId: '', semesterId: '', totalAmount: '', dueDate: new Date().toISOString().split('T')[0], status: 'UNPAID'
    });
    setIModal(true);
  };

  const renderStatusBadge = (status) => {
    if (status === 'PAID') return <span className="badge b-green">ĐÃ THU ĐỦ</span>;
    if (status === 'UNPAID') return <span className="badge b-red">CHƯA ĐÓNG</span>;
    if (status === 'PARTIAL') return <span className="badge b-amber">ĐÓNG 1 PHẦN</span>;
    if (status === 'OVERDUE') return <span className="badge b-gray">QUÁ HẠN</span>;
    return <span className="badge b-gray">{status}</span>;
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
          <div className="ph-title">Học phí &amp; Công nợ</div>
          <div className="ph-sub">Quản lý hóa đơn theo học kỳ</div>
        </div>
        <button className="btn btn-blue" onClick={() => openModal()}>+ Tạo hóa đơn</button>
      </div>
      
      <div className="card">
        {invoices.length === 0 ? (
          <div className="card-body" style={{textAlign:'center', padding:'50px', color:'var(--muted)'}}>
            <div style={{fontSize:'48px', marginBottom:'12px'}}><DollarSign className="w-4 h-4 inline-block mr-2" /></div>
            <div style={{fontSize:'16px', fontWeight:700, marginBottom:'8px'}}>Chưa có hóa đơn học phí</div>
            <div style={{fontSize:'13px'}}>Tạo hóa đơn mới cho sinh viên trong học kỳ hiện tại</div>
            <button className="btn btn-blue" style={{marginTop:'16px'}} onClick={() => openModal()}>+ Tạo hóa đơn đầu tiên</button>
          </div>
        ) : (
          <table className="tbl">
            <thead>
              <tr>
                <th>Mã HĐ</th>
                <th>Sinh viên</th>
                <th>Tổng học phí</th>
                <th>Đã đóng</th>
                <th>Còn nợ</th>
                <th>Hạn đóng</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {invoices.map(inv => {
                const debt = inv.totalAmount - inv.paidAmount;
                return (
                  <tr key={inv.id}>
                    <td style={{fontFamily:'monospace', color:'var(--muted)'}}>INV#{inv.id}</td>
                    <td style={{fontWeight:600}}>{inv.studentName || inv.studentCode || `SV ID: ${inv.studentId}`}</td>
                    <td style={{color:'var(--blue)', fontWeight:600}}>{inv.totalAmount.toLocaleString('vi-VN')} đ</td>
                    <td style={{color:'var(--green)'}}>{inv.paidAmount.toLocaleString('vi-VN')} đ</td>
                    <td style={{color: debt > 0 ? 'var(--red)' : 'var(--muted)', fontWeight: debt > 0 ? 700 : 400}}>
                      {debt > 0 ? debt.toLocaleString('vi-VN') + ' đ' : '0 đ'}
                    </td>
                    <td>{new Date(inv.dueDate).toLocaleDateString('vi-VN')}</td>
                    <td>{renderStatusBadge(inv.status)}</td>
                    <td>
                      <button className="btn btn-ghost btn-xs" onClick={() => openModal(inv)}>Sửa</button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {iModal && (
        <div className="ov open">
          <div className="modal" style={{width:'460px'}}>
            <div className="modal-hd">
              <span className="modal-title">{currentInvoice.id ? <><DollarSign className="w-4 h-4 inline-block mr-2" /> Sửa Hóa đơn học phí</> : <><DollarSign className="w-4 h-4 inline-block mr-2" /> Tạo Hóa đơn học phí</>}</span>
              <button className="close-btn" onClick={() => setIModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="fg">
                <label className="fl">ID Sinh viên</label>
                <input type="number" className="fc" value={currentInvoice.studentId} onChange={e => setCurrentInvoice({...currentInvoice, studentId: e.target.value})} placeholder="Nhập ID SV" />
              </div>
              <div className="fg">
                <label className="fl">ID Học kỳ</label>
                <input type="number" className="fc" value={currentInvoice.semesterId} onChange={e => setCurrentInvoice({...currentInvoice, semesterId: e.target.value})} placeholder="Nhập ID Học kỳ" />
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Tổng học phí (VNĐ)</label>
                  <input type="number" className="fc" value={currentInvoice.totalAmount} onChange={e => setCurrentInvoice({...currentInvoice, totalAmount: e.target.value})} placeholder="15000000" />
                </div>
                <div className="fg">
                  <label className="fl">Hạn đóng</label>
                  <input type="date" className="fc" value={currentInvoice.dueDate} onChange={e => setCurrentInvoice({...currentInvoice, dueDate: e.target.value})} />
                </div>
              </div>
              <div className="fg">
                <label className="fl">Trạng thái HĐ</label>
                <select className="fc" value={currentInvoice.status} onChange={e => setCurrentInvoice({...currentInvoice, status: e.target.value})}>
                  <option value="UNPAID">Chưa đóng</option>
                  <option value="PARTIAL">Đóng 1 phần</option>
                  <option value="PAID">Đã đóng đủ</option>
                  <option value="OVERDUE">Quá hạn</option>
                </select>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setIModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveInvoice}><Save className="w-4 h-4 inline-block mr-2" /> Lưu hóa đơn</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
