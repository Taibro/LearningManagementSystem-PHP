import React, { useState, useEffect } from 'react';
import { Upload } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Notifications() {
  const [notifications, setNotifications] = useState([]);
  const [toast, setToast] = useState(null);
  const [nModal, setNModal] = useState(false);

  const [currentNotif, setCurrentNotif] = useState({
    userId: '', title: '', body: '', type: 'SYSTEM'
  });

  useEffect(() => {
    fetchNotifications();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchNotifications = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/notifications`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setNotifications(data);
      }
    } catch (error) {
      showToast('Lỗi tải danh sách thông báo!', 'error');
    }
  };

  const handleSaveNotification = async () => {
    const payload = {
      userId: parseInt(currentNotif.userId),
      title: currentNotif.title,
      body: currentNotif.body,
      type: currentNotif.type
    };

    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/notifications`, {
        
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast('Gửi thông báo thành công!');
        setNModal(false);
        fetchNotifications();
      } else {
        showToast('Lỗi khi gửi thông báo!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDelete = async (id) => {
    try {
      await fetch(`${API_BASE_URL}/school-admin/notifications/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      showToast('Đã xóa thông báo!');
      fetchNotifications();
    } catch (err) {
      showToast('Lỗi xóa!', 'error');
    }
  };

  const handleMarkRead = async (id) => {
    try {
      await fetch(`${API_BASE_URL}/school-admin/notifications/${id}/read`, {
        
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      fetchNotifications();
    } catch (err) {}
  };

  const renderTypeBadge = (type) => {
    if (type === 'SCHEDULE_CHANGE') return <span className="badge b-amber">LỊCH HỌC</span>;
    if (type === 'GRADE') return <span className="badge b-green">ĐIỂM SỐ</span>;
    if (type === 'ENROLLMENT') return <span className="badge b-blue">GHI DANH</span>;
    if (type === 'SYSTEM') return <span className="badge b-gray">HỆ THỐNG</span>;
    if (type === 'REMINDER') return <span className="badge b-purple">NHẮC NHỞ</span>;
    return <span className="badge b-gray">{type}</span>;
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
        <div><div className="ph-title">Quản lý Thông báo</div></div>
        <button className="btn btn-blue" onClick={() => setNModal(true)}>📢 Gửi thông báo</button>
      </div>

      <div className="card">
        <table className="tbl">
          <thead>
            <tr>
              <th>#</th>
              <th>Người nhận</th>
              <th>Tiêu đề</th>
              <th>Loại</th>
              <th>Đã đọc</th>
              <th>Thời gian</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {notifications.map((n, idx) => (
              <tr key={n.id} style={{ background: !n.isRead ? '#f8fafc' : 'transparent' }}>
                <td style={{color:'var(--muted)'}}>{idx + 1}</td>
                <td>{n.userName || `User ID: ${n.userId}`}</td>
                <td style={{fontWeight:600}}>{n.title}</td>
                <td>{renderTypeBadge(n.type)}</td>
                <td>
                  {n.isRead 
                    ? <span className="badge b-green">Đã đọc</span> 
                    : <span className="badge b-red" style={{cursor:'pointer'}} onClick={() => handleMarkRead(n.id)}>Chưa đọc (click)</span>}
                </td>
                <td style={{fontSize:'11px', color:'var(--muted)'}}>
                  {new Date(n.createdAt).toLocaleString('vi-VN')}
                </td>
                <td>
                  <button className="btn btn-danger btn-xs" onClick={() => handleDelete(n.id)}>Xóa</button>
                </td>
              </tr>
            ))}
            {notifications.length === 0 && <tr><td colSpan="7" style={{textAlign:'center'}}>Chưa có thông báo nào</td></tr>}
          </tbody>
        </table>
      </div>

      {nModal && (
        <div className="ov open">
          <div className="modal">
            <div className="modal-hd"><span className="modal-title">📢 Gửi Thông báo</span><button className="close-btn" onClick={() => setNModal(false)}>×</button></div>
            <div className="modal-body">
              <div className="grid2">
                <div className="fg">
                  <label className="fl">ID Người nhận</label>
                  <input type="number" className="fc" value={currentNotif.userId} onChange={e => setCurrentNotif({...currentNotif, userId: e.target.value})} placeholder="Nhập ID User" />
                </div>
                <div className="fg">
                  <label className="fl">Loại thông báo</label>
                  <select className="fc" value={currentNotif.type} onChange={e => setCurrentNotif({...currentNotif, type: e.target.value})}>
                    <option value="SCHEDULE_CHANGE">Thay đổi lịch</option>
                    <option value="GRADE">Điểm số</option>
                    <option value="ENROLLMENT">Đăng ký học</option>
                    <option value="SYSTEM">Hệ thống</option>
                    <option value="REMINDER">Nhắc nhở</option>
                  </select>
                </div>
              </div>
              <div className="fg">
                <label className="fl">Tiêu đề</label>
                <input className="fc" value={currentNotif.title} onChange={e => setCurrentNotif({...currentNotif, title: e.target.value})} placeholder="VD: Lịch học ngày 25/04 thay đổi" />
              </div>
              <div className="fg">
                <label className="fl">Nội dung</label>
                <textarea className="fc" rows="4" value={currentNotif.body} onChange={e => setCurrentNotif({...currentNotif, body: e.target.value})} placeholder="Nội dung chi tiết của thông báo..."></textarea>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setNModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveNotification}><Upload className="w-4 h-4 inline-block mr-2" /> Gửi ngay</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
