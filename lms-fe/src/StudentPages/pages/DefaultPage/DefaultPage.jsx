import React from 'react';

export default function DefaultPage({ title }) {
  return (
    <div className="page active">
      <div className="page-title">{title}</div>
      <div className="card">
        <div className="card-body" style={{textAlign:'center',color:'var(--text-light)',padding:'40px'}}>
          Đang cập nhật dữ liệu...
        </div>
      </div>
    </div>
  );
}