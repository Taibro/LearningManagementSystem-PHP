import React, { useState, useEffect } from 'react';
import { Settings as SettingsIcon, Calendar, School, Lock, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Settings() {
  const [stats, setStats] = useState({
    totalStudents: 0,
    totalTeachers: 0,
    totalClasses: 0
  });

  const [activeTab, setActiveTab] = useState('general');

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/dashboard/stats`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setStats(data);
      }
    } catch (err) { }
  };

  return (
    <div className="page" style={{ position: 'relative' }}>

      {/* HEADER TÙY CHỈNH */}
      <div className="ph" style={{ marginBottom: '24px', background: 'linear-gradient(135deg, #0f172a, #1e293b)', padding: '30px', borderRadius: '16px', color: 'white', boxShadow: '0 10px 25px rgba(0,0,0,0.1)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <div style={{ width: '60px', height: '60px', background: 'rgba(255,255,255,0.1)', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '28px', border: '1px solid rgba(255,255,255,0.2)' }}><SettingsIcon className="w-4 h-4 inline-block mr-2" /></div>
          <div>
            <div style={{ fontSize: '24px', fontWeight: '800', letterSpacing: '-0.5px' }}>Cấu hình Hệ thống</div>
            <div style={{ fontSize: '14px', color: '#94a3b8', marginTop: '4px' }}>Trường Đại học Bách Khoa TP.HCM (HCMUT)</div>
          </div>
        </div>
      </div>

      <div style={{ display: 'flex', gap: '24px', alignItems: 'flex-start' }}>

        {/* SIDEBAR TABS */}
        <div style={{ width: '240px', flexShrink: 0, display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <button
            onClick={() => setActiveTab('general')}
            style={{ textAlign: 'left', padding: '12px 16px', borderRadius: '10px', background: activeTab === 'general' ? '#eff6ff' : 'transparent', color: activeTab === 'general' ? '#1d4ed8' : '#64748b', fontWeight: activeTab === 'general' ? '700' : '600', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '10px', transition: 'all 0.2s' }}>
            <span><School className="w-4 h-4 inline-block mr-2" /></span> Thông tin chung
          </button>
          <button
            onClick={() => setActiveTab('academic')}
            style={{ textAlign: 'left', padding: '12px 16px', borderRadius: '10px', background: activeTab === 'academic' ? '#eff6ff' : 'transparent', color: activeTab === 'academic' ? '#1d4ed8' : '#64748b', fontWeight: activeTab === 'academic' ? '700' : '600', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '10px', transition: 'all 0.2s' }}>
            <span><Calendar className="w-4 h-4 inline-block mr-2" /></span> Năm học & Học kỳ
          </button>
          <button
            onClick={() => setActiveTab('security')}
            style={{ textAlign: 'left', padding: '12px 16px', borderRadius: '10px', background: activeTab === 'security' ? '#eff6ff' : 'transparent', color: activeTab === 'security' ? '#1d4ed8' : '#64748b', fontWeight: activeTab === 'security' ? '700' : '600', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '10px', transition: 'all 0.2s' }}>
            <span><Lock className="w-4 h-4 inline-block mr-2" /></span> Bảo mật & API
          </button>

          <div className="card" style={{ marginTop: '20px', padding: '16px', background: 'linear-gradient(135deg, #2563eb, #3b82f6)', color: 'white', border: 'none' }}>
            <div style={{ fontSize: '13px', fontWeight: '700', marginBottom: '12px', color: 'rgba(255,255,255,0.9)' }}>HIỆU SUẤT HỆ THỐNG</div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '12px' }}><span>CPU Usage</span><strong>12%</strong></div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '12px' }}><span>RAM</span><strong>2.4 GB</strong></div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px' }}><span>Database</span><strong style={{ color: '#a7f3d0' }}>Healthy</strong></div>
          </div>
        </div>

        {/* MAIN CONTENT AREA */}
        <div style={{ flex: 1 }}>

          {activeTab === 'general' && (
            <div className="card anim-fadeup" style={{ padding: '24px' }}>
              <div style={{ fontSize: '18px', fontWeight: '700', color: '#0f172a', marginBottom: '24px', paddingBottom: '16px', borderBottom: '1px solid #e2e8f0' }}>Thông tin Cơ sở đào tạo</div>

              <div className="grid2" style={{ gap: '20px' }}>
                <div className="fg">
                  <label className="fl" style={{ fontSize: '13px', color: '#64748b' }}>Mã trường / Định danh</label>
                  <input className="fc" defaultValue="HCMUT" readOnly style={{ background: '#f8fafc', fontWeight: '600', color: '#94a3b8' }} />
                </div>
                <div className="fg">
                  <label className="fl" style={{ fontSize: '13px', color: '#64748b' }}>Tên hiển thị đầy đủ</label>
                  <input className="fc" defaultValue="Trường Đại học Bách Khoa TP.HCM" style={{ fontWeight: '500' }} />
                </div>
              </div>

              <div className="grid2" style={{ gap: '20px', marginTop: '16px' }}>
                <div className="fg">
                  <label className="fl" style={{ fontSize: '13px', color: '#64748b' }}>Email liên hệ</label>
                  <input className="fc" defaultValue="info@hcmut.edu.vn" />
                </div>
                <div className="fg">
                  <label className="fl" style={{ fontSize: '13px', color: '#64748b' }}>Số điện thoại</label>
                  <input className="fc" defaultValue="028-3865-4086" />
                </div>
              </div>

              <div className="fg" style={{ marginTop: '16px' }}>
                <label className="fl" style={{ fontSize: '13px', color: '#64748b' }}>Địa chỉ trụ sở chính</label>
                <textarea className="fc" rows="2" defaultValue="268 Lý Thường Kiệt, Phường 14, Quận 10, Thành phố Hồ Chí Minh"></textarea>
              </div>

              <div style={{ marginTop: '30px', display: 'flex', justifyContent: 'flex-end' }}>
                <button className="btn btn-blue" style={{ padding: '10px 24px', fontSize: '14px' }}><Save className="w-4 h-4 inline-block mr-2" /> Lưu thay đổi</button>
              </div>
            </div>
          )}

          {activeTab === 'academic' && (
            <div className="card anim-fadeup" style={{ padding: '24px' }}>
              <div style={{ fontSize: '18px', fontWeight: '700', color: '#0f172a', marginBottom: '24px', paddingBottom: '16px', borderBottom: '1px solid #e2e8f0' }}>Thiết lập Học kỳ</div>

              <div style={{ background: '#f8fafc', padding: '20px', borderRadius: '12px', border: '1px solid #e2e8f0', marginBottom: '24px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                  <div style={{ width: '40px', height: '40px', background: '#3b82f6', color: 'white', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>🕒</div>
                  <div>
                    <div style={{ fontSize: '15px', fontWeight: '700', color: '#0f172a' }}>Học kỳ đang diễn ra</div>
                    <div style={{ fontSize: '13px', color: '#64748b' }}>Hệ thống sẽ lấy dữ liệu dựa trên học kỳ này</div>
                  </div>
                </div>

                <div className="grid2" style={{ gap: '16px' }}>
                  <div className="fg">
                    <label className="fl" style={{ fontSize: '12px' }}>Học kỳ mặc định</label>
                    <select className="fc" style={{ fontWeight: '600' }}>
                      <option>Học kỳ 1 - Năm học 2024-2025</option>
                      <option>Học kỳ 2 - Năm học 2024-2025</option>
                    </select>
                  </div>
                  <div className="grid2" style={{ gap: '12px' }}>
                    <div className="fg">
                      <label className="fl" style={{ fontSize: '12px' }}>Ngày bắt đầu</label>
                      <input type="date" className="fc" defaultValue="2024-09-09" />
                    </div>
                    <div className="fg">
                      <label className="fl" style={{ fontSize: '12px' }}>Ngày kết thúc</label>
                      <input type="date" className="fc" defaultValue="2025-01-10" />
                    </div>
                  </div>
                </div>
              </div>

              <div style={{ fontSize: '15px', fontWeight: '700', color: '#0f172a', marginBottom: '16px' }}>Thống kê hiện tại</div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
                <div style={{ border: '1px solid #e2e8f0', padding: '16px', borderRadius: '12px', textAlign: 'center' }}>
                  <div style={{ fontSize: '28px', fontWeight: '800', color: '#10b981' }}>{stats.totalStudents}</div>
                  <div style={{ fontSize: '12px', color: '#64748b', fontWeight: '600' }}>SINH VIÊN ACTIVE</div>
                </div>
                <div style={{ border: '1px solid #e2e8f0', padding: '16px', borderRadius: '12px', textAlign: 'center' }}>
                  <div style={{ fontSize: '28px', fontWeight: '800', color: '#3b82f6' }}>{stats.totalTeachers}</div>
                  <div style={{ fontSize: '12px', color: '#64748b', fontWeight: '600' }}>GIẢNG VIÊN ACTIVE</div>
                </div>
                <div style={{ border: '1px solid #e2e8f0', padding: '16px', borderRadius: '12px', textAlign: 'center' }}>
                  <div style={{ fontSize: '28px', fontWeight: '800', color: '#f59e0b' }}>{stats.totalClasses}</div>
                  <div style={{ fontSize: '12px', color: '#64748b', fontWeight: '600' }}>LỚP HỌC ĐANG MỞ</div>
                </div>
              </div>

              <div style={{ marginTop: '30px', display: 'flex', justifyContent: 'flex-end' }}>
                <button className="btn btn-blue" style={{ padding: '10px 24px', fontSize: '14px' }}>Cập nhật Học kỳ</button>
              </div>
            </div>
          )}

          {activeTab === 'security' && (
            <div className="card anim-fadeup" style={{ padding: '24px' }}>
              <div style={{ fontSize: '18px', fontWeight: '700', color: '#0f172a', marginBottom: '24px', paddingBottom: '16px', borderBottom: '1px solid #e2e8f0' }}>Bảo mật & Tích hợp</div>

              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px', border: '1px solid #e2e8f0', borderRadius: '10px', marginBottom: '16px' }}>
                <div>
                  <div style={{ fontSize: '15px', fontWeight: '600', color: '#0f172a' }}>Xác thực 2 Bước (2FA)</div>
                  <div style={{ fontSize: '13px', color: '#64748b', marginTop: '2px' }}>Bắt buộc tất cả Admin và Giảng viên phải dùng OTP</div>
                </div>
                <label className="toggle" style={{ position: 'relative', width: '48px', height: '24px', display: 'inline-block' }}>
                  <input type="checkbox" defaultChecked style={{ opacity: 0, width: 0, height: 0 }} />
                  <span style={{ position: 'absolute', cursor: 'pointer', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: '#10b981', borderRadius: '34px' }}>
                    <span style={{ position: 'absolute', height: '18px', width: '18px', left: '26px', bottom: '3px', backgroundColor: 'white', borderRadius: '50%', transition: '0.3s' }}></span>
                  </span>
                </label>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px', border: '1px solid #e2e8f0', borderRadius: '10px', marginBottom: '24px' }}>
                <div>
                  <div style={{ fontSize: '15px', fontWeight: '600', color: '#0f172a' }}>Cho phép đăng nhập từ xa</div>
                  <div style={{ fontSize: '13px', color: '#64748b', marginTop: '2px' }}>Giới hạn IP mạng nội bộ trường học đối với Admin</div>
                </div>
                <label className="toggle" style={{ position: 'relative', width: '48px', height: '24px', display: 'inline-block' }}>
                  <input type="checkbox" style={{ opacity: 0, width: 0, height: 0 }} />
                  <span style={{ position: 'absolute', cursor: 'pointer', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: '#cbd5e1', borderRadius: '34px' }}>
                    <span style={{ position: 'absolute', height: '18px', width: '18px', left: '4px', bottom: '3px', backgroundColor: 'white', borderRadius: '50%', transition: '0.3s' }}></span>
                  </span>
                </label>
              </div>

              <div className="fg">
                <label className="fl" style={{ fontSize: '13px', color: '#64748b' }}>API Key Hệ thống (Read-only)</label>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <input type="password" className="fc" defaultValue="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" readOnly style={{ fontFamily: 'monospace' }} />
                  <button className="btn btn-ghost" style={{ border: '1px solid #e2e8f0' }}>Làm mới</button>
                </div>
              </div>
            </div>
          )}

        </div>
      </div>
    </div>
  );
}
