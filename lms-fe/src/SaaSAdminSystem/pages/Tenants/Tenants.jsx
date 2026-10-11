import React, { useState, useEffect } from 'react';
import { useOutletContext } from 'react-router-dom';
import { CheckCircle2, XCircle, PartyPopper, Lock, Zap, Unlock, Pencil, CalendarClock, RefreshCw } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_BASE = `${API_BASE_URL}/saas-admin`;

const getAuthHeaders = () => ({
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${localStorage.getItem('saas_token')}`
});

const formatDaysLeft = (daysLeft, expires) => {
  if (!expires || expires === '-') return <span style={{ color: 'var(--muted)' }}>–</span>;
  if (daysLeft < 0) return <span style={{ color: 'var(--accent2)', fontWeight: 600 }}>Hết hạn</span>;
  if (daysLeft === 0) return <span style={{ color: 'var(--accent2)', fontWeight: 600 }}>Hết hạn hôm nay</span>;
  if (daysLeft <= 30) return <span style={{ color: 'var(--accent2)' }}>{daysLeft} ngày còn lại</span>;
  return <span style={{ color: 'var(--muted)' }}>{daysLeft} ngày còn lại</span>;
};

export default function Tenants() {
  const { addToast } = useOutletContext();
  const [tenants, setTenants] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [activeTenant, setActiveTenant] = useState(null);
  const [editTenant, setEditTenant] = useState(null);

  // Form state cho thêm tenant
  const [form, setForm] = useState({
    schoolName: '', schoolCode: '', schoolType: 'UNIVERSITY',
    planId: 1, billingCycle: 'MONTHLY', phone: '',
    adminName: '', adminEmail: ''
  });

  // Edit form state
  const [editForm, setEditForm] = useState({
    name: '', phone: '', planId: '', extendType: 'none', extendMonths: 1, extendYears: 1, newEndDate: ''
  });

  // Plans cho dropdown
  const [plans, setPlans] = useState([]);

  // Filters
  const [searchTerm, setSearchTerm] = useState('');
  const [planFilter, setPlanFilter] = useState('Tất cả gói');
  const [statusFilter, setStatusFilter] = useState('Tất cả trạng thái');

  useEffect(() => {
    fetchTenants();
    fetchPlans();
  }, []);

  const fetchTenants = async () => {
    try {
      const res = await fetch(`${API_BASE}/tenants`, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setTenants(data);
      }
    } catch (err) {
      console.error('Lỗi khi tải tenants:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchPlans = async () => {
    try {
      const res = await fetch(`${API_BASE}/plans`, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setPlans(data);
        if (data.length > 0) setForm(f => ({ ...f, planId: data[0].id }));
      }
    } catch (err) {
      console.error('Lỗi khi tải plans:', err);
    }
  };

  const toggleTenant = async (id, isActive) => {
    try {
      const res = await fetch(`${API_BASE}/tenants/${id}/status`, {
        method: 'PATCH',
        headers: getAuthHeaders(),
        body: JSON.stringify({ isActive })
      });
      if (res.ok) {
        setTenants(prev => prev.map(t => t.id === id ? { ...t, active: isActive } : t));
        const tName = tenants.find(x => x.id === id)?.name;
        addToast(isActive ? <CheckCircle2 className="w-4 h-4 inline-block mr-2" /> : <Lock className="w-4 h-4 inline-block mr-2" />, `${isActive ? 'MỞ KHOÁ' : 'KHOÁ'} tenant: ${tName}`, isActive ? 'green' : 'blue');
      }
    } catch (err) {
      addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, 'Lỗi khi thay đổi trạng thái tenant', 'red');
    }
  };

  const handleCreateTenant = async () => {
    try {
      const res = await fetch(`${API_BASE}/tenants`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify(form)
      });
      if (res.ok) {
        setIsAddOpen(false);
        fetchTenants();
        addToast(<PartyPopper className="w-4 h-4 inline-block mr-2" />, 'Tạo Tenant thành công! Email đã gửi cho School Admin', 'green');
        setForm({ schoolName: '', schoolCode: '', schoolType: 'UNIVERSITY', planId: plans[0]?.id || 1, billingCycle: 'MONTHLY', phone: '', adminName: '', adminEmail: '' });
      } else {
        const err = await res.json();
        addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, err.message || 'Lỗi khi tạo tenant', 'red');
      }
    } catch (err) {
      addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, 'Không thể kết nối đến server', 'red');
    }
  };

  const openEditModal = (t) => {
    setEditTenant(t);
    setEditForm({ name: t.name || '', phone: t.phone || '', planId: '', extendType: 'none', extendMonths: 1, extendYears: 1, newEndDate: '' });
  };

  const handleUpdateTenant = async () => {
    const updates = {};
    if (editForm.name && editForm.name !== editTenant.name) updates.name = editForm.name;
    if (editForm.phone !== editTenant.phone) updates.phone = editForm.phone || null;
    if (editForm.planId) updates.planId = editForm.planId;
    if (editForm.extendType === 'months') updates.extendMonths = editForm.extendMonths;
    else if (editForm.extendType === 'years') updates.extendYears = editForm.extendYears;
    else if (editForm.extendType === 'date' && editForm.newEndDate) updates.newEndDate = editForm.newEndDate;

    try {
      const res = await fetch(`${API_BASE}/tenants/${editTenant.id}`, {
        method: 'PUT',
        headers: getAuthHeaders(),
        body: JSON.stringify(updates)
      });
      if (res.ok) {
        const updated = await res.json();
        setTenants(prev => prev.map(t => t.id === updated.id ? updated : t));
        setEditTenant(null);
        addToast(<CheckCircle2 className="w-4 h-4 inline-block mr-2" />, `Cập nhật Tenant "${updated.name}" thành công!`, 'green');
      } else {
        const err = await res.json();
        addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, err.message || 'Lỗi khi cập nhật tenant', 'red');
      }
    } catch (err) {
      addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, 'Không thể kết nối đến server', 'red');
    }
  };

  const filteredTenants = tenants.filter(t => {
    const searchLower = searchTerm.toLowerCase();
    const matchSearch = !searchTerm ||
      t.name?.toLowerCase().includes(searchLower) ||
      t.code?.toLowerCase().includes(searchLower) ||
      t.email?.toLowerCase().includes(searchLower);
    const matchPlan = planFilter === 'Tất cả gói' || t.planName === planFilter;
    let matchStatus = true;
    if (statusFilter === 'Đang hoạt động') matchStatus = t.active && t.daysLeft > 0;
    else if (statusFilter === 'Bị khóa') matchStatus = !t.active;
    else if (statusFilter === 'Hết hạn') matchStatus = t.daysLeft <= 0;
    return matchSearch && matchPlan && matchStatus;
  });

  if (loading) {
    return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '400px', color: 'var(--muted)' }}>Đang tải dữ liệu...</div>;
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <div className="flex gap-3">
          <input type="text" placeholder="Tìm tên trường, mã, email..." className="inp" style={{ maxWidth: '280px' }} value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
          <select className="inp" style={{ maxWidth: '160px' }} value={planFilter} onChange={e => setPlanFilter(e.target.value)}><option>Tất cả gói</option><option>Enterprise</option><option>Pro</option><option>Starter</option><option>Không có</option></select>
          <select className="inp" style={{ maxWidth: '160px' }} value={statusFilter} onChange={e => setStatusFilter(e.target.value)}><option>Tất cả trạng thái</option><option>Đang hoạt động</option><option>Bị khóa</option><option>Hết hạn</option></select>
        </div>
        <button className="btn btn-primary btn-sm" onClick={() => setIsAddOpen(true)}>Thêm Tenant</button>
      </div>

      <div className="card overflow-hidden">
        <table>
          <thead>
            <tr><th>TRƯỜNG / TRUNG TÂM</th><th>GÓI CƯỚC</th><th>SỐ USERS</th><th>HẾT HẠN</th><th>STORAGE</th><th>TRẠNG THÁI</th><th>KILL SWITCH</th><th></th></tr>
          </thead>
          <tbody>
            {filteredTenants.map(t => (
              <tr key={t.id}>
                <td><div className="font-semibold text-sm">{t.name}</div><div className="text-xs font-mono mt-0.5" style={{ color: 'var(--muted)' }}>{t.code} · {t.type}</div></td>
                <td><span className={`badge ${t.planName === 'Enterprise' ? 'badge-green' : t.planName === 'Pro' ? 'badge-purple' : t.planName === 'Không có' ? 'badge-red' : 'badge-yellow'}`}>{t.planName}</span></td>
                <td>
                  <div className="text-sm">{(t.students || 0).toLocaleString()} SV</div>
                  <div className="text-xs" style={{ color: 'var(--muted)' }}>{(t.teachers || 0).toLocaleString()} GV</div>
                  <div className="text-xs mt-0.5" style={{ color: 'var(--accent3)' }}>{(t.admins || 0).toLocaleString()} Admin</div>
                </td>
                <td>
                  <div className="text-sm font-mono">{t.expires && t.expires !== '-' ? t.expires : '–'}</div>
                  <div className="mt-0.5">{formatDaysLeft(t.daysLeft, t.expires)}</div>
                </td>
                <td><div className="text-sm">{t.storage}</div><div className="progress mt-1" style={{ width: '80px' }}><div className="progress-fill" style={{ width: `${Math.min((t.students * 0.05 + t.teachers * 0.1) / 100 * 100, 100)}%`, background: 'var(--accent)' }}></div></div></td>
                <td>{t.active ? <span className="badge badge-green">● Hoạt động</span> : <span className="badge badge-red">● Bị khóa</span>}</td>
                <td><label className="toggle"><input type="checkbox" checked={t.active} onChange={(e) => toggleTenant(t.id, e.target.checked)} /><span className="slider"></span></label></td>
                <td className="text-right whitespace-nowrap">
                  <div className="flex items-center justify-end gap-1">
                    <button className="btn btn-ghost btn-sm" onClick={() => setActiveTenant(t)}>Chi tiết</button>
                    <button className="btn btn-ghost btn-sm px-2" onClick={() => openEditModal(t)} title="Chỉnh sửa"><Pencil className="w-4 h-4" /></button>
                  </div>
                </td>
              </tr>
            ))}
            {filteredTenants.length === 0 && (
              <tr><td colSpan="8" className="text-center py-8 text-sm" style={{ color: 'var(--muted)' }}>Không tìm thấy kết quả nào phù hợp</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Modal Thêm Tenant */}
      {isAddOpen && (
        <div className="modal-overlay open">
          <div className="modal">
            <div className="flex items-center justify-between p-5 border-b" style={{ borderColor: 'var(--border)' }}>
              <div><p className="font-syne font-bold text-base">Thêm Tenant mới</p><p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>Tạo trường + tài khoản School Admin đầu tiên</p></div>
              <button onClick={() => setIsAddOpen(false)} className="w-7 h-7 rounded-lg flex items-center justify-center text-lg" style={{ background: 'var(--surface2)', color: 'var(--muted)' }}>×</button>
            </div>
            <div className="p-5 space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>TÊN TRƯỜNG / TRUNG TÂM *</label><input className="inp" placeholder="VD: ĐH Bách Khoa HCM" value={form.schoolName} onChange={e => setForm({...form, schoolName: e.target.value})} /></div>
                <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>MÃ TRƯỜNG *</label><input className="inp" placeholder="VD: HCMUT" value={form.schoolCode} onChange={e => setForm({...form, schoolCode: e.target.value})} /></div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>LOẠI HÌNH</label><select className="inp" value={form.schoolType} onChange={e => setForm({...form, schoolType: e.target.value})}><option value="UNIVERSITY">university</option><option value="COLLEGE">college</option><option value="LANGUAGE_CENTER">language_center</option><option value="HIGH_SCHOOL">high_school</option><option value="TUTORING_CENTER">tutoring_center</option></select></div>
                <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>GÓI CƯỚC *</label><select className="inp" value={form.planId} onChange={e => setForm({...form, planId: Number(e.target.value)})}>{plans.map(p => <option key={p.id} value={p.id}>{p.name} — ₫{(Number(p.monthlyPrice)/1000000).toFixed(1)}M/tháng</option>)}</select></div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>CHU KỲ THANH TOÁN</label><select className="inp" value={form.billingCycle} onChange={e => setForm({...form, billingCycle: e.target.value})}><option value="MONTHLY">monthly</option><option value="YEARLY">yearly</option></select></div>
                <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>SỐ ĐIỆN THOẠI</label><input className="inp" placeholder="028-xxxx-xxxx" value={form.phone} onChange={e => setForm({...form, phone: e.target.value})} /></div>
              </div>
              <div className="card-sm p-3 mt-3">
                <p className="text-xs font-semibold mb-2" style={{ color: 'var(--accent3)' }}><Zap className="w-4 h-4 inline-block mr-2" /> Tài khoản School Admin (tự động tạo)</p>
                <div className="grid grid-cols-2 gap-3">
                  <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>HỌ TÊN ADMIN</label><input className="inp" placeholder="VD: Nguyễn Văn A" value={form.adminName} onChange={e => setForm({...form, adminName: e.target.value})} /></div>
                  <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>EMAIL ADMIN *</label><input className="inp" type="email" placeholder="admin@truong.edu.vn" value={form.adminEmail} onChange={e => setForm({...form, adminEmail: e.target.value})} /></div>
                </div>
              </div>
            </div>
            <div className="flex justify-end gap-3 p-5 border-t" style={{ borderColor: 'var(--border)' }}>
              <button className="btn btn-ghost" onClick={() => setIsAddOpen(false)}>Huỷ</button>
              <button className="btn btn-primary" onClick={handleCreateTenant}>Tạo Tenant & Gửi email</button>
            </div>
          </div>
        </div>
      )}

      {/* Modal Chỉnh Sửa Tenant */}
      {editTenant && (
        <div className="modal-overlay open">
          <div className="modal" style={{ width: '560px' }}>
            <div className="flex items-center justify-between p-5 border-b" style={{ borderColor: 'var(--border)' }}>
              <div>
                <p className="font-syne font-bold text-base flex items-center gap-2"><Pencil className="w-4 h-4" /> Chỉnh sửa Tenant</p>
                <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{editTenant.name} ({editTenant.code})</p>
              </div>
              <button onClick={() => setEditTenant(null)} className="w-7 h-7 rounded-lg flex items-center justify-center text-lg" style={{ background: 'var(--surface2)', color: 'var(--muted)' }}>×</button>
            </div>
            <div className="p-5 space-y-4">
              {/* Thông tin cơ bản */}
              <div>
                <p className="text-xs font-mono font-semibold mb-2" style={{ color: 'var(--accent3)' }}>THÔNG TIN CƠ BẢN</p>
                <div className="grid grid-cols-2 gap-3">
                  <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>TÊN TRƯỜNG</label><input className="inp" value={editForm.name} onChange={e => setEditForm({...editForm, name: e.target.value})} /></div>
                  <div><label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>SỐ ĐIỆN THOẠI</label><input className="inp" value={editForm.phone} onChange={e => setEditForm({...editForm, phone: e.target.value})} /></div>
                </div>
              </div>

              {/* Đổi gói cước */}
              <div>
                <p className="text-xs font-mono font-semibold mb-2" style={{ color: 'var(--accent3)' }}>ĐỔI GÓI CƯỚC</p>
                <select className="inp" value={editForm.planId} onChange={e => setEditForm({...editForm, planId: e.target.value})}>
                  <option value="">-- Giữ nguyên gói hiện tại ({editTenant.planName}) --</option>
                  {plans.map(p => <option key={p.id} value={p.id}>{p.name} — ₫{(Number(p.monthlyPrice)/1000000).toFixed(1)}M/tháng</option>)}
                </select>
              </div>

              {/* Gia hạn */}
              <div>
                <p className="text-xs font-mono font-semibold mb-2" style={{ color: 'var(--accent3)' }}>
                  <CalendarClock className="w-4 h-4 inline-block mr-1" /> GIA HẠN SUBSCRIPTION
                </p>
                <p className="text-xs mb-2" style={{ color: 'var(--muted)' }}>
                  Ngày hết hạn hiện tại: <strong style={{ color: editTenant.daysLeft < 0 ? 'var(--accent2)' : 'inherit' }}>
                    {editTenant.expires !== '-' ? editTenant.expires : 'Chưa có'} {editTenant.daysLeft < 0 ? '(Đã hết hạn)' : ''}
                  </strong>
                </p>
                <select className="inp mb-3" value={editForm.extendType} onChange={e => setEditForm({...editForm, extendType: e.target.value})}>
                  <option value="none">-- Không gia hạn --</option>
                  <option value="months">Gia hạn thêm theo tháng</option>
                  <option value="years">Gia hạn thêm theo năm</option>
                  <option value="date">Đặt ngày hết hạn cụ thể</option>
                </select>
                {editForm.extendType === 'months' && (
                  <div className="flex items-center gap-2">
                    <input type="number" min="1" max="24" className="inp" style={{ width: '100px' }} value={editForm.extendMonths} onChange={e => setEditForm({...editForm, extendMonths: Number(e.target.value)})} />
                    <span className="text-sm" style={{ color: 'var(--muted)' }}>tháng</span>
                  </div>
                )}
                {editForm.extendType === 'years' && (
                  <div className="flex items-center gap-2">
                    <input type="number" min="1" max="5" className="inp" style={{ width: '100px' }} value={editForm.extendYears} onChange={e => setEditForm({...editForm, extendYears: Number(e.target.value)})} />
                    <span className="text-sm" style={{ color: 'var(--muted)' }}>năm</span>
                  </div>
                )}
                {editForm.extendType === 'date' && (
                  <input type="date" className="inp" value={editForm.newEndDate} onChange={e => setEditForm({...editForm, newEndDate: e.target.value})} />
                )}
              </div>
            </div>
            <div className="flex justify-end gap-3 p-5 border-t" style={{ borderColor: 'var(--border)' }}>
              <button className="btn btn-ghost" onClick={() => setEditTenant(null)}>Huỷ</button>
              <button className="btn btn-primary flex items-center gap-2" onClick={handleUpdateTenant}>
                <RefreshCw className="w-4 h-4" /> Lưu thay đổi
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal Chi tiết Tenant */}
      {activeTenant && (
        <div className="modal-overlay open">
          <div className="modal" style={{ width: '560px' }}>
            <div className="flex items-center justify-between p-5 border-b" style={{ borderColor: 'var(--border)' }}>
              <p className="font-syne font-bold text-base">{activeTenant.name}</p>
              <button onClick={() => setActiveTenant(null)} className="w-7 h-7 rounded-lg flex items-center justify-center text-lg" style={{ background: 'var(--surface2)', color: 'var(--muted)' }}>×</button>
            </div>

            <div className="p-5">
              <div className="grid grid-cols-4 gap-3 mb-4">
                <div className="card-sm p-3"><p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>MÃ TRƯỜNG</p><p className="font-mono font-bold truncate">{activeTenant.code}</p></div>
                <div className="card-sm p-3"><p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>GÓI CƯỚC</p><p className="font-semibold truncate">{activeTenant.planName}</p></div>
                <div className="card-sm p-3"><p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>STORAGE</p><p className="font-semibold truncate">{activeTenant.storage}</p></div>
                <div className="card-sm p-3"><p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>HẾT HẠN</p>
                  <p className="font-semibold text-xs">{activeTenant.expires !== '-' ? activeTenant.expires : '–'}</p>
                  <div className="mt-0.5">{formatDaysLeft(activeTenant.daysLeft, activeTenant.expires)}</div>
                </div>
                <div className="card-sm p-3"><p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>SINH VIÊN</p><p className="font-semibold">{(activeTenant.students || 0).toLocaleString()}</p></div>
                <div className="card-sm p-3"><p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>GIẢNG VIÊN</p><p className="font-semibold">{(activeTenant.teachers || 0).toLocaleString()}</p></div>
                <div className="card-sm p-3"><p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>ADMINS</p><p className="font-semibold" style={{ color: 'var(--accent3)' }}>{(activeTenant.admins || 0).toLocaleString()}</p></div>
              </div>

              <div className="card-sm p-3 mb-3">
                <p className="text-xs font-mono mb-1" style={{ color: 'var(--muted)' }}>EMAIL ADMIN TRƯỜNG</p>
                <p className="text-sm">{activeTenant.email}</p>
              </div>

              <div className="card-sm p-3">
                <p className="text-xs font-mono mb-2" style={{ color: 'var(--muted)' }}>TRẠNG THÁI KILL SWITCH</p>
                <div className="flex items-center gap-3">
                  <label className="toggle">
                    <input type="checkbox" checked={activeTenant.active} onChange={(e) => {
                      toggleTenant(activeTenant.id, e.target.checked);
                      setActiveTenant({...activeTenant, active: e.target.checked});
                    }} />
                    <span className="slider"></span>
                  </label>
                  <span className="text-sm" style={{ color: activeTenant.active ? 'var(--accent3)' : 'var(--accent2)' }}>
                    {activeTenant.active ? '● Trường đang hoạt động bình thường' : '● Trường đang bị khoá — User không thể đăng nhập'}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between p-5 border-t" style={{ borderColor: 'var(--border)' }}>
              <button className="btn btn-danger btn-sm pulse-red" onClick={() => {
                toggleTenant(activeTenant.id, !activeTenant.active);
                setActiveTenant(null);
              }}>
                {activeTenant.active ? <><Zap className="w-4 h-4 inline-block mr-2" /> Kích hoạt Kill Switch (Khoá ngay)</> : <><Unlock className="w-4 h-4 inline-block mr-2" /> Mở khoá Tenant</>}
              </button>
              <div className="flex gap-2">
                <button className="btn btn-ghost btn-sm flex items-center gap-1" onClick={() => { setActiveTenant(null); openEditModal(activeTenant); }}>
                  <Pencil className="w-3.5 h-3.5" /> Chỉnh sửa
                </button>
                <button className="btn btn-ghost btn-sm" onClick={() => setActiveTenant(null)}>Đóng</button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}