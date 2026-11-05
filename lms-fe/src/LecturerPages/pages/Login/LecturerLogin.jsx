import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import SearchableSelect from '../../../components/SearchableSelect';
import { BookOpen, Lock, User, GraduationCap, AlertCircle, ArrowRight, Loader2, School, Mail } from 'lucide-react';
import { API_BASE_URL, fetchActiveSchools } from '../../../config/apiConfig';

const LecturerLogin = ({ initialSchool }) => {
  const [mode, setMode] = useState('login'); // 'login' | 'register'
  const [loginCode, setLoginCode] = useState('');
  const [password, setPassword] = useState('');
  const [school, setSchool] = useState(initialSchool || '');

  // Register state
  const [regFullName, setRegFullName] = useState('');
  const [regTeacherCode, setRegTeacherCode] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regSpecialization, setRegSpecialization] = useState('');
  const [regPassword, setRegPassword] = useState('');

  const [error, setError] = useState('');
  const [successMsg, setSuccessMsg] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [schoolOptions, setSchoolOptions] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    fetchActiveSchools().then(data => {
      setSchoolOptions(data);
      if (initialSchool) {
        const matched = data.find(
          s => String(s.value).toLowerCase() === String(initialSchool).toLowerCase()
        );
        if (matched) setSchool(matched.value);
      }
    });
  }, [initialSchool]);

  const saveSessionAndRedirect = (data) => {
    if (data.token) localStorage.setItem('lecturerToken', data.token);
    if (data.refreshToken) localStorage.setItem('lecturerRefreshToken', data.refreshToken);
    localStorage.setItem('lecturerName', data.fullName || 'Giảng viên');
    localStorage.setItem('lecturerUser', JSON.stringify(data));

    const selectedSchool = schoolOptions.find(
      s => String(s.value).toLowerCase() === String(school).toLowerCase()
    );
    if (selectedSchool) localStorage.setItem('schoolName', selectedSchool.label);
    localStorage.setItem('schoolShortName', data.schoolCode || school);

    navigate('/weekly-schedule');
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setSuccessMsg('');

    if (!school) {
      setError('Vui lòng chọn trường học!');
      return;
    }

    setIsLoading(true);

    try {
      const res = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({
          loginCode: loginCode.trim(),
          password,
          userType: 'LECTURER',
          school
        })
      });

      const data = await res.json().catch(() => ({}));
      if (res.ok && data.token) {
        saveSessionAndRedirect(data);
      } else {
        setError(data.message || 'Mã giảng viên hoặc mật khẩu không chính xác!');
      }
    } catch (err) {
      setError('Lỗi kết nối máy chủ. Vui lòng thử lại sau!');
    } finally {
      setIsLoading(false);
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    setError('');
    setSuccessMsg('');

    if (!school) {
      setError('Vui lòng chọn trường học!');
      return;
    }

    setIsLoading(true);
    try {
      const res = await fetch(`${API_BASE_URL}/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({
          userType: 'LECTURER',
          school,
          fullName: regFullName.trim(),
          userCode: regTeacherCode.trim(),
          teacherCode: regTeacherCode.trim(),
          email: regEmail.trim(),
          specialization: regSpecialization.trim() || undefined,
          password: regPassword
        })
      });

      const data = await res.json().catch(() => ({}));
      if (res.ok) {
        if (data.token) {
          saveSessionAndRedirect(data);
        } else {
          setSuccessMsg('Đăng ký tài khoản Giảng viên thành công! Vui lòng đăng nhập.');
          setLoginCode(regTeacherCode.trim());
          setPassword(regPassword);
          setMode('login');
        }
      } else {
        setError(data.message || 'Không thể đăng ký tài khoản Giảng viên.');
      }
    } catch (err) {
      setError('Lỗi kết nối máy chủ. Vui lòng thử lại sau!');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F4F1F8] flex items-center justify-center p-4 relative overflow-hidden font-['Be_Vietnam_Pro']">
      {/* Background Ornaments */}
      <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-[#6B4FA0] opacity-10 rounded-full blur-3xl"></div>
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-[#E85D75] opacity-10 rounded-full blur-3xl"></div>

      <div className="max-w-5xl w-full bg-white rounded-3xl shadow-2xl overflow-hidden flex flex-col md:flex-row z-10 relative">
        {/* Left Side - Illustration & Welcome */}
        <div className="w-full md:w-1/2 bg-gradient-to-br from-[#4A3570] via-[#6B4FA0] to-[#8B6BBF] p-12 text-white flex flex-col justify-between relative overflow-hidden">
          <div className="absolute top-10 right-10 w-32 h-32 bg-white opacity-10 rounded-full blur-2xl"></div>
          <div className="absolute bottom-10 left-10 w-40 h-40 bg-[#F5A623] opacity-20 rounded-full blur-2xl"></div>

          <div className="z-10 relative">
            <div className="flex items-center gap-3 mb-8">
              <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center">
                <BookOpen className="w-7 h-7 text-white" />
              </div>
              <h1 className="text-3xl font-bold font-['Playfair_Display'] tracking-wide">
                {school || 'HUIT'}
              </h1>
            </div>

            <h2 className="text-4xl font-semibold mb-4 leading-tight">
              E-Office<br />Giảng Viên
            </h2>
            <p className="text-white/80 text-lg mb-8 leading-relaxed">
              Hệ thống quản lý giảng dạy, lịch trình và học vụ trực tuyến tích hợp xác thực tập trung Keycloak SSO.
            </p>
          </div>

          <div className="z-10 relative">
            <div className="flex items-center gap-4 bg-white/10 backdrop-blur-md p-4 rounded-2xl border border-white/20">
              <div className="w-12 h-12 bg-[#F5A623] rounded-full flex items-center justify-center shadow-lg">
                <GraduationCap className="w-6 h-6 text-white" />
              </div>
              <div>
                <p className="font-semibold text-white">Cổng thông tin</p>
                <p className="text-sm text-white/70">Năm học 2025 - 2026</p>
              </div>
            </div>
          </div>
        </div>

        {/* Right Side - Login / Register Form */}
        <div className="w-full md:w-1/2 p-12 lg:p-16 flex flex-col justify-center bg-white">
          <div className="mb-8 text-center">
            <h3 className="text-2xl font-bold text-gray-800 mb-2">
              {mode === 'login' ? 'Đăng nhập hệ thống' : 'Đăng ký tài khoản Giảng viên'}
            </h3>
            <p className="text-gray-500">
              {mode === 'login'
                ? 'Vui lòng nhập thông tin tài khoản của bạn'
                : 'Tạo tài khoản Giảng viên đồng bộ Keycloak SSO'}
            </p>
          </div>

          {mode === 'login' ? (
            <form onSubmit={handleLogin} className="space-y-5">
              <div className="relative z-10">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Trường / Trung tâm
                </label>
                <SearchableSelect
                  options={schoolOptions}
                  value={school}
                  onChange={setSchool}
                  icon={<School className="w-5 h-5" />}
                  triggerClassName="w-full border border-gray-200 rounded-xl text-sm transition-all"
                  triggerStyle={{ background: '#F9FAFB', height: '48px', padding: '0 16px' }}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Mã giảng viên / Email
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <User className="h-5 w-5 text-gray-400" />
                  </div>
                  <input
                    type="text"
                    required
                    value={loginCode}
                    onChange={(e) => setLoginCode(e.target.value)}
                    className="block w-full pl-11 pr-4 py-3 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-[#6B4FA0] focus:border-transparent transition-all bg-gray-50 focus:bg-white"
                    placeholder="Nhập mã giảng viên (VD: gv001) hoặc Email"
                  />
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="block text-sm font-medium text-gray-700">
                    Mật khẩu
                  </label>
                  <a href="#" className="text-sm text-[#6B4FA0] hover:text-[#4A3570] font-medium transition-colors">
                    Quên mật khẩu?
                  </a>
                </div>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <Lock className="h-5 w-5 text-gray-400" />
                  </div>
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="block w-full pl-11 pr-4 py-3 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-[#6B4FA0] focus:border-transparent transition-all bg-gray-50 focus:bg-white"
                    placeholder="••••••••"
                  />
                </div>
              </div>

              {error && (
                <div className="flex items-center gap-2 p-4 text-sm text-red-600 bg-red-50 rounded-xl border border-red-100">
                  <AlertCircle className="w-5 h-5 flex-shrink-0" />
                  <p>{error}</p>
                </div>
              )}

              {successMsg && (
                <div className="p-4 text-sm text-green-700 bg-green-50 rounded-xl border border-green-100">
                  {successMsg}
                </div>
              )}

              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex items-center justify-center gap-2 bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] hover:from-[#4A3570] hover:to-[#6B4FA0] text-white py-3.5 px-4 rounded-xl font-medium transition-all shadow-lg shadow-[#6B4FA0]/30 hover:shadow-[#6B4FA0]/50 disabled:opacity-70 disabled:cursor-not-allowed group"
              >
                {isLoading ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    <span>Đăng nhập</span>
                    <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                  </>
                )}
              </button>

              <div className="text-center text-sm text-gray-600 pt-2">
                Chưa có tài khoản Giảng viên?{' '}
                <button
                  type="button"
                  onClick={() => { setError(''); setMode('register'); }}
                  className="text-[#6B4FA0] font-semibold hover:underline"
                >
                  Đăng ký ngay →
                </button>
              </div>
            </form>
          ) : (
            <form onSubmit={handleRegister} className="space-y-4">
              <div className="relative z-10">
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Trường / Trung tâm
                </label>
                <SearchableSelect
                  options={schoolOptions}
                  value={school}
                  onChange={setSchool}
                  icon={<School className="w-5 h-5" />}
                  triggerClassName="w-full border border-gray-200 rounded-xl text-sm transition-all"
                  triggerStyle={{ background: '#F9FAFB', height: '46px', padding: '0 16px' }}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Họ và tên Giảng viên
                </label>
                <input
                  type="text"
                  required
                  value={regFullName}
                  onChange={(e) => setRegFullName(e.target.value)}
                  className="block w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm bg-gray-50 focus:bg-white"
                  placeholder="Nguyễn Văn A"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Mã giảng viên
                </label>
                <input
                  type="text"
                  required
                  value={regTeacherCode}
                  onChange={(e) => setRegTeacherCode(e.target.value)}
                  className="block w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm bg-gray-50 focus:bg-white"
                  placeholder="VD: GV002"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Email công vụ
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <Mail className="h-4 w-4 text-gray-400" />
                  </div>
                  <input
                    type="email"
                    required
                    value={regEmail}
                    onChange={(e) => setRegEmail(e.target.value)}
                    className="block w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl text-sm bg-gray-50 focus:bg-white"
                    placeholder="giangvien@huit.edu.vn"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Chuyên ngành (Tùy chọn)
                </label>
                <input
                  type="text"
                  value={regSpecialization}
                  onChange={(e) => setRegSpecialization(e.target.value)}
                  className="block w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm bg-gray-50 focus:bg-white"
                  placeholder="Công nghệ phần mềm"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Mật khẩu (tối thiểu 6 ký tự)
                </label>
                <input
                  type="password"
                  required
                  value={regPassword}
                  onChange={(e) => setRegPassword(e.target.value)}
                  className="block w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm bg-gray-50 focus:bg-white"
                  placeholder="••••••••"
                />
              </div>

              {error && (
                <div className="flex items-center gap-2 p-3 text-sm text-red-600 bg-red-50 rounded-xl border border-red-100">
                  <AlertCircle className="w-5 h-5 flex-shrink-0" />
                  <p>{error}</p>
                </div>
              )}

              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex items-center justify-center gap-2 bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] text-white py-3 px-4 rounded-xl font-medium transition-all shadow-lg"
              >
                {isLoading ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    <span>Đăng ký tài khoản</span>
                    <ArrowRight className="w-5 h-5" />
                  </>
                )}
              </button>

              <div className="text-center text-sm text-gray-600 pt-1">
                Đã có tài khoản?{' '}
                <button
                  type="button"
                  onClick={() => { setError(''); setMode('login'); }}
                  className="text-[#6B4FA0] font-semibold hover:underline"
                >
                  ← Quay lại Đăng nhập
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};

export default LecturerLogin;
