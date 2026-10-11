import React, { useState, useEffect } from 'react';
import { useOutletContext } from 'react-router-dom';
import { Check, X, Pencil, RefreshCw, XCircle, CheckCircle2 } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_BASE = `${API_BASE_URL}/saas-admin`;

const getAuthHeaders = () => ({
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${localStorage.getItem('saas_token')}`
});

export default function Plans() {
  const { addToast } = useOutletContext();
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(true);

  // Edit Plan State
  const [editPlan, setEditPlan] = useState(null);
  const [editForm, setEditForm] = useState({
    name: '', monthlyPrice: 0, yearlyPrice: 0, maxStudents: -1, maxStorageGb: -1
  });

  useEffect(() => {
    fetchPlans();
  }, []);

  const fetchPlans = async () => {
    try {
      const res = await fetch(`${API_BASE}/plans`, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setPlans(data);
      }
    } catch (err) {
      console.error('Lỗi khi tải plans:', err);
    } finally {
      setLoading(false);
    }
  };

  const formatPrice = (price) => {
    if (!price) return '₫0';
    const millions = Number(price) / 1000000;
    return `₫${millions.toFixed(1)}M`;
  };

  const parseFeatures = (featuresJson) => {
    try {
      return JSON.parse(featuresJson || '[]');
    } catch {
      return [];
    }
  };

  const getPlanColor = (code) => {
    if (!code) return 'var(--accent4)';
    const c = code.toUpperCase();
    if (c === 'STARTER') return 'var(--accent4)';
    if (c === 'PRO') return 'var(--accent)';
    if (c === 'ENTERPRISE') return 'var(--accent3)';
    return 'var(--accent)';
  };

  const getPlanBadgeClass = (code) => {
    if (!code) return 'badge-yellow';
    const c = code.toUpperCase();
    if (c === 'STARTER') return 'badge-yellow';
    if (c === 'PRO') return 'badge-purple';
    if (c === 'ENTERPRISE') return 'badge-green';
    return 'badge-blue';
  };

  const openEditModal = (plan) => {
    setEditPlan(plan);
    setEditForm({
      name: plan.name || '',
      monthlyPrice: plan.monthlyPrice || 0,
      yearlyPrice: plan.yearlyPrice || 0,
      maxStudents: plan.maxStudents !== undefined ? plan.maxStudents : -1,
      maxStorageGb: plan.maxStorageGb !== undefined ? plan.maxStorageGb : -1
    });
  };

  const handleUpdatePlan = async () => {
    try {
      const res = await fetch(`${API_BASE}/plans/${editPlan.id}`, {
        method: 'PUT',
        headers: getAuthHeaders(),
        body: JSON.stringify(editForm)
      });
      if (res.ok) {
        const updatedPlan = await res.json();
        // Cập nhật lại số lượng subscriber vì server trả về obj entity gốc không có trường này
        updatedPlan.subscriberCount = editPlan.subscriberCount;
        setPlans(prev => prev.map(p => p.id === updatedPlan.id ? updatedPlan : p));
        setEditPlan(null);
        addToast(<CheckCircle2 className="w-4 h-4 inline-block mr-2" />, `Cập nhật gói "${updatedPlan.name}" thành công!`, 'green');
      } else {
        const err = await res.json();
        addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, err.message || 'Lỗi khi cập nhật gói cước', 'red');
      }
    } catch (err) {
      addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, 'Không thể kết nối đến server', 'red');
    }
  };

  if (loading) {
    return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '400px', color: 'var(--muted)' }}>Đang tải dữ liệu...</div>;
  }

  return (
    <div>
      <div className="grid grid-cols-3 gap-5">
        {plans.map((plan) => {
          const isPro = plan.code?.toUpperCase() === 'PRO';
          const features = parseFeatures(plan.features);
          const color = getPlanColor(plan.code);
          const badgeClass = getPlanBadgeClass(plan.code);

          return (
            <div key={plan.id} className="card p-5 relative overflow-hidden"
              style={isPro ? { borderColor: 'var(--accent)', boxShadow: '0 0 30px rgba(124,109,250,.12)' } : {}}>
              {isPro && <div className="absolute -top-px left-0 right-0 h-0.5 rounded-t-xl" style={{ background: 'var(--accent)' }}></div>}
              <div className="absolute top-0 right-0 w-24 h-24 rounded-full -translate-y-8 translate-x-8" style={{ background: `${color}10` }}></div>
              
              <div className="flex items-center justify-between mb-1">
                <p className="font-mono text-xs" style={{ color }}>{plan.code?.toUpperCase()}</p>
                {isPro && <span className="badge badge-purple">PHỔ BIẾN NHẤT</span>}
              </div>
              
              <p className="font-syne font-bold text-2xl mb-1">
                {plan.code?.toUpperCase() === 'ENTERPRISE' ? 'Liên hệ' : formatPrice(plan.monthlyPrice)}
                {plan.code?.toUpperCase() !== 'ENTERPRISE' && <span className="text-sm font-sans font-normal" style={{ color: 'var(--muted)' }}>/tháng</span>}
                {plan.code?.toUpperCase() === 'ENTERPRISE' && <span className="text-sm font-sans font-normal ml-1" style={{ color: 'var(--muted)' }}>/ custom</span>}
              </p>
              
              <p className="text-xs mb-4" style={{ color: 'var(--muted)' }}>
                {plan.code?.toUpperCase() === 'ENTERPRISE' ? 'Hợp đồng theo năm · SLA riêng' : `${formatPrice(plan.yearlyPrice)}/năm (tiết kiệm 17%)`}
              </p>
              
              <div className="space-y-2 text-xs mb-5">
                <div className="flex items-center gap-2"><span style={{ color: 'var(--accent3)' }}><Check className="w-4 h-4 inline-block mr-2" /></span> Tối đa <strong>{plan.maxStudents === -1 ? 'Không giới hạn' : plan.maxStudents?.toLocaleString()}</strong> sinh viên</div>
                <div className="flex items-center gap-2"><span style={{ color: 'var(--accent3)' }}><Check className="w-4 h-4 inline-block mr-2" /></span> {plan.maxStorageGb === -1 ? 'Storage theo yêu cầu' : `${plan.maxStorageGb}GB lưu trữ`}</div>
                {features.map((f, i) => (
                  <div key={i} className="flex items-center gap-2">
                    <span style={{ color: f.included ? 'var(--accent3)' : 'var(--muted)' }}>{f.included ? <Check className="w-4 h-4 inline-block mr-2" /> : <X className="w-4 h-4 inline-block mr-2" />}</span>
                    <span style={f.included ? {} : { color: 'var(--muted)' }}>{f.name}</span>
                  </div>
                ))}
              </div>
              
              <div className="flex items-center justify-between">
                <span className={`badge ${badgeClass}`}>{plan.subscriberCount || 0} trường đang dùng</span>
                <button className="btn btn-ghost btn-sm flex items-center gap-1" onClick={() => openEditModal(plan)}>
                  <Pencil className="w-3.5 h-3.5" /> Sửa
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {/* Ma trận tính năng */}
      <div className="card mt-5 overflow-hidden">
        <div className="p-4 border-b" style={{ borderColor: 'var(--border)' }}>
          <p className="font-syne font-bold text-sm">Ma trận tính năng</p>
        </div>
        <table>
          <thead>
            <tr>
              <th style={{ width: '40%' }}>TÍNH NĂNG</th>
              {plans.map(p => <th key={p.id} className="text-center">{p.code?.toUpperCase()}</th>)}
            </tr>
          </thead>
          <tbody>
            <tr><td className="text-xs font-semibold py-2.5" style={{ color: 'var(--muted)' }}>HỌC VỤ CƠ BẢN</td>{plans.map(p => <td key={p.id}></td>)}</tr>
            <tr><td className="text-sm">Quản lý lớp học & Lịch học</td>{plans.map(p => <td key={p.id} className="text-center text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></td>)}</tr>
            <tr><td className="text-sm">Điểm danh & Đăng ký học phần</td>{plans.map(p => <td key={p.id} className="text-center text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></td>)}</tr>
            <tr><td className="text-sm">Thông báo trong app</td>{plans.map(p => <td key={p.id} className="text-center text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></td>)}</tr>
            
            <tr><td className="text-xs font-semibold py-2.5" style={{ color: 'var(--muted)' }}>TÀI CHÍNH & NHÂN SỰ</td>{plans.map(p => <td key={p.id}></td>)}</tr>
            <tr><td className="text-sm">Quản lý học phí</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'STARTER' ? { color: 'var(--muted)' } : {}}>{p.code?.toUpperCase() === 'STARTER' ? <X className="w-4 h-4 inline-block mr-2" /> : <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span>}</td>)}</tr>
            <tr><td className="text-sm">Bảng lương giảng viên theo bậc</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'STARTER' ? { color: 'var(--muted)' } : {}}>{p.code?.toUpperCase() === 'STARTER' ? <X className="w-4 h-4 inline-block mr-2" /> : <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span>}</td>)}</tr>
            
            <tr><td className="text-xs font-semibold py-2.5" style={{ color: 'var(--muted)' }}>NÂNG CAO</td>{plans.map(p => <td key={p.id}></td>)}</tr>
            <tr><td className="text-sm">Báo cáo & Dashboard Analytics</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'STARTER' ? { color: 'var(--muted)' } : {}}>{p.code?.toUpperCase() === 'STARTER' ? <X className="w-4 h-4 inline-block mr-2" /> : <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span>}</td>)}</tr>
            <tr><td className="text-sm">QR Code điểm danh</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'STARTER' ? { color: 'var(--muted)' } : {}}>{p.code?.toUpperCase() === 'STARTER' ? <X className="w-4 h-4 inline-block mr-2" /> : <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span>}</td>)}</tr>
            <tr><td className="text-sm">SSO / Azure AD / Google Workspace</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'ENTERPRISE' ? {} : { color: 'var(--muted)' }}>{p.code?.toUpperCase() === 'ENTERPRISE' ? <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span> : <X className="w-4 h-4 inline-block mr-2" />}</td>)}</tr>
            <tr><td className="text-sm">Open API tích hợp ERP</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'ENTERPRISE' ? {} : { color: 'var(--muted)' }}>{p.code?.toUpperCase() === 'ENTERPRISE' ? <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span> : <X className="w-4 h-4 inline-block mr-2" />}</td>)}</tr>
            <tr><td className="text-sm">Audit Log đầy đủ + Export</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'ENTERPRISE' ? {} : { color: 'var(--muted)' }}>{p.code?.toUpperCase() === 'ENTERPRISE' ? <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span> : <X className="w-4 h-4 inline-block mr-2" />}</td>)}</tr>
            <tr><td className="text-sm">SLA & Backup riêng</td>{plans.map(p => <td key={p.id} className="text-center" style={p.code?.toUpperCase() === 'ENTERPRISE' ? {} : { color: 'var(--muted)' }}>{p.code?.toUpperCase() === 'ENTERPRISE' ? <span className="text-green-400"><Check className="w-4 h-4 inline-block mr-2" /></span> : <X className="w-4 h-4 inline-block mr-2" />}</td>)}</tr>
          </tbody>
        </table>
      </div>

      {/* Modal Chỉnh Sửa Plan */}
      {editPlan && (
        <div className="modal-overlay open">
          <div className="modal" style={{ width: '500px' }}>
            <div className="flex items-center justify-between p-5 border-b" style={{ borderColor: 'var(--border)' }}>
              <div>
                <p className="font-syne font-bold text-base flex items-center gap-2">
                  <Pencil className="w-4 h-4" /> Chỉnh sửa gói cước
                </p>
                <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{editPlan.code}</p>
              </div>
              <button onClick={() => setEditPlan(null)} className="w-7 h-7 rounded-lg flex items-center justify-center text-lg" style={{ background: 'var(--surface2)', color: 'var(--muted)' }}>×</button>
            </div>
            
            <div className="p-5 space-y-4">
              <div>
                <label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>TÊN GÓI CƯỚC</label>
                <input className="inp" value={editForm.name} onChange={e => setEditForm({...editForm, name: e.target.value})} />
              </div>
              
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>GIÁ THEO THÁNG (VNĐ)</label>
                  <input type="number" className="inp" value={editForm.monthlyPrice} onChange={e => setEditForm({...editForm, monthlyPrice: Number(e.target.value)})} />
                </div>
                <div>
                  <label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>GIÁ THEO NĂM (VNĐ)</label>
                  <input type="number" className="inp" value={editForm.yearlyPrice} onChange={e => setEditForm({...editForm, yearlyPrice: Number(e.target.value)})} />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>GIỚI HẠN SINH VIÊN (-1: Không giới hạn)</label>
                  <input type="number" className="inp" value={editForm.maxStudents} onChange={e => setEditForm({...editForm, maxStudents: Number(e.target.value)})} />
                </div>
                <div>
                  <label className="text-xs font-mono mb-1.5 block" style={{ color: 'var(--muted)' }}>GIỚI HẠN LƯU TRỮ (GB) (-1: Không giới hạn)</label>
                  <input type="number" className="inp" value={editForm.maxStorageGb} onChange={e => setEditForm({...editForm, maxStorageGb: Number(e.target.value)})} />
                </div>
              </div>
            </div>

            <div className="flex justify-end gap-3 p-5 border-t" style={{ borderColor: 'var(--border)' }}>
              <button className="btn btn-ghost" onClick={() => setEditPlan(null)}>Huỷ</button>
              <button className="btn btn-primary flex items-center gap-2" onClick={handleUpdatePlan}>
                <RefreshCw className="w-4 h-4" /> Lưu thay đổi
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}