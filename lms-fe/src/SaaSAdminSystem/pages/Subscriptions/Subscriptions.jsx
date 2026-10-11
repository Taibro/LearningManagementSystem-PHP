import React, { useState, useEffect } from 'react';
import { CreditCard, Landmark, Smartphone, Banknote } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_BASE = `${API_BASE_URL}/saas-admin`;

const getAuthHeaders = () => ({
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${localStorage.getItem('saas_token')}`
});

export default function Subscriptions() {
  const [invoices, setInvoices] = useState([]);
  const [stats, setStats] = useState(null);
  const [activeTab, setActiveTab] = useState('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchInvoices();
    fetchStats();
  }, []);

  const fetchInvoices = async (status) => {
    try {
      const url = status ? `${API_BASE}/subscriptions/invoices?status=${status}` : `${API_BASE}/subscriptions/invoices`;
      const res = await fetch(url, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setInvoices(data);
      }
    } catch (err) {
      console.error('Lỗi khi tải invoices:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const res = await fetch(`${API_BASE}/subscriptions/stats`, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setStats(data);
      }
    } catch (err) {
      console.error('Lỗi khi tải stats:', err);
    }
  };

  const handleTabClick = (tab) => {
    setActiveTab(tab);
    if (tab === 'all') fetchInvoices();
    else if (tab === 'paid') fetchInvoices('PAID');
    else if (tab === 'pending') fetchInvoices('PENDING');
    else if (tab === 'failed') fetchInvoices('FAILED');
  };

  const statusBadge = { PAID: 'badge-green', PENDING: 'badge-yellow', FAILED: 'badge-red' };
  const statusLabel = { PAID: 'Đã thanh toán', PENDING: 'Chờ TT', FAILED: 'Thất bại' };
  const methodIcon = { BANK_TRANSFER: <Landmark className="w-4 h-4 inline-block mr-2" />, MOMO: <Smartphone className="w-4 h-4 inline-block mr-2" />, VNPAY: <CreditCard className="w-4 h-4 inline-block mr-2" />, CASH: <Banknote className="w-4 h-4 inline-block mr-2" />, bank_transfer: <Landmark className="w-4 h-4 inline-block mr-2" />, momo: <Smartphone className="w-4 h-4 inline-block mr-2" />, vnpay: <CreditCard className="w-4 h-4 inline-block mr-2" />, cash: <Banknote className="w-4 h-4 inline-block mr-2" /> };

  const formatAmount = (amount) => {
    if (!amount) return '₫0';
    return `₫${Number(amount).toLocaleString('vi-VN')}`;
  };

  if (loading) {
    return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '400px', color: 'var(--muted)' }}>Đang tải dữ liệu...</div>;
  }

  return (
    <div>
      <div className="grid grid-cols-3 gap-4 mb-5">
        <div className="card p-4">
          <p className="text-xs font-mono mb-2" style={{ color: 'var(--muted)' }}>TỔNG DOANH THU (YTD)</p>
          <p className="stat-num text-2xl" style={{ color: 'var(--accent)' }}>{formatAmount(stats?.totalRevenueYTD)}</p>
          <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>▲ Tổng thu từ đầu năm</p>
        </div>
        <div className="card p-4">
          <p className="text-xs font-mono mb-2" style={{ color: 'var(--muted)' }}>HOÁ ĐƠN CHỜ THANH TOÁN</p>
          <p className="stat-num text-2xl" style={{ color: 'var(--accent4)' }}>{stats?.pendingInvoiceCount || 0}</p>
          <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>Tổng {formatAmount(stats?.pendingAmount)} chưa thu</p>
        </div>
        <div className="card p-4">
          <p className="text-xs font-mono mb-2" style={{ color: 'var(--muted)' }}>CHURN RATE (THÁNG)</p>
          <p className="stat-num text-2xl" style={{ color: 'var(--accent3)' }}>{stats?.churnRate || '0%'}</p>
          <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>Tỷ lệ huỷ gói trong tháng</p>
        </div>
      </div>

      <div className="card overflow-hidden">
        <div className="flex items-center justify-between p-4 border-b" style={{ borderColor: 'var(--border)' }}>
          <p className="font-syne font-bold text-sm">Lịch sử Hoá đơn SaaS</p>
          <div className="flex gap-2">
            <div className={`tab ${activeTab === 'all' ? 'active' : ''}`} onClick={() => handleTabClick('all')}>Tất cả</div>
            <div className={`tab ${activeTab === 'paid' ? 'active' : ''}`} onClick={() => handleTabClick('paid')}>Đã thanh toán</div>
            <div className={`tab ${activeTab === 'pending' ? 'active' : ''}`} onClick={() => handleTabClick('pending')}>Chờ thanh toán</div>
            <div className={`tab ${activeTab === 'failed' ? 'active' : ''}`} onClick={() => handleTabClick('failed')}>Thất bại</div>
          </div>
        </div>
        <table>
          <thead>
            <tr><th>#INV</th><th>TRƯỜNG</th><th>GÓI</th><th>CHU KỲ</th><th>SỐ TIỀN</th><th>PHƯƠNG THỨC</th><th>NGÀY</th><th>TRẠNG THÁI</th></tr>
          </thead>
          <tbody>
            {invoices.map((i, index) => (
              <tr key={index}>
                <td className="font-mono text-xs">{i.invoiceCode}</td>
                <td className="text-sm font-semibold">{i.schoolName}</td>
                <td><span className={`badge ${i.planName === 'Enterprise' ? 'badge-green' : i.planName === 'Pro' ? 'badge-purple' : 'badge-yellow'}`}>{i.planName}</span></td>
                <td className="text-xs font-mono">{i.billingCycle?.toLowerCase()}</td>
                <td className="font-mono text-sm font-semibold">{formatAmount(i.amount)}</td>
                <td className="text-xs">{methodIcon[i.paymentMethod] || <CreditCard className="w-4 h-4 inline-block mr-2" />} {(i.paymentMethod || '').replace(/_/g, ' ').toLowerCase()}</td>
                <td className="text-xs font-mono">{i.createdAt ? new Date(i.createdAt).toLocaleDateString('vi-VN') : '-'}</td>
                <td><span className={`badge ${statusBadge[i.paymentStatus] || 'badge-yellow'}`}>{statusLabel[i.paymentStatus] || i.paymentStatus}</span></td>
              </tr>
            ))}
            {invoices.length === 0 && (
              <tr><td colSpan="8" className="text-center text-xs" style={{ color: 'var(--muted)', padding: '20px' }}>Không có hoá đơn nào</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}