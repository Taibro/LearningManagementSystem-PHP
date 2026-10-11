import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { RefreshCw, CheckCircle2, AlertTriangle, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const Declaration = () => {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState({
    expectedSessions: 120,
    expectedClasses: 5,
    notes: ''
  });
  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });

  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/profile`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setProfile(res.data);
    } catch (err) {
      console.error('Lỗi khi tải thông tin giảng viên:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async () => {
    if (!profile) return;
    setSaving(true);
    
    // Hack nhỏ: Tách số từ GV001 thành ID = 1 để gửi cho Backend
    let tId = 1; 
    if (profile.teacherCode) {
      const numMatch = profile.teacherCode.match(/\d+/);
      if (numMatch) tId = parseInt(numMatch[0]);
    }

    try {
      const token = localStorage.getItem('lecturerToken');
      const payload = {
        teacherId: tId,
        semesterId: 1, // Tạm fix cứng vì frontend chưa có api get học kỳ
        expectedSessions: parseInt(formData.expectedSessions),
        expectedClasses: parseInt(formData.expectedClasses),
        notes: formData.notes
      };

      const res = await axios.post(`${API_BASE_URL}/lecturer/teacher-declarations`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      showToast(res.data || 'Đã lưu khai báo giảng dạy thành công!', 'success');
    } catch (err) {
      console.error('Lỗi lưu khai báo:', err);
      showToast(err.response?.data?.message || 'Có lỗi xảy ra khi lưu khai báo!', 'error');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="p-10 text-center text-gray-500">Đang tải biểu mẫu...</div>;
  }

  return (
    <div className="animate-fadeIn relative">
      {/* Toast Notification */}
      {toast.show && (
        <div style={{
          position: 'fixed', top: 24, right: 24, zIndex: 10000,
          background: toast.type === 'success' ? '#10b981' : '#ef4444',
          color: 'white', padding: '14px 24px', borderRadius: 8,
          boxShadow: '0 10px 25px rgba(0,0,0,0.2)', fontWeight: 600, fontSize: 14,
          transition: 'all 0.3s ease-out'
        }}>
          {toast.type === 'success' ? <><CheckCircle2 className="w-4 h-4 inline-block mr-2" /> </> : <><AlertTriangle className="w-4 h-4 inline-block mr-2" /> </>}{toast.msg}
        </div>
      )}

      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Khai báo thông tin</h1>
        <p className="text-gray-400 text-sm mt-1">Cập nhật thông tin giảng dạy học kỳ</p>
      </div>
      
      <div className="card p-6 shadow-sm border border-gray-100">
        <div className="grid grid-cols-2 gap-x-6 gap-y-5">
          <div>
            <label className="block text-sm font-semibold text-gray-600 mb-1.5">Họ và tên giảng viên</label>
            <input className="input-field bg-gray-50 cursor-not-allowed font-medium text-purple-700" value={profile?.fullName || ''} readOnly />
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-600 mb-1.5">Mã giảng viên</label>
            <input className="input-field bg-gray-50 cursor-not-allowed font-medium text-gray-700" value={profile?.teacherCode || ''} readOnly />
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-600 mb-1.5">Khoa / Bộ môn</label>
            <input className="input-field bg-gray-50 cursor-not-allowed font-medium text-gray-700" value={profile?.departmentName || 'Chưa cập nhật'} readOnly />
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-600 mb-1.5">Học kỳ khai báo</label>
            <select className="input-field font-medium">
              <option value="1">HK2 - 2025-2026</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-600 mb-1.5">Số tiết dạy dự kiến</label>
            <input type="number" name="expectedSessions" className="input-field" value={formData.expectedSessions} onChange={handleInputChange} />
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-600 mb-1.5">Số lớp phụ trách</label>
            <input type="number" name="expectedClasses" className="input-field" value={formData.expectedClasses} onChange={handleInputChange} />
          </div>
          <div className="col-span-2">
            <label className="block text-sm font-semibold text-gray-600 mb-1.5">Ghi chú (Tùy chọn)</label>
            <textarea name="notes" className="input-field" rows="3" placeholder="Nhập ghi chú hoặc yêu cầu phòng máy (nếu có)..." value={formData.notes} onChange={handleInputChange}></textarea>
          </div>
        </div>
        
        <div className="flex gap-4 mt-8 pt-5 border-t border-gray-100">
          <button 
            onClick={handleSubmit} 
            disabled={saving}
            className="btn-primary min-w-[150px] flex justify-center items-center font-semibold"
          >
            {saving ? '⏳ Đang xử lý...' : <><Save className="w-4 h-4 inline-block mr-2" /> Lưu khai báo</>}
          </button>
          <button onClick={() => setFormData({ expectedSessions: 120, expectedClasses: 5, notes: '' })} className="btn-outline font-semibold"><RefreshCw className="w-4 h-4 inline-block mr-2" /> Đặt lại</button>
        </div>
      </div>
    </div>
  );
};

export default Declaration;