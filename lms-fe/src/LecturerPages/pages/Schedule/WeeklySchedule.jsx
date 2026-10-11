import React, { useState, useEffect } from 'react';
import Input from '../../components/Layout/Input';
import axios from 'axios';
import { MapPin, ChevronLeft, ChevronRight } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const WeeklySchedule = () => {
  const [selectedDate, setSelectedDate] = useState(() => new Date().toISOString().split('T')[0]);
  const [schedules, setSchedules] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchSchedule = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      // Gọi API của Backend, tự động hiểu GV001 thông qua Token
      const response = await axios.get(`${API_BASE_URL}/lecturer/schedules/weekly-schedule?date=${selectedDate}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setSchedules(response.data);
    } catch (error) {
      console.error("Lỗi khi tải lịch học:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSchedule();
  }, [selectedDate]);

  const handleDateChange = (e) => {
    setSelectedDate(e.target.value);
  };

  const handlePrevWeek = () => {
    const dateObj = new Date(selectedDate);
    dateObj.setDate(dateObj.getDate() - 7);
    setSelectedDate(dateObj.toISOString().split('T')[0]);
  };

  const handleNextWeek = () => {
    const dateObj = new Date(selectedDate);
    dateObj.setDate(dateObj.getDate() + 7);
    setSelectedDate(dateObj.toISOString().split('T')[0]);
  };

  const getMondayOf = (date) => {
    const d = new Date(date);
    const day = d.getDay(); // 0=CN
    const diff = (day === 0) ? -6 : 1 - day;
    d.setDate(d.getDate() + diff);
    return d;
  };

  const monday = getMondayOf(selectedDate);
  const weekDates = [0, 1, 2, 3, 4, 5, 6].map((i) => {
    const d = new Date(monday);
    d.setDate(monday.getDate() + i);
    return d;
  });

  // Hàm nhóm lịch theo Buổi (Sáng/Chiều/Tối) và Thứ (2 -> CN)
  const getSchedulesForSlot = (timeSlot, dayOfWeek) => {
    return schedules.filter(sch => {
      // timeSlot: 'SANG' (Tiết 1-6), 'CHIEU' (Tiết 7-12), 'TOI' (Tiết 13-16)
      const isMorning = sch.startPeriod <= 6;
      const isAfternoon = sch.startPeriod >= 7 && sch.startPeriod <= 12;
      const isEvening = sch.startPeriod >= 13;

      const matchSlot = 
        (timeSlot === 'SANG' && isMorning) ||
        (timeSlot === 'CHIEU' && isAfternoon) ||
        (timeSlot === 'TOI' && isEvening);
      
      // dayOfWeek trong Java thường 1=Thứ 2, 2=Thứ 3... 7=Chủ nhật
      return matchSlot && sch.dayOfWeek === dayOfWeek;
    });
  };

  const renderScheduleCard = (sch, idx) => {
    // Phân loại màu sắc dựa theo SessionType (LT/TH)
    const isTheory = sch.sessionType === 'Lý thuyết' || sch.sessionType === 'LT' || sch.sessionType === 'REGULAR';
    const cardClass = isTheory ? 'schedule-theory' : 'schedule-practice';
    const textColor = isTheory ? 'text-green-800' : 'text-indigo-800';
    const subColor = isTheory ? 'text-green-600' : 'text-indigo-600';
    const iconColor = isTheory ? 'text-green-700' : 'text-indigo-700';

    return (
      <div key={idx} className={`schedule-card ${cardClass} mb-2`}>
        <div className={`font-semibold ${textColor} text-xs`}>{sch.courseName}</div>
        <div className={`${subColor} text-xs mt-1`}>{sch.classCode}</div>
        <div className={`${subColor} text-xs`}>Tiết {sch.startPeriod}–{sch.endPeriod}</div>
        <div className={`${iconColor} text-xs font-medium mt-1`}><MapPin className="w-4 h-4 inline-block mr-2" /> {sch.roomName}</div>
      </div>
    );
  };

  return (
    <div className="animate-fadeIn">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Lịch theo tuần</h1>
          <p className="text-gray-400 text-sm mt-1">Ngày đang chọn: {selectedDate}</p>
        </div>
        
        <div className="flex items-center gap-2 flex-wrap">
          <Input 
            type="date" 
            value={selectedDate} 
            onChange={handleDateChange}
            className="w-36 text-sm" 
          />
          <button onClick={() => setSelectedDate(new Date().toISOString().split('T')[0])} className="btn-primary text-sm px-3 py-1.5">Hiện tại</button>
          <button onClick={handlePrevWeek} className="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 font-medium">‹ Trở về</button>
          <button onClick={handleNextWeek} className="btn-primary text-sm px-3 py-1.5">Tiếp ›</button>
        </div>
      </div>

      <div className="flex gap-4 mb-4 text-sm">
        <div className="flex items-center gap-2"><div className="w-3 h-3 rounded bg-green-400"></div><span className="text-gray-600">Lý thuyết</span></div>
        <div className="flex items-center gap-2"><div className="w-3 h-3 rounded bg-indigo-400"></div><span className="text-gray-600">Thực hành</span></div>
      </div>

      <div className="card overflow-hidden">
        {loading ? (
          <div className="p-10 text-center text-gray-500">Đang tải dữ liệu lịch học từ máy chủ...</div>
        ) : (
          <div className="week-grid">
            {/* Header */}
            <div className="week-header text-xs flex items-center justify-center">Ca học</div>
            {weekDates.map((d, i) => (
              <div key={i} className="week-header flex flex-col items-center justify-center leading-tight py-1.5">
                <span className="font-bold">{i === 6 ? 'CN' : `Thứ ${i + 2}`}</span>
                <span className="text-[10.5px] font-medium text-purple-200 mt-0.5">{d.toLocaleDateString('vi-VN')}</span>
              </div>
            ))}

            {/* Buổi Sáng */}
            <div className="week-cell session-label text-xs font-semibold text-purple-600">SÁNG</div>
            {[2, 3, 4, 5, 6, 7, 8].map(day => (
              <div key={`sang-${day}`} className="week-cell">
                {getSchedulesForSlot('SANG', day).map((sch, i) => renderScheduleCard(sch, i))}
              </div>
            ))}

            {/* Buổi Chiều */}
            <div className="week-cell session-label text-xs font-semibold text-purple-600">CHIỀU</div>
            {[2, 3, 4, 5, 6, 7, 8].map(day => (
              <div key={`chieu-${day}`} className="week-cell">
                {getSchedulesForSlot('CHIEU', day).map((sch, i) => renderScheduleCard(sch, i))}
              </div>
            ))}

            {/* Buổi Tối */}
            <div className="week-cell session-label text-xs font-semibold text-purple-600">TỐI</div>
            {[2, 3, 4, 5, 6, 7, 8].map(day => (
              <div key={`toi-${day}`} className="week-cell">
                {getSchedulesForSlot('TOI', day).map((sch, i) => renderScheduleCard(sch, i))}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default WeeklySchedule;