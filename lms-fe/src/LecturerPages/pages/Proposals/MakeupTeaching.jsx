import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Check, RefreshCw, CheckCircle2, AlertTriangle, Upload, X } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const MakeupTeaching = () => {
  const [history, setHistory] = useState([]);
  const [cancelledSessions, setCancelledSessions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Form states
  const [exceptionId, setExceptionId] = useState('');
  const [makeupDate, setMakeupDate] = useState('');
  const [shift, setShift] = useState('morning'); // morning, afternoon, evening
  const [room, setRoom] = useState('');
  const [availableRooms, setAvailableRooms] = useState([]);
  const [notes, setNotes] = useState('');

  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });

  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const fetchData = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const headers = { Authorization: `Bearer ${token}` };

      // Fetch cancelled sessions for dropdown
      const resSessions = await axios.get(`${API_BASE_URL}/lecturer/makeup-classes/cancelled-sessions`, { headers });
      setCancelledSessions(resSessions.data);
      if (resSessions.data.length > 0 && !exceptionId) {
        setExceptionId(resSessions.data[0].exceptionId);
      }

      // Fetch history
      const resHistory = await axios.get(`${API_BASE_URL}/lecturer/makeup-classes/history`, { headers });
      setHistory(resHistory.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    if (makeupDate && shift) {
      let start = 1, end = 3;
      if (shift === 'afternoon') { start = 7; end = 9; }
      if (shift === 'evening') { start = 13; end = 15; }

      const fetchRooms = async () => {
        try {
          const token = localStorage.getItem('lecturerToken');
          const res = await axios.get(`${API_BASE_URL}/lecturer/makeup-classes/available-rooms`, {
            headers: { Authorization: `Bearer ${token}` },
            params: { date: makeupDate, startPeriod: start, endPeriod: end }
          });
          setAvailableRooms(res.data);
          if (res.data.length > 0) setRoom(res.data[0].name);
          else setRoom('');
        } catch (e) {
          console.error('Error fetching available rooms', e);
        }
      };
      fetchRooms();
    }
  }, [makeupDate, shift]);

  const handleSubmit = async () => {
    if (!exceptionId || !makeupDate) {
      showToast('Vui lòng chọn buổi nghỉ gốc và ngày dạy bù!', 'error');
      return;
    }

    let start = 1, end = 3;
    if (shift === 'afternoon') { start = 7; end = 9; }
    if (shift === 'evening') { start = 13; end = 15; }

    setSubmitting(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const payload = {
        exceptionId: exceptionId,
        makeupDate: makeupDate,
        replacementStartPeriod: start,
        replacementEndPeriod: end,
        suggestedRoom: room,
        makeupNotes: notes
      };

      const res = await axios.post(`${API_BASE_URL}/lecturer/makeup-classes/submit`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      showToast(res.data || 'Đã gửi đề xuất dạy bù!');
      setMakeupDate('');
      setRoom('');
      setNotes('');
      fetchData(); // Reload
    } catch (err) {
      console.error(err);
      showToast(err.response?.data?.message || 'Có lỗi khi gửi đề xuất', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const getStatusStyle = (status) => {
    switch(status?.toLowerCase()) {
      case 'approved': return { box: 'border-green-200 bg-green-50', text: 'text-green-800', badge: 'bg-green-200 text-green-700', label: <><Check className="w-4 h-4 inline-block mr-2" /> Đã duyệt</>, subtext: 'text-green-600' };
      case 'rejected': return { box: 'border-red-200 bg-red-50', text: 'text-red-800', badge: 'bg-red-200 text-red-700', label: <><X className="w-4 h-4 inline-block mr-2" /> Từ chối</>, subtext: 'text-red-600' };
      default: return { box: 'border-yellow-200 bg-yellow-50', text: 'text-yellow-800', badge: 'bg-yellow-200 text-yellow-700', label: '⏳ Chờ duyệt', subtext: 'text-yellow-600' };
    }
  };

  return (
    <div className="animate-fadeIn relative">
      {/* Toast */}
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
        <h1 className="text-2xl font-bold text-gray-800">Đề xuất dạy bù</h1>
        <p className="text-gray-400 text-sm mt-1">Lên lịch bù cho các buổi đã xin phép nghỉ</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div className="card p-6 shadow-sm border border-gray-100 h-fit">
          <h3 className="font-bold text-gray-700 mb-5 uppercase text-[11px] tracking-widest border-b pb-2">Tạo lịch dạy bù</h3>
          <div className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Buổi nghỉ gốc cần bù</label>
              <select 
                value={exceptionId}
                onChange={e => setExceptionId(e.target.value)}
                className="input-field bg-gray-50 text-sm font-bold text-[#6B4FA0]"
              >
                {cancelledSessions.length > 0 ? (
                  cancelledSessions.map(session => (
                    <option key={session.exceptionId} value={session.exceptionId}>{session.displayLabel}</option>
                  ))
                ) : (
                  <option value="">Không có buổi nghỉ nào cần bù</option>
                )}
              </select>
            </div>
            
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Ngày dạy bù</label>
                <input 
                  type="date" 
                  value={makeupDate}
                  onChange={e => setMakeupDate(e.target.value)}
                  className="input-field text-sm font-bold text-[#6B4FA0]" 
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Ca học bù</label>
                <select 
                  value={shift}
                  onChange={e => setShift(e.target.value)}
                  className="input-field bg-gray-50 text-sm"
                >
                  <option value="morning">Sáng (Tiết 1-3)</option>
                  <option value="afternoon">Chiều (Tiết 7-9)</option>
                  <option value="evening">Tối (Tiết 13-15)</option>
                </select>
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Phòng học đề xuất</label>
              {availableRooms.length > 0 ? (
                <select 
                  value={room}
                  onChange={e => setRoom(e.target.value)}
                  className="input-field bg-gray-50 text-sm font-bold text-[#6B4FA0]"
                >
                  {availableRooms.map(r => (
                    <option key={r.id} value={r.name}>{r.name}</option>
                  ))}
                </select>
              ) : (
                <input 
                  type="text"
                  value={room}
                  onChange={e => setRoom(e.target.value)}
                  className="input-field text-sm bg-gray-100" 
                  placeholder={makeupDate ? "Không có phòng trống, nhập tay..." : "Vui lòng chọn ngày và ca"} 
                />
              )}
            </div>
            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1.5 ml-1">Ghi chú</label>
              <textarea 
                value={notes}
                onChange={e => setNotes(e.target.value)}
                className="input-field text-sm" 
                rows="2" 
                placeholder="Ghi chú thêm (Không bắt buộc)..."
              ></textarea>
            </div>
            <button 
              onClick={handleSubmit}
              disabled={submitting || cancelledSessions.length === 0}
              className={`w-full font-bold py-2.5 mt-2 uppercase text-xs tracking-widest ${cancelledSessions.length === 0 ? 'bg-gray-200 text-gray-400 cursor-not-allowed rounded-lg' : 'btn-primary shadow-lg shadow-purple-200'}`}
            >
              {submitting ? '⏳ Đang gửi...' : <><Upload className="w-4 h-4 inline-block mr-2" /> Gửi đề xuất dạy bù</>}
            </button>
          </div>
        </div>

        <div className="card p-6 shadow-sm border border-gray-100 h-fit max-h-[600px] flex flex-col">
          <div className="flex justify-between items-center mb-5 border-b pb-2">
            <h3 className="font-bold text-gray-700 uppercase text-[11px] tracking-widest">Trạng thái dạy bù</h3>
            <button onClick={fetchData} className="text-xs text-[#6B4FA0] font-bold hover:underline"><RefreshCw className="w-4 h-4 inline-block mr-2" /> Làm mới</button>
          </div>

          <div className="space-y-3 overflow-y-auto pr-2 custom-scrollbar flex-1">
            {loading ? (
               <div className="text-center text-sm text-gray-400 py-5">Đang tải lịch sử...</div>
            ) : history && history.length > 0 ? (
              history.map((item, idx) => {
                const style = getStatusStyle(item.status);
                return (
                  <div key={idx} className={`p-4 border ${style.box} rounded-xl transition-all`}>
                    <div className="flex justify-between items-center mb-1">
                      <span className={`font-black text-sm ${style.text}`}>{item.title}</span>
                      <span className={`text-[10px] uppercase tracking-wider ${style.badge} px-2 py-1 rounded-full font-bold`}>{item.status || style.label}</span>
                    </div>
                    <p className={`text-xs font-medium mt-2 ${style.subtext}`}>{item.makeupDetails}</p>
                  </div>
                )
              })
            ) : (
              <div className="text-center text-sm text-gray-400 py-10 italic">
                Bạn chưa có đề xuất dạy bù nào.
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MakeupTeaching;