import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { RefreshCw, CheckCircle2, AlertTriangle, Upload } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const StopTeaching = () => {
  const [history, setHistory] = useState([]);
  const [activeClasses, setActiveClasses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  
  // Form states
  const [selectedClassId, setSelectedClassId] = useState('');
  const [selectedScheduleId, setSelectedScheduleId] = useState('');
  const [date, setDate] = useState('');
  const [reason, setReason] = useState('');
  const [file, setFile] = useState(null);
  
  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });

  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/teaching-suspensions/history`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setHistory(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const fetchActiveClasses = async () => {
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/schedules/active-classes`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setActiveClasses(res.data);
    } catch (err) {
      console.error('Lỗi khi tải danh sách lớp:', err);
    }
  };

  useEffect(() => {
    fetchHistory();
    fetchActiveClasses();
  }, []);

  const handleSubmit = async () => {
    if (!selectedClassId || !selectedScheduleId || !date || !reason) {
      showToast('Vui lòng điền đầy đủ thông tin đề xuất', 'error');
      return;
    }

    setSubmitting(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const formData = new FormData();
      
      const dataPayload = {
        scheduleId: parseInt(selectedScheduleId),
        exceptionDate: date,
        reason: reason
      };

      // Backend yêu cầu part "data" là một chuỗi JSON
      formData.append('data', new Blob([JSON.stringify(dataPayload)], { type: 'application/json' }));
      
      if (file) {
        formData.append('proofFile', file);
      }

      const res = await axios.post(`${API_BASE_URL}/lecturer/teaching-suspensions/submit`, formData, {
        headers: { 
          Authorization: `Bearer ${token}`
        }
      });
      
      showToast(res.data || 'Đã gửi đề xuất thành công!');
      setDate('');
      setReason('');
      setFile(null);
      setSelectedClassId('');
      setSelectedScheduleId('');
      fetchHistory(); // Reload lịch sử
    } catch (err) {
      console.error(err);
      showToast(err.response?.data?.message || 'Có lỗi khi gửi đề xuất', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const getStatusBadge = (status) => {
    switch(status?.toLowerCase()) {
      case 'approved': return <span className="px-2 py-0.5 bg-green-100 text-green-700 text-xs rounded-full font-bold uppercase tracking-wider">Đã duyệt</span>;
      case 'rejected': return <span className="px-2 py-0.5 bg-red-100 text-red-600 text-xs rounded-full font-bold uppercase tracking-wider">Từ chối</span>;
      default: return <span className="px-2 py-0.5 bg-yellow-100 text-yellow-700 text-xs rounded-full font-bold uppercase tracking-wider">Chờ duyệt</span>;
    }
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('vi-VN');
  };

  const formatDateTime = (dateStr) => {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return `${d.toLocaleDateString('vi-VN')} ${d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute:'2-digit' })}`;
  };

  const selectedClass = activeClasses.find(c => c.classId === parseInt(selectedClassId));
  const availableSchedules = selectedClass ? selectedClass.schedules : [];

  return (
    <div className="animate-fadeIn relative">
      {toast.show && (
        <div style={{
          position: 'fixed', top: 24, right: 24, zIndex: 10000,
          background: toast.type === 'success' ? '#10b981' : '#ef4444',
          color: 'white', padding: '14px 24px', borderRadius: 8,
          boxShadow: '0 10px 25px rgba(0,0,0,0.2)', fontWeight: 600, fontSize: 14
        }}>
          {toast.type === 'success' ? <><CheckCircle2 className="w-4 h-4 inline-block mr-2" /> </> : <><AlertTriangle className="w-4 h-4 inline-block mr-2" /> </>}{toast.msg}
        </div>
      )}

      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Đề xuất tạm ngừng lịch dạy</h1>
        <p className="text-gray-400 text-sm mt-1">Yêu cầu tạm ngừng buổi dạy có lý do (Xin nghỉ phép)</p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div className="card p-6 shadow-sm border border-gray-100 h-fit">
          <h3 className="font-bold text-gray-700 mb-5 uppercase text-[11px] tracking-widest border-b pb-2">Tạo đề xuất mới</h3>
          <div className="space-y-5">
            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Lớp học phần</label>
              <select 
                className="input-field bg-gray-50 text-sm"
                value={selectedClassId}
                onChange={e => {
                  setSelectedClassId(e.target.value);
                  setSelectedScheduleId(''); // Reset schedule when class changes
                }}
              >
                <option value="">-- Chọn lớp học phần --</option>
                {activeClasses.map(cls => (
                  <option key={cls.classId} value={cls.classId}>
                    {cls.classCode} - {cls.courseName}
                  </option>
                ))}
              </select>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Ca học</label>
                <select 
                  className="input-field bg-gray-50 text-sm"
                  value={selectedScheduleId}
                  onChange={e => setSelectedScheduleId(e.target.value)}
                  disabled={!selectedClassId}
                >
                  <option value="">-- Chọn ca học --</option>
                  {availableSchedules.map(sch => (
                    <option key={sch.scheduleId} value={sch.scheduleId}>
                      Thứ {sch.dayOfWeek === 8 ? 'CN' : sch.dayOfWeek} (Tiết {sch.startPeriod}-{sch.endPeriod}) - P.{sch.roomName}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Ngày xin ngừng</label>
                <input 
                  type="date" 
                  value={date}
                  onChange={e => setDate(e.target.value)}
                  className="input-field text-sm font-bold text-[#6B4FA0]" 
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Lý do</label>
              <textarea 
                value={reason}
                onChange={e => setReason(e.target.value)}
                className="input-field text-sm" 
                rows="3" 
                placeholder="Nhập lý do chi tiết..."
              ></textarea>
            </div>
            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Đính kèm minh chứng</label>
              <input 
                type="file" 
                onChange={e => setFile(e.target.files[0])}
                className="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-xs file:font-bold file:bg-purple-50 file:text-purple-700 hover:file:bg-purple-100 cursor-pointer" 
              />
            </div>
            <button 
              onClick={handleSubmit}
              disabled={submitting}
              className="btn-primary w-full font-bold py-2.5 mt-2 shadow-lg shadow-purple-200 uppercase text-xs tracking-widest"
            >
              {submitting ? '⏳ Đang gửi...' : <><Upload className="w-4 h-4 inline-block mr-2" /> Gửi đề xuất</>}
            </button>
          </div>
        </div>
        
        <div className="card p-6 shadow-sm border border-gray-100 h-fit max-h-[600px] flex flex-col">
          <div className="flex justify-between items-center mb-5 border-b pb-2">
            <h3 className="font-bold text-gray-700 uppercase text-[11px] tracking-widest">Lịch sử đề xuất</h3>
            <button onClick={fetchHistory} className="text-xs text-[#6B4FA0] font-bold hover:underline"><RefreshCw className="w-4 h-4 inline-block mr-2" /> Làm mới</button>
          </div>
          
          <div className="space-y-3 overflow-y-auto pr-2 custom-scrollbar flex-1">
            {loading ? (
              <div className="text-center text-sm text-gray-400 py-5">Đang tải lịch sử...</div>
            ) : history && history.length > 0 ? (
              history.map(item => (
                <div key={item.exceptionId} className="border border-gray-100 hover:border-purple-200 bg-gray-50/50 rounded-xl p-4 transition-all">
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-bold text-sm text-gray-800">{item.classCode} - <span className="text-[#6B4FA0]">{formatDate(item.exceptionDate)}</span></span>
                    {getStatusBadge(item.status)}
                  </div>
                  <p className="text-sm text-gray-600 font-medium">Lý do: <span className="font-normal">{item.reason}</span></p>
                  <p className="text-[10px] text-gray-400 mt-2 font-bold uppercase tracking-wider">Gửi lúc: {formatDateTime(item.createdAt)}</p>
                </div>
              ))
            ) : (
              <div className="text-center text-sm text-gray-400 py-10 italic">
                Bạn chưa gửi đề xuất tạm ngừng giảng dạy nào.
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default StopTeaching;