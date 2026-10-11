import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { XCircle, Search, AlertTriangle } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const Salary = () => {
  const currentDate = new Date();
  const [year, setYear] = useState(currentDate.getFullYear());
  const [month, setMonth] = useState(currentDate.getMonth() + 1);
  const [salaryData, setSalaryData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ text: '', type: '' });

  // Định dạng tiền VNĐ
  const formatMoney = (amount) => {
    if (amount === undefined || amount === null) return '0đ';
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  const fetchSalary = async () => {
    setLoading(true);
    setMessage({ text: '', type: '' });
    setSalaryData(null);
    try {
      const token = localStorage.getItem('lecturerToken');
      const res = await axios.get(`${API_BASE_URL}/lecturer/salaries/monthly?year=${year}&month=${month}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setSalaryData(res.data);
    } catch (err) {
      if (err.response && err.response.status === 404) {
        setMessage({ text: `Không tìm thấy bảng lương tháng ${month}/${year}`, type: 'warning' });
      } else {
        setMessage({ text: 'Lỗi kết nối máy chủ', type: 'error' });
      }
    } finally {
      setLoading(false);
    }
  };

  // Tải bảng lương tháng hiện tại lúc mới vào
  useEffect(() => {
    fetchSalary();
  }, []);

  return (
    <div className="animate-fadeIn">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Thông tin lương</h1>
        <p className="text-gray-400 text-sm mt-1">Tra cứu bảng lương theo tháng</p>
      </div>

      {/* Box tìm kiếm */}
      <div className="bg-white rounded-xl p-5 mb-5 shadow-sm border border-gray-100">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1.5">Năm</label>
            <select 
              className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-2 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm font-medium"
              value={year}
              onChange={(e) => setYear(Number(e.target.value))}
            >
              {[2026, 2025, 2024].map(y => <option key={y} value={y}>{y}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1.5">Tháng</label>
            <select 
              className="border-[1.5px] border-[#E0D8F0] rounded-lg px-3.5 py-2 w-full outline-none focus:border-[#6B4FA0] transition-all text-sm font-medium"
              value={month}
              onChange={(e) => setMonth(Number(e.target.value))}
            >
              {[...Array(12).keys()].map(m => (
                <option key={m + 1} value={m + 1}>Tháng {m + 1}</option>
              ))}
            </select>
          </div>
          <div className="flex items-end">
            <button 
              onClick={fetchSalary}
              disabled={loading}
              className="w-full bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] text-white rounded-lg px-5 py-2.5 font-medium transition-all hover:translate-y-[-1px] hover:shadow-lg hover:shadow-purple-200 active:scale-95 flex items-center justify-center gap-2"
            >
              {loading ? '⏳ Đang tra cứu...' : <><Search className="w-4 h-4 inline-block mr-2" /> Xem bảng lương</>}
            </button>
          </div>
        </div>
      </div>

      {/* Hiển thị thông báo */}
      {message.text && (
        <div className={`p-4 mb-5 rounded-lg text-sm font-semibold border ${message.type === 'warning' ? 'bg-orange-50 text-orange-600 border-orange-200' : 'bg-red-50 text-red-600 border-red-200'}`}>
          {message.type === 'warning' ? <><AlertTriangle className="w-4 h-4 inline-block mr-2" /> </> : <><XCircle className="w-4 h-4 inline-block mr-2" /> </>} {message.text}
        </div>
      )}

      {/* Hiển thị Bảng lương nếu có */}
      {salaryData && (
        <>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-5 text-white">
            <div className="rounded-xl p-5 relative overflow-hidden shadow-md" style={{ background: 'linear-gradient(135deg,#4CAF50,#66BB6A)' }}>
              <div className="text-xs opacity-90 font-bold uppercase tracking-wider">Lương cơ bản</div>
              <div className="text-2xl font-bold mt-1">{formatMoney(salaryData.baseAmount)}</div>
              <div className="absolute -top-4 -right-4 w-16 h-16 bg-white/20 rounded-full"></div>
            </div>
            <div className="rounded-xl p-5 relative overflow-hidden shadow-md" style={{ background: 'linear-gradient(135deg,#6B4FA0,#8B6BBF)' }}>
              <div className="text-xs opacity-90 font-bold uppercase tracking-wider">Phụ cấp & Thưởng</div>
              <div className="text-2xl font-bold mt-1">{formatMoney(salaryData.bonusAmount)}</div>
              <div className="absolute -top-4 -right-4 w-16 h-16 bg-white/20 rounded-full"></div>
            </div>
            <div className="rounded-xl p-5 relative overflow-hidden shadow-md" style={{ background: 'linear-gradient(135deg,#E85D75,#EF5350)' }}>
              <div className="text-xs opacity-90 font-bold uppercase tracking-wider">Thực nhận (Sau KT)</div>
              <div className="text-2xl font-bold mt-1">{formatMoney(salaryData.netAmount)}</div>
              <div className="absolute -top-4 -right-4 w-16 h-16 bg-white/20 rounded-full"></div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-4 border-b border-gray-100 bg-gray-50/50 flex justify-between items-center">
              <h3 className="font-semibold text-gray-800">Chi tiết bảng lương - Tháng {salaryData.periodMonth}/{salaryData.periodYear}</h3>
              <span className={`px-3 py-1 text-xs font-bold rounded-full ${salaryData.status === 'PAID' ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}`}>
                {salaryData.status === 'PAID' ? 'ĐÃ THANH TOÁN' : 'CHỜ THANH TOÁN'}
              </span>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-gray-50/80 text-gray-600 border-b">
                    <th className="px-6 py-3 text-left font-bold uppercase text-[11px] tracking-wider">Khoản mục</th>
                    <th className="px-6 py-3 text-right font-bold uppercase text-[11px] tracking-wider">Số tiền</th>
                    <th className="px-6 py-3 text-left font-bold uppercase text-[11px] tracking-wider">Ghi chú</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  
                  {/* Item: Lương cơ bản */}
                  <tr className="hover:bg-purple-50/30 transition-colors">
                    <td className="px-6 py-4 font-medium text-gray-700">Lương cơ bản (Theo hệ số {salaryData.coefficientSnapshot})</td>
                    <td className="px-6 py-4 text-right font-bold text-green-600">{formatMoney(salaryData.baseAmount)}</td>
                    <td className="px-6 py-4 text-gray-500 text-xs italic">Bậc: {salaryData.degreeSnapshot || 'Không rõ'}</td>
                  </tr>

                  {/* Vòng lặp các khoản chi tiết */}
                  {salaryData.teacherSalaryDetails && salaryData.teacherSalaryDetails.map((detail, idx) => (
                    <tr key={idx} className={`hover:bg-purple-50/30 transition-colors ${detail.type === 'DEDUCTION' ? 'bg-red-50/30' : ''}`}>
                      <td className={`px-6 py-4 font-medium ${detail.type === 'DEDUCTION' ? 'text-red-600' : 'text-gray-700'}`}>
                        {detail.name || (detail.type === 'DEDUCTION' ? 'Khấu trừ / Thuế' : 'Phụ cấp / Thưởng')}
                      </td>
                      <td className={`px-6 py-4 text-right font-bold ${detail.type === 'DEDUCTION' ? 'text-red-600' : 'text-green-600'}`}>
                        {detail.type === 'DEDUCTION' ? '-' : '+'}{formatMoney(detail.amount)}
                      </td>
                      <td className="px-6 py-4 text-gray-500 text-xs">{detail.description || ''}</td>
                    </tr>
                  ))}

                  {/* Tổng thu nhập */}
                  <tr className="bg-purple-50/80 border-t-2 border-purple-200">
                    <td className="px-6 py-4 font-bold text-purple-900">TỔNG THỰC NHẬN CHUYỂN KHOẢN</td>
                    <td className="px-6 py-4 text-right font-black text-purple-700 text-xl">{formatMoney(salaryData.netAmount)}</td>
                    <td className="px-6 py-4"></td>
                  </tr>
                </tbody>
              </table>
            </div>
            
            <div className="p-4 bg-gray-50 border-t border-gray-100 text-xs text-gray-500 text-right">
              {salaryData.paymentDate ? `Thanh toán vào ngày: ${new Date(salaryData.paymentDate).toLocaleDateString('vi-VN')}` : 'Chưa có thông tin ngày thanh toán'}
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default Salary;