import React, { useState, useEffect } from 'react';
import { Plus, Edit, CheckCircle2, XCircle, AlertTriangle, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_BASE = `${API_BASE_URL}/school-admin`;

export default function Departments() {
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const [currentDept, setCurrentDept] = useState({ id: null, code: '', name: '', description: '' });

  // Toast State
  const [toast, setToast] = useState({ show: false, msg: '', type: 'success' });
  const showToast = (msg, type = 'success') => {
    setToast({ show: true, msg, type });
    setTimeout(() => setToast({ show: false, msg: '', type: 'success' }), 3000);
  };

  // Lấy schoolId và token từ localStorage
  const schoolId = localStorage.getItem('schoolId') || 1;
  const token = localStorage.getItem('adminToken');

  const fetchDepartments = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`${API_BASE}/get-all-departments?schoolId=${schoolId}`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (!res.ok) throw new Error(`Lỗi server: ${res.status}`);
      const data = await res.json();
      setDepartments(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchDepartments(); }, []);

  const openAddModal = () => {
    setIsEditMode(false);
    setCurrentDept({ id: null, code: '', name: '', description: '' });
    setShowModal(true);
  };

  const openEditModal = (dept) => {
    setIsEditMode(true);
    setCurrentDept({ ...dept });
    setShowModal(true);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setCurrentDept(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const url = isEditMode
      ? `${API_BASE}/update-department/${currentDept.id}`
      : `${API_BASE}/create-department`;
    const method = isEditMode ? 'PUT' : 'POST';

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          code: currentDept.code,
          name: currentDept.name,
          description: currentDept.description,
          schoolId,
        }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt || 'Có lỗi xảy ra');
      }
      showToast(isEditMode ? 'Cập nhật khoa thành công!' : 'Thêm khoa thành công!', 'success');
      setShowModal(false);
      fetchDepartments();
    } catch (err) {
      showToast(`Lỗi: ${err.message}`, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc muốn xóa khoa này không?')) return;
    try {
      const res = await fetch(`${API_BASE}/delete-department/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (!res.ok) throw new Error('Xóa thất bại');
      showToast('Xóa khoa thành công!', 'success');
      fetchDepartments();
    } catch (err) {
      showToast(`Lỗi: ${err.message}`, 'error');
    }
  };

  return (
    <div className="page">
      {/* Header */}
      <div className="ph">
        <div className="ph-title">Khoa / Bộ môn</div>
        <button className="btn btn-primary btn-sm" onClick={openAddModal}>
          + Thêm khoa mới
        </button>
      </div>

      {/* Table */}
      <div className="card">
        {loading && <p style={{ padding: 20 }}>⏳ Đang tải dữ liệu...</p>}
        {error && <p style={{ padding: 20, color: 'red' }}><XCircle className="w-4 h-4 inline-block mr-2" /> Lỗi: {error} — Hãy kiểm tra Backend có đang chạy không!</p>}
        {!loading && !error && departments.length === 0 && (
          <p style={{ padding: 20 }}>Chưa có khoa nào trong hệ thống.</p>
        )}
        {!loading && !error && departments.length > 0 && (
          <table className="tbl">
            <thead>
              <tr>
                <th>#</th>
                <th>Mã khoa</th>
                <th>Tên khoa</th>
                <th>Mô tả</th>
                <th>Số GV</th>
                <th>Số SV</th>
                <th>Số môn</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {departments.map((dept, idx) => (
                <tr key={dept.id}>
                  <td>{idx + 1}</td>
                  <td style={{ fontWeight: 700, color: 'var(--blue)' }}>{dept.code}</td>
                  <td>{dept.name}</td>
                  <td>{dept.description || '—'}</td>
                  <td>{dept.teacherCount}</td>
                  <td>{dept.studentCount}</td>
                  <td>{dept.courseCount}</td>
                  <td style={{ display: 'flex', gap: 6 }}>
                    <button className="btn btn-ghost btn-xs" onClick={() => openEditModal(dept)}>Sửa</button>
                    <button className="btn btn-ghost btn-xs" style={{ color: 'red' }} onClick={() => handleDelete(dept.id)}>Xóa</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Modal */}
      {showModal && (
        <div style={{
          position: 'fixed', inset: 0, backgroundColor: 'rgba(0,0,0,0.5)',
          display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 9999,
        }}>
          <div style={{
            background: '#fff', borderRadius: 10, padding: 28, width: 420,
            boxShadow: '0 8px 32px rgba(0,0,0,0.18)',
          }}>
            <h3 style={{ marginTop: 0, marginBottom: 20, fontSize: 18, fontWeight: 700 }}>
              {isEditMode ? <><Edit className="w-4 h-4 inline-block mr-2" /> Sửa thông tin Khoa</> : <><Plus className="w-4 h-4 inline-block mr-2" /> Thêm Khoa mới</>}
            </h3>
            <form onSubmit={handleSubmit}>
              <div style={{ marginBottom: 14 }}>
                <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Mã khoa (*)</label>
                <input
                  type="text" name="code" value={currentDept.code}
                  onChange={handleInputChange} required disabled={isEditMode}
                  placeholder="VD: CNTT"
                  style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                />
              </div>
              <div style={{ marginBottom: 14 }}>
                <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Tên khoa (*)</label>
                <input
                  type="text" name="name" value={currentDept.name}
                  onChange={handleInputChange} required
                  placeholder="VD: Công nghệ Thông tin"
                  style={{ width: '100%', padding: '8px 10px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 14 }}
                />
              </div>
              <div style={{ marginBottom: 20 }}>
                <label style={{ display: 'block', marginBottom: 5, fontSize: 13, fontWeight: 600 }}>Mô tả</label>
                <textarea
                  name="description" value={currentDept.description || ''}
                  onChange={handleInputChange}
                  placeholder="Nhập mô tả khoa..."
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
