import React, { useState, useEffect } from 'react';
import { CheckCircle2, School, Search, AlertTriangle, User, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_TEACHER = `${API_BASE_URL}/school-admin/teachers`;
const API_DEPT = `${API_BASE_URL}/school-admin`;

export default function Teachers() {
  const [teachers, setTeachers] = useState([]);
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [tModal, setTModal] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);

  const [currentTeacher, setCurrentTeacher] = useState({
    id: null, fullName: '', teacherCode: '', email: '', phone: '', citizenIdNumber: '000000000000',
    departmentId: '', degree: 'Cử nhân', specialization: '', joinedDate: '', bio: ''
  });

  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });
  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const schoolId = localStorage.getItem('schoolId') || 1;

  const fetchData = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('adminToken');
      const headers = { 'Authorization': `Bearer ${token}` };

      const [resTeachers, resDepts] = await Promise.all([
        fetch(`${API_TEACHER}/get-all`, { headers }),
        fetch(`${API_DEPT}/get-all-departments?schoolId=${schoolId}`, { headers })
      ]);
      if (resTeachers.ok && resDepts.ok) {
        setTeachers(await resTeachers.json());
        setDepartments(await resDepts.json());
      }
    } catch (err) {
      showToast('Lỗi tải dữ liệu', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const openAddModal = () => {
    setIsEditMode(false);
    setCurrentTeacher({
      id: null, fullName: '', teacherCode: '', email: '', phone: '', citizenIdNumber: '000000000000',
      departmentId: departments.length > 0 ? departments[0].id : '', degree: 'Thạc sĩ', specialization: '', joinedDate: '', bio: ''
    });
    setTModal(true);
  };

  const openEditModal = (t) => {
    setIsEditMode(true);
    setCurrentTeacher({
      id: t.id, fullName: t.fullName, teacherCode: t.teacherCode, email: t.email, phone: t.phone,
      citizenIdNumber: '000000000000', departmentId: t.departmentId, degree: t.degree,
      specialization: t.specialization, joinedDate: t.joinedDate || '', bio: t.bio || ''
    });
    setTModal(true);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setCurrentTeacher(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const url = isEditMode ? `${API_TEACHER}/update-teacher/${currentTeacher.id}` : `${API_TEACHER}/create-teacher`;
    const method = isEditMode ? 'PUT' : 'POST';

    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ ...currentTeacher, departmentId: parseInt(currentTeacher.departmentId) }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt || 'Lỗi lưu dữ liệu');
      }
      showToast(isEditMode ? 'Cập nhật thành công!' : 'Thêm GV thành công!', 'success');
      setTModal(false);
      fetchData();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const getInitials = (name) => {
    if (!name) return 'GV';
    const parts = name.trim().split(' ');
    if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
    return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
  };

  return (
    <div className="page">
      <div className="ph">
        <div>
          <div className="ph-title">Quản lý Giảng viên</div>
          <div className="ph-sub">{teachers.length} giảng viên · Đa ngành</div>
        </div>
        <button className="btn btn-blue" onClick={openAddModal}>+ Thêm giảng viên</button>
      </div>

      <div className="filter-bar">
        <input className="fc" style={{ maxWidth: '260px' }} placeholder="Tìm theo tên, mã GV..." />
        <select className="fc" style={{ maxWidth: '160px' }}>
          <option value="">Tất cả khoa</option>
          {departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
        </select>
        <select className="fc" style={{ maxWidth: '140px' }}>
          <option>Tất cả học vị</option>
          <option>Tiến sĩ</option>
          <option>Thạc sĩ</option>
        </select>
      </div>

      <table className="tbl" style={{ background: 'white' }}>
        <thead>
          <tr>
            <th>Mã GV</th><th>Giảng viên</th><th>Khoa</th><th>Học vị</th><th>Chuyên ngành</th><th>Thao tác</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan="6" style={{ textAlign: 'center', padding: 20 }}>Đang tải...</td></tr>
          ) : teachers.length === 0 ? (
            <tr><td colSpan="6" style={{ textAlign: 'center', padding: 20 }}>Chưa có giảng viên nào</td></tr>
          ) : (
            teachers.map(t => (
              <tr key={t.id}>
                <td style={{ fontWeight: 700, color: 'var(--blue)' }}>{t.teacherCode}</td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '9px' }}>
                    <div className={`av av-${t.id % 2 === 0 ? 'blue' : 'pink'} av-lg`}>{getInitials(t.fullName)}</div>
                    <div>
                      <div style={{ fontWeight: 700 }}>{t.fullName}</div>
                      <div style={{ fontSize: '11px', color: 'var(--muted)' }}>{t.email}</div>
                    </div>
                  </div>
                </td>
                <td>{t.departmentName}</td>
                <td>
                  <span className={`badge ${t.degree === 'Tiến sĩ' ? 'b-purple' : 'b-amber'}`}>
                    {t.degree || 'Chưa rõ'}
                  </span>
                </td>
                <td style={{ fontSize: '12px', color: 'var(--muted)' }}>{t.specialization}</td>
                <td>
                  <div style={{ display: 'flex', gap: '4px' }}>
                    <button className="btn btn-ghost btn-xs" onClick={() => openEditModal(t)}>Sửa</button>
                    <button className="btn btn-teal btn-xs">Phân công</button>
                  </div>
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>

      {tModal && (
        <div className="ov open" style={{ zIndex: 999 }}>
          <div className="modal" style={{ width: 600 }}>
            <div className="modal-hd">
              <span className="modal-title">{isEditMode ? <><User className="w-4 h-4 inline-block mr-2" />‍<School className="w-4 h-4 inline-block mr-2" /> Sửa Giảng viên</> : <><User className="w-4 h-4 inline-block mr-2" />‍<School className="w-4 h-4 inline-block mr-2" /> Thêm Giảng viên</>}</span>
              <button className="close-btn" type="button" onClick={() => setTModal(false)}>×</button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="grid2">
                  <div className="fg">
                    <label className="fl">Họ và tên (*)</label>
                    <input className="fc" name="fullName" value={currentTeacher.fullName} onChange={handleInputChange} required placeholder="Nguyễn Văn A" />
                  </div>
                  <div className="fg">
                    <label className="fl">Mã giảng viên (*)</label>
                    <input className="fc" name="teacherCode" value={currentTeacher.teacherCode} onChange={handleInputChange} required disabled={isEditMode} placeholder="GV001" />
                  </div>
                </div>
                <div className="grid2">
                  <div className="fg">
                    <label className="fl">Email (*)</label>
                    <input className="fc" type="email" name="email" value={currentTeacher.email} onChange={handleInputChange} required disabled={isEditMode} placeholder="gv@hcmut.edu.vn" />
                  </div>
                  <div className="fg">
                    <label className="fl">Điện thoại (*)</label>
                    <input className="fc" name="phone" value={currentTeacher.phone} onChange={handleInputChange} required placeholder="09xxxxxxxx" />
                  </div>
                </div>
                <div className="grid2">
                  <div className="fg">
                    <label className="fl">Khoa / Bộ môn (*)</label>
                    <select className="fc" name="departmentId" value={currentTeacher.departmentId} onChange={handleInputChange} required>
                      <option value="" disabled>-- Chọn Khoa --</option>
                      {departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
                    </select>
                  </div>
                  <div className="fg">
                    <label className="fl">Học vị</label>
                    <select className="fc" name="degree" value={currentTeacher.degree} onChange={handleInputChange}>
                      <option value="Cử nhân">Cử nhân</option><option value="Thạc sĩ">Thạc sĩ</option><option value="Tiến sĩ">Tiến sĩ</option><option value="Giáo sư">Giáo sư</option>
                    </select>
                  </div>
                </div>
                <div className="grid2">
                  <div className="fg">
                    <label className="fl">Chuyên ngành</label>
                    <input className="fc" name="specialization" value={currentTeacher.specialization} onChange={handleInputChange} placeholder="Trí tuệ nhân tạo..." />
                  </div>
                  <div className="fg">
                    <label className="fl">CCCD (*)</label>
                    <input className="fc" name="citizenIdNumber" value={currentTeacher.citizenIdNumber} onChange={handleInputChange} required disabled={isEditMode} placeholder="079xxxxxxxx" />
                  </div>
                </div>
              </div>
              <div className="modal-ft">
                <button type="button" className="btn btn-ghost" onClick={() => setTModal(false)}>Hủy</button>
                <button type="submit" className="btn btn-blue"><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Toast */}
      {toast.show && (
        <div style={{
          position: 'fixed', top: 24, right: 24, zIndex: 10000,
          background: toast.type === 'success' ? '#10b981' : '#ef4444',
          color: 'white', padding: '14px 24px', borderRadius: 8,
          boxShadow: '0 10px 25px rgba(0,0,0,0.2)', fontWeight: 600, fontSize: 14,
          transition: 'all 0.3s ease-out'
        }}>
          {toast.type === 'success' ? <><CheckCircle2 className="w-4 h-4 inline-block mr-2" /> </> : <><AlertTriangle className="w-4 h-4 inline-block mr-2" /> </>}{toast.msg}
        </div>
      )}
    </div>
  );
}
