import React, { useState, useEffect } from 'react';
import { AlertTriangle, Save, CheckCircle2, XCircle, RefreshCw } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const getAdminToken = () => localStorage.getItem('adminToken');

export default function Exceptions() {
  const [exceptions, setExceptions] = useState([]);
  const [schedules, setSchedules] = useState([]);
  const [pendingSuspensions, setPendingSuspensions] = useState([]);
  const [toast, setToast] = useState(null);
  const [activeTab, setActiveTab] = useState('suspensions'); // 'suspensions' | 'exceptions'

  // Form state
  const [eModal, setEModal] = useState(false);
  const [currentEx, setCurrentEx] = useState({
    id: null, scheduleId: '', exceptionDate: '', reason: '', exceptionType: 'CANCELLED',
    replacementDate: '', replacementRoomId: '', approvalStatus: 'APPROVED'
  });

  const [rejectModal, setRejectModal] = useState({ open: false, id: null, note: '' });

  // Searchable Dropdown state
  const [searchSc, setSearchSc] = useState('');

  useEffect(() => {
    fetchPendingSuspensions();
    fetchExceptions();
    fetchSchedules();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchPendingSuspensions = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedule-exceptions/pending`, {
        headers: { 'Authorization': `Bearer ${getAdminToken()}` }
      });
      if (res.ok) {
        const data = await res.json();
        setPendingSuspensions(data);
      }
    } catch (error) {
      console.error('Lỗi tải đề xuất nghỉ dạy:', error);
    }
  };

  const fetchExceptions = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedule-exceptions`, {
        headers: { 'Authorization': `Bearer ${getAdminToken()}` }
      });
      if (res.ok) {
        const data = await res.json();
        setExceptions(data);
      }
    } catch (error) {
      showToast('Lỗi tải ngoại lệ!', 'error');
    }
  };

  const fetchSchedules = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedules`, {
        headers: { 'Authorization': `Bearer ${getAdminToken()}` }
      });
      if (res.ok) {
        const data = await res.json();
        setSchedules(data);
      }
    } catch (error) {
      console.error(error);
    }
  };

  const handleApprove = async (id) => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedule-exceptions/${id}/approve`, {
        
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${getAdminToken()}` }
      });
      if (res.ok) {
        showToast('Đã duyệt đề xuất nghỉ dạy! Thông báo đã gửi đến giảng viên và sinh viên.');
        fetchPendingSuspensions();
        fetchExceptions();
      } else {
        showToast('Lỗi khi duyệt!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối!', 'error');
    }
  };

  const handleOpenReject = (id) => {
    setRejectModal({ open: true, id, note: '' });
  };

  const handleConfirmReject = async () => {
    if (!rejectModal.note.trim()) {
      showToast('Vui lòng nhập lý do từ chối!', 'error');
      return;
    }
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedule-exceptions/${rejectModal.id}/reject`, {
        
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${getAdminToken()}`
        },
        body: JSON.stringify({ adminNote: rejectModal.note })
      });
      if (res.ok) {
        showToast('Đã từ chối đề xuất. Thông báo đã gửi đến giảng viên.');
        setRejectModal({ open: false, id: null, note: '' });
        fetchPendingSuspensions();
        fetchExceptions();
      } else {
        showToast('Lỗi khi từ chối!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối!', 'error');
    }
  };

  const handleSaveEx = async () => {
    const payload = { ...currentEx };
    if (!payload.replacementDate) payload.replacementDate = null;
    if (!payload.replacementRoomId) payload.replacementRoomId = null;

    const method = currentEx.id ? 'PUT' : 'POST';
    const url = currentEx.id
      ? `${API_BASE_URL}/school-admin/schedule-exceptions/${currentEx.id}`
      : `${API_BASE_URL}/school-admin/schedule-exceptions`;

    try {
      const res = await fetch(url, {
        
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${getAdminToken()}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast(currentEx.id ? 'Cập nhật ngoại lệ thành công!' : 'Thêm ngoại lệ thành công!');
        setEModal(false);
        fetchExceptions();
      } else {
        showToast('Lỗi khi lưu!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDeleteEx = async (id) => {
    if (!window.confirm('Bạn có chắc muốn xóa ngoại lệ này?')) return;
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedule-exceptions/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${getAdminToken()}` }
      });
      if (res.ok) {
        showToast('Đã xóa ngoại lệ!');
        fetchExceptions();
      }
    } catch (err) {
      showToast('Lỗi khi xóa!', 'error');
    }
  };

  const openExModal = (ex = null) => {
    setCurrentEx(ex ? { ...ex } : {
      id: null, scheduleId: '', exceptionDate: '', reason: '',
      exceptionType: 'CANCELLED', replacementDate: '', replacementRoomId: '', approvalStatus: 'APPROVED'
    });
    setSearchSc(ex && schedules.find(s => s.id === ex.scheduleId) ? `Sch#${ex.scheduleId} – ${schedules.find(s => s.id === ex.scheduleId).classCode}` : '');
    setEModal(true);
  };

  const renderBadge = (type) => {
    if (!type) return null;
    const typeStr = typeof type === 'string' ? type : type.toString();
    if (typeStr === 'CANCELLED') return <span className="badge b-gray">CANCELLED</span>;
    if (typeStr === 'RESCHEDULED') return <span className="badge b-amber">RESCHEDULED</span>;
    if (typeStr === 'ROOM_CHANGE') return <span className="badge b-blue">ROOM_CHANGE</span>;
    if (typeStr === 'SUBSTITUTED') return <span className="badge b-purple">SUBSTITUTED</span>;
    return <span className="badge b-gray">{typeStr}</span>;
  };

  const renderStatusBadge = (status) => {
    if (!status) return null;
    const s = typeof status === 'string' ? status : status.toString();
    if (s === 'APPROVED') return <span className="badge b-green">Đã duyệt</span>;
    if (s === 'REJECTED') return <span className="badge b-red">Từ chối</span>;
    return <span className="badge b-amber">Chờ duyệt</span>;
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return isNaN(d) ? dateStr : d.toLocaleDateString('vi-VN');
  };

  return (
    <div className="page" style={{ position: 'relative' }}>

      {/* TOAST */}
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

      {/* HEADER */}
      <div className="ph">
        <div>
          <div className="ph-title">Ngoại lệ & Đề xuất nghỉ dạy</div>
          <div className="ph-sub">Duyệt đề xuất của giảng viên · Nghỉ lễ · Dời lịch</div>
        </div>
        {activeTab === 'exceptions' && (
          <button className="btn btn-blue" onClick={() => openExModal()}>+ Thêm ngoại lệ</button>
        )}
        {activeTab === 'suspensions' && (
          <button className="btn btn-ghost" onClick={fetchPendingSuspensions}>
            <RefreshCw style={{ width: 14, display: 'inline', marginRight: 4 }} /> Làm mới
          </button>
        )}
      </div>

      {/* TABS */}
      <div style={{ display: 'flex', gap: 0, marginBottom: 16, borderBottom: '2px solid var(--border)' }}>
        <button
          onClick={() => setActiveTab('suspensions')}
          style={{
            padding: '10px 20px', fontWeight: 600, fontSize: 13, border: 'none', cursor: 'pointer',
            background: 'transparent', color: activeTab === 'suspensions' ? 'var(--blue)' : 'var(--muted)',
            borderBottom: activeTab === 'suspensions' ? '2px solid var(--blue)' : '2px solid transparent',
            marginBottom: -2
          }}
        >
          Đề xuất nghỉ dạy {pendingSuspensions.length > 0 && (
            <span style={{ background: '#ef4444', color: '#fff', borderRadius: 10, padding: '1px 7px', fontSize: 11, marginLeft: 6 }}>
              {pendingSuspensions.length}
            </span>
          )}
        </button>
        <button
          onClick={() => setActiveTab('exceptions')}
          style={{
            padding: '10px 20px', fontWeight: 600, fontSize: 13, border: 'none', cursor: 'pointer',
            background: 'transparent', color: activeTab === 'exceptions' ? 'var(--blue)' : 'var(--muted)',
            borderBottom: activeTab === 'exceptions' ? '2px solid var(--blue)' : '2px solid transparent',
            marginBottom: -2
          }}
        >
          Ngoại lệ lịch học
        </button>
      </div>

      {/* TAB: PENDING SUSPENSIONS */}
      {activeTab === 'suspensions' && (
        <div className="card">
          <table className="tbl">
            <thead>
              <tr>
                <th>#</th>
                <th>Giảng viên</th>
                <th>Lớp học phần</th>
                <th>Ngày nghỉ</th>
                <th>Lý do</th>
                <th>Minh chứng</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {pendingSuspensions.map((s, idx) => (
                <tr key={s.id} style={{ background: '#fffbeb' }}>
                  <td style={{ color: 'var(--muted)' }}>{idx + 1}</td>
                  <td>
                    <div style={{ fontWeight: 700 }}>{s.teacherName || '—'}</div>
                    <div style={{ fontSize: 11, color: 'var(--muted)' }}>{s.teacherCode}</div>
                  </td>
                  <td>
                    <div style={{ fontWeight: 700, fontFamily: 'monospace', color: 'var(--blue)' }}>{s.classCode || s.scheduleDetails}</div>
                    <div style={{ fontSize: 11, color: 'var(--muted)' }}>{s.courseName}</div>
                  </td>
                  <td style={{ fontWeight: 700 }}>{formatDate(s.exceptionDate)}</td>
                  <td style={{ maxWidth: 200 }}>{s.reason}</td>
                  <td>
                    {s.proofFileUrl
                      ? <a href={s.proofFileUrl} target="_blank" rel="noreferrer" className="btn btn-ghost btn-xs">Xem file</a>
                      : <span style={{ color: 'var(--muted)', fontSize: 12 }}>Không có</span>
                    }
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <button
                        className="btn btn-xs"
                        style={{ background: '#16a34a', color: '#fff', display: 'flex', alignItems: 'center', gap: 4 }}
                        onClick={() => handleApprove(s.id)}
                      >
                        <CheckCircle2 style={{ width: 13 }} /> Duyệt
                      </button>
                      <button
                        className="btn btn-danger btn-xs"
                        style={{ display: 'flex', alignItems: 'center', gap: 4 }}
                        onClick={() => handleOpenReject(s.id)}
                      >
                        <XCircle style={{ width: 13 }} /> Từ chối
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {pendingSuspensions.length === 0 && (
                <tr><td colSpan="7" style={{ textAlign: 'center', padding: 30, color: 'var(--muted)' }}>
                  Không có đề xuất nghỉ dạy nào đang chờ duyệt.
                </td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* TAB: EXCEPTIONS */}
      {activeTab === 'exceptions' && (
        <div className="card">
          <table className="tbl">
            <thead>
              <tr>
                <th>#</th>
                <th>Ca học</th>
                <th>Ngày NL</th>
                <th>Lý do</th>
                <th>Loại</th>
                <th>Trạng thái</th>
                <th>Ngày thay thế</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {exceptions.map((ex, index) => (
                <tr key={ex.id}>
                  <td style={{ color: 'var(--muted)' }}>{index + 1}</td>
                  <td style={{ fontFamily: 'monospace', fontSize: '12px', color: 'var(--blue)' }}>
                    {ex.classCode || ex.scheduleDetails}
                  </td>
                  <td style={{ fontWeight: 700 }}>{formatDate(ex.exceptionDate)}</td>
                  <td>{ex.reason}</td>
                  <td>{renderBadge(ex.exceptionType)}</td>
                  <td>{renderStatusBadge(ex.approvalStatus)}</td>
                  <td>{ex.replacementDate ? formatDate(ex.replacementDate) : '—'}</td>
                  <td>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <button className="btn btn-ghost btn-xs" onClick={() => openExModal(ex)}>Sửa</button>
                      <button className="btn btn-danger btn-xs" onClick={() => handleDeleteEx(ex.id)}>Xóa</button>
                    </div>
                  </td>
                </tr>
              ))}
              {exceptions.length === 0 && <tr><td colSpan="8" style={{ textAlign: 'center' }}>Chưa có ngoại lệ nào</td></tr>}
            </tbody>
          </table>
        </div>
      )}

      {/* MODAL: Add/Edit Exception */}
      {eModal && (
        <div className="ov open">
          <div className="modal" style={{ width: '500px' }}>
            <div className="modal-hd">
              <span className="modal-title"><AlertTriangle className="w-4 h-4 inline-block mr-2" /> {currentEx.id ? 'Sửa Ngoại lệ' : 'Thêm Ngoại lệ Lịch học'}</span>
              <button className="close-btn" onClick={() => setEModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="fg relative">
                <label className="fl">Ca học (Tìm kiếm)</label>
                <div style={{ position: 'relative' }}>
                  <input 
                    type="text" 
                    className="fc" 
                    placeholder="Gõ mã lớp, thứ, ca học để tìm..." 
                    onChange={e => {
                      setSearchSc(e.target.value);
                      const val = e.target.value.toLowerCase();
                      const options = document.querySelectorAll('.schedule-option');
                      options.forEach(opt => {
                        const text = opt.innerText.toLowerCase();
                        opt.style.display = text.includes(val) ? 'block' : 'none';
                      });
                    }}
                    onFocus={() => document.getElementById('schedule-dropdown').style.display = 'block'}
                    onBlur={() => setTimeout(() => document.getElementById('schedule-dropdown').style.display = 'none', 200)}
                    value={searchSc}
                  />
                  <div 
                    id="schedule-dropdown" 
                    style={{
                      display: 'none', position: 'absolute', top: '100%', left: 0, right: 0, 
                      maxHeight: '200px', overflowY: 'auto', background: '#fff', 
                      border: '1px solid #ccc', borderRadius: '4px', zIndex: 100, 
                      boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
                    }}
                  >
                    {schedules.map(sc => (
                      <div 
                        key={sc.id} 
                        className="schedule-option"
                        style={{ padding: '8px 12px', cursor: 'pointer', borderBottom: '1px solid #eee', fontSize: '13px' }}
                        onMouseDown={() => {
                          setCurrentEx({ ...currentEx, scheduleId: sc.id });
                          setSearchSc(`Sch#${sc.id} – ${sc.classCode} (Thứ ${sc.dayOfWeek} · ${sc.startTime} - ${sc.endTime})`);
                          document.getElementById('schedule-dropdown').style.display = 'none';
                        }}
                        onMouseEnter={e => e.target.style.background = '#f1f5f9'}
                        onMouseLeave={e => e.target.style.background = 'transparent'}
                      >
                        Sch#{sc.id} – {sc.classCode} (Thứ {sc.dayOfWeek} · {sc.startTime} - {sc.endTime})
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              <div className="fg">
                <label className="fl">Ngày ngoại lệ</label>
                <input type="date" className="fc" value={currentEx.exceptionDate} onChange={e => setCurrentEx({ ...currentEx, exceptionDate: e.target.value })} />
              </div>
              <div className="fg">
                <label className="fl">Lý do</label>
                <input className="fc" value={currentEx.reason} onChange={e => setCurrentEx({ ...currentEx, reason: e.target.value })} placeholder="Nghỉ Quốc khánh, GV ốm, Sự kiện..." />
              </div>
              <div className="fg">
                <label className="fl">Loại ngoại lệ</label>
                <select className="fc" value={currentEx.exceptionType} onChange={e => setCurrentEx({ ...currentEx, exceptionType: e.target.value })}>
                  <option value="CANCELLED">cancelled – Hủy buổi học</option>
                  <option value="RESCHEDULED">rescheduled – Dời sang ngày khác</option>
                  <option value="ROOM_CHANGE">room_change – Đổi phòng học</option>
                  <option value="SUBSTITUTED">substituted – Giáo viên dạy thay</option>
                </select>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Ngày dạy bù (nếu có)</label>
                  <input type="date" className="fc" value={currentEx.replacementDate || ''} onChange={e => setCurrentEx({ ...currentEx, replacementDate: e.target.value })} />
                </div>
                <div className="fg">
                  <label className="fl">Phòng ID thay thế</label>
                  <input type="number" className="fc" value={currentEx.replacementRoomId || ''} onChange={e => setCurrentEx({ ...currentEx, replacementRoomId: e.target.value })} placeholder="Nhập ID phòng..." />
                </div>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setEModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveEx}><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: Reject with reason */}
      {rejectModal.open && (
        <div className="ov open">
          <div className="modal" style={{ width: '420px' }}>
            <div className="modal-hd">
              <span className="modal-title"><XCircle className="w-4 h-4 inline-block mr-2" style={{ color: '#ef4444' }} /> Từ chối đề xuất nghỉ dạy</span>
              <button className="close-btn" onClick={() => setRejectModal({ open: false, id: null, note: '' })}>×</button>
            </div>
            <div className="modal-body">
              <div className="fg">
                <label className="fl">Lý do từ chối <span style={{ color: '#ef4444' }}>*</span></label>
                <textarea
                  className="fc"
                  rows="4"
                  value={rejectModal.note}
                  onChange={e => setRejectModal(prev => ({ ...prev, note: e.target.value }))}
                  placeholder="Nhập lý do từ chối để thông báo đến giảng viên..."
                />
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setRejectModal({ open: false, id: null, note: '' })}>Hủy</button>
              <button
                className="btn btn-danger"
                onClick={handleConfirmReject}
              >
                <XCircle className="w-4 h-4 inline-block mr-2" /> Xác nhận từ chối
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
