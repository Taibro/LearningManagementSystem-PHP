import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { X, UploadCloud, FileText, Download, Trash2, Eye, BarChart, ClipboardList, CheckCircle2, Search, AlertTriangle, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const Documents = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [materials, setMaterials] = useState([]);
  const [loading, setLoading] = useState(false);
  
  // Upload states
  const [file, setFile] = useState(null);
  const [title, setTitle] = useState('');
  const [docType, setDocType] = useState('Slide bài giảng');
  const [uploading, setUploading] = useState(false);
  const fileInputRef = useRef(null);

  // Filters
  const [filterType, setFilterType] = useState('');
  const [classes, setClasses] = useState([]);
  const [selectedClassId, setSelectedClassId] = useState('');
  const [uploadClassId, setUploadClassId] = useState('');
  const getToday = () => { const d = new Date(); return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0'); };
  const [uploadDate, setUploadDate] = useState(getToday());

  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });

  const teacherId = 1; // Tạm cứng cho Giảng viên số 1

  useEffect(() => {
    const fetchClasses = async () => {
      try {
        const token = localStorage.getItem('lecturerToken');
        const res = await axios.get(`${API_BASE_URL}/lecturer/schedules/active-classes`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        setClasses(res.data);
        if (res.data && res.data.length > 0) {
          setSelectedClassId(res.data[0].classId);
          setUploadClassId(res.data[0].classId);
        }
      } catch (err) {
        console.error(err);
      }
    };
    fetchClasses();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const fetchMaterials = async () => {
    if (!selectedClassId) return;
    setLoading(true);
    try {
      const token = localStorage.getItem('lecturerToken');
      let url = `${API_BASE_URL}/lecturer/materials?teacherId=${teacherId}&classId=${selectedClassId}`;
      if (filterType && filterType !== 'Tất cả') {
        url += `&docType=${encodeURIComponent(filterType)}`;
      }
      
      const res = await axios.get(url, { headers: { Authorization: `Bearer ${token}` } });
      setMaterials(res.data);
    } catch (err) {
      console.error(err);
      setMaterials([]); // fallback to empty
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (selectedClassId) {
      fetchMaterials();
    }
  }, [filterType, selectedClassId]);

  const handleUpload = async () => {
    if (!file || !title) {
      showToast('Vui lòng nhập tên tài liệu và chọn file!', 'error');
      return;
    }

    setUploading(true);
    const token = localStorage.getItem('lecturerToken');
    const formData = new FormData();
    formData.append('file', file);
    formData.append('title', title);
    formData.append('docType', docType);
    formData.append('classId', uploadClassId);
    formData.append('teacherId', teacherId);
    if (uploadDate) {
      formData.append('uploadDate', uploadDate);
    }

    try {
      const res = await axios.post(`${API_BASE_URL}/lecturer/materials/upload`, formData, {
        headers: { 
          Authorization: `Bearer ${token}`,
          'Content-Type': 'multipart/form-data'
        }
      });
      showToast(res.data || 'Tải lên thành công!');
      setIsModalOpen(false);
      setFile(null);
      setTitle('');
      fetchMaterials(); // Reload list
    } catch (err) {
      console.error(err);
      showToast(err.response?.data || 'Có lỗi khi tải lên', 'error');
    } finally {
      setUploading(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa tài liệu này?')) return;
    
    try {
      const token = localStorage.getItem('lecturerToken');
      await axios.delete(`${API_BASE_URL}/lecturer/materials/${id}?teacherId=${teacherId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      showToast('Đã xóa tài liệu!');
      fetchMaterials();
    } catch (err) {
      console.error(err);
      showToast('Lỗi khi xóa tài liệu', 'error');
    }
  };

  const getIconForType = (type) => {
    if (type?.includes('Slide')) return { icon: <BarChart className="w-4 h-4 inline-block mr-2" />, color: 'text-red-500', bg: 'bg-red-100' };
    if (type?.includes('Bài tập')) return { icon: <FileText className="w-4 h-4 inline-block mr-2" />, color: 'text-blue-500', bg: 'bg-blue-100' };
    return { icon: <ClipboardList className="w-4 h-4 inline-block mr-2" />, color: 'text-green-500', bg: 'bg-green-100' };
  };

  // Format bytes to human readable size for file selection
  const formatSize = (bytes) => {
    if (!bytes || bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <>
      <div className="animate-fadeIn relative">
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

        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-800">Quản lý tài liệu bài giảng</h1>
            <p className="text-gray-400 text-sm mt-1">Upload và quản lý slide, tài liệu giảng dạy</p>
          </div>
          <button
            onClick={() => setIsModalOpen(true)}
            className="btn-primary text-sm shadow-md"
          >
            + Thêm tài liệu
          </button>
        </div>

        <div className="card p-5 mb-5 shadow-sm border border-gray-100">
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-1.5">Lớp học phần</label>
              <select className="input-field font-medium" value={selectedClassId} onChange={e => setSelectedClassId(e.target.value)}>
                {classes.map(cls => (
                  <option key={cls.classId} value={cls.classId}>{cls.classCode} - {cls.courseName}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-1.5">Loại tài liệu</label>
              <select className="input-field font-medium" value={filterType} onChange={e => setFilterType(e.target.value)}>
                <option value="">Tất cả</option>
                <option value="Slide bài giảng">Slide bài giảng</option>
                <option value="Bài tập">Bài tập</option>
                <option value="Đề thi">Đề thi</option>
              </select>
            </div>
            <div className="flex items-end">
              <button onClick={fetchMaterials} className="btn-primary w-full shadow-md hover:shadow-lg">
                {loading ? '⏳ Đang tải...' : <><Search className="w-4 h-4 inline-block mr-2" /> Tìm kiếm</>}
              </button>
            </div>
          </div>
        </div>

        {materials && materials.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {materials.map((mat) => {
              const style = getIconForType(mat.docType);
              return (
                <div key={mat.id} className="card p-5 hover:shadow-lg transition-all cursor-pointer border border-gray-100 group">
                  <div className="flex items-start gap-4">
                    <div className={`w-12 h-12 ${style.bg} rounded-xl flex items-center justify-center ${style.color} text-2xl flex-shrink-0 group-hover:scale-110 transition-transform`}>
                      {style.icon}
                    </div>
                    <div className="flex-1 min-w-0">
                      <h4 className="font-bold text-gray-800 text-sm truncate" title={mat.title}>{mat.title}</h4>
                      <p className="text-xs font-bold text-purple-600 mt-1 uppercase tracking-wider">{mat.docType || 'Tài liệu'}</p>
                      <div className="flex items-center gap-2 mt-2 font-medium">
                        <span className="text-xs text-gray-500">{mat.fileSize || '0 KB'}</span>
                        <span className="text-xs text-gray-300">•</span>
                        <span className="text-xs text-gray-500">{mat.uploadDate || 'Mới'}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-2 mt-5 pt-4 border-t border-gray-50">
                    <a href={`${API_BASE_URL}/lecturer/materials/${mat.id}/view`} target="_blank" rel="noreferrer" className="flex-1 text-xs px-2 py-2 bg-purple-50 text-purple-700 font-bold rounded-lg hover:bg-purple-100 flex items-center justify-center gap-1 transition-colors">
                      <Eye className="w-3 h-3" /> Xem
                    </a>
                    <a href={`${API_BASE_URL}/lecturer/materials/${mat.id}/download`} className="flex-1 text-xs px-2 py-2 bg-blue-50 text-blue-700 font-bold rounded-lg hover:bg-blue-100 flex items-center justify-center gap-1 transition-colors">
                      <Download className="w-3 h-3" /> Tải về
                    </a>
                    <button onClick={() => handleDelete(mat.id)} className="flex-1 text-xs px-2 py-2 bg-red-50 text-red-600 font-bold rounded-lg hover:bg-red-100 flex items-center justify-center gap-1 transition-colors">
                      <Trash2 className="w-3 h-3" /> Xóa
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          <div className="card p-10 text-center text-gray-400 font-medium flex flex-col items-center">
            <FileText className="w-16 h-16 text-gray-200 mb-3" />
            <p>{loading ? 'Đang tải dữ liệu đám mây...' : 'Chưa có tài liệu nào được tải lên.'}</p>
            {!loading && <p className="text-sm mt-1">Bấm nút "Thêm tài liệu" ở góc trên để upload bài giảng.</p>}
          </div>
        )}
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-[9999] flex justify-center items-center bg-black/40 backdrop-blur-sm pointer-events-auto">
          <div className="relative bg-white w-full max-w-xl rounded-2xl shadow-[0_20px_60px_-15px_rgba(0,0,0,0.3)] border border-gray-200 overflow-hidden transform transition-all animate-fadeIn">
            <div className="flex justify-between items-center px-6 py-4 border-b border-gray-100 bg-gray-50/50">
              <h3 className="font-extrabold text-lg text-gray-800">Thêm tài liệu mới</h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-gray-400 hover:text-red-500 bg-white hover:bg-red-50 p-1.5 rounded-lg transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 space-y-5">
              <div>
                <label className="block text-[12px] font-black text-gray-500 uppercase tracking-widest mb-2 ml-1">Lớp học phần</label>
                <select 
                  value={uploadClassId}
                  onChange={(e) => setUploadClassId(e.target.value)}
                  className="w-full border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 focus:outline-none focus:border-[#8B6BBF] bg-gray-50/50 text-sm font-medium"
                >
                  {classes.map(cls => (
                    <option key={cls.classId} value={cls.classId}>{cls.classCode} - {cls.courseName}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-[12px] font-black text-gray-500 uppercase tracking-widest mb-2 ml-1">Tên tài liệu</label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 focus:outline-none focus:border-[#8B6BBF] bg-gray-50/50 text-sm font-medium transition-colors"
                  placeholder="Nhập tên bài giảng, slide..."
                />
              </div>

              <div>
                <label className="block text-[12px] font-black text-gray-500 uppercase tracking-widest mb-2 ml-1">Phân loại</label>
                <select 
                  value={docType}
                  onChange={(e) => setDocType(e.target.value)}
                  className="w-full border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 focus:outline-none focus:border-[#8B6BBF] bg-gray-50/50 text-sm font-medium"
                >
                  <option value="Slide bài giảng">Slide bài giảng</option>
                  <option value="Bài tập">Bài tập</option>
                  <option value="Đề thi">Đề thi</option>
                </select>
              </div>

              <div>
                <label className="block text-[12px] font-black text-gray-500 uppercase tracking-widest mb-2 ml-1">Ngày áp dụng</label>
                <input
                  type="date"
                  value={uploadDate}
                  readOnly
                  className="w-full border-[1.5px] border-[#E0D8F0] rounded-lg px-4 py-2.5 bg-gray-100 text-gray-500 text-sm font-medium cursor-not-allowed focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-[12px] font-black text-gray-500 uppercase tracking-widest mb-2 ml-1">File đính kèm</label>
                <div 
                  onClick={() => fileInputRef.current.click()}
                  className={`border-2 border-dashed ${file ? 'border-[#6B4FA0] bg-purple-50/50' : 'border-[#E0D8F0] hover:bg-purple-50'} rounded-xl p-8 flex flex-col items-center justify-center text-gray-400 transition-all cursor-pointer group`}
                >
                    <UploadCloud className={`w-10 h-10 mb-3 transition-colors ${file ? 'text-[#6B4FA0]' : 'text-gray-300 group-hover:text-[#8B6BBF]'}`} />
                    {file ? (
                      <div className="text-center">
                        <span className="text-sm font-bold text-[#6B4FA0] block">{file.name}</span>
                        <span className="text-xs text-gray-400 mt-1 block">{formatSize(file.size)}</span>
                      </div>
                    ) : (
                      <>
                        <span className="text-sm font-bold text-gray-500">Nhấn để duyệt file trên máy</span>
                        <span className="text-xs mt-1 text-gray-400">(PDF, DOCX, PPTX, JPG...)</span>
                      </>
                    )}
                </div>
                <input 
                  type="file" 
                  ref={fileInputRef} 
                  className="hidden" 
                  onChange={(e) => setFile(e.target.files[0])} 
                />
              </div>
            </div>

            <div className="px-6 py-5 bg-gray-50 border-t border-gray-100 flex justify-end gap-3">
              <button
                onClick={() => setIsModalOpen(false)}
                className="px-6 py-2.5 text-sm font-bold text-gray-600 bg-white border-[1.5px] border-gray-200 rounded-lg hover:bg-gray-100 active:scale-95 transition-all"
              >
                Hủy bỏ
              </button>
              <button 
                onClick={handleUpload}
                disabled={uploading}
                className="px-6 py-2.5 text-sm font-bold text-white bg-gradient-to-r from-[#6B4FA0] to-[#8B6BBF] rounded-lg hover:shadow-md active:scale-95 transition-all shadow-purple-200"
              >
                {uploading ? '⏳ Đang tải lên mây...' : <><Save className="w-4 h-4 inline-block mr-2" /> Lưu tài liệu</>}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Documents;