import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import SearchableSelect from '../../../components/SearchableSelect';
import { BookOpen, Lock, User, GraduationCap, AlertCircle, ArrowRight, Loader2, School } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const LecturerLogin = ({ initialSchool }) => {
  const [loginCode, setLoginCode] = useState('');
  const [password, setPassword] = useState('');
  const [school, setSchool] = useState(initialSchool || '');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [schoolOptions, setSchoolOptions] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    fetch(`${API_BASE_URL}/schools/active`)
      .then(res => res.json())
      .then(data => setSchoolOptions(data))
      .catch(err => console.error("Failed to fetch schools", err));
  }, []);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!school) {
      setError('Vui lòng chọn trường học!');
      return;
    }
    
    setIsLoading(true);

    try {
      const res = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          loginCode, 
          password, 
          userType: 'LECTURER',
          school 
        })
      });

      if (res.ok) {
        const data = await res.json();
        // Lưu Token và Tên của Giảng viên
        if (data.token) localStorage.setItem('lecturerToken', data.token);
        localStorage.setItem('lecturerName', data.fullName || 'Giảng viên');

        const selectedSchool = schoolOptions.find(s => s.value === school);
        if (selectedSchool) localStorage.setItem('schoolName', selectedSchool.label);
        localStorage.setItem('schoolShortName', school);

        
        // Chuyển hướng vào E-Office
        navigate('/weekly-schedule');
      } else {
        setError('Mã giảng viên hoặc mật khẩu không chính xác!');
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
          {/* Abstract circles */}
          <div className="absolute top-10 right-10 w-32 h-32 bg-white opacity-10 rounded-full blur-2xl"></div>
          <div className="absolute bottom-10 left-10 w-40 h-40 bg-[#F5A623] opacity-20 rounded-full blur-2xl"></div>

          <div className="z-10 relative">
            <div className="flex items-center gap-3 mb-8">
              <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center">
                <BookOpen className="w-7 h-7 text-white" />
              </div>
              <h1 className="text-3xl font-bold font-['Playfair_Display'] tracking-wide">HUIT</h1>
            </div>
            
            <h2 className="text-4xl font-semibold mb-4 leading-tight">
              E-Office<br/>Giảng Viên
            </h2>
            <p className="text-white/80 text-lg mb-8 leading-relaxed">
              Hệ thống quản lý giảng dạy, lịch trình và học vụ trực tuyến dành riêng cho Giảng viên trường Đại học Công Thương TP.HCM.
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

        {/* Right Side - Login Form */}
        <div className="w-full md:w-1/2 p-12 lg:p-16 flex flex-col justify-center bg-white">
          <div className="mb-10 text-center">
            <h3 className="text-2xl font-bold text-gray-800 mb-2">Đăng nhập hệ thống</h3>
            <p className="text-gray-500">Vui lòng nhập thông tin tài khoản của bạn</p>
          </div>

          <form onSubmit={handleLogin} className="space-y-6">
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
                  placeholder="Nhập mã giảng viên (VD: GV001)"
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

            {/* Error Message */}
            {error && (
              <div className="flex items-center gap-2 p-4 text-sm text-red-600 bg-red-50 rounded-xl border border-red-100 animate-fade-in">
                <AlertCircle className="w-5 h-5 flex-shrink-0" />
                <p>{error}</p>
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
          </form>

          <div className="mt-8 text-center text-sm text-gray-500">
            Bạn gặp sự cố khi đăng nhập? <a href="#" className="text-[#6B4FA0] font-medium hover:underline">Liên hệ IT Support</a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LecturerLogin;
