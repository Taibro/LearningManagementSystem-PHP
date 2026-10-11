import React, { useState, useEffect } from 'react';
import { BarChart, FileText, Check, ClipboardList, CheckCircle2, XCircle, Search, X } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Attendance() {
  const [records, setRecords] = useState([]);
  const [toast, setToast] = useState(null);

  // Form states
  const [aModal, setAModal] = useState(false);
  const [currentRecord, setCurrentRecord] = useState({ 
    id: null, scheduleId: '', studentId: '', attendanceDate: new Date().toISOString().split('T')[0], status: 'PRESENT', note: '' 
  });

  useEffect(() => {
    fetchRecords();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchRecords = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/attendance`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setRecords(data);
      }
    } catch (error) {
      showToast('Lỗi tải danh sách điểm danh!', 'error');
    }
  };

  const handleSaveRecord = async () => {
    const method = currentRecord.id ? 'PUT' : 'POST';
    const url = currentRecord.id 
      ? `${API_BASE_URL}/school-admin/attendance/${currentRecord.id}`
      : `${API_BASE_URL}/school-admin/attendance`;

    const payload = {
      scheduleId: parseInt(currentRecord.scheduleId),
      studentId: parseInt(currentRecord.studentId),
      attendanceDate: currentRecord.attendanceDate,
      status: currentRecord.status,
      note: currentRecord.note
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
        showToast(currentRecord.id ? 'Cập nhật thành công!' : 'Thêm thành công!');
        setAModal(false);
        fetchRecords();
      } else {
        showToast('Lỗi khi lưu!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const openModal = (record = null) => {
    setCurrentRecord(record ? { ...record } : { 
      id: null, scheduleId: '', studentId: '', attendanceDate: new Date().toISOString().split('T')[0], status: 'PRESENT', note: '' 
    });
    setAModal(true);
  };

  // Tính toán số liệu thống kê tự động
  const countPresent = records.filter(r => r.status === 'PRESENT').length;
  const countLate = records.filter(r => r.status === 'LATE').length;
  const countAbsent = records.filter(r => r.status === 'ABSENT').length;
  const countTotal = records.length;

  const renderStatusBadge = (status) => {
    if (status === 'PRESENT') return <span className="badge b-green"><Check className="w-4 h-4 inline-block mr-2" /> PRESENT</span>;
    if (status === 'LATE') return <span className="badge b-amber">⏰ LATE</span>;
    if (status === 'ABSENT') return <span className="badge b-red"><X className="w-4 h-4 inline-block mr-2" /> ABSENT</span>;
    if (status === 'EXCUSED') return <span className="badge b-blue">EXCUSED</span>;
    return <span className="badge b-gray">{status}</span>;
  };

  const formatDate = (dateString) => {
    if (!dateString) return '—';
    return new Date(dateString).toLocaleDateString('vi-VN');
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
          <div className="ph-title">Quản lý Điểm danh</div>
          <div className="ph-sub">Tra cứu và chỉnh sửa điểm danh theo buổi học</div>
        </div>
        <button className="btn btn-blue" onClick={() => openModal()}>+ Thêm điểm danh</button>
      </div>
      
      <div className="card mb4">
        <div className="filter-bar">
          <select className="fc" style={{maxWidth:'240px'}}><option>Tất cả lớp</option></select>
          <input type="date" className="fc" style={{maxWidth:'150px'}} />
          <button className="btn btn-blue btn-sm"><Search className="w-4 h-4 inline-block mr-2" /> Tìm</button>
          <button className="btn btn-ghost btn-sm"><BarChart className="w-4 h-4 inline-block mr-2" /> Xuất Excel</button>
        </div>
      </div>

      <div className="grid4 mb4">
        <div className="stat" style={{cursor:'default'}}>
          <div className="stat-top" style={{background:'var(--green)'}}></div>
          <div className="stat-icon"><CheckCircle2 className="w-4 h-4 inline-block mr-2" /></div><div className="stat-label">Có mặt</div><div className="stat-num">{countPresent}</div>
        </div>
        <div className="stat" style={{cursor:'default'}}>
          <div className="stat-top" style={{background:'var(--amber)'}}></div>
          <div className="stat-icon">⏰</div><div className="stat-label">Đi trễ</div><div className="stat-num">{countLate}</div>
        </div>
        <div className="stat" style={{cursor:'default'}}>
          <div className="stat-top" style={{background:'var(--red)'}}></div>
          <div className="stat-icon"><XCircle className="w-4 h-4 inline-block mr-2" /></div><div className="stat-label">Vắng mặt</div><div className="stat-num">{countAbsent}</div>
        </div>
        <div className="stat" style={{cursor:'default'}}>
          <div className="stat-top" style={{background:'var(--blue-lt)'}}></div>
          <div className="stat-icon"><FileText className="w-4 h-4 inline-block mr-2" /></div><div className="stat-label">Tổng bản ghi</div><div className="stat-num">{countTotal}</div>
        </div>
      </div>

      <div className="card">
        <table className="tbl">
          <thead>
            <tr>
              <th>Ca học</th>
              <th>Sinh viên</th>
              <th>Ngày ĐD</th>
              <th>Trạng thái</th>
              <th>Ghi chú</th>
              <th>Lúc</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {records.map(r => (
              <tr key={r.id}>
                <td>{r.scheduleDetails || `Sch #${r.scheduleId}`}</td>
                <td>
                  <div style={{display:'flex', alignItems:'center', gap:'7px'}}>
                    <div className="av av-blue" style={{width:'26px', height:'26px', fontSize:'10px'}}>SV</div>
                    {r.studentName || r.studentCode || `ID: ${r.studentId}`}
                  </div>
                </td>
                <td>{formatDate(r.attendanceDate)}</td>
                <td>{renderStatusBadge(r.status)}</td>
                <td>{r.note || '—'}</td>
                <td style={{fontSize:'11px', color:'var(--muted)'}}>
                  {r.checkedAt ? new Date(r.checkedAt).toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'}) : '—'}
                </td>
                <td>
                  <button className="btn btn-ghost btn-xs" onClick={() => openModal(r)}>Sửa</button>
                </td>
              </tr>
            ))}
            {records.length === 0 && <tr><td colSpan="7" style={{textAlign:'center'}}>Chưa có bản ghi điểm danh nào</td></tr>}
          </tbody>
        </table>
      </div>

      {aModal && (
        <div className="ov open">
          <div className="modal" style={{width:'440px'}}>
            <div className="modal-hd">
              <span className="modal-title">{currentRecord.id ? <><ClipboardList className="w-4 h-4 inline-block mr-2" /> Chỉnh sửa Điểm danh</> : <><ClipboardList className="w-4 h-4 inline-block mr-2" /> Thêm Điểm danh</>}</span>
              <button className="close-btn" onClick={() => setAModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Mã SV (ID tạm)</label>
                  <input type="number" className="fc" value={currentRecord.studentId} onChange={e => setCurrentRecord({...currentRecord, studentId: e.target.value})} placeholder="ID Sinh viên" />
                </div>
                <div className="fg">
                  <label className="fl">Ca học (ID tạm)</label>
                  <input type="number" className="fc" value={currentRecord.scheduleId} onChange={e => setCurrentRecord({...currentRecord, scheduleId: e.target.value})} placeholder="ID Ca học" />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Ngày</label>
                  <input type="date" className="fc" value={currentRecord.attendanceDate} onChange={e => setCurrentRecord({...currentRecord, attendanceDate: e.target.value})} />
                </div>
                <div className="fg">
                  <label className="fl">Trạng thái</label>
                  <select className="fc" value={currentRecord.status} onChange={e => setCurrentRecord({...currentRecord, status: e.target.value})}>
                    <option value="PRESENT">PRESENT – Có mặt</option>
                    <option value="ABSENT">ABSENT – Vắng mặt</option>
                    <option value="LATE">LATE – Đi trễ</option>
                    <option value="EXCUSED">EXCUSED – Vắng có phép</option>
                  </select>
                </div>
              </div>
              <div className="fg">
                <label className="fl">Ghi chú</label>
                <textarea className="fc" rows="2" value={currentRecord.note} onChange={e => setCurrentRecord({...currentRecord, note: e.target.value})} placeholder="Lý do vắng, đi trễ..."></textarea>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setAModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveRecord}><Check className="w-4 h-4 inline-block mr-2" /> Cập nhật</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
