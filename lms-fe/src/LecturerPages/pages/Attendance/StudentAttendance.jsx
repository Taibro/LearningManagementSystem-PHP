import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useLecturerContext } from '../../context/LecturerContext';
import { BarChart, Calendar, RefreshCw, CheckCircle2, AlertTriangle, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const StudentAttendance = () => {
  const today = new Date().toISOString().split('T')[0];
  const [date, setDate] = useState(today);
  
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });

  const { activeClass } = useLecturerContext();
  const classId = activeClass?.classId;
  const scheduleId = activeClass?.classId || 1; // Tạm xài classId làm scheduleId vì API cần cả 2
  const teacherId = 1; // Có thể lấy từ UserDetails sau

  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const fetchAttendance = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/attendance?classId=${classId}&scheduleId=${scheduleId}&date=${date}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setData(res.data);
    } catch (err) {
      console.error("Lỗi lấy danh sách điểm danh:", err);
      // Nếu API lỗi (chưa có lớp này), ta set rỗng
      setData({ totalStudents: 0, totalPresent: 0, totalAbsent: 0, presentPercentage: 0, students: [] });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (classId) {
      fetchAttendance();
    }
  }, [date, classId]);

  const handleStatusChange = (studentId, newStatus) => {
    if (!data) return;
    
    const updatedStudents = data.students.map(st => 
      st.studentId === studentId ? { ...st, status: newStatus } : st
    );

    // Tính lại thống kê
    const presentCount = updatedStudents.filter(st => st.status === 'PRESENT').length;
    const absentCount = updatedStudents.length - presentCount;
    const percent = updatedStudents.length === 0 ? 0 : Math.round((presentCount / updatedStudents.length) * 100);

    setData({
      ...data,
      students: updatedStudents,
      totalPresent: presentCount,
      totalAbsent: absentCount,
      presentPercentage: percent
    });
  };

  const handleSave = async () => {
    if (!data || data.students.length === 0) return;
    setSaving(true);
    
    try {
      const token = localStorage.getItem('lecturerToken');
      const payload = {
        scheduleId: scheduleId,
        classId: classId,
        attendanceDate: date,
        teacherId: teacherId,
        records: data.students.map(st => ({
          studentId: st.studentId,
          status: st.status || 'PRESENT' // Mặc định là có mặt nếu chưa có gì
        }))
      };

      const res = await axios.post(`${API_BASE_URL}/lecturer/attendance/save`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });
      showToast(res.data || 'Đã lưu điểm danh thành công!');
    } catch (err) {
      console.error(err);
      showToast(err.response?.data?.message || 'Có lỗi xảy ra!', 'error');
    } finally {
      setSaving(false);
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

      <div className="mb-6 flex justify-between items-end">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Điểm danh sinh viên</h1>
          <p className="text-gray-400 text-sm mt-1">Quản lý chuyên cần buổi học</p>
        </div>
        <div className="bg-white border-[1.5px] border-[#6B4FA0] px-3 py-1.5 rounded-xl shadow-sm flex items-center gap-2">
          <span className="text-[#6B4FA0] font-black text-xs"><Calendar className="w-4 h-4 inline-block mr-2" /> Ngày:</span>
          <input 
            type="date" 
            value={date} 
            onChange={e => setDate(e.target.value)}
            className="text-[#6B4FA0] font-bold text-xs outline-none bg-transparent" 
          />
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div className="card p-5 border-l-4 border-[#6B4FA0] flex flex-col items-center shadow-sm">
          <div className="text-gray-400 text-[10px] font-black uppercase tracking-tighter">Sĩ số</div>
          <div className="text-3xl font-black text-gray-800 mt-1">{data?.students?.length || 0}</div>
        </div>
        <div className="card p-5 border-l-4 border-[#4CAF50] flex flex-col items-center shadow-sm">
          <div className="text-[#4CAF50] text-[10px] font-black uppercase tracking-tighter">Có mặt</div>
          <div className="text-3xl font-black text-[#2E7D32] mt-1">{data?.totalPresent || 0}</div>
        </div>
        <div className="card p-5 border-l-4 border-[#E85D75] flex flex-col items-center shadow-sm">
          <div className="text-[#E85D75] text-[10px] font-black uppercase tracking-tighter">Vắng</div>
          <div className="text-3xl font-black text-[#C62828] mt-1">{data?.totalAbsent || 0}</div>
        </div>
        <div className="card p-5 border-l-4 border-[#F5A623] flex flex-col items-center shadow-sm">
          <div className="text-[#F5A623] text-[10px] font-black uppercase tracking-tighter">Tỷ lệ</div>
          <div className="text-3xl font-black text-[#F5A623] mt-1">{data?.presentPercentage || 0}%</div>
        </div>
      </div>

      <div className="card overflow-hidden shadow-sm border border-gray-100">
        <div className="p-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/30">
          <h3 className="font-bold text-gray-700 uppercase text-[10px] tracking-widest ml-2">
            Danh sách điểm danh {loading && '(Đang tải...)'}
          </h3>
          <div className="flex gap-2">
             <button className="btn-outline text-[10px] py-1.5 px-4 font-bold"><BarChart className="w-4 h-4 inline-block mr-2" /> Excel</button>
             <button onClick={fetchAttendance} className="bg-[#E85D75] text-white rounded-lg text-[10px] py-1.5 px-4 font-bold hover:opacity-90"><RefreshCw className="w-4 h-4 inline-block mr-2" /> Tải lại</button>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 text-gray-500 border-b">
                <th className="px-6 py-4 text-left font-bold uppercase text-[10px]">STT</th>
                <th className="px-6 py-4 text-left font-bold uppercase text-[10px]">Sinh viên</th>
                <th className="px-6 py-4 text-center font-bold uppercase text-[10px] text-[#4CAF50]">Có mặt</th>
                <th className="px-6 py-4 text-center font-bold uppercase text-[10px] text-[#F5A623]">Phép</th>
                <th className="px-6 py-4 text-center font-bold uppercase text-[10px] text-[#E85D75]">KP</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {data && data.students && data.students.length > 0 ? (
                data.students.map((st, idx) => {
                  const status = st.status || 'PRESENT'; // Mặc định hiển thị
                  return (
                    <tr key={st.studentId} className="hover:bg-[#F9F7FF] transition-all">
                      <td className="px-6 py-4 text-gray-400 font-bold">{idx + 1}</td>
                      <td className="px-6 py-4">
                        <div className="font-bold text-gray-700">{st.fullName}</div>
                        <div className="text-[10px] font-bold text-gray-400 uppercase">MSSV: {st.studentCode}</div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <input type="radio" name={`at-${st.studentId}`} className="w-5 h-5 accent-[#4CAF50] cursor-pointer" 
                          checked={status === 'PRESENT'} onChange={() => handleStatusChange(st.studentId, 'PRESENT')} />
                      </td>
                      <td className="px-6 py-4 text-center">
                        <input type="radio" name={`at-${st.studentId}`} className="w-5 h-5 accent-[#F5A623] cursor-pointer" 
                          checked={status === 'EXCUSED'} onChange={() => handleStatusChange(st.studentId, 'EXCUSED')} />
                      </td>
                      <td className="px-6 py-4 text-center">
                        <input type="radio" name={`at-${st.studentId}`} className="w-5 h-5 accent-[#E85D75] cursor-pointer" 
                          checked={status === 'ABSENT'} onChange={() => handleStatusChange(st.studentId, 'ABSENT')} />
                      </td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan="5" className="px-6 py-10 text-center text-gray-400 italic font-medium">
                    {loading ? 'Đang tải danh sách sinh viên...' : 'Không có sinh viên nào hoặc lớp chưa được xếp lịch học hôm nay.'}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        <div className="p-5 bg-gray-50/50 border-t border-gray-100 flex justify-end">
           <button 
              onClick={handleSave}
              disabled={saving || !data || data.students.length === 0}
              className={`px-10 py-3 font-bold uppercase text-xs tracking-widest shadow-xl rounded-lg text-white ${saving ? 'bg-gray-400' : 'bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] hover:opacity-90 shadow-purple-200'}`}
           >
              {saving ? '⏳ Đang lưu...' : <><Save className="w-4 h-4 inline-block mr-2" /> Lưu dữ liệu điểm danh</>}
           </button>
        </div>
      </div>
    </div>
  );
};

export default StudentAttendance;