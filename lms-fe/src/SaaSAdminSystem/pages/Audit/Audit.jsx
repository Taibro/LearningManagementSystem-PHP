import React, { useState, useEffect } from 'react';
import { API_BASE_URL } from '../../../config/apiConfig';


const API_BASE = `${API_BASE_URL}/saas-admin`;

const getAuthHeaders = () => ({
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${localStorage.getItem('saas_token')}`
});

export default function Audit() {
  const [audits, setAudits] = useState([]);
  const [loading, setLoading] = useState(true);
  const [actionFilter, setActionFilter] = useState('');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchAuditLogs();
  }, []);

  const fetchAuditLogs = async (action) => {
    try {
      const url = action ? `${API_BASE}/audit?action=${action}` : `${API_BASE}/audit`;
      const res = await fetch(url, { headers: getAuthHeaders() });
      if (res.ok) {
        const data = await res.json();
        setAudits(data);
      }
    } catch (err) {
      console.error('Lỗi khi tải audit logs:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleActionFilter = (action) => {
    setActionFilter(action);
    if (action) {
      fetchAuditLogs(action);
    } else {
      fetchAuditLogs();
    }
  };

  const actionColor = { INSERT: 'badge-green', UPDATE: 'badge-blue', DELETE: 'badge-red', LOGIN: 'badge-purple' };

  const formatTime = (dateStr) => {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    return d.toLocaleString('vi-VN');
  };

  const filteredAudits = searchTerm
    ? audits.filter(a =>
        a.userEmail?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        a.tableName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        a.action?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        a.schoolName?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    : audits;

  if (loading) {
    return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '400px', color: 'var(--muted)' }}>Đang tải dữ liệu...</div>;
  }

  return (
    <div>
      <div className="flex items-center gap-3 mb-4">
        <input type="text" placeholder="Tìm user, bảng, action..." className="inp" style={{ maxWidth: '260px' }} value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
        <select className="inp" style={{ maxWidth: '150px' }} value={actionFilter} onChange={e => handleActionFilter(e.target.value)}>
          <option value="">Tất cả action</option>
          <option value="INSERT">INSERT</option>
          <option value="UPDATE">UPDATE</option>
          <option value="DELETE">DELETE</option>
          <option value="LOGIN">LOGIN</option>
        </select>
      </div>
      <div className="card overflow-hidden">
        <table>
          <thead>
            <tr><th>THỜI GIAN</th><th>NGƯỜI DÙNG</th><th>TRƯỜNG</th><th>ACTION</th><th>BẢNG</th><th>RECORD ID</th><th>IP</th></tr>
          </thead>
          <tbody>
            {filteredAudits.map((a, index) => (
              <tr key={a.id || index}>
                <td className="font-mono text-xs" style={{ color: 'var(--muted)' }}>{formatTime(a.createdAt)}</td>
                <td className="text-xs">{a.userEmail}</td>
                <td className="text-xs">{a.schoolName}</td>
                <td><span className={`badge ${actionColor[a.action] || 'badge-blue'}`}>{a.action}</span></td>
                <td className="font-mono text-xs">{a.tableName}</td>
                <td className="font-mono text-xs" style={{ color: 'var(--muted)' }}>#{a.recordId}</td>
                <td className="font-mono text-xs" style={{ color: 'var(--muted)' }}>{a.ipAddress}</td>
              </tr>
            ))}
            {filteredAudits.length === 0 && (
              <tr><td colSpan="7" className="text-center text-xs" style={{ color: 'var(--muted)', padding: '20px' }}>Không có audit log nào</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}