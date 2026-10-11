import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { CheckCircle2, AlertTriangle } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const SubstituteTeaching = () => {
  const [teachers, setTeachers] = useState([]);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Form states
  const [date, setDate] = useState('');
  const [substituteTeacherId, setSubstituteTeacherId] = useState('');
  const [content, setContent] = useState('');
  const [reason, setReason] = useState('');
  
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

      // Fetch eligible substitute teachers
      const resTeachers = await axios.get(`${API_BASE_URL}/lecturer/substitute-teaching/eligible-teachers`, { headers });
      setTeachers(resTeachers.data);
      if (resTeachers.data.length > 0 && !substituteTeacherId) {
        setSubstituteTeacherId(resTeachers.data[0].teacherId);
      }

      // Fetch history
      const resHistory = await axios.get(`${API_BASE_URL}/lecturer/substitute-teaching/history`, { headers });
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

  const handleSubmit = async () => {
    if (!date || !substituteTeacherId || !content || !reason) {
      showToast('Vui lòng điền đầy đủ các thông tin bắt buộc!', 'error');
      return;
    }

    setSubmitting(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const payload = {
        scheduleId: 1, // Tạm fix vì chưa có dropdown chọn lịch
        exceptionDate: date,
        substituteTeacherId: substituteTeacherId,
        substituteContent: content,
        reason: reason
      };

      const res = await axios.post(`${API_BASE_URL}/lecturer/substitute-teaching/submit`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      showToast(res.data || 'Đã gửi đề xuất thành công!');
      setDate('');
      setContent('');
      setReason('');
      fetchData();
    } catch (err) {
      console.error(err);
      showToast(err.response?.data?.message || 'Có lỗi khi gửi đề xuất', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const getStatusConfig = (status) => {
    switch(status?.toLowerCase()) {
      case 'approved': return { text: 'Đã duyệt', color: 'text-green-600', bg: 'bg-green-50', border: 'border-green-100' };
      case 'rejected': return { text: 'Từ chối', color: 'text-red-500', bg: 'bg-red-50', border: 'border-red-100' };
      default: return { text: 'Đang chờ duyệt', color: 'text-orange-500', bg: 'bg-orange-50', border: 'border-orange-100' };
    }
  };

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
        <h1 className="text-2xl font-bold text-gray-800">Đề xuất dạy thay</h1>
        <p className="text-gray-400 text-sm mt-1 font-medium">Ủy quyền và gửi yêu cầu giảng viên khác dạy thay</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-xl p-6 shadow-sm border border-[#E8E0F5]">
          <h3 className="font-bold text-gray-700 text-[11px] uppercase tracking-[2px] mb-6">Thông tin yêu cầu</h3>

          <div className="space-y-5">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Lớp học phần cần thay</label>
                <select className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-3 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-gray-50/30 font-medium">
                  <option>010110195604 - 14DHTH04 (Giả lập)</option>
                </select>
              </div>
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Ngày dạy cần thay</label>
                <input 
                  type="date" 
                  value={date}
                  onChange={e => setDate(e.target.value)}
                  className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-3 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-gray-50/30 text-purple-700 font-bold" 
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Ca học</label>
                <select className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-3 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-gray-50/30 font-medium">
                  <option>Sáng (Tiết 1-3)</option>
                </select>
              </div>
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Giảng viên dạy thay</label>
                <select 
                  value={substituteTeacherId}
                  onChange={e => setSubstituteTeacherId(e.target.value)}
                  className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-3 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-gray-50/30 font-bold text-purple-700"
                >
                  {teachers.length > 0 ? (
                    teachers.map(t => (
                      <option key={t.teacherId} value={t.teacherId}>{t.displayLabel}</option>
                    ))
                  ) : (
                    <option value="">Không có GV cùng chuyên môn</option>
                  )}
                </select>
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Nội dung bài dạy thay</label>
              <textarea
                value={content}
                onChange={e => setContent(e.target.value)}
                className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-3 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-white min-h-[100px]"
                placeholder="Mô tả chi tiết chương, bài học hoặc nội dung cần truyền đạt..."
              ></textarea>
            </div>

            <div>
              <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Lý do đề xuất</label>
              <textarea
                value={reason}
                onChange={e => setReason(e.target.value)}
                className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-3 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-white min-h-[80px]"
                placeholder="Nhập lý do cụ thể để phòng đào tạo phê duyệt..."
              ></textarea>
            </div>

            <div className="flex gap-4 pt-2">
              <button 
                onClick={handleSubmit}
                disabled={submitting || teachers.length === 0}
                className={`flex-1 text-white rounded-xl px-6 py-3.5 text-sm font-black shadow-lg transition-all uppercase tracking-widest ${submitting || teachers.length === 0 ? 'bg-gray-300 cursor-not-allowed' : 'bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] shadow-purple-200 hover:translate-y-[-2px] active:scale-95'}`}
              >
                {submitting ? 'Đang gửi...' : 'Gửi đề xuất ngay'}
              </button>
              <button onClick={() => { setDate(''); setContent(''); setReason(''); }} className="px-8 py-3.5 border-[1.5px] border-gray-200 text-gray-400 rounded-xl text-sm font-bold hover:bg-gray-50 transition-all active:scale-95 uppercase tracking-widest">
                Xóa form
              </button>
            </div>
          </div>
        </div>

        <div className="space-y-6 flex flex-col h-full max-h-[800px]">
          <div className="bg-white rounded-xl p-6 shadow-sm border border-[#E8E0F5]">
            <h3 className="font-bold text-gray-700 text-[11px] uppercase tracking-widest mb-4">Lưu ý quy trình</h3>
            <ul className="space-y-3">
              <li className="flex gap-3 items-start">
                <span className="w-5 h-5 rounded-full bg-purple-100 text-[#6B4FA0] flex items-center justify-center text-[10px] font-bold shrink-0 mt-0.5">1</span>
                <p className="text-[12px] text-gray-500 leading-relaxed">Đề xuất cần gửi trước buổi dạy ít nhất **24 giờ**.</p>
              </li>
              <li className="flex gap-3 items-start">
                <span className="w-5 h-5 rounded-full bg-purple-100 text-[#6B4FA0] flex items-center justify-center text-[10px] font-bold shrink-0 mt-0.5">2</span>
                <p className="text-[12px] text-gray-500 leading-relaxed">Hệ thống chỉ hiển thị Giảng viên dạy thay thuộc **cùng bộ môn**.</p>
              </li>
              <li className="flex gap-3 items-start">
                <span className="w-5 h-5 rounded-full bg-purple-100 text-[#6B4FA0] flex items-center justify-center text-[10px] font-bold shrink-0 mt-0.5">3</span>
                <p className="text-[12px] text-gray-500 leading-relaxed">Yêu cầu chỉ có hiệu lực sau khi **Trưởng bộ môn** phê duyệt.</p>
              </li>
            </ul>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-[#E8E0F5] flex-1 flex flex-col">
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-bold text-[#6B4FA0] text-[11px] uppercase tracking-widest">Lịch sử dạy thay</h3>
              <button onClick={fetchData} className="text-[10px] text-gray-400 hover:text-purple-600 font-bold uppercase">Làm mới</button>
            </div>
            
            <div className="space-y-3 overflow-y-auto pr-2 custom-scrollbar">
              {loading ? (
                 <div className="text-center text-xs text-gray-400 py-4">Đang tải...</div>
              ) : history && history.length > 0 ? (
                history.map(item => {
                  const conf = getStatusConfig(item.status);
                  return (
                    <div key={item.exceptionId} className={`p-3 border ${conf.border} rounded-lg shadow-sm bg-white`}>
                      <div className="text-[12px] font-bold text-gray-800">{item.title}</div>
                      <div className={`text-[10px] font-bold mt-1.5 uppercase tracking-wider ${conf.color} ${conf.bg} inline-block px-2 py-0.5 rounded-md`}>
                        {conf.text}
                      </div>
                    </div>
                  );
                })
              ) : (
                <div className="text-center text-xs text-gray-400 py-6 italic">
                  Chưa có lịch sử đề xuất.
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SubstituteTeaching;