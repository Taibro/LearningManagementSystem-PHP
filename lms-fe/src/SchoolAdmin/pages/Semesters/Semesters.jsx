import React, { useState, useEffect } from 'react';
import { Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Semesters() {
  const [academicYears, setAcademicYears] = useState([]);
  const [semesters, setSemesters] = useState([]);
  const [toast, setToast] = useState(null);

  // Modals state
  const [ayModalOpen, setAyModalOpen] = useState(false);
  const [semModalOpen, setSemModalOpen] = useState(false);

  // Form state
  const [currentAy, setCurrentAy] = useState({ id: null, name: '', startDate: '', endDate: '', isActive: true });
  const [currentSem, setCurrentSem] = useState({ id: null, academicYearId: '', name: '', startDate: '', endDate: '', isActive: true });

  const SCHOOL_ID = localStorage.getItem('schoolId') || 1;
  const token = localStorage.getItem('adminToken');

  useEffect(() => {
    fetchAcademicYears();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchAcademicYears = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/academic-years/school/${SCHOOL_ID}`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setAcademicYears(data);
        fetchAllSemesters(data);
      }
    } catch (error) {
      showToast('Lỗi khi tải năm học!', 'error');
    }
  };

  const fetchAllSemesters = async (years) => {
    let allSems = [];
    for (let year of years) {
      try {
        const res = await fetch(`${API_BASE_URL}/school-admin/semesters/academic-year/${year.id}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          allSems = [...allSems, ...data];
        }
      } catch (error) {
        console.error("Lỗi tải học kỳ", error);
      }
    }
    setSemesters(allSems);
  };

  // --- ACADEMIC YEAR LOGIC ---
  const handleSaveAy = async () => {
    const payload = { ...currentAy, schoolId: SCHOOL_ID };
    const method = currentAy.id ? 'PUT' : 'POST';
    const url = currentAy.id
      ? `${API_BASE_URL}/school-admin/academic-years/${currentAy.id}`
      : `${API_BASE_URL}/school-admin/academic-years`;

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast(currentAy.id ? 'Cập nhật năm học thành công!' : 'Thêm năm học thành công!');
        setAyModalOpen(false);
        fetchAcademicYears();
      } else {
        showToast('Lỗi khi lưu năm học!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDeleteAy = async (id) => {
    if (!window.confirm("Bạn có chắc muốn xóa năm học này? Các học kỳ liên quan có thể bị ảnh hưởng.")) return;
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/academic-years/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        showToast('Đã xóa năm học!');
        fetchAcademicYears();
      }
    } catch (err) {
      showToast('Lỗi khi xóa năm học!', 'error');
    }
  };

  const openAyModal = (ay = null) => {
    setCurrentAy(ay ? { ...ay } : { id: null, name: '', startDate: '', endDate: '', isActive: true });
    setAyModalOpen(true);
  };

  // --- SEMESTER LOGIC ---
  const handleSaveSem = async () => {
    const method = currentSem.id ? 'PUT' : 'POST';
    const url = currentSem.id
      ? `${API_BASE_URL}/school-admin/semesters/${currentSem.id}`
      : `${API_BASE_URL}/school-admin/semesters`;

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(currentSem)
      });
      if (res.ok) {
        showToast(currentSem.id ? 'Cập nhật học kỳ thành công!' : 'Thêm học kỳ thành công!');
        setSemModalOpen(false);
        fetchAcademicYears();
      } else {
        showToast('Lỗi khi lưu học kỳ!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDeleteSem = async (id) => {
    if (!window.confirm("Bạn có chắc muốn xóa học kỳ này?")) return;
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/semesters/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        showToast('Đã xóa học kỳ!');
        fetchAcademicYears();
      }
    } catch (err) {
      showToast('Lỗi khi xóa học kỳ!', 'error');
    }
  };

  const openSemModal = (sem = null) => {
    setCurrentSem(sem ? { ...sem } : { id: null, academicYearId: academicYears[0]?.id || '', name: '', startDate: '', endDate: '', isActive: true });
    setSemModalOpen(true);
  };

  return (
    <div className="page" style={{ position: 'relative' }}>

      {/* TOAST NOTIFICATION */}
      {toast && (
        <div style={{
          position: 'fixed', top: '20px', right: '20px', zIndex: 9999,
          padding: '12px 20px', borderRadius: '4px', color: '#fff',
          boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
          background: toast.type === 'success' ? '#4caf50' : '#f44336'
        }}>
          {toast.msg}
        </div>
      )}

      <div className="ph" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <div className="ph-title">Năm học & Học kỳ</div>
          <div className="ph-sub">Quản lý cấu trúc thời gian đào tạo</div>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="btn btn-ghost" style={{ border: '1px solid #ccc' }} onClick={() => openAyModal()}>+ Thêm Năm học</button>
          <button className="btn btn-blue" onClick={() => openSemModal()}>+ Thêm Học kỳ</button>
        </div>
      </div>

      <div className="grid2">
        {/* BẢNG NĂM HỌC */}
        <div className="card">
          <div className="card-hd"><div className="card-title">Danh sách Năm học</div></div>
          <table className="tbl">
            <thead>
              <tr>
                <th>Tên năm học</th>
                <th>Thời gian</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {academicYears.map(ay => (
                <tr key={ay.id}>
                  <td style={{ fontWeight: 700 }}>{ay.name}</td>
                  <td style={{ fontSize: '12px' }}>{ay.startDate} đến {ay.endDate}</td>
                  <td>
                    {ay.isActive
                      ? <span className="badge b-green"><span className="dot-on"></span> Active</span>
                      : <span className="badge b-gray"><span className="dot-off"></span> Inactive</span>}
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <button className="btn btn-ghost btn-xs" onClick={() => openAyModal(ay)}>Sửa</button>
                      <button className="btn btn-danger btn-xs" onClick={() => handleDeleteAy(ay.id)}>Xóa</button>
                    </div>
                  </td>
                </tr>
              ))}
              {academicYears.length === 0 && <tr><td colSpan="4" style={{ textAlign: 'center' }}>Chưa có dữ liệu</td></tr>}
            </tbody>
          </table>
        </div>

        {/* BẢNG HỌC KỲ */}
        <div className="card">
          <div className="card-hd"><div className="card-title">Danh sách Học kỳ</div></div>
          <table className="tbl">
            <thead>
              <tr>
                <th>Tên HK</th>
                <th>Năm học</th>
                <th>Thời gian</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {semesters.map(sem => (
                <tr key={sem.id}>
                  <td style={{ fontWeight: 700 }}>{sem.name}</td>
                  <td>{sem.academicYearName}</td>
                  <td style={{ fontSize: '12px' }}>{sem.startDate} đến {sem.endDate}</td>
                  <td>
                    {sem.isActive
                      ? <span className="badge b-blue"><span className="dot-on"></span> Active</span>
                      : <span className="badge b-gray"><span className="dot-off"></span> Inactive</span>}
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <button className="btn btn-ghost btn-xs" onClick={() => openSemModal(sem)}>Sửa</button>
                      <button className="btn btn-danger btn-xs" onClick={() => handleDeleteSem(sem.id)}>Xóa</button>
                    </div>
                  </td>
                </tr>
              ))}
              {semesters.length === 0 && <tr><td colSpan="5" style={{ textAlign: 'center' }}>Chưa có dữ liệu</td></tr>}
            </tbody>
          </table>
        </div>
      </div>

      {/* MODAL NĂM HỌC */}
      {ayModalOpen && (
        <div className="ov open">
          <div className="modal">
            <div className="modal-hd">
              <span className="modal-title">{currentAy.id ? 'Sửa Năm học' : 'Thêm Năm học'}</span>
              <button className="close-btn" onClick={() => setAyModalOpen(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="fg">
                <label className="fl">Tên năm học</label>
                <input className="fc" value={currentAy.name} onChange={e => setCurrentAy({ ...currentAy, name: e.target.value })} placeholder="VD: 2024-2025" />
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Ngày bắt đầu</label>
                  <input type="date" className="fc" value={currentAy.startDate} onChange={e => setCurrentAy({ ...currentAy, startDate: e.target.value })} />
                </div>
                <div className="fg">
                  <label className="fl">Ngày kết thúc</label>
                  <input type="date" className="fc" value={currentAy.endDate} onChange={e => setCurrentAy({ ...currentAy, endDate: e.target.value })} />
                </div>
              </div>
              <div className="fg" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <input type="checkbox" checked={currentAy.isActive} onChange={e => setCurrentAy({ ...currentAy, isActive: e.target.checked })} />
                <label>Đang hoạt động</label>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setAyModalOpen(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveAy}><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL HỌC KỲ */}
      {semModalOpen && (
        <div className="ov open">
          <div className="modal">
            <div className="modal-hd">
              <span className="modal-title">{currentSem.id ? 'Sửa Học kỳ' : 'Thêm Học kỳ'}</span>
              <button className="close-btn" onClick={() => setSemModalOpen(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="fg">
                <label className="fl">Năm học</label>
                <select className="fc" value={currentSem.academicYearId} onChange={e => setCurrentSem({ ...currentSem, academicYearId: e.target.value })}>
                  <option value="">-- Chọn năm học --</option>
                  {academicYears.map(ay => (
                    <option key={ay.id} value={ay.id}>{ay.name}</option>
                  ))}
                </select>
              </div>
              <div className="fg">
                <label className="fl">Tên học kỳ</label>
                <input className="fc" value={currentSem.name} onChange={e => setCurrentSem({ ...currentSem, name: e.target.value })} placeholder="VD: Học kỳ 1" />
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Ngày bắt đầu</label>
                  <input type="date" className="fc" value={currentSem.startDate} onChange={e => setCurrentSem({ ...currentSem, startDate: e.target.value })} />
                </div>
                <div className="fg">
                  <label className="fl">Ngày kết thúc</label>
                  <input type="date" className="fc" value={currentSem.endDate} onChange={e => setCurrentSem({ ...currentSem, endDate: e.target.value })} />
                </div>
              </div>
              <div className="fg" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <input type="checkbox" checked={currentSem.isActive} onChange={e => setCurrentSem({ ...currentSem, isActive: e.target.checked })} />
                <label>Đang hoạt động</label>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setSemModalOpen(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveSem}><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
