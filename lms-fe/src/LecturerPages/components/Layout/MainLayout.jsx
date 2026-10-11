import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import { useLecturerContext } from '../../context/LecturerContext';
import NotificationDropdown from '../../../components/NotificationDropdown';

const MainLayout = () => {
  const { classes, activeClass, setActiveClass } = useLecturerContext();

  return (
    <div className="flex h-screen overflow-hidden bg-gray-100">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-hidden relative">
        <div className="topbar bg-white px-6 py-3 flex items-center justify-between border-b border-gray-200">
          <div className="flex items-center gap-2 text-sm">
             <span className="text-gray-500 font-bold">Dashboard</span>
             <span className="text-gray-400">/</span>
             <span className="text-gray-700">HUIT E-Office</span>
          </div>

          <div className="flex items-center gap-6">
            {/* GLOBAL CLASS SELECTOR */}
            {classes && classes.length > 0 && (
              <div className="flex items-center gap-2">
                <span className="text-xs font-bold text-gray-500 uppercase">Lớp đang chọn:</span>
                <select 
                  className="text-sm font-bold bg-purple-50 text-[#6B4FA0] border-none rounded-lg px-3 py-1.5 outline-none cursor-pointer hover:bg-purple-100 transition-colors"
                  value={activeClass?.classId || ''}
                  onChange={(e) => {
                    const selected = classes.find(c => c.classId.toString() === e.target.value);
                    if (selected) setActiveClass(selected);
                  }}
                >
                  {classes.map((c, idx) => (
                    <option key={idx} value={c.classId}>
                      {c.className || c.subjectName || `Lớp học phần ${c.classId}`}
                    </option>
                  ))}
                </select>
              </div>
            )}

            <div className="h-8 w-px bg-gray-200"></div>

             <div className="flex items-center gap-3">
                <div className="text-right">
                  <div className="text-sm font-bold text-gray-800">
                    {localStorage.getItem('lecturerName') || 'Giảng viên'}
                  </div>
                  <div className="text-xs text-gray-400">Giảng viên</div>
                </div>
                
                {/* NOTIFICATIONS */}
                <NotificationDropdown tokenKey="lecturerToken" />
                
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white font-bold text-sm">
                  {localStorage.getItem('lecturerName') ? localStorage.getItem('lecturerName').charAt(0).toUpperCase() : 'GV'}
                </div>
                {/* NÚT ĐĂNG XUẤT */}
                <button 
                  onClick={() => {
                    localStorage.removeItem('lecturerToken');
                    localStorage.removeItem('lecturerName');
                    window.location.href = '/login';
                  }}
                  className="ml-2 px-3 py-1.5 bg-red-50 text-red-600 text-xs font-semibold border border-red-200 rounded-lg hover:bg-red-500 hover:text-white transition-colors"
                >
                  Đăng xuất
                </button>
             </div>
          </div>
        </div>
        <main className="flex-1 overflow-y-auto p-6 bg-[#F4F1F8]">
          <Outlet />
        </main>
      </div>
    </div>
  );
};
export default MainLayout;