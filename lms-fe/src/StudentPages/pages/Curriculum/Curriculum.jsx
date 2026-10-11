import React from 'react';

export default function Curriculum() { 
  return (
    <div className="page active">
      <div className="page-title">Chương trình khung</div>
      <div className="card" style={{overflowX:'auto'}}>
        <table className="tbl" style={{minWidth:'800px'}}>
          <tbody>
            <tr><th>STT</th><th>Tên môn học/Học phần</th><th>Mã Học phần</th><th>Học phần</th><th>Số TC</th><th>Số tiết LT</th><th>Số tiết TH</th><th>Nhóm tự chọn</th><th>Số TC bắt buộc của nhóm</th><th>Đạt</th></tr>
            <tr className="section-row"><td colSpan="10" style={{backgroundColor: '#f1f5f9', fontWeight: 'bold', color: '#1e293b'}}>Học kỳ 1 (Năm 1) &nbsp;&nbsp;&nbsp; <span style={{color: '#3b82f6'}}>8 TC</span></td></tr>
            <tr><td>1</td><td>Lập trình Java</td><td>INT101</td><td></td><td>3</td><td>45</td><td>0</td><td>0</td><td></td><td><span style={{color: 'green', fontWeight: 'bold'}}>✔</span></td></tr>
            <tr className="red-row" style={{backgroundColor: '#fee2e2'}}><td>2</td><td>Cơ sở dữ liệu</td><td>INT103</td><td></td><td>3</td><td>30</td><td>30</td><td>0</td><td></td><td><span style={{color: 'red', fontWeight: 'bold'}}>✘</span></td></tr>
            <tr><td>3</td><td>Tiếng Anh giao tiếp 1</td><td>ENG101</td><td></td><td>2</td><td>30</td><td>0</td><td>0</td><td></td><td><span style={{color: 'green', fontWeight: 'bold'}}>✔</span></td></tr>
            
            <tr className="section-row"><td colSpan="10" style={{backgroundColor: '#f1f5f9', fontWeight: 'bold', color: '#1e293b'}}>Học kỳ 2 (Năm 1) &nbsp;&nbsp;&nbsp; <span style={{color: '#3b82f6'}}>16 TC</span></td></tr>
            <tr><td>4</td><td>Lập trình Web (Spring Boot)</td><td>INT102</td><td></td><td>3</td><td>45</td><td>0</td><td>0</td><td></td><td><span style={{color: 'green', fontWeight: 'bold'}}>✔</span></td></tr>
            <tr><td>5</td><td>Trí tuệ nhân tạo (AI)</td><td>INT104</td><td></td><td>4</td><td>45</td><td>30</td><td>1</td><td>4</td><td><span style={{color: 'green', fontWeight: 'bold'}}>✔</span></td></tr>
            <tr><td>6</td><td>Nguyên lý kế toán</td><td>ACC101</td><td></td><td>3</td><td>45</td><td>0</td><td>1</td><td>3</td><td><span style={{color: 'green', fontWeight: 'bold'}}>✔</span></td></tr>
            <tr><td>7</td><td>Mạch điện tử</td><td>ELE101</td><td></td><td>3</td><td>45</td><td>0</td><td>3</td><td>6</td><td><span style={{color: 'green', fontWeight: 'bold'}}>✔</span></td></tr>
            <tr><td>8</td><td>Quản trị học</td><td>BUS101</td><td></td><td>3</td><td>45</td><td>0</td><td>2</td><td>6</td><td><span style={{color: 'green', fontWeight: 'bold'}}>✔</span></td></tr>

            <tr className="section-row"><td colSpan="10" style={{backgroundColor: '#f1f5f9', fontWeight: 'bold', color: '#1e293b'}}>Học kỳ 1 (Năm 2) &nbsp;&nbsp;&nbsp; <span style={{color: '#3b82f6'}}>6 TC</span></td></tr>
            <tr><td>9</td><td>Cấu trúc dữ liệu</td><td>INT201</td><td></td><td>3</td><td>45</td><td>0</td><td>0</td><td></td><td></td></tr>
            <tr><td>10</td><td>Mạng máy tính</td><td>INT202</td><td></td><td>3</td><td>45</td><td>0</td><td>0</td><td></td><td></td></tr>

            <tr className="section-row"><td colSpan="10" style={{backgroundColor: '#f1f5f9', fontWeight: 'bold', color: '#1e293b'}}>Học kỳ 2 (Năm 2) &nbsp;&nbsp;&nbsp; <span style={{color: '#3b82f6'}}>10 TC</span></td></tr>
            <tr><td>11</td><td>Tiếng Anh chuyên ngành</td><td>ENG102</td><td></td><td>2</td><td>30</td><td>0</td><td>0</td><td></td><td></td></tr>
            <tr><td>12</td><td>Kế toán tài chính</td><td>ACC102</td><td></td><td>3</td><td>45</td><td>0</td><td>1</td><td>3</td><td></td></tr>
            <tr><td>13</td><td>Marketing căn bản</td><td>BUS102</td><td></td><td>3</td><td>45</td><td>0</td><td>2</td><td>6</td><td></td></tr>
            <tr><td>14</td><td>Vi xử lý</td><td>ELE102</td><td></td><td>3</td><td>45</td><td>0</td><td>3</td><td>6</td><td></td></tr>
          </tbody>
        </table>
      </div>
    </div>
  ); 
}