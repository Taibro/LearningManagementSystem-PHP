import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { API_BASE_URL } from '../../../config/apiConfig';


const Survey = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchSurvey = async () => {
      try {
        const token = localStorage.getItem('lecturerToken');
        const res = await axios.get(`${API_BASE_URL}/lecturer/evaluations/dashboard`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        setData(res.data);
      } catch (err) {
        console.error("Lỗi tải khảo sát", err);
      } finally {
        setLoading(false);
      }
    };
    fetchSurvey();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[60vh]">
        <div className="text-gray-400 font-bold uppercase tracking-widest text-sm flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div>
          Đang tải kết quả khảo sát...
        </div>
      </div>
    );
  }

  if (!data) {
    return (
      <div className="flex items-center justify-center h-[60vh] text-red-400 font-bold">
        Không thể tải kết quả khảo sát. Vui lòng thử lại sau.
      </div>
    );
  }

  const renderStars = (score) => {
    const rounded = Math.round(score);
    return '★'.repeat(rounded) + '☆'.repeat(5 - rounded);
  };

  return (
    <div className="animate-fadeIn">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Khảo sát</h1>
        <p className="text-gray-400 text-sm mt-1">Kết quả khảo sát giảng dạy từ sinh viên</p>
      </div>

      <div className="grid grid-cols-4 gap-4 mb-5">
        <div className="card p-4 text-center shadow-sm border-b-4 border-purple-500">
          <div className="text-4xl font-black text-purple-700">{data.averageScore?.toFixed(1) || '0.0'}</div>
          <div className="text-yellow-400 text-lg tracking-widest mt-1">{renderStars(data.averageScore || 0)}</div>
          <div className="text-[11px] font-bold text-gray-400 mt-1 uppercase tracking-wider">Điểm TB giảng dạy</div>
        </div>
        <div className="card p-4 text-center shadow-sm border-b-4 border-green-500">
          <div className="text-4xl font-black text-green-600">{data.satisfactionRate}%</div>
          <div className="text-[11px] font-bold text-gray-400 mt-2.5 uppercase tracking-wider">Sinh viên hài lòng</div>
        </div>
        <div className="card p-4 text-center shadow-sm border-b-4 border-blue-500">
          <div className="text-4xl font-black text-blue-600">{data.surveyedClasses}</div>
          <div className="text-[11px] font-bold text-gray-400 mt-2.5 uppercase tracking-wider">Lớp đã khảo sát</div>
        </div>
        <div className="card p-4 text-center shadow-sm border-b-4 border-orange-500">
          <div className="text-4xl font-black text-orange-500">{data.totalResponses}</div>
          <div className="text-[11px] font-bold text-gray-400 mt-2.5 uppercase tracking-wider">Lượt phản hồi</div>
        </div>
      </div>

      <div className="card p-6 mb-5 shadow-sm border border-gray-100">
        <h3 className="font-bold text-gray-700 mb-6 uppercase text-[11px] tracking-widest border-b pb-2">Kết quả theo tiêu chí</h3>
        <div className="space-y-5">
          {[
            { label: 'Kiến thức chuyên môn', val: data.criteriaKnowledge || 0 },
            { label: 'Phương pháp giảng dạy', val: data.criteriaMethod || 0 },
            { label: 'Tương tác với sinh viên', val: data.criteriaInteraction || 0 },
            { label: 'Tài liệu giảng dạy', val: data.criteriaMaterials || 0 },
            { label: 'Đúng giờ, kỷ luật', val: data.criteriaPunctuality || 0 },
          ].map((item, idx) => (
            <div key={idx}>
              <div className="flex justify-between text-sm mb-1.5">
                <span className="text-gray-600 font-bold">{item.label}</span>
                <span className="font-black text-[#6B4FA0]">{item.val.toFixed(1)}/5</span>
              </div>
              <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-gradient-to-r from-[#6B4FA0] to-[#E85D75] rounded-full transition-all duration-1000" 
                  style={{ width: `${(item.val / 5) * 100}%` }}
                ></div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="card p-6 shadow-sm border border-gray-100">
        <h3 className="font-bold text-gray-700 mb-5 uppercase text-[11px] tracking-widest border-b pb-2">Nhận xét từ sinh viên</h3>
        <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
          {data.comments && data.comments.length > 0 ? (
            data.comments.map((cmt, idx) => {
              // Rotate background colors for comments
              const bgs = ['bg-purple-50 border-purple-100', 'bg-blue-50 border-blue-100', 'bg-orange-50 border-orange-100', 'bg-green-50 border-green-100'];
              const bgClass = bgs[idx % bgs.length];
              
              return (
                <div key={idx} className={`p-4 border rounded-xl shadow-sm transition-all ${bgClass}`}>
                  <p className="text-[13px] text-gray-700 font-medium italic">"{cmt.content}"</p>
                  <p className="text-[10px] text-gray-400 mt-2 font-bold uppercase tracking-wider">
                    <span className="text-gray-600">{cmt.classCode}</span> • {cmt.author}
                  </p>
                </div>
              );
            })
          ) : (
            <div className="text-center text-sm text-gray-400 py-10 italic font-medium">
              Chưa có nhận xét nào từ sinh viên.
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Survey;