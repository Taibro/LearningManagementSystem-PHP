import React, { useState, useEffect } from 'react';
import { CalendarDays, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Schedule() {
  function getMondayOf(date) {
    const d = new Date(date);
    const day = d.getDay(); // 0=CN
    const diff = (day === 0) ? -6 : 1 - day;
    d.setDate(d.getDate() + diff);
    return d;
  }

  function toLocalIso(d) {
    return d.toISOString().split('T')[0];
  }

  const [selectedDate, setSelectedDate] = useState(toLocalIso(new Date()));
  const days = [2, 3, 4, 5, 6, 7, 1]; // Thứ 2 đến Chủ nhật (Chủ nhật là 1)

  const monday = getMondayOf(selectedDate);
  const weekDates = days.map((_, i) => {
    const d = new Date(monday);
    d.setDate(monday.getDate() + i);
    return d;
  });

  const goWeek = (delta) => {
    const d = new Date(selectedDate);
    d.setDate(d.getDate() + delta * 7);
    setSelectedDate(toLocalIso(d));
  };

  const [sModal, setSModal] = useState(false);
  const [schedules, setSchedules] = useState([]);
  const [toast, setToast] = useState(null);

  // Form state
  const [currentSc, setCurrentSc] = useState({ 
    id: null, classId: 1, roomId: 1, dayOfWeek: 2, type: 'REGULAR', 
    startTime: '07:30', endTime: '09:30', startDate: '', endDate: '' 
  });

  // Exception Modal state
  const [eModal, setEModal] = useState(false);
  const [currentEx, setCurrentEx] = useState({
    scheduleId: '', exceptionDate: '', reason: '', exceptionType: 'CANCELLED',
    replacementDate: '', replacementRoomId: '', approvalStatus: 'APPROVED'
  });

  useEffect(() => {
    fetchSchedules();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchSchedules = async () => {
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${API_BASE_URL}/school-admin/schedules`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setSchedules(data);
      }
    } catch (error) {
      showToast('Lỗi tải lịch học!', 'error');
    }
  };

  const handleSaveSc = async () => {
    const method = currentSc.id ? 'PUT' : 'POST';
    const url = currentSc.id 
      ? `${API_BASE_URL}/school-admin/schedules/${currentSc.id}`
      : `${API_BASE_URL}/school-admin/schedules`;

    // Đảm bảo startTime / endTime có format hh:mm:ss nếu Backend đòi (nếu chỉ type="time" thì nó chỉ có hh:mm)
    const payload = { 
      ...currentSc, 
      startTime: currentSc.startTime.length === 5 ? currentSc.startTime + ':00' : currentSc.startTime,
      endTime: currentSc.endTime.length === 5 ? currentSc.endTime + ':00' : currentSc.endTime,
    };

    try {
      const res = await fetch(url, {
        method,
        
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast(currentSc.id ? 'Cập nhật lịch học thành công!' : 'Tạo lịch học thành công!');
        setSModal(false);
        fetchSchedules();
      } else {
        showToast('Lỗi khi lưu!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDeleteSc = async (id) => {
    if(!window.confirm("Bạn có chắc muốn xóa lịch học này?")) return;
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedules/${id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        showToast('Đã xóa!');
        fetchSchedules();
      }
    } catch (err) {
      showToast('Lỗi khi xóa!', 'error');
    }
  };

  const handleSaveEx = async () => {
    const payload = { ...currentEx };
    if (!payload.replacementDate) payload.replacementDate = null;
    if (!payload.replacementRoomId) payload.replacementRoomId = null;

    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/schedule-exceptions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast('Tạo ngoại lệ thành công! Thông báo đã được gửi.');
        setEModal(false);
        // fetchSchedules() if we need to see changes, but exceptions might not change schedule grid unless we fetch exceptions too.
        // For now, just show toast.
      } else {
        showToast('Lỗi khi tạo ngoại lệ!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const openExModal = (scheduleId) => {
    setCurrentEx({
      scheduleId: scheduleId, exceptionDate: '', reason: '', exceptionType: 'CANCELLED',
      replacementDate: '', replacementRoomId: '', approvalStatus: 'APPROVED'
    });
    setSModal(false); // Close schedule modal
    setEModal(true);
  };

  const openModal = (sc = null) => {
    setCurrentSc(sc ? { ...sc } : { 
      id: null, classId: 1, roomId: 1, dayOfWeek: 2, type: 'REGULAR', 
      startTime: '07:30', endTime: '09:30', startDate: '', endDate: '' 
    });
    setSModal(true);
  };

  // Logic phân loại lịch học vào ô Sáng / Chiều / Tối theo Grid thiết kế cũ
  const renderCell = (day, shift) => {
    // shift: 'morning', 'afternoon', 'evening'
    const found = schedules.find(sc => {
      if (sc.dayOfWeek !== day) return false;
      
      if (sc.startDate && sc.endDate) {
         const dIndex = day === 1 ? 6 : day - 2;
         const currentDayDate = toLocalIso(weekDates[dIndex]);
         if (currentDayDate < sc.startDate || currentDayDate > sc.endDate) {
           return false;
         }
      }

      const hour = parseInt(sc.startTime?.split(':')[0] || 0);
      if (shift === 'morning' && hour < 12) return true;
      if (shift === 'afternoon' && hour >= 12 && hour < 17) return true;
      if (shift === 'evening' && hour >= 17) return true;
      return false;
    });

    if (!found) return <div key={day} className="wk-cell"></div>;

    // Phân loại CSS thẻ theo loại lịch
    let cardClass = 'sc-reg';
    if (found.type === 'LAB') cardClass = 'sc-lab';
    if (found.type === 'MAKEUP' || found.type === 'EXAM') cardClass = 'sc-ex';

    return (
      <div key={day} className="wk-cell">
        <div className={`sc-card ${cardClass}`} onClick={() => openModal(found)} style={{cursor: 'pointer'}} title="Nhấn để sửa">
          <strong>{found.classCode || `Lớp ${found.classId}`} {found.type === 'MAKEUP' && '(Bù)'}</strong><br/>
          {found.startTime?.substring(0,5)}–{found.endTime?.substring(0,5)}<br/>
          Phòng {found.roomNumber || `ID:${found.roomId}`}<br/>
          GV: {found.teacherName || '—'}
        </div>
      </div>
    );
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
          <div className="ph-title">Lịch học theo tuần</div>
          <div className="ph-sub">Quản lý thời khóa biểu trực quan</div>
        </div>
        <div style={{display:'flex', gap:'8px', alignItems:'center'}}>
          <input type="date" className="form-ctrl" style={{width:'130px', padding:'4px', fontSize:'13px', borderRadius:'4px', border:'1px solid #ccc'}}
            value={selectedDate}
            onChange={e => setSelectedDate(e.target.value)} />
          <button className="btn btn-ghost btn-sm" onClick={() => goWeek(-1)}>‹ Tuần trước</button>
          <button className="btn btn-blue btn-sm" onClick={() => setSelectedDate(toLocalIso(new Date()))}>Hôm nay</button>
          <button className="btn btn-ghost btn-sm" onClick={() => goWeek(1)}>Tuần sau ›</button>
          <button className="btn btn-blue" onClick={() => openModal()}>+ Tạo lịch</button>
        </div>
      </div>
      
      <div className="card" style={{overflowX:'auto'}}>
        {/* --- GIỮ NGUYÊN CSS GRID VÀ CẤU TRÚC HTML GỐC --- */}
        <div className="wk-grid">
          <div className="wk-head" style={{fontSize:'10px'}}>Ca học</div>
          {days.map((dow, i) => (
            <div key={dow} className="wk-head">
              <div>{dow === 1 ? 'CN' : `Thứ ${dow}`}</div>
              <div style={{fontSize:'10px', opacity:'.75'}}>
                {weekDates[i].toLocaleDateString('vi-VN')}
              </div>
            </div>
          ))}

          {/* HÀNG SÁNG */}
          <div className="wk-cell ca">SÁNG</div>
          {days.map(day => renderCell(day, 'morning'))}

          {/* HÀNG CHIỀU */}
          <div className="wk-cell ca">CHIỀU</div>
          {days.map(day => renderCell(day, 'afternoon'))}

          {/* HÀNG TỐI */}
          <div className="wk-cell ca">TỐI</div>
          {days.map(day => renderCell(day, 'evening'))}

        </div>

        <div style={{padding:'10px 16px', display:'flex', gap:'16px', fontSize:'11px', background:'#f8fafc', borderTop:'1px solid var(--border)'}}>
          <span><span style={{display:'inline-block', width:'10px', height:'10px', background:'#dbeafe', borderLeft:'3px solid var(--blue-lt)', marginRight:'4px', verticalAlign:'middle'}}></span>Regular</span>
          <span><span style={{display:'inline-block', width:'10px', height:'10px', background:'#dcfce7', borderLeft:'3px solid #22c55e', marginRight:'4px', verticalAlign:'middle'}}></span>Lab</span>
          <span><span style={{display:'inline-block', width:'10px', height:'10px', background:'#fef3c7', borderLeft:'3px solid #f59e0b', marginRight:'4px', verticalAlign:'middle'}}></span>Makeup/Exam</span>
        </div>
      </div>

      {sModal && (
        <div className="ov open">
          <div className="modal">
            <div className="modal-hd">
              <span className="modal-title">{currentSc.id ? <><CalendarDays className="w-4 h-4 inline-block mr-2" /> Sửa Lịch học</> : <><CalendarDays className="w-4 h-4 inline-block mr-2" /> Tạo Lịch học</>}</span>
              <button className="close-btn" onClick={() => setSModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="grid2">
                <div className="fg">
                  <label className="fl">ID Lớp học</label>
                  <input type="number" className="fc" value={currentSc.classId} onChange={e => setCurrentSc({...currentSc, classId: parseInt(e.target.value)})} />
                </div>
                <div className="fg">
                  <label className="fl">ID Phòng học</label>
                  <input type="number" className="fc" value={currentSc.roomId} onChange={e => setCurrentSc({...currentSc, roomId: parseInt(e.target.value)})} />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Thứ trong tuần</label>
                  <select className="fc" value={currentSc.dayOfWeek} onChange={e => setCurrentSc({...currentSc, dayOfWeek: parseInt(e.target.value)})}>
                    <option value="2">Thứ 2</option>
                    <option value="3">Thứ 3</option>
                    <option value="4">Thứ 4</option>
                    <option value="5">Thứ 5</option>
                    <option value="6">Thứ 6</option>
                    <option value="7">Thứ 7</option>
                    <option value="1">Chủ nhật</option>
                  </select>
                </div>
                <div className="fg">
                  <label className="fl">Loại buổi</label>
                  <select className="fc" value={currentSc.type} onChange={e => setCurrentSc({...currentSc, type: e.target.value})}>
                    <option value="REGULAR">REGULAR</option>
                    <option value="MAKEUP">MAKEUP</option>
                    <option value="EXAM">EXAM</option>
                    <option value="LAB">LAB</option>
                    <option value="SEMINAR">SEMINAR</option>
                  </select>
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Giờ bắt đầu</label>
                  <input type="time" className="fc" value={currentSc.startTime} onChange={e => setCurrentSc({...currentSc, startTime: e.target.value})} />
                </div>
                <div className="fg">
                  <label className="fl">Giờ kết thúc</label>
                  <input type="time" className="fc" value={currentSc.endTime} onChange={e => setCurrentSc({...currentSc, endTime: e.target.value})} />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Áp dụng từ ngày</label>
                  <input type="date" className="fc" value={currentSc.startDate || ''} onChange={e => setCurrentSc({...currentSc, startDate: e.target.value})} />
                </div>
                <div className="fg">
                  <label className="fl">Áp dụng đến ngày</label>
                  <input type="date" className="fc" value={currentSc.endDate || ''} onChange={e => setCurrentSc({...currentSc, endDate: e.target.value})} />
                </div>
              </div>
            </div>
            <div className="modal-ft">
              {currentSc.id && (
                <>
                  <button className="btn btn-danger" style={{marginRight: 'auto'}} onClick={() => handleDeleteSc(currentSc.id)}>Xóa</button>
                  <button className="btn btn-outline" style={{borderColor: '#ef4444', color: '#ef4444'}} onClick={() => openExModal(currentSc.id)}>Thêm ngoại lệ</button>
                </>
              )}
              <button className="btn btn-ghost" onClick={() => setSModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveSc}><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: Thêm Ngoại lệ Nhanh */}
      {eModal && (
        <div className="ov open">
          <div className="modal" style={{ width: '500px' }}>
            <div className="modal-hd">
              <span className="modal-title">Thêm Ngoại lệ cho Lịch học #{currentEx.scheduleId}</span>
              <button className="close-btn" onClick={() => setEModal(false)}>×</button>
            </div>
            <div className="modal-body">
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
              <button className="btn btn-blue" onClick={handleSaveEx}><Save className="w-4 h-4 inline-block mr-2" /> Tạo Ngoại lệ</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
