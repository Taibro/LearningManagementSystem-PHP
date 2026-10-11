import React, { useState, useEffect } from 'react';
import { useOutletContext } from 'react-router-dom';
import { Check, CheckCircle2, XCircle } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_BASE = `${API_BASE_URL}/saas-admin`;

const getAuthHeaders = () => ({
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${localStorage.getItem('saas_token')}`
});

export default function SystemLogs() {
  const { addToast } = useOutletContext();
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('all');
  const [totalCount, setTotalCount] = useState(0);
  const [unresolvedCount, setUnresolvedCount] = useState(0);

  useEffect(() => {
    fetchLogs();
  }, []);

  const fetchLogs = async (resolved) => {
    try {
      const url = resolved !== undefined ? `${API_BASE}/logs?resolved=${resolved}` : `${API_BASE}/logs`;
      const res = await fetch(url, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setLogs(data);
        if (resolved === undefined) {
          setTotalCount(data.length);
          setUnresolvedCount(data.filter(l => !l.isResolved).length);
        }
      }
    } catch (err) {
      console.error('Lỗi khi tải logs:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleTabClick = (tab) => {
    setActiveTab(tab);
    if (tab === 'all') fetchLogs();
    else if (tab === 'unresolved') fetchLogs(false);
    else if (tab === 'resolved') fetchLogs(true);
  };

  const markResolved = async (id) => {
    try {
      const res = await fetch(`${API_BASE}/logs/${id}/resolve`, {
        method: 'PATCH',
        headers: getAuthHeaders()
      });
      if (res.ok) {
        setLogs(prev => prev.map(l => l.id === id ? { ...l, isResolved: true } : l));
        setUnresolvedCount(prev => Math.max(0, prev - 1));
        addToast(<CheckCircle2 className="w-4 h-4 inline-block mr-2" />, 'Đã đánh dấu lỗi là Resolved', 'green');
      }
    } catch (err) {
      addToast(<XCircle className="w-4 h-4 inline-block mr-2" />, 'Lỗi khi cập nhật trạng thái', 'red');
    }
  };

  const formatTime = (dateStr) => {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    return d.toLocaleString('vi-VN');
  };

  if (loading) {
    return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '400px', color: 'var(--muted)' }}>Đang tải dữ liệu...</div>;
  }

  return (
    <div>
      <div className="flex items-center gap-3 mb-4">
        <div className="flex gap-2">
          <div className={`tab ${activeTab === 'all' ? 'active' : ''}`} onClick={() => handleTabClick('all')}>Tất cả ({totalCount})</div>
          <div className={`tab ${activeTab === 'unresolved' ? 'active' : ''}`} onClick={() => handleTabClick('unresolved')}>Chưa xử lý ({unresolvedCount})</div>
          <div className={`tab ${activeTab === 'resolved' ? 'active' : ''}`} onClick={() => handleTabClick('resolved')}>Đã fix</div>
        </div>
        <select className="inp ml-auto" style={{ maxWidth: '180px' }}><option>24h qua</option><option>7 ngày</option></select>
      </div>
      <div className="card overflow-hidden">
        <table>
          <thead>
            <tr><th style={{ width: '50px' }}>#</th><th>ENDPOINT</th><th>LỖI</th><th>TRƯỜNG</th><th>THỜI GIAN</th><th>TRẠNG THÁI</th><th></th></tr>
          </thead>
          <tbody>
            {logs.map(l => (
              <tr key={l.id}>
                <td className="font-mono text-xs" style={{ color: 'var(--muted)' }}>{l.id}</td>
                <td className="font-mono text-xs" style={{ color: 'var(--accent)' }}>{l.endpoint}</td>
                <td className="text-xs max-w-xs truncate" style={{ maxWidth: '200px', color: 'var(--accent2)' }}>{l.errorMessage}</td>
                <td className="text-xs">{l.schoolName}</td>
                <td className="font-mono text-xs" style={{ color: 'var(--muted)' }}>{formatTime(l.createdAt)}</td>
                <td>{l.isResolved ? <span className="badge badge-green"><Check className="w-4 h-4 inline-block mr-2" /> Đã fix</span> : <span className="badge badge-red pulse-red">● Chưa xử lý</span>}</td>
                <td>{!l.isResolved && <button className="btn btn-ghost btn-sm" onClick={() => markResolved(l.id)}>Mark fixed</button>}</td>
              </tr>
            ))}
            {logs.length === 0 && (
              <tr><td colSpan="7" className="text-center text-xs" style={{ color: 'var(--muted)', padding: '20px' }}>Không có log nào</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}