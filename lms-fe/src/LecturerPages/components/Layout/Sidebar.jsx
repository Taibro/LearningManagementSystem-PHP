import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';
import SimpleBar from 'simplebar-react';
import { BarChart, Users, CalendarDays, FileText, Settings, User, DollarSign, FolderOpen, Check, ChevronDown, LineChart, Calendar, StopCircle, RefreshCw, TrendingDown, ClipboardList } from 'lucide-react';

const Sidebar = () => {
  const [isAttendanceOpen, setIsAttendanceOpen] = useState(true);
  const rawSchoolName = localStorage.getItem('schoolName') || 'Đại học Công Thương TP.HCM';
  const schoolName = rawSchoolName.replace(/\n/g, ' ');
  const schoolShort = localStorage.getItem('schoolShortName') || 'HUIT';

  const navClass = ({ isActive }) =>
    `px-4 py-2.5 text-white text-[13px] flex items-center gap-3 transition-all no-underline font-medium mx-2 my-0 rounded-lg outline-none ${
      isActive ? 'bg-white/20 border-l-[3px] border-[#F5A623] shadow-md' : 'hover:bg-white/10 text-gray-100'
    }`;

  const subNavClass = ({ isActive }) =>
    `block px-12 py-2 text-[13px] no-underline transition-all duration-200 ${
      isActive ? 'text-[#F5A623] font-bold bg-white/5' : 'text-purple-100 hover:text-white hover:bg-white/5'
    }`;

  return (
    <aside
      className="w-64 flex-shrink-0 h-screen flex flex-col z-10 text-white shadow-2xl overflow-hidden"
      style={{ background: 'linear-gradient(180deg, #4A3570 0%, #6B4FA0 60%, #8B6BBF 100%)' }}
    >
      <div className="p-4 pb-2 border-b border-white/15 shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center font-bold text-[#6B4FA0] text-sm shadow-inner text-center leading-none tracking-tighter shrink-0">
            {schoolShort}
          </div>
          <div className="overflow-hidden">
            <div 
              className="font-bold text-[12px] leading-tight text-white uppercase tracking-tighter"
              style={{ display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}
            >
              {schoolName}
            </div>
          </div>
        </div>
      </div>

      <SimpleBar className="flex-1 min-h-0 pb-4 sidebar-scroll">
        <div className="text-[10px] tracking-[1.5px] uppercase text-white/40 px-6 pt-3 pb-1 font-black">E-OFFICE</div>

        <div className="text-[10px] tracking-[1.5px] uppercase text-white/40 px-6 pt-2 pb-1 font-black">CÔNG TÁC GIẢNG DẠY</div>

        <NavLink to="/profile" className={navClass}><User className="w-4 h-4 inline-block mr-2" /> Hồ sơ cá nhân</NavLink>
        <NavLink to="/salary" className={navClass}><DollarSign className="w-4 h-4 inline-block mr-2" /> Thông tin lương</NavLink>
        <NavLink to="/declaration" className={navClass}><FileText className="w-4 h-4 inline-block mr-2" /> Khai báo thông tin</NavLink>
        <NavLink to="/documents" className={navClass}><FolderOpen className="w-4 h-4 inline-block mr-2" /> Quản lý tài liệu</NavLink>

        <div className="mt-0">
          <div
            className="px-6 py-2.5 text-white text-[13px] flex items-center justify-between cursor-pointer font-medium hover:bg-white/10 transition-colors mx-2 rounded-lg"
            onClick={() => setIsAttendanceOpen(!isAttendanceOpen)}
          >
            <div className="flex items-center gap-3">
              <span className="text-gray-100 opacity-80"><Check className="w-4 h-4 inline-block mr-2" /></span>
              <span>Chuyên cần - Rèn luyện</span>
            </div>
            <span className={`transition-transform duration-300 text-[10px] ${isAttendanceOpen ? 'rotate-180' : ''}`}><ChevronDown className="w-4 h-4 inline-block mr-2" /></span>
          </div>

          <div className={`overflow-hidden transition-all duration-300 ease-in-out ${isAttendanceOpen ? 'max-h-64 bg-black/10' : 'max-h-0'}`}>
            <NavLink to="/attendance" className={subNavClass}>Điểm danh sinh viên</NavLink>
            <NavLink to="/qr-code" className={subNavClass}>Điểm danh QR Code</NavLink>
            {/* <NavLink to="/assessment" className={subNavClass}>Phiếu đánh giá</NavLink> */}
          </div>
        </div>

        <NavLink to="/results" className={navClass}><BarChart className="w-4 h-4 inline-block mr-2" /> Quản lý kết quả</NavLink>
        <NavLink to="/progress-schedule" className={navClass}><LineChart className="w-4 h-4 inline-block mr-2" /> Lịch theo tiến độ</NavLink>
        <NavLink to="/weekly-schedule" className={navClass}><Calendar className="w-4 h-4 inline-block mr-2" /> Lịch theo tuần</NavLink>

        <div className="text-[10px] tracking-[1.5px] uppercase text-white/40 px-6 pt-3 pb-1 font-black">ĐỀ XUẤT</div>
        <NavLink to="/stop-teaching" className={navClass}><StopCircle className="w-4 h-4 inline-block mr-2" /> Tạm ngừng dạy</NavLink>
        <NavLink to="/makeup-teaching" className={navClass}><RefreshCw className="w-4 h-4 inline-block mr-2" /> Dạy bù</NavLink>
        <NavLink to="/substitute-teaching" className={navClass}><Users className="w-4 h-4 inline-block mr-2" /> Dạy thay</NavLink>

        <div className="text-[10px] tracking-[1.5px] uppercase text-white/40 px-6 pt-3 pb-1 font-black">BÁO CÁO</div>
        <NavLink to="/statistics" className={navClass}><TrendingDown className="w-4 h-4 inline-block mr-2" /> Thống kê thực giảng</NavLink>
        <NavLink to="/survey" className={navClass}><ClipboardList className="w-4 h-4 inline-block mr-2" /> Khảo sát</NavLink>

        <div className="text-[10px] tracking-[1.5px] uppercase text-white/40 px-6 pt-3 pb-1 font-black">HỆ THỐNG</div>
        <NavLink to="/settings" className={navClass}><Settings className="w-4 h-4 inline-block mr-2" /> Cài đặt hệ thống</NavLink>

      </SimpleBar>
    </aside>
  );
};

export default Sidebar;