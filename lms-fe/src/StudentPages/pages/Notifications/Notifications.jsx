import React, { useEffect, useState } from 'react';
import { getNotifications } from '../../studentApi';

export default function Notifications() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getNotifications()
      .then(data => { setItems(data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const typeColor = (type) => {
    if (type === 'SCHEDULE_CHANGE') return 'var(--orange)';
    if (type === 'GRADE') return 'var(--green)';
    if (type === 'REMINDER') return 'var(--red)';
    return 'var(--blue)';
  };

  const formatDate = (dt) => dt ? new Date(dt).toLocaleDateString('vi-VN') : '';

  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{margin:0}}>Ghi chú nhắc nhở</div>
        <div style={{fontSize:'13px',color:'var(--text-light)'}}>
          {items.filter(n => !n.isRead).length} chưa đọc
        </div>
      </div>
      <div className="card"><div className="card-body" style={{padding:0}}>
        {loading && <div style={{padding:'20px',textAlign:'center',color:'var(--text-light)'}}>Đang tải...</div>}
        {!loading && items.length === 0 && (
          <div style={{padding:'30px',textAlign:'center',color:'var(--text-light)'}}>Không có thông báo</div>
        )}
        {items.map((n, i) => (
          <div key={n.id || i} style={{
            padding:'14px 20px',
            borderBottom:'1px solid #f0f2f5',
            display:'flex',
            justifyContent:'space-between',
            alignItems:'flex-start',
            background: n.isRead ? 'transparent' : '#fff8f0'
          }}>
            <div>
              <div style={{fontWeight:600,color:typeColor(n.type),fontSize:'13px'}}>
                {n.title}
                {!n.isRead && <span style={{marginLeft:'8px',background:'var(--red)',color:'white',borderRadius:'99px',padding:'1px 6px',fontSize:'10px'}}>MỚI</span>}
              </div>
              {n.body && <div style={{fontSize:'12px',color:'var(--text-light)',marginTop:'4px'}}>{n.body}</div>}
              <div style={{fontSize:'11px',color:'var(--text-light)',marginTop:'4px'}}>{formatDate(n.createdAt)}</div>
            </div>
          </div>
        ))}
      </div></div>
    </div>
  );
}