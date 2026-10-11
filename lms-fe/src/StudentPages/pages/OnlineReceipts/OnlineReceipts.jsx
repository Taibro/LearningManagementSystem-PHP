import React from 'react';
import { X } from 'lucide-react';

export default function OnlineReceipts() { 
  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{margin:0}}>Phiếu thu</div>
        <button className="btn btn-blue" onClick={() => alert('Đang mở trang thanh toán...')}>Tiếp tục thanh toán ›</button>
      </div>
      <div className="card" style={{overflowX:'auto'}}>
        <table className="tbl">
          <tbody>
            <tr><th>STT</th><th>Mã đơn</th><th>Nội dung thu</th><th>Số tiền (VNĐ)</th><th>Ngày thanh toán</th><th>Đã thanh toán</th><th>Đã cập nhật công nợ</th><th>Trạng thái giao dịch</th></tr>
            <tr><td>1</td><td style={{fontFamily:'monospace',fontSize:'11px'}}>HUITA71BCCCAC8324C</td><td>Thu học phí</td><td style={{textAlign:'right'}}>17,205,000</td><td>30/12/2025 19:59:45</td><td style={{textAlign:'center'}}><span style={{color:'var(--green)',fontSize:'18px'}}>✔</span></td><td style={{textAlign:'center'}}><span style={{color:'var(--green)',fontSize:'18px'}}>✔</span></td><td style={{color:'var(--green)',fontWeight:600}}>Thành công</td></tr>
            <tr><td>2</td><td style={{fontFamily:'monospace',fontSize:'11px'}}>HUIT2409C62D8AF54D</td><td>Thu học phí</td><td style={{textAlign:'right'}}>2,785,000</td><td>19/07/2025 10:35:27</td><td style={{textAlign:'center'}}><span style={{color:'var(--red)',fontSize:'18px'}}><X className="w-4 h-4 inline-block mr-2" /></span></td><td style={{textAlign:'center'}}><span style={{color:'var(--red)',fontSize:'18px'}}><X className="w-4 h-4 inline-block mr-2" /></span></td><td style={{color:'var(--red)'}}>Giao dịch đã hủy</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  ); 
}