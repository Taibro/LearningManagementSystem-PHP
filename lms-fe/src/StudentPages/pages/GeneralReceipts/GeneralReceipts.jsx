import React from 'react';
import { RefreshCw, Edit } from 'lucide-react';

export default function GeneralReceipts() { 
  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{margin:0, borderLeft:'4px solid var(--blue)', paddingLeft:'10px'}}>Phiếu thu tổng hợp</div>
        <button className="btn-icon">⛶</button>
      </div>
      <div className="card" style={{overflowX:'auto'}}>
        <table className="tbl">
          <tbody>
            <tr><th>STT</th><th>Số phiếu</th><th>Mã hóa đơn</th><th>Ngày thu</th><th>Số tiền</th><th>Đơn vị thu</th><th>Loại HĐĐT</th><th>HĐDT</th><th>Chi tiết</th><th>Nhật ký</th></tr>
            <tr><td>1</td><td>193813</td><td></td><td>20/01/2026 09:35</td><td style={{textAlign:'right'}}>579,150</td><td>Ngân hàng ngoài trường 2</td><td>Cá nhân</td><td><button className="btn-icon btn-sm"><RefreshCw className="w-4 h-4 inline-block mr-2" /></button></td><td><button className="btn-icon btn-sm"><Edit className="w-4 h-4 inline-block mr-2" /></button></td><td><button className="btn-icon btn-sm">☰</button></td></tr>
            <tr><td>2</td><td>832565</td><td>C25TTP61588</td><td>30/12/2025 20:03</td><td style={{textAlign:'right'}}>17,205,000</td><td>NH Sacombank</td><td>Cá nhân</td><td><button className="btn-icon btn-sm">☁</button></td><td><button className="btn-icon btn-sm"><Edit className="w-4 h-4 inline-block mr-2" /></button></td><td><button className="btn-icon btn-sm">☰</button></td></tr>
          </tbody>
        </table>
      </div>
    </div>
  ); 
}