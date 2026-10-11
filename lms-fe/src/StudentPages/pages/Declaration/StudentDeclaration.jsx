import React, { useState, useEffect } from 'react';
import { getProfile, updateProfile } from '../../studentApi';
import './StudentDeclaration.css';

export default function StudentDeclaration() {
  const [profile, setProfile] = useState(null);
  const [formData, setFormData] = useState({
    email: '',
    phone: '',
    address: '',
    gender: 'MALE'
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      setLoading(true);
      const data = await getProfile();
      setProfile(data);
      setFormData({
        email: data.email || '',
        phone: data.phone || '',
        address: data.address || '',
        gender: data.gender || 'MALE'
      });
    } catch (err) {
      console.error(err);
      setMessage({ type: 'error', text: 'Không thể tải thông tin sinh viên.' });
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setSaving(true);
      setMessage({ type: '', text: '' });
      await updateProfile(formData);
      setMessage({ type: 'success', text: 'Cập nhật thông tin thành công!' });
      // Fetch fresh data
      fetchProfile();
    } catch (err) {
      console.error(err);
      setMessage({ type: 'error', text: err.response?.data?.message || 'Có lỗi xảy ra khi cập nhật.' });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="student-declaration-loading">Đang tải dữ liệu...</div>;
  }

  if (!profile) return null;

  return (
    <div className="student-declaration-container">
      <div className="student-declaration-header">
        <h2 className="student-declaration-title">Kê khai thông tin sinh viên</h2>
        <p className="student-declaration-subtitle">Cập nhật thông tin liên lạc cá nhân để nhà trường tiện liên hệ.</p>
      </div>

      {message.text && (
        <div className={`student-declaration-alert ${message.type}`}>
          {message.text}
        </div>
      )}

      <form onSubmit={handleSubmit} className="student-declaration-form">
        <div className="form-section-title">Thông tin cơ bản (Không thể chỉnh sửa)</div>
        <div className="form-grid">
          <div className="form-group">
            <label>Mã sinh viên</label>
            <input type="text" value={profile.studentCode || ''} disabled className="readonly-input" />
          </div>
          <div className="form-group">
            <label>Họ và tên</label>
            <input type="text" value={profile.fullName || ''} disabled className="readonly-input" />
          </div>
          <div className="form-group">
            <label>Lớp</label>
            <input type="text" value={profile.className || ''} disabled className="readonly-input" />
          </div>
          <div className="form-group">
            <label>Khoa</label>
            <input type="text" value={profile.departmentName || ''} disabled className="readonly-input" />
          </div>
        </div>

        <div className="form-section-title mt-4">Thông tin liên hệ (Có thể chỉnh sửa)</div>
        <div className="form-grid">
          <div className="form-group">
            <label>Email cá nhân *</label>
            <input 
              type="email" 
              name="email"
              value={formData.email} 
              onChange={handleChange}
              required 
              placeholder="VD: sv@gmail.com"
            />
          </div>
          <div className="form-group">
            <label>Số điện thoại *</label>
            <input 
              type="text" 
              name="phone"
              value={formData.phone} 
              onChange={handleChange}
              required 
              placeholder="VD: 0912345678"
            />
          </div>
          <div className="form-group">
            <label>Giới tính</label>
            <select name="gender" value={formData.gender} onChange={handleChange}>
              <option value="MALE">Nam</option>
              <option value="FEMALE">Nữ</option>
              <option value="OTHER">Khác</option>
            </select>
          </div>
          <div className="form-group full-width">
            <label>Địa chỉ liên hệ</label>
            <textarea 
              name="address"
              value={formData.address} 
              onChange={handleChange}
              rows="3"
              placeholder="Nhập địa chỉ chi tiết (Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố)"
            />
          </div>
        </div>

        <div className="form-actions">
          <button type="submit" disabled={saving} className="btn-save">
            {saving ? 'Đang lưu...' : 'Lưu thông tin'}
          </button>
        </div>
      </form>
    </div>
  );
}
