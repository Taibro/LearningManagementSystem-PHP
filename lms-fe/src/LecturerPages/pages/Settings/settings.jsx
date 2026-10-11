import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { CheckCircle2, AlertTriangle, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const Settings = () => {
  const [profile, setProfile] = useState({ fullName: '', email: '', departmentName: '', phone: '', avatarUrl: '' });
  const [loading, setLoading] = useState(true);
  const [savingProfile, setSavingProfile] = useState(false);
  const [savingPwd, setSavingPwd] = useState(false);
  
  // Password states
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });
  const fileInputRef = useRef(null);

  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const fetchProfile = async () => {
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/settings/profile`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setProfile(res.data);
    } catch (err) {
      console.error(err);
      showToast('Lỗi tải thông tin cá nhân', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  const handleUpdateProfile = async () => {
    setSavingProfile(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.put(`${API_BASE_URL}/lecturer/settings/profile`, { phone: profile.phone }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      showToast(res.data || 'Cập nhật số điện thoại thành công!');
    } catch (err) {
      console.error(err);
      showToast(err.response?.data?.message || 'Có lỗi khi cập nhật hồ sơ', 'error');
    } finally {
      setSavingProfile(false);
    }
  };

  const handleChangePassword = async () => {
    if (!currentPassword || !newPassword || !confirmPassword) {
      showToast('Vui lòng điền đủ thông tin mật khẩu', 'error');
      return;
    }
    if (newPassword !== confirmPassword) {
      showToast('Mật khẩu xác nhận không khớp', 'error');
      return;
    }

    setSavingPwd(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const payload = { currentPassword, newPassword, confirmPassword };
      const res = await axios.put(`${API_BASE_URL}/lecturer/settings/password`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });
      showToast(res.data || 'Đổi mật khẩu thành công!');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (err) {
      console.error(err);
      showToast(err.response?.data?.message || 'Có lỗi khi đổi mật khẩu', 'error');
    } finally {
      setSavingPwd(false);
    }
  };

  const handleAvatarChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    try {
      const token = localStorage.getItem('lecturerToken');
      const formData = new FormData();
      formData.append('file', file);
      
      const res = await axios.post(`${API_BASE_URL}/lecturer/settings/avatar`, formData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      setProfile({ ...profile, avatarUrl: res.data });
      showToast('Đổi ảnh đại diện thành công!');
    } catch (err) {
      console.error(err);
      showToast('Không thể tải lên ảnh đại diện', 'error');
    }
  };

  const triggerFileSelect = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const getInitials = (name) => {
    if (!name) return 'GV';
    const parts = name.trim().split(' ');
    if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
    return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
  };

  if (loading) {
    return <div className="p-10 text-center text-gray-400">Đang tải cấu hình...</div>;
  }

  return (
    <div className="animate-fadeIn p-4 md:p-6 bg-gray-50/30 min-h-screen font-sans relative">
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

      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-gray-800">Cài đặt tài khoản</h1>
        <p className="text-gray-400 text-sm mt-1">Quản lý thông tin cá nhân và tuỳ chọn hệ thống</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Cột trái: Form thông tin */}
        <div className="lg:col-span-2 space-y-6">

          {/* Card 1: Thông tin cá nhân */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 transition-all hover:shadow-md">
            <h3 className="font-bold text-gray-800 text-lg mb-6 border-b border-gray-50 pb-3">Thông tin giảng viên</h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Họ và tên</label>
                <input
                  type="text"
                  value={profile.fullName || ''}
                  disabled
                  className="border-[1.5px] border-gray-100 rounded-lg px-4 py-2.5 w-full outline-none text-sm font-medium text-gray-400 bg-gray-100 cursor-not-allowed"
                />
              </div>
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Email (Trường cấp)</label>
                <input
                  type="email"
                  value={profile.email || ''}
                  disabled
                  className="border-[1.5px] border-gray-100 rounded-lg px-4 py-2.5 w-full outline-none text-sm font-medium text-gray-400 bg-gray-100 cursor-not-allowed"
                />
              </div>
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Khoa / Bộ môn</label>
                <input
                  type="text"
                  value={profile.departmentName || ''}
                  disabled
                  className="border-[1.5px] border-gray-100 rounded-lg px-4 py-2.5 w-full outline-none text-sm font-medium text-gray-400 bg-gray-100 cursor-not-allowed"
                />
              </div>
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Số điện thoại</label>
                <input
                  type="text"
                  value={profile.phone || ''}
                  onChange={(e) => setProfile({...profile, phone: e.target.value})}
                  placeholder="Nhập số điện thoại liên hệ"
                  className="border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm font-bold text-purple-700 bg-white"
                />
              </div>
            </div>

            <div className="mt-6 flex justify-end">
              <button 
                onClick={handleUpdateProfile}
                disabled={savingProfile}
                className={`text-white rounded-lg px-8 py-2.5 text-sm font-bold shadow-md transition-all uppercase tracking-widest ${savingProfile ? 'bg-gray-400 cursor-not-allowed' : 'bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] hover:translate-y-[-1px] active:scale-95'}`}
              >
                {savingProfile ? '⏳ Đang lưu...' : <><Save className="w-4 h-4 inline-block mr-2" /> Cập nhật hồ sơ</>}
              </button>
            </div>
          </div>

          {/* Card 2: Đổi mật khẩu */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 transition-all hover:shadow-md">
            <h3 className="font-bold text-gray-800 text-lg mb-6 border-b border-gray-50 pb-3">Đổi mật khẩu</h3>

            <div className="space-y-4 max-w-md">
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Mật khẩu hiện tại</label>
                <input
                  type="password"
                  value={currentPassword}
                  onChange={(e) => setCurrentPassword(e.target.value)}
                  placeholder="••••••••"
                  className="border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-white"
                />
              </div>
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Mật khẩu mới</label>
                <input
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  placeholder="••••••••"
                  className="border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-white"
                />
              </div>
              <div>
                <label className="block text-[11px] font-black text-gray-400 uppercase mb-2 ml-1 tracking-widest">Xác nhận mật khẩu mới</label>
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  placeholder="••••••••"
                  className="border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm bg-white"
                />
              </div>
              <button 
                onClick={handleChangePassword}
                disabled={savingPwd}
                className={`mt-2 bg-white text-[#6B4FA0] border-[1.5px] border-[#6B4FA0] rounded-lg px-6 py-2.5 text-sm font-bold transition-all active:scale-95 ${savingPwd ? 'opacity-50 cursor-not-allowed' : 'hover:bg-purple-50'}`}
              >
                {savingPwd ? 'Đang đổi...' : 'Đổi mật khẩu'}
              </button>
            </div>
          </div>

        </div>

        {/* Cột phải: Avatar & Tùy chọn */}
        <div className="space-y-6">

          {/* Card 3: Ảnh đại diện */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 transition-all hover:shadow-md flex flex-col items-center relative">
            <div className="w-32 h-32 rounded-full p-1 bg-gradient-to-r from-[#6B4FA0] to-[#E85D75] mb-4">
               <div className="w-full h-full bg-white rounded-full flex items-center justify-center overflow-hidden border-2 border-white relative group cursor-pointer" onClick={triggerFileSelect}>
                  {profile.avatarUrl ? (
                    <img src={profile.avatarUrl} alt="Avatar" className="w-full h-full object-cover group-hover:opacity-80 transition-opacity" />
                  ) : (
                    <span className="text-4xl font-black text-[#6B4FA0] group-hover:opacity-50">{getInitials(profile.fullName)}</span>
                  )}
                  <div className="absolute inset-0 bg-black/30 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <span className="text-white text-[10px] font-bold uppercase tracking-wider">Đổi ảnh</span>
                  </div>
               </div>
            </div>
            <input 
              type="file" 
              ref={fileInputRef} 
              onChange={handleAvatarChange} 
              className="hidden" 
              accept="image/*" 
            />
            
            <h4 className="font-bold text-gray-800 text-lg">{profile.fullName || 'Giảng viên'}</h4>
            <span className="px-4 py-1 mt-2 bg-purple-50 text-[#6B4FA0] rounded-full text-[10px] font-bold uppercase tracking-widest border border-purple-100">
              Instructor
            </span>
            <button 
              onClick={triggerFileSelect}
              className="mt-6 w-full text-[11px] font-black text-gray-400 uppercase tracking-widest border-[1.5px] border-gray-200 rounded-lg px-4 py-2.5 hover:border-[#6B4FA0] hover:text-[#6B4FA0] transition-all"
            >
              Upload Avatar mới
            </button>
          </div>

          {/* Card 4: Tùy chọn thông báo */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 transition-all hover:shadow-md">
            <h3 className="font-bold text-gray-800 text-lg mb-4 border-b border-gray-50 pb-3">Thông báo</h3>

            <div className="space-y-4">
              <label className="flex items-center justify-between cursor-pointer group">
                <span className="text-sm font-medium text-gray-600 group-hover:text-[#6B4FA0] transition-colors">Thông báo nộp bài từ sinh viên</span>
                <input type="checkbox" defaultChecked className="w-4 h-4 accent-[#6B4FA0]" />
              </label>
              <label className="flex items-center justify-between cursor-pointer group">
                <span className="text-sm font-medium text-gray-600 group-hover:text-[#6B4FA0] transition-colors">Tin nhắn nội bộ trường</span>
                <input type="checkbox" defaultChecked className="w-4 h-4 accent-[#6B4FA0]" />
              </label>
              <label className="flex items-center justify-between cursor-pointer group">
                <span className="text-sm font-medium text-gray-600 group-hover:text-[#6B4FA0] transition-colors">Nhắc nhở lịch chấm thi</span>
                <input type="checkbox" defaultChecked className="w-4 h-4 accent-[#6B4FA0]" />
              </label>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
};

export default Settings;