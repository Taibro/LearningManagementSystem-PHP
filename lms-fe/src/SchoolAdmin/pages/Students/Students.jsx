import React, { useState, useEffect } from 'react';
import { GraduationCap, Search, User, Save, Download } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Students() {
  const [students, setStudents] = useState([]);
  const [toast, setToast] = useState(null);

  // Form states
  const [sModal, setSModal] = useState(false);
  const [currentStudent, setCurrentStudent] = useState({ 
    id: null, userId: '', studentCode: '', departmentId: '', enrollmentYear: new Date().getFullYear(), major: '', className: '' 
  });

  useEffect(() => {
    fetchStudents();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchStudents = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/students`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setStudents(data);
      }
    } catch (error) {
      showToast('Lỗi khi tải danh sách sinh viên!', 'error');
    }
  };

  const handleSaveStudent = async () => {
    const method = currentStudent.id ? 'PUT' : 'POST';
    const url = currentStudent.id 
      ? `${API_BASE_URL}/school-admin/students/${currentStudent.id}`
      : `${API_BASE_URL}/school-admin/students`;

    const payload = {
      userId: parseInt(currentStudent.userId) || 0,
      studentCode: currentStudent.studentCode,
      departmentId: currentStudent.departmentId ? parseInt(currentStudent.departmentId) : null,
      enrollmentYear: parseInt(currentStudent.enrollmentYear),
      major: currentStudent.major,
      className: currentStudent.className
    };

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast(currentStudent.id ? 'Cập nhật sinh viên thành công!' : 'Thêm sinh viên thành công!');
        setSModal(false);
        fetchStudents();
      } else {
        showToast('Lỗi khi lưu sinh viên!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDeleteStudent = async (id) => {
    if(!window.confirm("Bạn có chắc muốn xóa sinh viên này?")) return;
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/students/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        showToast('Đã xóa!');
        fetchStudents();
      }
    } catch (err) {
      showToast('Lỗi khi xóa!', 'error');
    }
  };

  const openStudentModal = (student = null) => {
    setCurrentStudent(student ? { ...student } : { 
      id: null, userId: '', studentCode: '', departmentId: '', enrollmentYear: new Date().getFullYear(), major: '', className: '' 
    });
    setSModal(true);
  };

  // Helper tạo chữ viết tắt cho avatar
  const getInitials = (name) => {
    if (!name) return 'SV';
    const parts = name.split(' ');
    if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  };

  // Chọn màu ngẫu nhiên cho avatar dựa trên MSSV hoặc Tên
  const getAvatarClass = (name) => {
    const charCode = name ? name.charCodeAt(0) % 3 : 0;
    if (charCode === 0) return 'av-blue';
    if (charCode === 1) return 'av-pink';
    return 'av-amber';
  };

  return (
    <div className="page" style={{ position: 'relative' }}>
      
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

      <div className="ph">
        <div>
          <div className="ph-title">Quản lý Sinh viên</div>
          <div className="ph-sub">{students.length} sinh viên đang theo học</div>
        </div>
        <div style={{display:'flex', gap:'8px'}}>
          <button className="btn btn-ghost"><Download className="w-4 h-4 inline-block mr-2" /> Import Excel</button>
          <button className="btn btn-blue" onClick={() => openStudentModal()}>+ Thêm sinh viên</button>
        </div>
      </div>

      <div className="filter-bar">
        <input className="fc" style={{maxWidth:'260px'}} placeholder="MSSV, tên, email..." />
        <select className="fc" style={{maxWidth:'140px'}}>
          <option>Tất cả khoa</option>
        </select>
        <select className="fc" style={{maxWidth:'140px'}}>
          <option>Tất cả lớp</option>
        </select>
        <select className="fc" style={{maxWidth:'120px'}}>
          <option>Tất cả năm</option>
        </select>
      </div>

      <div className="card">
        <table className="tbl">
          <thead>
            <tr>
              <th>MSSV</th>
              <th>Sinh viên</th>
              <th>Khoa</th>
              <th>Chuyên ngành</th>
              <th>Lớp HC</th>
              <th>Năm nhập</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {students.map((st) => (
              <tr key={st.id}>
                <td style={{fontWeight:700, color:'var(--blue)'}}>{st.studentCode}</td>
                <td>
                  <div style={{display:'flex', alignItems:'center', gap:'9px'}}>
                    <div className={`av ${getAvatarClass(st.fullName)} av-lg`}>{getInitials(st.fullName)}</div>
                    <div>
                      <div style={{fontWeight:700}}>{st.fullName || 'Chưa cập nhật tên'}</div>
                      <div style={{fontSize:'11px', color:'var(--muted)'}}>{st.email || 'Chưa cập nhật email'} · {st.gender === 'MALE' ? 'Nam' : st.gender === 'FEMALE' ? 'Nữ' : 'Khác'}</div>
                    </div>
                  </div>
                </td>
                <td>{st.departmentName || '—'}</td>
                <td>{st.major || '—'}</td>
                <td style={{fontFamily:'monospace'}}>{st.className || '—'}</td>
                <td>{st.enrollmentYear}</td>
                <td>
                  <div style={{display:'flex', gap:'4px'}}>
                    <button className="btn btn-ghost btn-xs" onClick={() => openStudentModal(st)}>Xem</button>
                    <button className="btn btn-danger btn-xs" onClick={() => handleDeleteStudent(st.id)}>Xóa</button>
                  </div>
                </td>
              </tr>
            ))}
            {students.length === 0 && <tr><td colSpan="7" style={{textAlign:'center'}}>Chưa có sinh viên nào</td></tr>}
          </tbody>
        </table>
        
        <div className="pg">
          <span>Hiển thị {students.length}/{students.length} sinh viên</span>
          <div className="pg-btns">
            <button className="pg-btn">‹</button>
            <button className="pg-btn act">1</button>
            <button className="pg-btn">›</button>
          </div>
        </div>
      </div>

      {sModal && (
        <div className="ov open">
          <div className="modal">
            <div className="modal-hd">
              <span className="modal-title">{currentStudent.id ? <><User className="w-4 h-4 inline-block mr-2" />‍<GraduationCap className="w-4 h-4 inline-block mr-2" /> Sửa thông tin Sinh viên</> : <><User className="w-4 h-4 inline-block mr-2" />‍<GraduationCap className="w-4 h-4 inline-block mr-2" /> Thêm Sinh viên</>}</span>
              <button className="close-btn" onClick={() => setSModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="grid2">
                <div className="fg">
                  <label className="fl">User ID (Tài khoản gốc)</label>
                  <input type="number" className="fc" value={currentStudent.userId} onChange={e => setCurrentStudent({...currentStudent, userId: e.target.value})} placeholder="ID người dùng..." />
                </div>
                <div className="fg">
                  <label className="fl">MSSV</label>
                  <input className="fc" value={currentStudent.studentCode} onChange={e => setCurrentStudent({...currentStudent, studentCode: e.target.value})} placeholder="21IT001" />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Department ID (Khoa)</label>
                  <input type="number" className="fc" value={currentStudent.departmentId || ''} onChange={e => setCurrentStudent({...currentStudent, departmentId: e.target.value})} placeholder="ID Khoa..." />
                </div>
                <div className="fg">
                  <label className="fl">Lớp hành chính</label>
                  <input className="fc" value={currentStudent.className} onChange={e => setCurrentStudent({...currentStudent, className: e.target.value})} placeholder="CNTT21A" />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Chuyên ngành</label>
                  <input className="fc" value={currentStudent.major} onChange={e => setCurrentStudent({...currentStudent, major: e.target.value})} placeholder="Kỹ thuật phần mềm" />
                </div>
                <div className="fg">
                  <label className="fl">Năm nhập học</label>
                  <input type="number" className="fc" value={currentStudent.enrollmentYear} onChange={e => setCurrentStudent({...currentStudent, enrollmentYear: e.target.value})} placeholder="2021" />
                </div>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setSModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveStudent}><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
