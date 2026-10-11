import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import SearchableSelect from '../../../components/SearchableSelect';
import { Loader2 } from 'lucide-react';
import './StudentLogin.css';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function StudentLogin({ initialSchool }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [school, setSchool] = useState(initialSchool || '');

  const [errorEmail, setErrorEmail] = useState(false);
  const [errorPass, setErrorPass] = useState(false);
  const [errorSchool, setErrorSchool] = useState(false);
  const [generalError, setGeneralError] = useState('');

  const [showPass, setShowPass] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [loading, setLoading] = useState(false);
  const [shake, setShake] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [progressWidth, setProgressWidth] = useState('0%');
  const [schoolOptions, setSchoolOptions] = useState([]);

  useEffect(() => {
    const fetchSchools = async () => {
      try {
        const res = await axios.get(`${API_BASE_URL}/schools/active`);
        setSchoolOptions(res.data);
      } catch (error) {
        console.error("Failed to fetch schools", error);
      }
    };
    fetchSchools();
  }, []);

  const navigate = useNavigate();

  const handleLogin = async () => {
    let hasError = false;

    if (!email.trim()) { setErrorEmail(true); hasError = true; } else { setErrorEmail(false); }
    if (!password) { setErrorPass(true); hasError = true; } else { setErrorPass(false); }
    if (!school) { setErrorSchool(true); hasError = true; } else { setErrorSchool(false); }

    setGeneralError('');

    if (hasError) {
      setShake(true);
      setTimeout(() => setShake(false), 350);
      return;
    }

    setLoading(true);

    try {
      const res = await axios.post(`${API_BASE_URL}/auth/login`, {
        userType: 'STUDENT',
        loginCode: email.trim(),
        password: password,
        school: school
      });

      if (res.data && res.data.token) {
        localStorage.setItem('token', res.data.token);
        localStorage.setItem('user', JSON.stringify(res.data));

        const selectedSchool = schoolOptions.find(s => s.value === school);
        if (selectedSchool) localStorage.setItem('schoolName', selectedSchool.label);
        localStorage.setItem('schoolShortName', school);

        setShowSuccess(true);
        setTimeout(() => setProgressWidth('100%'), 50);

        setTimeout(() => {
          navigate('/dashboard');
        }, 2500);
      } else {
        setGeneralError('Đăng nhập thất bại. Vui lòng thử lại.');
        setLoading(false);
      }
    } catch (err) {
      setGeneralError(err.response?.data?.message || 'Tài khoản hoặc mật khẩu không chính xác.');
      setLoading(false);
    }
  };

  return (
    <div className="student-login-body">
      <div className="sl-layout">
        {/* ══════════ LEFT ══════════ */}
        <div className="sl-left">
          <div className="sl-blob sl-blob-1"></div>
          <div className="sl-blob sl-blob-2"></div>
          <div className="sl-blob sl-blob-3"></div>

          <div className="logo-wrap sl-fl">
            <div className="logo-icon">E</div>
            <div>
              <div className="logo-text">EduSpace</div>
              <div className="logo-sub">Student Portal</div>
            </div>
          </div>

          <div style={{ position: 'relative', zIndex: 1 }}>
            <div className="badge-student sl-fl d1" style={{ marginBottom: '24px' }}>
              <span className="badge-dot"></span>
              CỔNG SINH VIÊN
            </div>
            <h1 className="headline sl-fl d2">
              Học tập.<br />
              <span className="accent">Phát triển</span><br />
              toàn diện.
            </h1>
            <div style={{ width: '40px', height: '3px', background: 'rgba(167,139,250,.5)', borderRadius: '2px', margin: '22px 0' }} className="sl-fl d3"></div>
            <p className="desc sl-fl d3">Xem lịch học, đăng ký môn học, tra cứu điểm số và nhận thông báo từ giảng viên mọi lúc mọi nơi.</p>

            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginTop: '28px' }} className="sl-fl d4">
              <div className="feature-chip">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M5 13l4 4L19 7" /></svg>
                Lịch học cá nhân
              </div>
              <div className="feature-chip">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M5 13l4 4L19 7" /></svg>
                Đăng ký môn học
              </div>
              <div className="feature-chip">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M5 13l4 4L19 7" /></svg>
                Tra cứu điểm số
              </div>
              <div className="feature-chip">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M5 13l4 4L19 7" /></svg>
                Tài liệu học tập
              </div>
              <div className="feature-chip">
                <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M5 13l4 4L19 7" /></svg>
                Học phí & Học bổng
              </div>
            </div>
          </div>

          <div style={{ display: 'flex', gap: '16px', position: 'relative', zIndex: 1 }} className="sl-fl d5">
            <div className="stat-box"><div className="stat-num">62,840</div><div className="stat-lbl">Sinh viên</div></div>
            <div className="stat-box"><div className="stat-num">38</div><div className="stat-lbl">Trường / TT</div></div>
            <div className="stat-box"><div className="stat-num">4.8★</div><div className="stat-lbl">Đánh giá</div></div>
          </div>
        </div>

        {/* ══════════ RIGHT ══════════ */}
        <div className="sl-right">
          <div className={`success-wrap ${showSuccess ? 'show' : ''}`} id="success">
            <div className="success-icon-wrap">📚</div>
            <div className="success-title">Chào mừng trở lại!</div>
            <div className="success-sub">Đang chuyển đến trang Sinh viên...</div>
            <div className="progress-bar"><div className="progress-fill" style={{ width: progressWidth, transition: 'width 2s ease' }}></div></div>
          </div>

          <a href="/login-giang-vien.html" className="back-btn sl-fu" style={{ marginBottom: 'auto' }}>
            <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
            Cổng Giảng viên
          </a>

          <div className="form-section" style={{ margin: 'auto 0' }}>
            <div className="sl-fu d1">
              <h2 className="form-title">Đăng nhập<br />Sinh viên</h2>
              <p className="form-sub">Nhập thông tin tài khoản được cấp bởi nhà trường</p>
            </div>
            <div className="hr-line sl-fu d2"></div>

            {/* Mã SV */}
            <div className="sl-fu d2">
              <label className="lbl">Mã sinh viên</label>
              <div className="field">
                <svg className="field-ico" style={{ color: '#94A3B8' }} fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                <input
                  className="inp"
                  type="text"
                  placeholder="2001216301"
                  autoComplete="username"
                  value={email}
                  onChange={(e) => { setEmail(e.target.value); setErrorEmail(false); }}
                />
              </div>
              <div className={`err-msg ${errorEmail ? 'on' : ''}`}>Vui lòng nhập mã sinh viên</div>
            </div>

            {/* Mật khẩu */}
            <div className="sl-fu d3">
              <label className="lbl">Mật khẩu</label>
              <div className="field">
                <svg className="field-ico" style={{ color: '#94A3B8' }} fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
                <input
                  className="inp inp-pass"
                  type={showPass ? 'text' : 'password'}
                  placeholder="••••••••••••"
                  autoComplete="current-password"
                  value={password}
                  onChange={(e) => { setPassword(e.target.value); setErrorPass(false); }}
                />
                <button className="eye-btn" onClick={() => setShowPass(!showPass)} type="button" style={{ color: showPass ? '#475569' : '#94A3B8' }}>
                  <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                </button>
              </div>
              <div className={`err-msg ${errorPass ? 'on' : ''}`}>Mật khẩu không được để trống</div>
            </div>

            {/* Chọn trường */}
            <div className="sl-fu d3" style={{ position: 'relative', zIndex: 10 }}>
              <label className="lbl">Trường / Trung tâm</label>
              <SearchableSelect
                options={schoolOptions}
                value={school}
                onChange={(val) => { setSchool(val); setErrorSchool(false); }}
                hasError={errorSchool}
                icon={<svg width="20" height="20" style={{ color: '#94A3B8' }} fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0H5m9-7h-4" /></svg>}
                triggerStyle={{ background: '#F8FAFC', border: errorSchool ? '1px solid #ef4444' : '1px solid #E2E8F0', height: '48px', borderRadius: '12px' }}
              />
              <div className={`err-msg ${errorSchool ? 'on' : ''}`}>Vui lòng chọn trường của bạn</div>
            </div>

            {/* General Error Message */}
            {generalError && <div className="err-general sl-fu d3">{generalError}</div>}


            {/* Remember / Forgot */}
            <div className="row-mid sl-fu d4">
              <div className="check-row" onClick={() => setRememberMe(!rememberMe)}>
                <div className={`custom-cb ${rememberMe ? 'on' : ''}`}></div>
                <span className="cb-lbl">Ghi nhớ đăng nhập</span>
              </div>
              <a href="#" className="forgot">Quên mật khẩu?</a>
            </div>

            {/* Submit */}
            <button className={`btn-login sl-fu d4 ${loading ? 'loading' : ''} ${shake ? 'shake' : ''}`} onClick={handleLogin} disabled={loading}>
              <span className="btn-txt">Đăng nhập ngay</span>
              <div className="sl-spinner-container">
                <Loader2 className="lucide-spin" size={18} />
                <span style={{ fontSize: '13px' }}>Đang xác thực...</span>
              </div>
            </button>


            <p className="form-footer sl-fu d6">
              Giảng viên? <a href="/lecturer/login">Đăng nhập tại đây →</a>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
