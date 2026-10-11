import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Bell } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/statistics/dashboard`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setStats(res.data);
    } catch (err) {
      console.error("Lỗi khi tải Dashboard:", err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="p-10 text-center text-gray-500">Đang tải dữ liệu tổng quan...</div>;
  }

  // Nếu API không trả về gì (hoặc backend bị lỗi) thì dùng số 0
  const totalClasses = stats?.classDetails?.length || 0;
  const totalPeriods = stats?.totalPeriods || 0;
  const upcomingExams = stats?.upcomingExamShifts || 0;
  const remindersCount = stats?.reminders?.length || 0;

  return (
    <div className="animate-fadeIn">
      <div className="mb-6 flex justify-between items-end">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Tổng quan hệ thống</h1>
          <p className="text-gray-400 text-sm mt-1">Học kỳ hiện tại: <span className="font-semibold text-purple-600">{stats?.currentSemesterLabel || 'Đang cập nhật'}</span></p>
        </div>
      </div>

      {/* 4 Thẻ Thống Kê */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <div className="stat-card shadow-sm" style={{ background: 'linear-gradient(135deg,#6B4FA0,#8B6BBF)' }}>
          <div className="text-white text-xs opacity-80 font-semibold tracking-wider">TỔNG SỐ LỚP ĐANG DẠY</div>
          <div className="text-white text-3xl font-bold mt-1">{totalClasses}</div>
        </div>
        <div className="stat-card shadow-sm" style={{ background: 'linear-gradient(135deg,#4CAF50,#66BB6A)' }}>
          <div className="text-white text-xs opacity-80 font-semibold tracking-wider">SỐ TIẾT ĐÃ DẠY</div>
          <div className="text-white text-3xl font-bold mt-1">{totalPeriods}</div>
        </div>
        <div className="stat-card shadow-sm" style={{ background: 'linear-gradient(135deg,#2196F3,#42A5F5)' }}>
          <div className="text-white text-xs opacity-80 font-semibold tracking-wider">CA GÁC THI SẮP TỚI</div>
          <div className="text-white text-3xl font-bold mt-1">{upcomingExams}</div>
        </div>
        <div className="stat-card shadow-sm" style={{ background: 'linear-gradient(135deg,#F5A623,#FFB74D)' }}>
          <div className="text-white text-xs opacity-80 font-semibold tracking-wider">THÔNG BÁO MỚI</div>
          <div className="text-white text-3xl font-bold mt-1">{remindersCount}</div>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-6">
        {/* Bảng Tiến độ Lớp học */}
        <div className="card p-5 col-span-2 shadow-sm">
          <h3 className="font-bold text-gray-700 mb-4 border-b pb-2">Tiến độ giảng dạy các lớp</h3>
          {stats?.classDetails && stats.classDetails.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead>
                  <tr className="text-gray-500 border-b">
                    <th className="pb-2 font-medium">Môn học</th>
                    <th className="pb-2 font-medium">Mã lớp</th>
                    <th className="pb-2 font-medium text-center">Đã dạy</th>
                    <th className="pb-2 font-medium text-center">Tiến độ</th>
                  </tr>
                </thead>
                <tbody>
                  {stats.classDetails.map((cls, idx) => (
                    <tr key={idx} className="border-b last:border-0 hover:bg-gray-50">
                      <td className="py-3 font-semibold text-gray-700">{cls.subjectName}</td>
                      <td className="py-3 text-purple-600 font-medium">{cls.classCode}</td>
                      <td className="py-3 text-center text-gray-600">{cls.completedPeriods} / {cls.totalPeriods} tiết</td>
                      <td className="py-3">
                        <div className="flex items-center gap-2 justify-center">
                          <div className="w-24 bg-gray-200 rounded-full h-2.5">
                            <div className="bg-purple-600 h-2.5 rounded-full" style={{ width: `${cls.progressPercentage}%` }}></div>
                          </div>
                          <span className="text-xs font-bold text-gray-700">{cls.progressPercentage}%</span>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="text-sm text-gray-500 py-4 text-center italic">Chưa có dữ liệu lớp học nào trong học kỳ này.</p>
          )}
        </div>

        {/* Cột Nhắc nhở */}
        <div className="card p-5 shadow-sm">
          <h3 className="font-bold text-gray-700 mb-4 border-b pb-2">Nhắc nhở hệ thống <Bell className="w-4 h-4 inline-block mr-2" /></h3>
          {stats?.reminders && stats.reminders.length > 0 ? (
            <ul className="space-y-3">
              {stats.reminders.map((rem, idx) => (
                <li key={idx} className="flex gap-2 text-sm text-gray-600 bg-orange-50 p-3 rounded-lg border border-orange-100">
                  <span>👉</span> <span>{rem}</span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-sm text-gray-500 italic text-center py-4">Bạn không có nhắc nhở nào.</p>
          )}
          
          <div className="mt-6 bg-blue-50 p-4 rounded-lg border border-blue-100">
            <h4 className="font-semibold text-blue-800 text-sm mb-1">Tiến độ tổng quan</h4>
            <div className="flex items-end gap-2">
              <span className="text-3xl font-extrabold text-blue-600">{stats?.overallProgress || 0}%</span>
              <span className="text-xs text-blue-500 mb-1">hoàn thành</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;