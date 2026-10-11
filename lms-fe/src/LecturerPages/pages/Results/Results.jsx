import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useLecturerContext } from '../../context/LecturerContext';
import { BarChart, CheckCircle2, Search, AlertTriangle, Lock, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const Results = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [locking, setLocking] = useState(false);
  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });

  const { activeClass } = useLecturerContext();
  const classId = activeClass?.classId;

  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const fetchGrades = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/grades?classId=${classId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setData(res.data);
    } catch (err) {
      console.error(err);
      setData(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (classId) {
      fetchGrades();
    }
  }, [classId]);

  const calculateGrade = (cc, gk, ck) => {
    const c = cc || 0;
    const g = gk || 0;
    const k = ck || 0;
    const total = (c * 0.1) + (g * 0.3) + (k * 0.6);
    return Math.round(total * 10) / 10;
  };

  const getClassification = (total) => {
    if (total >= 9.0) return { label: 'Xuất sắc', class: 'bg-green-100 text-green-700' };
    if (total >= 8.0) return { label: 'Giỏi', class: 'bg-blue-100 text-blue-700' };
    if (total >= 7.0) return { label: 'Khá', class: 'bg-indigo-100 text-indigo-700' };
    if (total >= 5.0) return { label: 'Trung bình', class: 'bg-yellow-100 text-yellow-700' };
    return { label: 'Không đạt', class: 'bg-red-100 text-red-700' };
  };

  const handleGradeChange = (enrollmentId, field, value) => {
    if (!data || data.isLocked) return;
    
    let numValue = parseFloat(value);
    if (isNaN(numValue)) numValue = 0;
    if (numValue > 10) numValue = 10;
    if (numValue < 0) numValue = 0;

    const updatedStudents = data.students.map(st => {
      if (st.enrollmentId === enrollmentId) {
        const updatedSt = { ...st, [field]: numValue };
        updatedSt.total = calculateGrade(updatedSt.cc, updatedSt.gk, updatedSt.ck);
        updatedSt.classification = getClassification(updatedSt.total).label;
        return updatedSt;
      }
      return st;
    });

    setData({ ...data, students: updatedStudents });
  };

  const handleSave = async () => {
    if (!data || data.isLocked) return;
    setSaving(true);
    
    try {
      const token = localStorage.getItem('lecturerToken');
      const payload = {
        classId: classId,
        grades: data.students.map(st => ({
          enrollmentId: st.enrollmentId,
          gk: st.gk || 0,
          ck: st.ck || 0
        }))
      };

      const res = await axios.post(`${API_BASE_URL}/lecturer/grades/save`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });
      showToast(res.data || 'Lưu điểm thành công!');
      fetchGrades(); // Tải lại thống kê
    } catch (err) {
      console.error(err);
      showToast(err.response?.data?.message || 'Có lỗi khi lưu điểm', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleLock = async () => {
    if (!data || data.isLocked) return;
    if (!window.confirm('CẢNH BÁO: Sau khi khóa sổ, bạn sẽ KHÔNG THỂ sửa điểm được nữa. Bạn có chắc chắn?')) return;
    
    setLocking(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.post(`${API_BASE_URL}/lecturer/grades/lock/${classId}`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      });
      showToast(res.data || 'Đã khóa sổ bảng điểm!');
      fetchGrades();
    } catch (err) {
      console.error(err);
      showToast(err.response?.data || 'Không thể khóa sổ', 'error');
    } finally {
      setLocking(false);
    }
  };

  return (
    <div className="animate-fadeIn relative">
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

      <div className="mb-6 flex justify-between items-end">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Quản lý kết quả học tập</h1>
          <p className="text-gray-400 text-sm mt-1">Nhập và quản lý điểm số sinh viên</p>
        </div>
        {data?.isLocked && (
          <div className="bg-red-50 text-red-600 border border-red-200 px-4 py-2 rounded-xl font-bold text-sm shadow-sm flex items-center gap-2">
            <Lock className="w-4 h-4 inline-block mr-2" /> BẢNG ĐIỂM ĐÃ KHÓA SỔ
          </div>
        )}
      </div>

      <div className="card p-5 mb-5 shadow-sm border border-gray-100">
        <div className="grid grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-bold text-gray-500 uppercase tracking-widest mb-1.5 ml-1 text-[11px]">Học kỳ</label>
            <select className="input-field font-medium bg-gray-50">
              <option>HK2 - 2025-2026</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-bold text-gray-500 uppercase tracking-widest mb-1.5 ml-1 text-[11px]">Lớp học phần</label>
            <div className="input-field font-bold text-[#6B4FA0] bg-gray-50 flex items-center h-10">
              {activeClass ? activeClass.className : 'Chưa chọn lớp'}
            </div>
          </div>
          <div className="flex items-end gap-2">
            <button onClick={fetchGrades} className="btn-primary flex-1 shadow-md shadow-purple-200">
              {loading ? '⏳...' : <><Search className="w-4 h-4 inline-block mr-2" /> Tải bảng điểm</>}
            </button>
            <button className="btn-outline font-bold shadow-sm"><BarChart className="w-4 h-4 inline-block mr-2" /> Xuất Excel</button>
          </div>
        </div>
      </div>

      {/* Score summary cards */}
      <div className="grid grid-cols-4 gap-4 mb-5">
        <div className="card p-4 text-center shadow-sm border-b-4 border-purple-500">
          <div className="text-3xl font-black text-purple-700">{data?.classAverage?.toFixed(1) || '0.0'}</div>
          <div className="text-[11px] font-bold text-gray-400 uppercase tracking-wider mt-1">Điểm TB lớp</div>
        </div>
        <div className="card p-4 text-center shadow-sm border-b-4 border-green-500">
          <div className="text-3xl font-black text-green-600">{data?.passedCount || 0}</div>
          <div className="text-[11px] font-bold text-gray-400 uppercase tracking-wider mt-1">Đạt (≥5.0)</div>
        </div>
        <div className="card p-4 text-center shadow-sm border-b-4 border-red-500">
          <div className="text-3xl font-black text-red-500">{data?.failedCount || 0}</div>
          <div className="text-[11px] font-bold text-gray-400 uppercase tracking-wider mt-1">Không đạt</div>
        </div>
        <div className="card p-4 text-center shadow-sm border-b-4 border-yellow-500">
          <div className="text-3xl font-black text-yellow-600">{data?.excellentCount || 0}</div>
          <div className="text-[11px] font-bold text-gray-400 uppercase tracking-wider mt-1">Xuất sắc (≥9.0)</div>
        </div>
      </div>

      <div className="card overflow-hidden shadow-sm border border-gray-100">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-200 text-[11px] uppercase tracking-wider">
                <th className="px-4 py-4 text-center font-black text-gray-500 w-16">STT</th>
                <th className="px-4 py-4 text-left font-black text-gray-500">Họ tên sinh viên</th>
                <th className="px-4 py-4 text-center font-black text-gray-500 w-32">MSSV</th>
                <th className="px-2 py-4 text-center font-black text-blue-500 w-24" title="Tự động tính từ Điểm danh">CC (10%) <Lock className="w-4 h-4 inline-block mr-2" /></th>
                <th className="px-2 py-4 text-center font-black text-[#6B4FA0] w-24">GK (30%)</th>
                <th className="px-2 py-4 text-center font-black text-[#6B4FA0] w-24">CK (60%)</th>
                <th className="px-4 py-4 text-center font-black text-green-600 w-24">Tổng</th>
                <th className="px-4 py-4 text-center font-black text-gray-500 w-32">Xếp loại</th>
              </tr>
            </thead>
            <tbody>
              {data?.students && data.students.length > 0 ? (
                data.students.map((st, idx) => {
                  const badge = getClassification(st.total);
                  return (
                    <tr key={st.enrollmentId} className="hover:bg-purple-50/30 transition-colors border-b border-gray-50 group">
                      <td className="px-4 py-4 text-center font-bold text-gray-400">{idx + 1}</td>
                      <td className="px-4 py-4 font-bold text-gray-800">{st.fullName}</td>
                      <td className="px-4 py-4 text-center text-gray-500 font-medium text-xs tracking-wider">{st.studentCode}</td>
                      
                      <td className="px-2 py-4 text-center">
                        <div className="w-14 mx-auto text-center border-none bg-gray-100 rounded-lg py-1.5 text-xs font-bold text-gray-500" title="Điểm chuyên cần do hệ thống tự tính">
                          {st.cc !== null ? st.cc : '-'}
                        </div>
                      </td>
                      
                      <td className="px-2 py-4 text-center">
                        <input 
                          type="number" 
                          disabled={data.isLocked}
                          value={st.gk === null ? '' : st.gk} 
                          onChange={(e) => handleGradeChange(st.enrollmentId, 'gk', e.target.value)}
                          className={`w-14 text-center border-2 rounded-lg py-1.5 text-xs font-bold outline-none transition-all ${data.isLocked ? 'bg-gray-50 border-gray-200 text-gray-500' : 'border-purple-100 focus:border-purple-500 text-purple-700 bg-white shadow-sm focus:shadow-md'}`} 
                          min="0" max="10" step="0.1" 
                        />
                      </td>
                      
                      <td className="px-2 py-4 text-center">
                        <input 
                          type="number" 
                          disabled={data.isLocked}
                          value={st.ck === null ? '' : st.ck} 
                          onChange={(e) => handleGradeChange(st.enrollmentId, 'ck', e.target.value)}
                          className={`w-14 text-center border-2 rounded-lg py-1.5 text-xs font-bold outline-none transition-all ${data.isLocked ? 'bg-gray-50 border-gray-200 text-gray-500' : 'border-purple-100 focus:border-purple-500 text-purple-700 bg-white shadow-sm focus:shadow-md'}`} 
                          min="0" max="10" step="0.1" 
                        />
                      </td>
                      
                      <td className="px-4 py-4 text-center font-black text-green-600 text-base">{st.total?.toFixed(1) || '-'}</td>
                      
                      <td className="px-4 py-4 text-center">
                        <span className={`px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider whitespace-nowrap ${badge.class}`}>
                          {st.classification || badge.label}
                        </span>
                      </td>
                    </tr>
                  )
                })
              ) : (
                <tr>
                  <td colSpan="8" className="px-6 py-10 text-center text-gray-400 italic font-medium">
                    {loading ? 'Đang tải bảng điểm...' : 'Không có dữ liệu sinh viên trong lớp này.'}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        <div className="p-5 bg-gray-50 border-t border-gray-100 flex justify-end gap-3">
          <button 
            onClick={handleLock}
            disabled={!data || data.isLocked || locking}
            className={`px-6 py-2.5 rounded-lg text-sm font-bold shadow-sm transition-all flex items-center gap-2 ${!data || data.isLocked ? 'bg-gray-200 text-gray-400 cursor-not-allowed' : 'bg-white border-2 border-red-200 text-red-600 hover:bg-red-50 active:scale-95'}`}
          >
            {locking ? '⏳ Đang xử lý...' : <><Lock className="w-4 h-4 inline-block mr-2" /> Khóa sổ điểm</>}
          </button>
          <button 
            onClick={handleSave}
            disabled={!data || data.isLocked || saving}
            className={`px-8 py-2.5 rounded-lg text-sm font-bold shadow-lg transition-all flex items-center gap-2 ${!data || data.isLocked ? 'bg-gray-300 text-gray-500 cursor-not-allowed' : 'bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] text-white hover:shadow-xl hover:opacity-90 active:scale-95 shadow-purple-200'}`}
          >
            {saving ? '⏳ Đang lưu...' : <><Save className="w-4 h-4 inline-block mr-2" /> Lưu bảng điểm</>}
          </button>
        </div>
      </div>
    </div>
  );
};

export default Results;