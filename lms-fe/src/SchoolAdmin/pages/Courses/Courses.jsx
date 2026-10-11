import React, { useState, useEffect } from 'react';
import { Plus, Edit, CheckCircle2, XCircle, AlertTriangle, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_COURSE = `${API_BASE_URL}/school-admin/courses`;
const API_DEPT = `${API_BASE_URL}/school-admin`; // Để lấy danh sách khoa

export default function Courses() {
  const [courses, setCourses] = useState([]);
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [showModal, setShowModal] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const [currentCourse, setCurrentCourse] = useState({
    id: null, code: '', name: '', credits: 3, theorySessions: 30, practicalSessions: 15, description: '', departmentId: ''
  });

  // Toast State
  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });
  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  const schoolId = localStorage.getItem('schoolId') || 1;
  const token = localStorage.getItem('adminToken');

  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      // Gọi cả 2 API cùng lúc cho nhanh
      const headers = { 'Authorization': `Bearer ${token}` };
      const [resCourses, resDepts] = await Promise.all([
        fetch(`${API_COURSE}/get-all`, { headers }),
        fetch(`${API_DEPT}/get-all-departments?schoolId=${schoolId}`, { headers })
      ]);

      if (!resCourses.ok || !resDepts.ok) throw new Error('Lỗi khi tải dữ liệu từ Server');

      const dataCourses = await resCourses.json();
      const dataDepts = await resDepts.json();

      setCourses(dataCourses);
      setDepartments(dataDepts);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const openAddModal = () => {
    setIsEditMode(false);
    setCurrentCourse({ id: null, code: '', name: '', credits: 3, theorySessions: 30, practicalSessions: 0, description: '', departmentId: departments.length > 0 ? departments[0].id : '' });
    setShowModal(true);
  };

  const openEditModal = (course) => {
    setIsEditMode(true);
    setCurrentCourse({ ...course });
    setShowModal(true);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setCurrentCourse(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!currentCourse.departmentId) {
      showToast('Vui lòng chọn Khoa cho môn học!', 'error');
      return;
    }

    const url = isEditMode
      ? `${API_COURSE}/update-course/${currentCourse.id}`
      : `${API_COURSE}/create-course`;
    const method = isEditMode ? 'PUT' : 'POST';

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          code: currentCourse.code,
          name: currentCourse.name,
          credits: parseInt(currentCourse.credits),
          theorySessions: parseInt(currentCourse.theorySessions),
          practicalSessions: parseInt(currentCourse.practicalSessions),
          description: currentCourse.description,
          departmentId: parseInt(currentCourse.departmentId),
        }),
      });

      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt || 'Có lỗi xảy ra');
      }
      showToast(isEditMode ? 'Cập nhật môn học thành công!' : 'Thêm môn học thành công!', 'success');
      setShowModal(false);
      fetchData(); // Tải lại bảng dữ liệu
    } catch (err) {
      showToast(`Lỗi: ${err.message}`, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc muốn xóa môn học này không? Tất cả các Lớp Học Phần thuộc môn này cũng sẽ bị xóa!')) return;
    try {
      const res = await fetch(`${API_COURSE}/delete-course/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (!res.ok) throw new Error('Xóa thất bại');
      showToast('Xóa môn học thành công!', 'success');
      fetchData();
    } catch (err) {
      showToast(`Lỗi: ${err.message}`, 'error');
    }
  };

  return (
    <div className="page">
      {/* Header */}
      <div className="ph">
        <div className="ph-title">Quản lý Môn học</div>
        <button className="btn btn-primary btn-sm" onClick={openAddModal}>
          + Thêm môn học
        </button>
      </div>

      {/* Table */}
      <div className="card">
        {loading && <p style={{ padding: 20 }}>⏳ Đang tải dữ liệu môn học...</p>}
        {error && <p style={{ padding: 20, color: 'red' }}><XCircle className="w-4 h-4 inline-block mr-2" /> Lỗi: {error} — (Hãy kiểm tra DB và Backend)</p>}

        {!loading && !error && courses.length === 0 && (
          <p style={{ padding: 20 }}>Chưa có môn học nào. Hãy bấm "Thêm môn học" để tạo mới.</p>
        )}

        {!loading && !error && courses.length > 0 && (
          <table className="tbl">
            <thead>
              <tr>
                <th>#</th>
                <th>Mã môn</th>
                <th>Tên môn</th>
                <th>Số TC</th>
                <th>LT / TH</th>
                <th>Tổng số tiết</th>
                <th>Thuộc Khoa</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {courses.map((course, idx) => (
                <tr key={course.id}>
                  <td>{idx + 1}</td>
                  <td style={{ fontWeight: 700, color: 'var(--blue)' }}>{course.code}</td>
                  <td style={{ fontWeight: 500 }}>{course.name}</td>
                  <td>{course.credits}</td>
                  <td>{course.theorySessions} / {course.practicalSessions}</td>
                  <td style={{ fontWeight: 600 }}>{course.totalSessions}</td>
                  <td><span className="badge b-gray">{course.departmentName || 'Không xác định'}</span></td>
                  <td style={{ display: 'flex', gap: 6 }}>
                    <button className="btn btn-ghost btn-xs" onClick={() => openEditModal(course)}>Sửa</button>
                    <button className="btn btn-ghost btn-xs" style={{ color: 'red' }} onClick={() => handleDelete(course.id)}>Xóa</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Modal Thêm / Sửa */}
      {showModal && (
        <div style={{
          position: 'fixed', inset: 0, backgroundColor: 'rgba(0,0,0,0.5)',
          display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 9999,
        }}>
          <div style={{
            background: '#fff', borderRadius: 10, padding: 28, width: 500,
            boxShadow: '0 8px 32px rgba(0,0,0,0.18)', maxHeight: '90vh', overflowY: 'auto'
          }}>
            <h3 style={{ marginTop: 0, marginBottom: 20, fontSize: 18, fontWeight: 700 }}>
              {isEditMode ? <><Edit className="w-4 h-4 inline-block mr-2" /> Sửa thông tin Môn học</> : <><Plus className="w-4 h-4 inline-block mr-2" /> Thêm Môn học mới</>}
            </h3>

            <form onSubmit={handleSubmit}>
              <div style={{ display: 'flex', gap: 15, marginBottom: 14 }}>
                <div style={{ flex: 1 }}>
                  <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Mã môn (*)</label>
                  <input
                    type="text" name="code" value={currentCourse.code}
                    onChange={handleInputChange} required disabled={isEditMode}
                    placeholder="VD: INT101"
                    style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                  />
                </div>
                <div style={{ flex: 2 }}>
                  <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Tên môn học (*)</label>
                  <input
                    type="text" name="name" value={currentCourse.name}
                    onChange={handleInputChange} required
                    placeholder="VD: Lập trình Java"
                    style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                  />
                </div>
              </div>

              <div style={{ marginBottom: 14 }}>
                <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Thuộc Khoa / Bộ môn (*)</label>
                <select
                  name="departmentId" value={currentCourse.departmentId}
                  onChange={handleInputChange} required
                  style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                >
                  <option value="" disabled>-- Chọn Khoa --</option>
                  {departments.map(dept => (
                    <option key={dept.id} value={dept.id}>{dept.name} ({dept.code})</option>
                  ))}
                </select>
              </div>

              <div style={{ display: 'flex', gap: 15, marginBottom: 14 }}>
                <div style={{ flex: 1 }}>
                  <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Số Tín chỉ (*)</label>
                  <input
                    type="number" name="credits" value={currentCourse.credits} min="1"
                    onChange={handleInputChange} required
                    style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                  />
                </div>
                <div style={{ flex: 1 }}>
                  <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Tiết Lý thuyết</label>
                  <input
                    type="number" name="theorySessions" value={currentCourse.theorySessions} min="0"
                    onChange={handleInputChange} required
                    style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                  />
                </div>
                <div style={{ flex: 1 }}>
                  <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Tiết Thực hành</label>
                  <input
                    type="number" name="practicalSessions" value={currentCourse.practicalSessions} min="0"
                    onChange={handleInputChange} required
                    style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                  />
                </div>
              </div>

              <div style={{ marginBottom: 20 }}>
                <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Mô tả môn học</label>
                <textarea
                  name="description" value={currentCourse.description || ''}
                  onChange={handleInputChange}
                  placeholder="Mô tả tóm tắt nội dung môn học..."
                  style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14, minHeight: 80, resize: 'vertical' }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10 }}>
                <button type="button" onClick={() => setShowModal(false)}
                  style={{ padding: '8px 18px', borderRadius: 6, border: '1px solid #d1d5db', background: '#f3f4f6', cursor: 'pointer', fontSize: 14 }}>
                  Hủy
                </button>
                <button type="submit"
                  style={{ padding: '8px 18px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700, fontSize: 14 }}>
                  <Save className="w-4 h-4 inline-block mr-2" /> Lưu dữ liệu
                </button>
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
