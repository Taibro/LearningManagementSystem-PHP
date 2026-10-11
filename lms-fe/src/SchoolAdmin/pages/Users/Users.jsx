import React, { useState, useEffect } from 'react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Users() {
  const [users, setUsers] = useState([]);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchUsers = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/users`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setUsers(data);
      }
    } catch (error) {
      showToast('Lỗi khi tải danh sách người dùng!', 'error');
    }
  };

  // Helper render huy hiệu Vai trò
  const renderRoleBadge = (role) => {
    if (role === 'teacher') return <span className="badge b-purple">teacher</span>;
    if (role === 'student') return <span className="badge b-teal">student</span>;
    if (role === 'admin') return <span className="badge b-amber">admin</span>;
    return <span className="badge b-gray">{role}</span>;
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
        <div className="ph-title">Tài khoản</div>
      </div>
      
      <div className="card">
        <table className="tbl">
          <thead>
            <tr>
              <th>#</th>
              <th>Họ tên</th>
              <th>Email</th>
              <th>Vai trò</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user, index) => (
              <tr key={user.id}>
                <td>{index + 1}</td>
                <td style={{fontWeight: 600}}>{user.fullName}</td>
                <td>{user.email}</td>
                <td>{renderRoleBadge(user.role)}</td>
                <td>
                  {user.isActive !== false 
                    ? <span className="badge b-green">Active</span> 
                    : <span className="badge b-gray">Locked</span>}
                </td>
                <td>
                  <button className="btn btn-ghost btn-xs">Sửa</button>
                </td>
              </tr>
            ))}
            {users.length === 0 && (
              <tr><td colSpan="6" style={{textAlign: 'center'}}>Chưa có tài khoản nào</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
