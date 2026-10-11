import React, { useState } from 'react';
import './SaaSAdminLogin.css';
import { CheckCircle2, XCircle, GraduationCap, School, Key, AlertTriangle, Info, Mail, Lock, EyeOff, Eye, Shield } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function SaaSAdminLogin() {
  // Không dùng useNavigate nữa, vì ta cần nhảy hẳn sang App khác

  // Tự động nhận diện: Nếu link là /saas/login -> Bật sẵn giao diện SaaS Dark Mode
  const [activeScreen, setActiveScreen] = useState(
    window.location.pathname.includes('/saas') ? 'saas' : 'school'
  );
  const [schoolView, setSchoolView] = useState('main'); // main | forgot | otp
  const [saasView, setSaasView] = useState('main'); // main | otp | setup

  const [tempToken, setTempToken] = useState('');
  const [qrCodeUrl, setQrCodeUrl] = useState('');

  // Form State Cổng Trường Học
  const [sSchool, setSSchool] = useState('');
  const [sEmail, setSEmail] = useState('');
  const [sPass, setSPass] = useState('');
  const [sShowPass, setSShowPass] = useState(false);
  const [sLoading, setSLoading] = useState(false);
  const [sError, setSError] = useState('');
  const [sShake, setSShake] = useState(false);

  // Form State Cổng Toàn Cục SaaS
  const [saEmail, setSaEmail] = useState('');
  const [saPass, setSaPass] = useState('');
  const [saShowPass, setSaShowPass] = useState(false);
  const [use2fa, setUse2fa] = useState(true);
  const [saLoading, setSaLoading] = useState(false);
  const [saError, setSaError] = useState('');
  const [saShake, setSaShake] = useState(false);

  const [toasts, setToasts] = useState([]);

  const showToast = (msg, type = 'blue') => {
    const id = Date.now();
    setToasts(prev => [...prev, { id, msg, type }]);
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 3500);
  };

  /* ==========================================
     XỬ LÝ ĐĂNG NHẬP & OTP CHO ADMIN SCHOOL
  ========================================== */
  const handleSchoolLogin = async () => {
    setSError('');
    if (!sSchool) return setSError('Vui lòng chọn trường / trung tâm.');
    if (!sEmail) return setSError('Vui lòng nhập email đăng nhập.');
    if (!sPass) return setSError('Vui lòng nhập mật khẩu.');

    setSLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userType: 'SCHOOL_ADMIN',
          loginCode: sEmail,
          password: sPass
        })
      });

      const data = await response.json();
      setSLoading(false);

      if (!response.ok) {
        setSError(data.message || 'Email hoặc mật khẩu không đúng.');
        setSShake(true);
        setTimeout(() => setSShake(false), 400);
        return;
      }

      localStorage.setItem('school_token', data.token);
      localStorage.setItem('school_user', JSON.stringify(data));

      setSchoolView('otp');
      showToast('Mã OTP đã được gửi đến email của bạn', 'green');
    } catch (err) {
      setSLoading(false);
      setSError('Không thể kết nối đến Backend Server. Vui lòng thử lại sau.');
      setSShake(true);
      setTimeout(() => setSShake(false), 400);
    }
  };

  // NHẢY VỀ SCHOOL ADMIN
  const verifySchoolOtp = () => {
    showToast('Đăng nhập thành công! Đang chuyển hướng...', 'green');
    setTimeout(() => {
      window.location.href = '/dashboard'; // Ép trình duyệt nhảy về luồng Admin School
    }, 800);
  };

  /* ==========================================
     XỬ LÝ ĐĂNG NHẬP & OTP CHO SAAS ENGINE
  ========================================== */
  const handleSaasLogin = async () => {
    setSaError('');
    if (!saEmail) return setSaError('Vui lòng nhập email Super Admin.');
    if (!saPass) return setSaError('Vui lòng nhập mật khẩu.');

    setSaLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userType: 'SAAS_ADMIN',
          loginCode: saEmail,
          password: saPass
        })
      });

      const data = await response.json();
      setSaLoading(false);

      if (!response.ok) {
        setSaError(data.message || 'Tài khoản hệ thống hoặc mật khẩu không chính xác.');
        setSaShake(true);
        setTimeout(() => setSaShake(false), 400);
        return;
      }

      if (data.requireSetup) {
        setTempToken(data.token);
        fetchQrCode(saEmail);
        setSaasView('setup');
        showToast('Vui lòng thiết lập Xác thực 2 bước', 'blue');
      } else if (data.require2fa) {
        setTempToken(data.token);
        setSaasView('otp');
        showToast('Mã OTP từ Authenticator App', 'blue');
      } else {
        localStorage.setItem('saas_token', data.token);
        localStorage.setItem('saas_user', JSON.stringify(data));
        showToast('Đăng nhập thành công!', 'green');
        setTimeout(() => window.location.href = '/saas/dashboard', 800);
      }
    } catch (err) {
      setSaLoading(false);
      setSaError('Không thể kết nối đến Backend Server. Vui lòng thử lại sau.');
      setSaShake(true);
      setTimeout(() => setSaShake(false), 400);
    }
  };

  const fetchQrCode = async (email) => {
    try {
      const response = await fetch(`${API_BASE_URL}/auth/2fa/setup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
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

  // NHẢY VỀ SAAS DASHBOARD
  const verifySaasOtp = async (codeOverride) => {
    const inputs = document.querySelectorAll('.saas-screen .otp-input');
    const code = typeof codeOverride === 'string' ? codeOverride : Array.from(inputs).map(inp => inp.value).join('');
    if (code.length !== 6) return;

    try {
      if (saasView === 'setup') {
        const response = await fetch(`${API_BASE_URL}/auth/2fa/verify-setup`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email: saEmail, code })
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
              body: JSON.stringify({ email: saEmail, code })
            });
            if (loginResp.ok) {
              const data = await loginResp.json();
              localStorage.setItem('saas_token', data.token);
              localStorage.setItem('saas_user', JSON.stringify(data));

              showToast('Xác thực & Thiết lập thành công!', 'green');
              setTimeout(() => {
                window.location.href = '/saas/dashboard';
              }, 800);
            } else {
              showToast('Có lỗi xảy ra khi đăng nhập', 'red');
            }
          } else {
            showToast('Mã OTP không đúng, vui lòng thử lại', 'red');
          }
        }
      } else {
        const response = await fetch(`${API_BASE_URL}/auth/login/verify-2fa`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${tempToken}`
          },
          body: JSON.stringify({ email: saEmail, code })
        });

        if (response.ok) {
          const data = await response.json();
          localStorage.setItem('saas_token', data.token);
          localStorage.setItem('saas_user', JSON.stringify(data));

          showToast('Xác thực Super Admin thành công!', 'green');
          setTimeout(() => {
            window.location.href = '/saas/dashboard';
          }, 800);
        } else {
          showToast('Mã OTP không đúng hoặc đã hết hạn', 'red');
        }
      }
    } catch (err) {
      showToast('Lỗi kết nối máy chủ xác thực', 'red');
    }
  };

  const handleOtpInput = (e, nextIdx, finalCallback) => {
    e.target.value = e.target.value.replace(/\D/g, '');
    if (e.target.value && nextIdx < 6) e.target.nextElementSibling?.focus();
    if (nextIdx === 6 && e.target.value) setTimeout(finalCallback, 300);
  };

  const handleOtpKeyDown = (e, prevIdx) => {
    if (e.key === 'Backspace' && !e.target.value && prevIdx >= 0) e.target.previousElementSibling?.focus();
  };

  return (
    <div className="saas-login-portal">
      <div className="toast-stack">
        {toasts.map(t => {
          const borders = { green: '#16a34a', blue: '#2563eb', amber: '#d97706', red: '#dc2626' };
          const icons = { green: <CheckCircle2 className="w-4 h-4 inline-block mr-2" />, blue: <Info className="w-4 h-4 inline-block mr-2" />, amber: <AlertTriangle className="w-4 h-4 inline-block mr-2" />, red: <XCircle className="w-4 h-4 inline-block mr-2" /> };
          return (
            <div key={t.id} className="toast" style={{ borderLeftColor: borders[t.type] || borders.blue }}>
              <span style={{ fontSize: '16px' }}>{icons[t.type]}</span>
              <span style={{ flex: 1, color: '#0f172a' }}>{t.msg}</span>
              <span style={{ color: '#94a3b8', cursor: 'pointer' }} onClick={() => setToasts(prev => prev.filter(x => x.id !== t.id))}>×</span>
            </div>
          );
        })}
      </div>

      {/* 1. MÀN HÌNH ĐĂNG NHẬP TRƯỜNG HỌC */}
      <div className={`screen school-bg ${activeScreen === 'school' ? 'active' : ''}`}>
        <div className="blob" style={{ width: 320, height: 320, background: '#bbdefb', opacity: 0.5, top: -80, left: -80 }}></div>
        <div className="blob" style={{ width: 240, height: 240, background: '#c8e6c9', opacity: 0.4, bottom: -60, right: -60 }}></div>

        <div className={`school-card glass ${sShake ? 'shake' : ''}`}>
          <div className="school-header">
            <div className="school-logo anim-float"><School className="w-4 h-4 inline-block mr-2" /></div>
            <h1 style={{ fontSize: '20px', fontWeight: 800, color: 'white', marginBottom: '4px' }}>Cổng quản trị nhà trường</h1>
            <p style={{ fontSize: '12px', color: 'rgba(255,255,255,.8)', lineHeight: 1.5 }}>Đăng nhập hệ thống quản lý đào tạo, khóa học<br />và lịch học phân tán</p>
          </div>

          {schoolView === 'main' && (
            <div className="school-body">
              <div style={{ marginBottom: '16px' }}>
                <label className="form-label" style={{ color: '#64748b', marginBottom: '6px' }}>Chọn đơn vị đào tạo</label>
                <div className="inp-wrap">
                  <span className="inp-icon"><School className="w-4 h-4 inline-block mr-2" /></span>
                  <select className="inp school-inp" style={{ appearance: 'none', cursor: 'pointer' }} value={sSchool} onChange={e => setSSchool(e.target.value)}>
                    <option value="">-- Chọn trường / trung tâm --</option>
                    <option value="hcmut"><GraduationCap className="w-4 h-4 inline-block mr-2" /> Trường ĐH Bách Khoa TP.HCM (HCMUT)</option>
                    <option value="huit"><GraduationCap className="w-4 h-4 inline-block mr-2" /> Trường ĐH Công Thương (HUIT)</option>
                  </select>
                  <span style={{ position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)', color: '#94a3b8', pointerEvents: 'none' }}>▾</span>
                </div>
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label className="form-label" style={{ color: '#64748b', marginBottom: '6px' }}>Email đăng nhập</label>
                <div className="inp-wrap">
                  <span className="inp-icon"><Mail className="w-4 h-4 inline-block mr-2" />️</span>
                  <input type="email" className="inp school-inp" placeholder="admin@school.edu.vn" value={sEmail} onChange={e => setSEmail(e.target.value)} />
                </div>
              </div>

              <div style={{ marginBottom: '8px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                  <label className="form-label" style={{ color: '#64748b', margin: 0 }}>Mật khẩu</label>
                  <span onClick={() => setSchoolView('forgot')} style={{ fontSize: '12px', color: '#1976d2', fontWeight: 600, cursor: 'pointer' }}>Quên mật khẩu?</span>
                </div>
                <div className="inp-wrap">
                  <span className="inp-icon"><Lock className="w-4 h-4 inline-block mr-2" /></span>
                  <input type={sShowPass ? 'text' : 'password'} className="inp school-inp" placeholder="Nhập mật khẩu..." value={sPass} onChange={e => setSPass(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSchoolLogin()} />
                  <span className="inp-eye" onClick={() => setSShowPass(!sShowPass)}>{sShowPass ? <EyeOff className="w-4 h-4 inline-block mr-2" /> : <Eye className="w-4 h-4 inline-block mr-2" />}</span>
                </div>
              </div>

              {sError && (
                <div style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: '8px', padding: '10px', marginTop: '14px', fontSize: '13px', color: '#b91c1c', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span><AlertTriangle className="w-4 h-4 inline-block mr-2" /></span><span>{sError}</span>
                </div>
              )}

              <button className="btn-login school-btn mb-4" style={{ marginTop: '16px' }} disabled={sLoading} onClick={handleSchoolLogin}>
                {sLoading ? <span className="spinner"></span> : <><span>Tiếp tục xác thực OTP</span><span>→</span></>}
              </button>

              <div style={{ textAlign: 'center', paddingTop: '14px', borderTop: '1px solid #f1f5f9' }}>
                <p style={{ fontSize: '12.5px', color: '#94a3b8' }}>Bạn quản trị toàn cục? <span onClick={() => setActiveScreen('saas')} style={{ color: '#6366f1', fontWeight: 700, cursor: 'pointer' }}>Vào SaaS Engine →</span></p>
              </div>
            </div>
          )}

          {schoolView === 'otp' && (
            <div className="school-body">
              <div style={{ textAlign: 'center', marginBottom: '20px' }}>
                <div className="anim-float" style={{ fontSize: '36px', marginBottom: '8px' }}><Lock className="w-4 h-4 inline-block mr-2" /></div>
                <h3 style={{ fontSize: '16px', fontWeight: 800, color: '#0f172a' }}>Xác thực bảo mật OTP</h3>
                <p style={{ fontSize: '12.5px', color: '#64748b', marginTop: '4px' }}>Nhập chuỗi mã an toàn đã được hệ thống gửi về email của nhà trường.</p>
              </div>
              <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginBottom: '20px' }}>
                {[0, 1, 2, 3, 4, 5].map(idx => (
                  <input key={idx} className="otp-input" maxLength="1" onInput={e => handleOtpInput(e, idx + 1, verifySchoolOtp)} onKeyDown={e => handleOtpKeyDown(e, idx - 1)} />
                ))}
              </div>
              <button className="btn-login school-btn" onClick={verifySchoolOtp}>Xác nhận & Vào hệ thống</button>
              <div style={{ textAlign: 'center', marginTop: '14px' }}>
                <span onClick={() => setSchoolView('main')} style={{ fontSize: '13px', color: '#1976d2', fontWeight: 600, cursor: 'pointer' }}>← Quay lại</span>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* 2. MÀN HÌNH ĐĂNG NHẬP SAAS GLOBAL */}
      <div className={`screen saas-screen ${activeScreen === 'saas' ? 'active' : ''}`}>
        <div className="saas-left">
          <div className="grid-lines"></div>
          <div style={{ position: 'relative', zIndex: 10, width: '100%', maxWidth: '440px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '36px' }} className="anim-fadeup">
              <div className="saas-logo-mark anim-pulse">Σ</div>
              <div>
                <div style={{ fontSize: '20px', fontWeight: 900, color: 'white', lineHeight: 1 }}>EduSaaS</div>
                <div style={{ fontSize: '10px', color: 'rgba(255,255,255,.5)', letterSpacing: '1px', textTransform: 'uppercase', marginTop: '3px' }}>Global Core Dashboard</div>
              </div>
            </div>

            <div className="anim-fadeup" style={{ animationDelay: '.1s' }}>
              <h1 style={{ fontSize: '32px', fontWeight: 900, color: 'white', lineHeight: 1.2, marginBottom: '14px' }}>Giám sát hạ tầng<br /><span style={{ background: 'linear-gradient(135deg,#a78bfa,#60a5fa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>Multi-tenant cloud</span></h1>
              <p style={{ fontSize: '13.5px', color: 'rgba(255,255,255,.55)', lineHeight: 1.6, marginBottom: '24px' }}>Cổng console an toàn điều khiển tài nguyên phần cứng, database cô lập và vòng đời subscription của từng tenant.</p>
            </div>
          </div>
        </div>

        <div className="saas-right">
          <div style={{ position: 'absolute', top: '20px', left: '20px' }}>
            <button onClick={() => { setActiveScreen('school'); setSError(''); }} style={{ padding: '6px 12px', border: '1.5px solid #e2e8f0', borderRadius: '8px', background: 'white', fontSize: '12px', fontWeight: 600, color: '#64748b', cursor: 'pointer' }}>← Cổng Nhà Trường</button>
          </div>

          <div className="saas-card anim-fadeup">
            {saasView === 'main' && (
              <div className={saShake ? 'shake' : ''}>
                <div style={{ marginBottom: '24px' }}>
                  <h2 style={{ fontSize: '24px', fontWeight: 900, color: '#0f172a', letterSpacing: '-.5px' }}>SaaS Root Access</h2>
                  <p style={{ fontSize: '13px', color: '#64748b', marginTop: '2px' }}>Yêu cầu tài khoản Super Admin quyền cao nhất</p>
                </div>

                <div style={{ marginBottom: '14px' }}>
                  <label className="form-label" style={{ color: '#64748b', marginBottom: '4px' }}>Super Admin Email</label>
                  <div className="inp-wrap">
                    <span className="inp-icon"><Key className="w-4 h-4 inline-block mr-2" /></span>
                    <input type="email" className="inp saas-inp" placeholder="superadmin@edusaas.io" value={saEmail} onChange={e => setSaEmail(e.target.value)} />
                  </div>
                </div>

                <div style={{ marginBottom: '14px' }}>
                  <label className="form-label" style={{ color: '#64748b', marginBottom: '4px' }}>Mật khẩu bảo mật</label>
                  <div className="inp-wrap">
                    <span className="inp-icon"><Lock className="w-4 h-4 inline-block mr-2" /></span>
                    <input type={saShowPass ? 'text' : 'password'} className="inp saas-inp" placeholder="••••••••" value={saPass} onChange={e => setSaPass(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSaasLogin()} />
                    <span className="inp-eye" onClick={() => setSaShowPass(!saShowPass)}>{saShowPass ? <EyeOff className="w-4 h-4 inline-block mr-2" /> : <Eye className="w-4 h-4 inline-block mr-2" />}</span>
                  </div>
                </div>

                <div style={{ background: '#f8fafc', border: '1px solid #e2e8f0', borderRadius: '10px', padding: '12px', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <span style={{ fontSize: '16px' }}><Shield className="w-4 h-4 inline-block mr-2" />️</span>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: '13px', fontWeight: 600, color: '#0f172a' }}>Bắt buộc mã hóa 2FA</div>
                    <div style={{ fontSize: '11px', color: '#64748b', marginTop: '1px' }}>Xác thực qua Authenticator App</div>
                  </div>
                  <label style={{ position: 'relative', width: 44, height: 24, cursor: 'pointer' }}>
                    <input type="checkbox" style={{ opacity: 0, width: 0, height: 0 }} checked={use2fa} onChange={() => setUse2fa(!use2fa)} />
                    <span style={{ position: 'absolute', inset: 0, background: use2fa ? '#6366f1' : '#cbd5e1', borderRadius: '12px', transition: 'all .2s' }}>
                      <span style={{ width: 18, height: 18, background: 'white', borderRadius: '50%', position: 'absolute', top: 3, left: use2fa ? 23 : 3, transition: 'all .2s' }}></span>
                    </span>
                  </label>
                </div>

                {saError && (
                  <div style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: '8px', padding: '10px', marginBottom: '14px', fontSize: '13px', color: '#b91c1c' }}><AlertTriangle className="w-4 h-4 inline-block mr-2" /> {saError}</div>
                )}

                <button className="btn-login saas-btn" disabled={saLoading} onClick={handleSaasLogin}>
                  {saLoading ? <span className="spinner"></span> : <span>Tiếp tục xác thực Token</span>}
                </button>
              </div>
            )}

            {saasView === 'otp' && (
              <div>
                <div style={{ textAlign: 'center', marginBottom: '20px' }}>
                  <h3 style={{ fontSize: '18px', fontWeight: 900, color: '#0f172a' }}>Thiết bị Token 2FA</h3>
                  <p style={{ fontSize: '12.5px', color: '#64748b', marginTop: '4px' }}>Nhập mã an toàn từ Authenticator App của bạn</p>
                </div>
                <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginBottom: '20px' }}>
                  {[0, 1, 2, 3, 4, 5].map(idx => (
                    <input key={idx} className="otp-input" maxLength="1" onInput={e => handleOtpInput(e, idx + 1, verifySaasOtp)} onKeyDown={e => handleOtpKeyDown(e, idx - 1)} />
                  ))}
                </div>
                <button className="btn-login saas-btn" onClick={() => verifySaasOtp()}>Xác minh & Khởi động Console</button>
                <div style={{ textAlign: 'center', marginTop: '14px' }}>
                  <span onClick={() => setSaasView('main')} style={{ fontSize: '13px', color: '#64748b', fontWeight: 600, cursor: 'pointer' }}>← Hủy</span>
                </div>
              </div>
            )}

            {saasView === 'setup' && (
              <div>
                <div style={{ textAlign: 'center', marginBottom: '20px' }}>
                  <h3 style={{ fontSize: '18px', fontWeight: 900, color: '#0f172a' }}>Thiết lập Token 2FA</h3>
                  <p style={{ fontSize: '12.5px', color: '#64748b', marginTop: '4px' }}>Dùng Authenticator App quét mã QR này</p>
                </div>
                {qrCodeUrl ? (
                  <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px' }}>
                    <img src={qrCodeUrl} alt="QR Code" style={{ width: 160, height: 160, borderRadius: 8, border: '2px solid #e2e8f0' }} />
                  </div>
                ) : (
                  <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px', height: 160, alignItems: 'center' }}>
                    <span className="spinner" style={{ borderColor: '#6366f1', borderRightColor: 'transparent' }}></span>
                  </div>
                )}
                <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginBottom: '20px' }}>
                  {[0, 1, 2, 3, 4, 5].map(idx => (
                    <input key={idx} className="otp-input" maxLength="1" onInput={e => handleOtpInput(e, idx + 1, verifySaasOtp)} onKeyDown={e => handleOtpKeyDown(e, idx - 1)} />
                  ))}
                </div>
                <button className="btn-login saas-btn" onClick={() => verifySaasOtp()}>Xác nhận thiết lập</button>
                <div style={{ textAlign: 'center', marginTop: '14px' }}>
                  <span onClick={() => setSaasView('main')} style={{ fontSize: '13px', color: '#64748b', fontWeight: 600, cursor: 'pointer' }}>← Hủy</span>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}