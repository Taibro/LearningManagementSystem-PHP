import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useLecturerContext } from '../../context/LecturerContext';
import { API_BASE_URL } from '../../../config/apiConfig';


const ProgressSchedule = () => {
  const [schedules, setSchedules] = useState([]);
  const [loading, setLoading] = useState(true);
  const { loadClasses } = useLecturerContext(); // Dùng hook Context

  useEffect(() => {
    const fetchProgress = async () => {
      try {
        const token = localStorage.getItem('lecturerToken');
        const res = await axios.get(`${API_BASE_URL}/lecturer/schedules/progress-schedule`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        setSchedules(res.data);
        
        // Trích xuất danh sách lớp độc nhất để quăng lên Header
        const uniqueClasses = [];
        const classIds = new Set();
        res.data.forEach(item => {
          if (item.classId && !classIds.has(item.classId)) {
            classIds.add(item.classId);
            uniqueClasses.push({
              classId: item.classId,
              className: item.classCode || item.subjectName
            });
          }
        });
        // Lỡ API không trả về classId, mình mock luôn vài lớp để test
        if (uniqueClasses.length === 0) {
          uniqueClasses.push({ classId: 1, className: "14DHTH04 - Quản trị mạng" });
          uniqueClasses.push({ classId: 2, className: "16DHTH10 - Kiến trúc máy tính" });
        }
        
        loadClasses(uniqueClasses); // Bơm lên Header

      } catch (err) {
        console.error("Lỗi lấy tiến độ:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchProgress();
  }, []);

  if (loading) {
    return <div className="text-center p-10 text-gray-500 font-bold">Đang tải tiến độ học phần...</div>;
  }

  return (
    <div className="animate-fadeIn pb-10">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Tiến độ học phần</h1>
        <p className="text-gray-400 text-sm mt-1">Theo dõi số tiết đã dạy trên tổng số tiết của từng môn</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {schedules.map((item, idx) => {
          // Tính phần trăm tiến độ
          const percent = item.totalPeriods > 0 
            ? Math.min(100, Math.round((item.completedPeriods / item.totalPeriods) * 100)) 
            : 0;

          return (
            <div key={idx} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow group">
              <div className="p-5 border-b border-gray-50">
                <div className="flex justify-between items-start mb-2">
                  <span className="px-3 py-1 bg-purple-50 text-[#6B4FA0] text-[10px] font-bold rounded-full uppercase tracking-wider border border-purple-100">
                    {item.classCode || `Lớp ${item.classId}`}
                  </span>
                  <span className="text-xs font-bold text-gray-400">HK2 - 2025</span>
                </div>
                <h3 className="font-bold text-gray-800 text-lg group-hover:text-[#6B4FA0] transition-colors leading-tight line-clamp-2">
                  {item.subjectName}
                </h3>
              </div>
              
              <div className="p-5 bg-gray-50/50">
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-gray-500 font-medium">Tiến độ giảng dạy</span>
                  <span className="font-black text-[#6B4FA0]">{percent}%</span>
                </div>
                
                <div className="w-full bg-gray-200 rounded-full h-2.5 mb-4 overflow-hidden">
                  <div 
                    className="bg-gradient-to-r from-[#6B4FA0] to-[#E85D75] h-2.5 rounded-full transition-all duration-1000"
                    style={{ width: `${percent}%` }}
                  ></div>
                </div>
                
                <div className="flex justify-between text-xs text-gray-500">
                  <div className="flex flex-col items-center p-2 bg-white rounded-lg border border-gray-100 flex-1 mr-2">
                    <span className="font-bold text-gray-800 text-sm mb-0.5">{item.completedPeriods}</span>
                    <span className="uppercase text-[9px] tracking-widest">Đã dạy</span>
                  </div>
                  <div className="flex flex-col items-center p-2 bg-white rounded-lg border border-gray-100 flex-1 ml-2">
                    <span className="font-bold text-gray-800 text-sm mb-0.5">{item.totalPeriods}</span>
                    <span className="uppercase text-[9px] tracking-widest">Tổng tiết</span>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
        {schedules.length === 0 && !loading && (
          <div className="col-span-full p-10 text-center text-gray-500 bg-white rounded-xl shadow-sm border border-gray-100">
            Không tìm thấy dữ liệu tiến độ cho các lớp đang dạy.
          </div>
        )}
      </div>
    </div>
  );
};
export default ProgressSchedule;