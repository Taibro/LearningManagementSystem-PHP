import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const Profile = () => {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ text: '', type: '' });

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
      console.error('Lỗi khi tải hồ sơ:', err);
      setMessage({ text: 'Lỗi khi tải thông tin từ máy chủ!', type: 'error' });
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setProfile(prev => ({ ...prev, [name]: value }));
  };

  const handleUpdate = async () => {
    setSaving(true);
    setMessage({ text: '', type: '' });
    try {
      const token = localStorage.getItem('lecturerToken');
      // Gửi dữ liệu cập nhật
      await axios.put(`${API_BASE_URL}/lecturer/profile`, profile, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setMessage({ text: 'Cập nhật hồ sơ thành công!', type: 'success' });
      // Cập nhật lại tên trên thanh topbar nếu có đổi tên
      localStorage.setItem('lecturerName', profile.fullName);
      
      // Xóa thông báo sau 3 giây
      setTimeout(() => setMessage({ text: '', type: '' }), 3000);
    } catch (err) {
      console.error('Lỗi khi cập nhật:', err);
      setMessage({ text: 'Lỗi cập nhật. Vui lòng thử lại!', type: 'error' });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="p-10 text-center text-gray-500">Đang tải hồ sơ từ máy chủ...</div>;
  }

  if (!profile) return null;

  return (
    <div className="animate-fadeIn">
      <div className="mb-6 flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Hồ sơ cá nhân</h1>
          <p className="text-gray-400 text-sm mt-1">Quản lý thông tin mã số: {profile.teacherCode}</p>
        </div>
        {message.text && (
          <div className={`px-4 py-2 rounded-lg text-sm font-medium ${message.type === 'success' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
            {message.text}
          </div>
        )}
      </div>

      <div className="grid grid-cols-3 gap-5">
        {/* Cột trái: Avatar & Vai trò */}
        <div className="card p-6 flex flex-col items-center">
          <div className="w-24 h-24 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-3xl font-bold mb-4 shadow-lg">
            {profile.fullName ? profile.fullName.charAt(0).toUpperCase() : 'GV'}
          </div>
          <h3 className="font-bold text-gray-800 text-lg text-center">{profile.fullName}</h3>
          <p className="text-gray-400 text-sm mt-1">{profile.degree || 'Giảng viên'}</p>
          <p className="text-purple-600 text-sm font-medium mt-1 text-center">{profile.departmentName || 'Chưa cập nhật bộ môn'}</p>
          
          <div className="mt-6 w-full pt-6 border-t border-gray-100 text-sm text-gray-500 space-y-2">
            <div className="flex justify-between"><span>Mã NV:</span> <span className="font-medium text-gray-700">{profile.teacherCode}</span></div>
            <div className="flex justify-between"><span>Môn chính:</span> <span className="font-medium text-gray-700">{profile.primaryTeachingCourse || 'Chưa có'}</span></div>
          </div>
          <button className="btn-outline mt-6 text-sm w-full">📷 Đổi ảnh đại diện</button>
        </div>

        {/* Cột phải: Form cập nhật thông tin */}
        <div className="card p-6 col-span-2">
          <h3 className="font-semibold text-gray-700 mb-5 border-b pb-3">Thông tin chi tiết</h3>
          <div className="grid grid-cols-2 gap-x-6 gap-y-4">
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Họ và tên</label>
              <input name="fullName" value={profile.fullName || ''} onChange={handleInputChange} className="input-field text-sm bg-gray-50" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Ngày sinh</label>
              <input name="dateOfBirth" type="date" value={profile.dateOfBirth || ''} onChange={handleInputChange} className="input-field text-sm" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Giới tính</label>
              <select name="gender" value={profile.gender || 'MALE'} onChange={handleInputChange} className="input-field text-sm">
                <option value="MALE">Nam</option>
                <option value="FEMALE">Nữ</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Số CMND/CCCD</label>
              <input name="citizenIdNumber" value={profile.citizenIdNumber || ''} onChange={handleInputChange} className="input-field text-sm" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Email liên hệ</label>
              <input name="email" value={profile.email || ''} onChange={handleInputChange} className="input-field text-sm" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Số điện thoại</label>
              <input name="phone" value={profile.phone || ''} onChange={handleInputChange} className="input-field text-sm" />
            </div>
            <div className="col-span-2">
              <label className="block text-xs font-semibold text-gray-500 mb-1">Địa chỉ thường trú</label>
              <input name="address" value={profile.address || ''} onChange={handleInputChange} className="input-field text-sm" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Trình độ học vấn</label>
              <select name="degree" value={profile.degree || ''} onChange={handleInputChange} className="input-field text-sm">
                <option value="Cử nhân">Cử nhân</option>
                <option value="Thạc sĩ">Thạc sĩ</option>
                <option value="Tiến sĩ">Tiến sĩ</option>
                <option value="Phó Giáo sư">Phó Giáo sư</option>
                <option value="Giáo sư">Giáo sư</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 mb-1">Chuyên ngành</label>
              <input name="specialization" value={profile.specialization || ''} onChange={handleInputChange} className="input-field text-sm" />
            </div>
          </div>
          
          <div className="mt-8 flex justify-end">
            <button 
              onClick={handleUpdate} 
              disabled={saving}
              className="btn-primary text-sm min-w-[160px] flex items-center justify-center"
            >
              {saving ? '⏳ Đang lưu...' : <><Save className="w-4 h-4 inline-block mr-2" /> Cập nhật thông tin</>}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Profile;