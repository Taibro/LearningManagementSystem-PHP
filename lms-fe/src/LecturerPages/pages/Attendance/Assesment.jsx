import React from 'react';
import { Search, Save } from 'lucide-react';

const Assesment = () => {
  return (
    <div className="animate-fadeIn">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Phiếu đánh giá</h1>
        <p className="text-gray-400 text-sm mt-1">Đánh giá chuyên cần và rèn luyện sinh viên</p>
      </div>

      <div className="card p-5 mb-5 border border-gray-100 shadow-sm">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-[11px] font-bold text-gray-400 uppercase mb-1.5 ml-1">Học kỳ</label>
            <select className="input-field text-sm"><option>HK2 - 2025-2026</option></select>
          </div>
          <div>
            <label className="block text-[11px] font-bold text-gray-400 uppercase mb-1.5 ml-1">Lớp học phần</label>
            <select className="input-field text-sm"><option>010110195604 - 14DHTH04</option></select>
          </div>
          <div className="flex items-end">
            <button className="btn-primary w-full shadow-md text-sm py-2.5"><Search className="w-4 h-4 inline-block mr-2" /> Tải danh sách</button>
          </div>
        </div>
      </div>

      <div className="card overflow-hidden border border-gray-100 shadow-sm">
        <div className="p-4 border-b border-gray-100 bg-gray-50/50">
          <h3 className="font-bold text-[#6B4FA0] text-xs uppercase tracking-wider">Đánh giá rèn luyện - HK2 2025-2026</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 text-gray-600 border-b">
                <th className="px-4 py-3 text-left font-bold text-[10px] uppercase">Họ tên</th>
                <th className="px-4 py-3 text-center font-bold text-[10px] uppercase">Thái độ</th>
                <th className="px-4 py-3 text-center font-bold text-[10px] uppercase">Chuyên cần</th>
                <th className="px-4 py-3 text-center font-bold text-[10px] uppercase">Học tập</th>
                <th className="px-4 py-3 text-center font-bold text-[10px] uppercase">Tổng</th>
                <th className="px-4 py-3 text-center font-bold text-[10px] uppercase">Xếp loại</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              <tr className="hover:bg-[#F9F7FF] transition-all">
                <td className="px-4 py-4 font-bold text-gray-700">Kiều Tấn Phát</td>
                <td className="px-4 py-4 text-center"><input type="number" className="w-14 text-center border-[#E0D8F0] border-[1.5px] rounded-lg p-1 text-xs outline-none focus:border-[#6B4FA0]" defaultValue="25" /></td>
                <td className="px-4 py-4 text-center"><input type="number" className="w-14 text-center border-[#E0D8F0] border-[1.5px] rounded-lg p-1 text-xs outline-none focus:border-[#6B4FA0]" defaultValue="30" /></td>
                <td className="px-4 py-4 text-center"><input type="number" className="w-14 text-center border-[#E0D8F0] border-[1.5px] rounded-lg p-1 text-xs outline-none focus:border-[#6B4FA0]" defaultValue="40" /></td>
                <td className="px-4 py-4 text-center font-black text-[#6B4FA0] text-base">95</td>
                <td className="px-4 py-4 text-center"><span className="badge-present text-[10px] px-3 py-1">Xuất sắc</span></td>
              </tr>
            </tbody>
          </table>
        </div>
        <div className="p-4 bg-gray-50/50 flex justify-end">
          <button className="btn-primary px-10 font-bold uppercase text-[11px] tracking-widest"><Save className="w-4 h-4 inline-block mr-2" /> Lưu phiếu đánh giá</button>
        </div>
      </div>
    </div>
  );
};
export default Assesment;