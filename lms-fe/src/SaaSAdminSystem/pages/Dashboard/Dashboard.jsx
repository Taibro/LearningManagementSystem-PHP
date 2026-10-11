import React, { useEffect, useState } from 'react';
import Chart from 'chart.js/auto';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_BASE = `${API_BASE_URL}/saas-admin`;

const getAuthHeaders = () => ({
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${localStorage.getItem('saas_token')}`
});

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardStats();
  }, []);

  const fetchDashboardStats = async () => {
    try {
      const res = await fetch(`${API_BASE}/dashboard/stats`, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setStats(data);
      }
    } catch (err) {
      console.error('Lỗi khi tải dashboard:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!stats) return;

    const gridColor = 'rgba(30,33,48,.8)';
    const font = { family: 'DM Mono', size: 10 };

    const revenueLabels = stats.revenueHistory?.map(r => r.month) || [];
    const revenueData = stats.revenueHistory?.map(r => Number(r.revenue) / 1000000) || [];
    const newClientsData = stats.revenueHistory?.map(r => r.newClients) || [];

    const revChart = new Chart(document.getElementById('revenueChart'), {
      type: 'bar',
      data: {
        labels: revenueLabels,
        datasets: [
          { label:'MRR (triệu ₫)', data: revenueData, backgroundColor:'rgba(124,109,250,.7)', borderRadius:5, borderSkipped:false },
          { label:'Khách mới', data: newClientsData, backgroundColor:'rgba(109,250,194,.7)', borderRadius:5, borderSkipped:false, yAxisID:'y1' },
        ]
      },
      options: {
        responsive: true, maintainAspectRatio: false, interaction: { mode: 'index' },
        plugins: { legend: { display: false } },
        scales: {
          x: { grid: { color: gridColor }, ticks: { color: '#5a5f7a', font } },
          y: { grid: { color: gridColor }, ticks: { color: '#5a5f7a', font, callback: v => v + 'M' } },
          y1: { position: 'right', grid: { display: false }, ticks: { color: '#5a5f7a', font } }
        }
      }
    });

    const planLabels = stats.planDistribution?.map(p => p.planName) || [];
    const planData = stats.planDistribution?.map(p => p.count) || [];
    const planColors = ['#7c6dfa','#6dfac2','#fac96d','#fa6d8e','#6dc2fa'];

    const planChart = new Chart(document.getElementById('planChart'), {
      type: 'doughnut',
      data: {
        labels: planLabels,
        datasets: [{ data: planData, backgroundColor: planColors.slice(0, planLabels.length), borderWidth: 0, hoverOffset: 4 }]
      },
      options: { responsive: true, maintainAspectRatio: false, cutout: '72%', plugins: { legend: { display: false } } }
    });

    return () => { revChart.destroy(); planChart.destroy(); };
  }, [stats]);

  const formatMRR = (value) => {
    if (!value) return '₫0';
    const millions = Number(value) / 1000000;
    return `₫${millions.toFixed(1)}M`;
  };

  if (loading) {
    return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '400px', color: 'var(--muted)' }}>Đang tải dữ liệu...</div>;
  }

  return (
    <div>
      <div className="grid grid-cols-4 gap-4 mb-5">
        <div className="card p-5 col-span-1" style={{ background: 'linear-gradient(135deg,rgba(124,109,250,.15),rgba(124,109,250,.04))', borderColor: 'rgba(124,109,250,.25)' }}>
          <p className="text-xs font-mono mb-3" style={{ color: 'var(--muted)' }}>MRR (THÁNG NÀY)</p>
          <p className="stat-num text-3xl mrr-glow" style={{ color: 'var(--accent)' }}>{formatMRR(stats?.mrr)}</p>
          <p className="text-xs mt-2" style={{ color: 'var(--accent3)' }}>▲ {stats?.mrrGrowthPercent || '+0%'} so với tháng trước</p>
        </div>
        <div className="card p-5">
          <p className="text-xs font-mono mb-3" style={{ color: 'var(--muted)' }}>TỔNG TRƯỜNG / TT</p>
          <p className="stat-num text-3xl">{stats?.totalSchools || 0}</p>
          <div className="flex items-center gap-2 mt-2"><span className="badge badge-green">+{stats?.newSchoolsThisMonth || 0} tháng này</span></div>
        </div>
        <div className="card p-5">
          <p className="text-xs font-mono mb-3" style={{ color: 'var(--muted)' }}>TỔNG USERS</p>
          <p className="stat-num text-3xl">{((stats?.totalStudents || 0) + (stats?.totalTeachers || 0) + (stats?.totalSchoolAdmins || 0)).toLocaleString()}</p>
          <p className="text-xs mt-2" style={{ color: 'var(--muted)' }}>{(stats?.totalStudents || 0).toLocaleString()} SV · {(stats?.totalTeachers || 0).toLocaleString()} GV · {(stats?.totalSchoolAdmins || 0).toLocaleString()} Admin</p>
        </div>
        <div className="card p-5">
          <p className="text-xs font-mono mb-3" style={{ color: 'var(--muted)' }}>STORAGE DÙNG</p>
          <p className="stat-num text-3xl">{stats?.storageUsed || '0'}<span className="text-lg font-sans font-normal ml-1" style={{ color: 'var(--muted)' }}></span></p>
          <div className="progress mt-3"><div className="progress-fill" style={{ width: `${stats?.storagePercent || 0}%`, background: 'var(--accent4)' }}></div></div>
          <p className="text-xs mt-1.5" style={{ color: 'var(--muted)' }}>{stats?.storagePercent || 0}% / {stats?.storageQuota || '0'} quota</p>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4 mb-5">
        <div className="card p-5 col-span-2">
          <div className="flex items-center justify-between mb-4">
            <p className="font-syne font-bold text-sm">Doanh thu 6 tháng gần nhất</p>
            <div className="flex gap-2">
              <div className="flex items-center gap-1.5 text-xs" style={{ color: 'var(--muted)' }}><span className="w-2.5 h-2.5 rounded-sm inline-block" style={{ background: 'var(--accent)' }}></span> MRR</div>
              <div className="flex items-center gap-1.5 text-xs" style={{ color: 'var(--muted)' }}><span className="w-2.5 h-2.5 rounded-sm inline-block" style={{ background: 'var(--accent3)' }}></span> Khách mới</div>
            </div>
          </div>
          <div style={{ height: '180px' }}><canvas id="revenueChart"></canvas></div>
        </div>
        <div className="card p-5">
          <p className="font-syne font-bold text-sm mb-4">Phân bổ Gói cước</p>
          <div style={{ height: '160px' }}><canvas id="planChart"></canvas></div>
          <div className="space-y-2 mt-4">
            {stats?.planDistribution?.map((pd, i) => {
              const colors = ['#7c6dfa','#6dfac2','#fac96d','#fa6d8e'];
              return (
                <div key={i} className="flex items-center justify-between text-xs">
                  <span className="flex items-center gap-1.5"><span className="w-2.5 h-2.5 rounded-full inline-block" style={{ background: colors[i % colors.length] }}></span>{pd.planName}</span>
                  <span className="font-mono">{pd.count} trường</span>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="card">
          <div className="flex items-center justify-between p-4 border-b" style={{ borderColor: 'var(--border)' }}>
            <p className="font-syne font-bold text-sm">Sắp hết hạn <span className="ml-1 badge badge-yellow">{stats?.expiringSubscriptions?.length || 0} trường</span></p>
            <span className="text-xs" style={{ color: 'var(--muted)' }}>trong 30 ngày tới</span>
          </div>
          <div className="divide-y" style={{ borderColor: 'var(--border)' }}>
            {stats?.expiringSubscriptions?.map((es, i) => (
              <div key={i} className="p-3 flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold">{es.schoolName}</p>
                  <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>Gói {es.planName} · {es.studentCount?.toLocaleString()} SV</p>
                </div>
                <div className="text-right">
                  <span className={`badge ${es.daysLeft <= 7 ? 'badge-red pulse-red' : 'badge-yellow'}`}>{es.daysLeft} ngày</span>
                  <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>₫{(Number(es.monthlyPrice) / 1000000).toFixed(1)}M/tháng</p>
                </div>
              </div>
            ))}
            {(!stats?.expiringSubscriptions || stats.expiringSubscriptions.length === 0) && (
              <div className="p-4 text-center text-xs" style={{ color: 'var(--muted)' }}>Không có trường nào sắp hết hạn</div>
            )}
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between p-4 border-b" style={{ borderColor: 'var(--border)' }}>
            <p className="font-syne font-bold text-sm">System Health</p>
            <span className="badge badge-green">● All systems operational</span>
          </div>
          <div className="p-4 space-y-4">
            <div><div className="flex justify-between text-xs mb-1.5"><span style={{ color: 'var(--muted)' }}>API Response Time</span><span className="font-mono">{stats?.apiResponseTime || 0}ms avg</span></div><div className="progress"><div className="progress-fill" style={{ width: `${Math.min((stats?.apiResponseTime || 0) / 10, 100)}%`, background: 'var(--accent3)' }}></div></div></div>
            <div><div className="flex justify-between text-xs mb-1.5"><span style={{ color: 'var(--muted)' }}>System Load (Memory)</span><span className="font-mono">{stats?.cpuLoad || 0}%</span></div><div className="progress"><div className="progress-fill" style={{ width: `${stats?.cpuLoad || 0}%`, background: 'var(--accent)' }}></div></div></div>
            <div><div className="flex justify-between text-xs mb-1.5"><span style={{ color: 'var(--muted)' }}>DB Connections</span><span className="font-mono">{stats?.dbConnectionsActive || 0} / {stats?.dbConnectionsMax || 1000}</span></div><div className="progress"><div className="progress-fill" style={{ width: `${Math.min(((stats?.dbConnectionsActive || 0) / Math.max(stats?.dbConnectionsMax || 1000, 1)) * 100, 100)}%`, background: 'var(--accent)' }}></div></div></div>
            <div><div className="flex justify-between text-xs mb-1.5"><span style={{ color: 'var(--muted)' }}>Cloudinary Storage</span><span className="font-mono">{stats?.storageUsed || '0'} / {stats?.storageQuota || '0'}</span></div><div className="progress"><div className="progress-fill" style={{ width: `${stats?.storagePercent || 0}%`, background: 'var(--accent4)' }}></div></div></div>
            <div><div className="flex justify-between text-xs mb-1.5"><span style={{ color: 'var(--muted)' }}>Uptime (30 ngày)</span><span className="font-mono text-green-400">{(stats?.uptime || 99.99).toFixed(2)}%</span></div><div className="progress"><div className="progress-fill" style={{ width: `${stats?.uptime || 99.99}%`, background: 'var(--accent3)' }}></div></div></div>
          </div>
          <div className="px-4 pb-4">
            <div className="card-sm p-3 flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full flex-shrink-0" style={{ background: 'var(--accent2)' }}></div>
              <p className="text-xs" style={{ color: 'var(--muted)' }}><span style={{ color: 'var(--accent2)' }}>{stats?.unresolvedErrors || 0} lỗi mới</span> chưa xử lý</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}