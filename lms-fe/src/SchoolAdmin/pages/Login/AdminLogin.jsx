import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import SearchableSelect from '../../../components/SearchableSelect';
import './AdminLogin.css';
import { BarChart, Check, CheckCircle2, XCircle, GraduationCap, School, AlertTriangle, Info, PartyPopper, Rocket, Globe, Mail, Lock, EyeOff, Eye, Circle, Upload, Hand, Shield, Zap } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function AdminLogin({ initialSchool }) {
  const navigate = useNavigate();

  // Screen States
  const [activeScreen, setActiveScreen] = useState('school'); // 'school' | 'saas'
  const [schoolView, setSchoolView] = useState('main'); // 'main' | 'forgot' | 'otp' | 'setup'
  const [saasView, setSaasView] = useState('main'); // 'main' | 'otp'
  
  const [tempToken, setTempToken] = useState('');
  const [qrCodeUrl, setQrCodeUrl] = useState('');

  // Input States
  const [sEmail, setSEmail] = useState('admin@hcmut.edu.vn');
  const [sPass, setSPass] = useState('Admin@123');
  const [school, setSchool] = useState(initialSchool || '');
  const [sShowPass, setSShowPass] = useState(false);
  const [sLoading, setSLoading] = useState(false);
  const [sError, setSError] = useState('');
  const [shake, setShake] = useState(false);

  const [saEmail, setSaEmail] = useState('superadmin@edusaas.io');
  const [saPass, setSaPass] = useState('SuperAdmin@2024');
  const [saShowPass, setSaShowPass] = useState(false);
  const [use2fa, setUse2fa] = useState(true);
  const [saLoading, setSaLoading] = useState(false);
  const [saError, setSaError] = useState('');

  // Toast State
  const [toasts, setToasts] = useState([]);
  const [schoolOptions, setSchoolOptions] = useState([]);

  useEffect(() => {
    fetch(`${API_BASE_URL}/schools/active`, { headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` } })
      .then(res => res.json())
      .then(data => setSchoolOptions(data))
      .catch(err => console.error("Failed to fetch schools", err));
  }, []);

  const addToast = (msg, type = 'blue') => {
    const id = Date.now();
    setToasts(prev => [...prev, { id, msg, type }]);
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 4000);
  };

  // --- Handlers ---
  const handleSchoolLogin = async () => {
    setSError('');
    if (!school) return setSError('Vui lòng chọn trường học.');
    if (!sEmail) return setSError('Vui lòng nhập email đăng nhập.');
    if (!sPass) return setSError('Vui lòng nhập mật khẩu.');

    setSLoading(true);
    try {
      const res = await fetch(`${API_BASE_URL}/auth/login`, {
        
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` },
        body: JSON.stringify({ loginCode: sEmail, password: sPass, userType: 'SCHOOL_ADMIN', school: school })
      });
      setSLoading(false);

      if (res.ok) {
        const data = await res.json();
        // Lấy tên thật từ Backend bỏ vô túi áo
        localStorage.setItem('adminToken', data.token); // QUAN TRỌNG: LƯU TOKEN
        localStorage.setItem('adminName', data.fullName || 'Admin');
        localStorage.setItem('adminEmail', data.email || '');

        const selectedSchool = schoolOptions.find(s => s.value === school);
        if (selectedSchool) localStorage.setItem('schoolName', selectedSchool.label);
        localStorage.setItem('schoolShortName', school);
        if (data.requireSetup) {
          setTempToken(data.token);
          fetchQrCode(sEmail);
          setSchoolView('setup');
          addToast('Vui lòng thiết lập Xác thực 2 bước', 'blue');
        } else if (data.require2fa) {
          setTempToken(data.token);
          setSchoolView('otp');
          addToast(`Mã OTP đã gửi đến thiết bị xác thực`, 'blue');
        } else {
          addToast(`Đăng nhập thành công, đang chuyển hướng...`, 'green');
          setTimeout(() => navigate('/dashboard'), 1000);
        }
      } else {
        setSError('Email hoặc mật khẩu không đúng!');
        setShake(true);
        setTimeout(() => setShake(false), 400);
      }
    } catch (err) {
      setSLoading(false);
      setSError('Lỗi kết nối đến máy chủ!');
      setShake(true);
      setTimeout(() => setShake(false), 400);
    }
  };

  const handleSaasLogin = () => {
    setSaError('');
    if (!saEmail) return setSaError('Vui lòng nhập email Super Admin.');
    if (!saPass) return setSaError('Vui lòng nhập mật khẩu.');

    setSaLoading(true);
    setTimeout(() => {
      setSaLoading(false);
      if (saEmail === 'superadmin@edusaas.io' && saPass === 'SuperAdmin@2024') {
        if (use2fa) {
          setSaasView('otp');
          addToast('Mã OTP đã gửi đến thiết bị xác thực', 'blue');
        } else {
          addToast(<><PartyPopper className="w-4 h-4 inline-block mr-2" /> Đăng nhập Super Admin thành công!</>, 'green');
          setTimeout(() => navigate('/admin/dashboard'), 1000);
        }
      } else {
        setSaError('Sai thông tin. Thử: superadmin@edusaas.io / SuperAdmin@2024');
      }
    }, 1600);
  };

  const fetchQrCode = async (email) => {
    try {
      const response = await fetch(`${API_BASE_URL}/auth/2fa/setup`, {
        
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` },
        body: JSON.stringify({ email })
      });
      if (response.ok) {
        const data = await response.json();
        setQrCodeUrl(data.qrCodeImageUri);
      }
    } catch (error) {
      console.error('Error fetching QR code', error);
    }
  };

  const handleVerifySchoolOtp = async (codeOverride) => {
    const inputs = document.querySelectorAll('.school-bg .otp-input');
    const code = typeof codeOverride === 'string' ? codeOverride : Array.from(inputs).map(inp => inp.value).join('');
    
    if (code.length !== 6) {
      return addToast('Vui lòng nhập đủ 6 số OTP', 'red');
    }

    try {
      if (schoolView === 'setup') {
        const response = await fetch(`${API_BASE_URL}/auth/2fa/verify-setup`, {
        
        method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` },
          body: JSON.stringify({ email: sEmail, code })
        });
        if (response.ok) {
          const isValid = await response.json();
          if (isValid) {
            // Setup thành công, gọi luôn login verify
            const loginResp = await fetch(`${API_BASE_URL}/auth/login/verify-2fa`, {
        
        method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${tempToken}`
              },
              body: JSON.stringify({ email: sEmail, code })
            });
            if (loginResp.ok) {
              const data = await loginResp.json();
              localStorage.setItem('adminToken', data.token);
              if (data.schoolId) localStorage.setItem('schoolId', data.schoolId);
              addToast(<><PartyPopper className="w-4 h-4 inline-block mr-2" /> Thiết lập 2FA & Đăng nhập thành công!</>, 'green');
              setTimeout(() => navigate('/dashboard'), 1000);
            } else {
              addToast('Có lỗi xảy ra khi xác thực token thật', 'red');
            }
          } else {
            addToast('Mã OTP không đúng, vui lòng thử lại', 'red');
            setShake(true); setTimeout(() => setShake(false), 400);
          }
        }
      } else {
        const res = await fetch(`${API_BASE_URL}/auth/login/verify-2fa`, {
        
        method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${tempToken}`
          },
          body: JSON.stringify({ email: sEmail, code })
        });

        if (res.ok) {
          const data = await res.json();
          localStorage.setItem('adminToken', data.token); // Lưu token thật
          if (data.schoolId) localStorage.setItem('schoolId', data.schoolId);
          addToast(<><PartyPopper className="w-4 h-4 inline-block mr-2" /> Đăng nhập thành công! Chào mừng Admin!</>, 'green');
          setTimeout(() => navigate('/dashboard'), 1000);
        } else {
          addToast('Mã OTP không chính xác!', 'red');
          setShake(true);
          setTimeout(() => setShake(false), 400);
        }
      }
    } catch (err) {
      addToast('Lỗi kết nối máy chủ', 'red');
    }
  };


  const handleVerifySaasOtp = () => {
    addToast(<><Rocket className="w-4 h-4 inline-block mr-2" /> Super Admin đã xác thực thành công!</>, 'green');
    setTimeout(() => navigate('/dashboard'), 1000); // Đổi hướng đến trang Admin Dashboard
  };

  const handleOtpInput = (e, nextIdx, verifyFunc) => {
    e.target.value = e.target.value.replace(/\D/g, '');
    if (e.target.value && nextIdx < 6) {
      e.target.nextElementSibling?.focus();
    }
    if (nextIdx === 6 && e.target.value) {
      setTimeout(verifyFunc, 300);
    }
  };

  const handleOtpKey = (e, prevIdx) => {
    if (e.key === 'Backspace' && !e.target.value && prevIdx >= 0) {
      e.target.previousElementSibling?.focus();
    }
  };

  return (
    <div className="admin-login-wrapper">
      {/* TOAST WRAPPER */}
      <div className="toast-wrap">
        {toasts.map(t => {
          const colors = { green: '#16a34a', blue: '#2563eb', amber: '#d97706', red: '#dc2626' };
          const icons = { green: <CheckCircle2 className="w-4 h-4 inline-block mr-2" />, blue: <Info className="w-4 h-4 inline-block mr-2" />, amber: <AlertTriangle className="w-4 h-4 inline-block mr-2" />, red: <XCircle className="w-4 h-4 inline-block mr-2" /> };
          return (
            <div key={t.id} className="toast" style={{ borderLeftColor: colors[t.type] || colors.blue }}>
              <span style={{ fontSize: '18px' }}>{icons[t.type]}</span>
              <span style={{ color: '#0f172a', flex: 1 }}>{t.msg}</span>
              <span style={{ color: '#94a3b8', cursor: 'pointer', fontSize: '18px' }} onClick={() => setToasts(prev => prev.filter(x => x.id !== t.id))}>×</span>
            </div>
          );
        })}
      </div>

      {/* =========================================
          SCREEN 1: SCHOOL ADMIN
      ========================================= */}
      <div className={`screen school-bg ${activeScreen === 'school' ? 'active' : ''}`}>
        <div className="blob" style={{ width: 320, height: 320, background: '#bbdefb', opacity: .5, top: -80, left: -80, animationDelay: '0s' }}></div>
        <div className="blob" style={{ width: 240, height: 240, background: '#c8e6c9', opacity: .4, bottom: -60, right: -60, animationDelay: '2s' }}></div>
        <div className="blob" style={{ width: 180, height: 180, background: '#e1bee7', opacity: .3, top: '50%', left: -60, animationDelay: '4s' }}></div>

        <div className={`school-card glass ${shake ? 'shake' : ''}`}>
          <div className="school-header">
            <div style={{ position: 'relative', zIndex: 1 }}>
              <div className="school-logo anim-float"><School className="w-4 h-4 inline-block mr-2" /></div>
              <h1 style={{ fontSize: 20, fontWeight: 800, color: 'white', marginBottom: 4 }}>Cổng quản trị nhà trường</h1>
              <p style={{ fontSize: 12.5, color: 'rgba(255,255,255,.75)', lineHeight: 1.5 }}>Đăng nhập vào hệ thống quản lý lớp học<br />và lịch học của trường bạn</p>
            </div>
          </div>

          {schoolView === 'main' && (
            <div className="school-body">
              <div style={{ position: 'relative', zIndex: 10, marginBottom: 14 }}>
                <label className="fl text-[#64748b] mb-1.5">Trường / Trung tâm</label>
                <SearchableSelect
                  options={schoolOptions}
                  value={school}
                  onChange={setSchool}
                  icon={<School className="w-4 h-4 inline-block mr-2" />}
                  triggerStyle={{ background: '#fff', border: '1px solid #e2e8f0', height: '44px', borderRadius: '10px' }}
                />
              </div>

              <div style={{ marginBottom: 14 }}>
                <label className="fl text-[#64748b] mb-1.5">Email đăng nhập</label>
                <div className="inp-wrap">
                  <span className="inp-icon"><Mail className="w-4 h-4 inline-block mr-2" />️</span>
                  <input type="email" placeholder="admin@school.edu.vn" className="inp school-inp" value={sEmail} onChange={e => setSEmail(e.target.value)} />
                </div>
              </div>

              <div style={{ marginBottom: 6 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                  <label className="fl text-[#64748b] !mb-0">Mật khẩu</label>
                  <span onClick={() => setSchoolView('forgot')} style={{ fontSize: 12, color: '#1976d2', fontWeight: 600, cursor: 'pointer' }}>Quên mật khẩu?</span>
                </div>
                <div className="inp-wrap">
                  <span className="inp-icon"><Lock className="w-4 h-4 inline-block mr-2" /></span>
                  <input type={sShowPass ? "text" : "password"} placeholder="Nhập mật khẩu..." className="inp school-inp" value={sPass} onChange={e => setSPass(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSchoolLogin()} />
                  <span className="inp-eye" onClick={() => setSShowPass(!sShowPass)}>{sShowPass ? <EyeOff className="w-4 h-4 inline-block mr-2" /> : <Eye className="w-4 h-4 inline-block mr-2" />}</span>
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: 8, margin: '12px 0' }}>
                <input type="checkbox" className="cb" defaultChecked />
                <label style={{ fontSize: 13, color: '#475569', cursor: 'pointer' }}>Ghi nhớ đăng nhập</label>
              </div>

              {sError && (
                <div style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 9, padding: '10px 12px', marginBottom: 14, fontSize: 13, color: '#b91c1c', display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span><AlertTriangle className="w-4 h-4 inline-block mr-2" /></span><span>{sError}</span>
                </div>
              )}

              <button className="btn-login school-btn" disabled={sLoading} onClick={handleSchoolLogin}>
                {sLoading ? <span className="spinner"></span> : <><span>Đăng nhập</span><span>→</span></>}
              </button>

              <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '20px 0' }}>
                <div style={{ flex: 1, height: 1, background: '#e2e8f0' }}></div>
                <span style={{ fontSize: 12, color: '#94a3b8', fontWeight: 500 }}>hoặc đăng nhập bằng</span>
                <div style={{ flex: 1, height: 1, background: '#e2e8f0' }}></div>
              </div>

              <div style={{ display: 'flex', gap: 10, marginBottom: 20 }}>
                <button onClick={() => addToast('Đang kết nối Google...', 'blue')} style={{ flex: 1, padding: 10, border: '1.5px solid #e2e8f0', borderRadius: 10, background: 'white', cursor: 'pointer', fontSize: 13, fontWeight: 600, color: '#374151', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
                  <span style={{ fontSize: 16 }}><Circle className="w-4 h-4 inline-block mr-2" /></span> Google
                </button>
                <button onClick={() => addToast('Đang kết nối Microsoft...', 'blue')} style={{ flex: 1, padding: 10, border: '1.5px solid #e2e8f0', borderRadius: 10, background: 'white', cursor: 'pointer', fontSize: 13, fontWeight: 600, color: '#374151', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
                  <span style={{ fontSize: 16 }}>🟦</span> Microsoft
                </button>
              </div>

              <div style={{ textAlign: 'center', paddingTop: 16, borderTop: '1px solid #f1f5f9' }}>
                <p style={{ fontSize: 12.5, color: '#94a3b8' }}>Bạn là Super Admin? <span onClick={() => setActiveScreen('saas')} style={{ color: '#6366f1', fontWeight: 700, cursor: 'pointer' }}>Truy cập SaaS Console →</span></p>
              </div>
            </div>
          )}

          {schoolView === 'forgot' && (
            <div className="school-body">
              <div style={{ textAlign: 'center', marginBottom: 20 }}>
                <div className="anim-float" style={{ fontSize: 40, marginBottom: 12 }}><Mail className="w-4 h-4 inline-block mr-2" /></div>
                <h3 style={{ fontSize: 17, fontWeight: 800, color: '#0f172a', marginBottom: 6 }}>Khôi phục mật khẩu</h3>
                <p style={{ fontSize: 13, color: '#64748b', lineHeight: 1.6 }}>Nhập email đăng ký tài khoản. Chúng tôi sẽ gửi liên kết đặt lại cho bạn.</p>
              </div>
              <div className="inp-wrap" style={{ marginBottom: 16 }}>
                <span className="inp-icon"><Mail className="w-4 h-4 inline-block mr-2" />️</span>
                <input type="email" placeholder="Email tài khoản của bạn" className="inp school-inp" />
              </div>
              <button className="btn-login school-btn" onClick={() => { addToast('Đã gửi link khôi phục', 'green'); setSchoolView('main'); }}><Upload className="w-4 h-4 inline-block mr-2" /> Gửi link khôi phục</button>
              <div style={{ textAlign: 'center', marginTop: 16 }}>
                <span onClick={() => setSchoolView('main')} style={{ fontSize: 13, color: '#1976d2', fontWeight: 600, cursor: 'pointer' }}>← Quay lại đăng nhập</span>
              </div>
            </div>
          )}

          {schoolView === 'otp' && (
            <div className="school-body">
              <div style={{ textAlign: 'center', marginBottom: 22 }}>
                <div className="anim-float" style={{ fontSize: 40, marginBottom: 12 }}><Lock className="w-4 h-4 inline-block mr-2" /></div>
                <h3 style={{ fontSize: 17, fontWeight: 800, color: '#0f172a', marginBottom: 6 }}>Xác thực 2 bước</h3>
                <p style={{ fontSize: 13, color: '#64748b', lineHeight: 1.6 }}>Nhập mã OTP đã gửi đến<br /><strong style={{ color: '#0f172a' }}>a***n@hcmut.edu.vn</strong></p>
              </div>
              <div style={{ display: 'flex', justifyContent: 'center', gap: 10, marginBottom: 20 }}>
                {[0, 1, 2, 3, 4, 5].map(idx => (
                  <input key={idx} className="otp-input" maxLength="1" onInput={e => handleOtpInput(e, idx + 1, () => handleVerifySchoolOtp())} onKeyDown={e => handleOtpKey(e, idx - 1)} />
                ))}
              </div>
              <button className="btn-login school-btn" onClick={() => handleVerifySchoolOtp()}><Check className="w-4 h-4 inline-block mr-2" /> Xác nhận OTP</button>
              <div style={{ textAlign: 'center', marginTop: 14 }}>
                <span onClick={() => setSchoolView('main')} style={{ fontSize: 13, color: '#94a3b8', cursor: 'pointer' }}>← Quay lại</span>
              </div>
            </div>
          )}

          {schoolView === 'setup' && (
            <div className="school-body">
              <div style={{ textAlign: 'center', marginBottom: 20 }}>
                <h3 style={{ fontSize: 18, fontWeight: 900, color: '#0f172a' }}>Thiết lập Token 2FA</h3>
                <p style={{ fontSize: 12.5, color: '#64748b', marginTop: 4 }}>Dùng Authenticator App quét mã QR này</p>
              </div>
              {qrCodeUrl ? (
                <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 20 }}>
                  <img src={qrCodeUrl} alt="QR Code" style={{ width: 160, height: 160, borderRadius: 8, border: '2px solid #e2e8f0' }} />
                </div>
              ) : (
                <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 20, height: 160, alignItems: 'center' }}>
                  <span className="spinner" style={{ borderColor: '#6366f1', borderRightColor: 'transparent' }}></span>
                </div>
              )}
              <div style={{ display: 'flex', justifyContent: 'center', gap: 10, marginBottom: 20 }}>
                {[0, 1, 2, 3, 4, 5].map(idx => (
                  <input key={idx} className="otp-input" maxLength="1" onInput={e => handleOtpInput(e, idx + 1, () => handleVerifySchoolOtp())} onKeyDown={e => handleOtpKey(e, idx - 1)} />
                ))}
              </div>
              <button className="btn-login school-btn" onClick={() => handleVerifySchoolOtp()}><Check className="w-4 h-4 inline-block mr-2" /> Xác nhận thiết lập</button>
              <div style={{ textAlign: 'center', marginTop: 14 }}>
                <span onClick={() => setSchoolView('main')} style={{ fontSize: 13, color: '#94a3b8', cursor: 'pointer' }}>← Hủy</span>
              </div>
            </div>
          )}
        </div>
        <div style={{ position: 'absolute', bottom: 16, left: 0, right: 0, textAlign: 'center', fontSize: 11.5, color: '#94a3b8', zIndex: 10 }}>
          Powered by <strong style={{ color: '#6366f1' }}>EduSaaS Platform</strong> · v3.2
        </div>
      </div>

      {/* =========================================
          SCREEN 2: SAAS SUPER ADMIN
      ========================================= */}
      <div className={`screen saas-screen ${activeScreen === 'saas' ? 'active' : ''}`}>
        <div className="saas-left">
          <div className="grid-lines"></div>
          <div className="blob" style={{ width: 300, height: 300, background: '#6366f1', opacity: .12, top: -80, right: -80 }}></div>
          <div className="blob" style={{ width: 200, height: 200, background: '#a78bfa', opacity: .1, bottom: 20, left: -60 }}></div>

          <div style={{ position: 'relative', zIndex: 10, width: '100%', maxWidth: 460 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 44 }} className="anim-fadeup">
              <div className="saas-logo-mark anim-pulse2">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" /></svg>
              </div>
              <div>
                <div style={{ fontSize: 22, fontWeight: 900, color: 'white', letterSpacing: '-.5px', lineHeight: 1 }}>EduSaaS</div>
                <div style={{ fontSize: 11, color: 'rgba(255,255,255,.45)', fontWeight: 500, letterSpacing: 1, textTransform: 'uppercase' }}>Super Admin Console</div>
              </div>
            </div>

            <div className="anim-fadeup" style={{ animationDelay: '.1s' }}>
              <h1 style={{ fontSize: 34, fontWeight: 900, color: 'white', lineHeight: 1.2, letterSpacing: '-.8px', marginBottom: 14 }}>Quản trị tập trung<br /><span style={{ background: 'linear-gradient(135deg,#a78bfa,#60a5fa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>mọi tổ chức</span></h1>
              <p style={{ fontSize: 14, color: 'rgba(255,255,255,.55)', lineHeight: 1.7, marginBottom: 32 }}>Nền tảng SaaS cho phép bạn quản lý đồng thời<br />nhiều trường học, trung tâm đào tạo từ một console.</p>
            </div>

            <div className="anim-fadeup" style={{ animationDelay: '.2s' }}>
              <div className="feat-item"><div className="feat-icon" style={{ background: 'rgba(99,102,241,.2)' }}><School className="w-4 h-4 inline-block mr-2" /></div><div><div style={{ fontSize: 13.5, fontWeight: 700, color: 'rgba(255,255,255,.9)' }}>Multi-tenant Management</div><div style={{ fontSize: 12, color: 'rgba(255,255,255,.45)', marginTop: 2 }}>Quản lý nhiều trường/trung tâm với data hoàn toàn tách biệt</div></div></div>
              <div className="feat-item"><div className="feat-icon" style={{ background: 'rgba(139,92,246,.2)' }}><BarChart className="w-4 h-4 inline-block mr-2" /></div><div><div style={{ fontSize: 13.5, fontWeight: 700, color: 'rgba(255,255,255,.9)' }}>Analytics Toàn hệ thống</div><div style={{ fontSize: 12, color: 'rgba(255,255,255,.45)', marginTop: 2 }}>Theo dõi MRR, tenant growth, uptime và hoạt động real-time</div></div></div>
              <div className="feat-item"><div className="feat-icon" style={{ background: 'rgba(16,185,129,.2)' }}><Lock className="w-4 h-4 inline-block mr-2" /></div><div><div style={{ fontSize: 13.5, fontWeight: 700, color: 'rgba(255,255,255,.9)' }}>Bảo mật cấp Enterprise</div><div style={{ fontSize: 12, color: 'rgba(255,255,255,.45)', marginTop: 2 }}>2FA, audit logs, role-based access control (RBAC)</div></div></div>
            </div>
          </div>
        </div>

        <div className="saas-right">
          <div style={{ position: 'absolute', top: 20, left: 20 }}>
            <button onClick={() => setActiveScreen('school')} style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '7px 14px', border: '1.5px solid #e2e8f0', borderRadius: 9, background: 'white', fontSize: 12.5, fontWeight: 600, color: '#64748b', cursor: 'pointer' }}>
              ← School Admin Login
            </button>
          </div>

          <div className="saas-card">
            {saasView === 'main' && (
              <>
                <div style={{ marginBottom: 28 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20 }}>
                    <div className="saas-logo-mark" style={{ width: 44, height: 44 }}>
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" /></svg>
                    </div>
                    <div><div style={{ fontSize: 13, fontWeight: 700, color: '#0f172a' }}>EduSaaS Platform</div><div style={{ fontSize: 11, color: '#94a3b8' }}>Super Admin Console</div></div>
                  </div>
                  <h2 style={{ fontSize: 26, fontWeight: 900, color: '#0f172a', letterSpacing: '-.5px', lineHeight: 1.2, marginBottom: 6 }}>Chào mừng trở lại! <Hand className="w-4 h-4 inline-block mr-2" /></h2>
                  <p style={{ fontSize: 13.5, color: '#64748b' }}>Đăng nhập để quản lý toàn bộ hệ thống</p>
                </div>

                <div style={{ marginBottom: 14 }}>
                  <label className="fl text-[#64748b] mb-1.5">Super Admin Email</label>
                  <div className="inp-wrap">
                    <span className="inp-icon"><Mail className="w-4 h-4 inline-block mr-2" />️</span>
                    <input type="email" placeholder="superadmin@edusaas.io" className="inp saas-inp" value={saEmail} onChange={e => setSaEmail(e.target.value)} />
                  </div>
                </div>

                <div style={{ marginBottom: 8 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                    <label className="fl text-[#64748b] !mb-0">Mật khẩu</label>
                  </div>
                  <div className="inp-wrap">
                    <span className="inp-icon"><Lock className="w-4 h-4 inline-block mr-2" /></span>
                    <input type={saShowPass ? "text" : "password"} placeholder="Nhập mật khẩu..." className="inp saas-inp" value={saPass} onChange={e => setSaPass(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSaasLogin()} />
                    <span className="inp-eye" onClick={() => setSaShowPass(!saShowPass)}>{saShowPass ? <EyeOff className="w-4 h-4 inline-block mr-2" /> : <Eye className="w-4 h-4 inline-block mr-2" />}</span>
                  </div>
                </div>

                <div style={{ background: '#f8fafc', border: '1px solid #e2e8f0', borderRadius: 10, padding: '12px 14px', marginBottom: 16, display: 'flex', alignItems: 'center', gap: 10 }}>
                  <span style={{ fontSize: 16 }}><Shield className="w-4 h-4 inline-block mr-2" /></span>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13, fontWeight: 600, color: '#0f172a' }}>Xác thực 2 bước (2FA)</div>
                    <div style={{ fontSize: 11.5, color: '#64748b', marginTop: 1 }}>Yêu cầu OTP sau khi đăng nhập</div>
                  </div>
                  <label style={{ position: 'relative', width: 44, height: 24, flexShrink: 0, cursor: 'pointer' }}>
                    <input type="checkbox" style={{ opacity: 0, width: 0, height: 0 }} checked={use2fa} onChange={() => setUse2fa(!use2fa)} />
                    <span style={{ position: 'absolute', inset: 0, background: use2fa ? '#6366f1' : '#cbd5e1', borderRadius: 12, transition: 'background .15s' }}>
                      <span style={{ width: 18, height: 18, background: 'white', borderRadius: '50%', position: 'absolute', top: 3, left: use2fa ? 23 : 3, transition: 'all .15s', boxShadow: '0 2px 4px rgba(0,0,0,.15)' }}></span>
                    </span>
                  </label>
                </div>

                {saError && (
                  <div style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 9, padding: '10px 12px', marginBottom: 14, fontSize: 13, color: '#b91c1c', display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span><AlertTriangle className="w-4 h-4 inline-block mr-2" /></span><span>{saError}</span>
                  </div>
                )}

                <button className="btn-login saas-btn" disabled={saLoading} onClick={handleSaasLogin}>
                  {saLoading ? <span className="spinner"></span> : <><span>Đăng nhập hệ thống</span><span><Zap className="w-4 h-4 inline-block mr-2" /></span></>}
                </button>
              </>
            )}

            {saasView === 'otp' && (
              <>
                <div style={{ textAlign: 'center', marginBottom: 24 }}>
                  <div className="anim-float" style={{ width: 64, height: 64, borderRadius: 16, background: 'linear-gradient(135deg,#6366f1,#8b5cf6)', margin: '0 auto 16px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26, boxShadow: '0 8px 24px rgba(99,102,241,.3)' }}><Lock className="w-4 h-4 inline-block mr-2" /></div>
                  <h3 style={{ fontSize: 20, fontWeight: 800, color: '#0f172a', marginBottom: 6 }}>Xác thực Super Admin</h3>
                  <p style={{ fontSize: 13, color: '#64748b', lineHeight: 1.6 }}>Mã OTP đã gửi đến thiết bị 2FA<br /><strong style={{ color: '#4f46e5' }}>superadmin@edusaas.io</strong></p>
                </div>
                <div style={{ display: 'flex', justifyContent: 'center', gap: 10, marginBottom: 20 }}>
                  {[0, 1, 2, 3, 4, 5].map(idx => (
                    <input key={idx} className="otp-input" maxLength="1" style={{ borderColor: '#e2e8f0' }} onInput={e => handleOtpInput(e, idx + 1, handleVerifySaasOtp)} onKeyDown={e => handleOtpKey(e, idx - 1)} />
                  ))}
                </div>
                <button className="btn-login saas-btn" onClick={handleVerifySaasOtp}><Zap className="w-4 h-4 inline-block mr-2" /> Xác nhận &amp; Vào hệ thống</button>
                <div style={{ textAlign: 'center', marginTop: 14 }}>
                  <span onClick={() => setSaasView('main')} style={{ fontSize: 13, color: '#94a3b8', cursor: 'pointer' }}>← Quay lại</span>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
