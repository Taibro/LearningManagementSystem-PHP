import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { DollarSign, ClipboardList, GraduationCap, School, Info, User, File } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Dashboard() {
  const [stats, setStats] = useState({
    totalStudents: 0,
    totalTeachers: 0,
    totalClasses: 0,
    todayAbsences: 0,
    totalTuitionDebt: 0,
    schoolName: ''
  });

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${API_BASE_URL}/school-admin/dashboard/stats`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (res.ok) {
        const data = await res.json();
        setStats(data);
      } else {
        console.warn("Lỗi xác thực hoặc không có quyền truy cập");
      }
    } catch (err) {
      console.error("Lỗi tải Dashboard:", err);
    }
  };

  return (
    <div className="page">
      <div className="ph mb6">
        <div>
          <div className="ph-title">Tổng quan · {stats.schoolName || 'Đang tải...'}</div>
          <div className="ph-sub">Cập nhật lúc: {new Date().toLocaleTimeString('vi-VN')} · Thống kê thời gian thực</div>
        </div>
        <button className="btn btn-blue" onClick={() => alert('Đã xuất báo cáo tổng hợp PDF')}><File className="w-4 h-4 inline-block mr-2" /> Xuất báo cáo</button>
      </div>

      <div className="grid5 mb4">
        <Link to="/students" className="stat" style={{textDecoration:'none'}}>
          <div className="stat-top" style={{background:'linear-gradient(90deg,#1976d2,#42a5f5)'}}></div>
          <div className="stat-icon"><User className="w-4 h-4 inline-block mr-2" />‍<GraduationCap className="w-4 h-4 inline-block mr-2" /></div>
          <div className="stat-label">Sinh viên</div>
          <div className="stat-num">{stats.totalStudents}</div>
          <div className="stat-foot up">↑ Cập nhật liên tục</div>
        </Link>
        <Link to="/teachers" className="stat" style={{textDecoration:'none'}}>
          <div className="stat-top" style={{background:'linear-gradient(90deg,#00897b,#4db6ac)'}}></div>
          <div className="stat-icon"><User className="w-4 h-4 inline-block mr-2" />‍<School className="w-4 h-4 inline-block mr-2" /></div>
          <div className="stat-label">Giảng viên</div>
          <div className="stat-num">{stats.totalTeachers}</div>
          <div className="stat-foot">100% hoạt động</div>
        </Link>
        <Link to="/classes" className="stat" style={{textDecoration:'none'}}>
          <div className="stat-top" style={{background:'linear-gradient(90deg,#e65100,#ffb74d)'}}></div>
          <div className="stat-icon"><GraduationCap className="w-4 h-4 inline-block mr-2" /></div>
          <div className="stat-label">Lớp học</div>
          <div className="stat-num">{stats.totalClasses}</div>
          <div className="stat-foot">Đang hoạt động</div>
        </Link>
        <Link to="/attendance" className="stat" style={{textDecoration:'none'}}>
          <div className="stat-top" style={{background:'linear-gradient(90deg,#c62828,#ef5350)'}}></div>
          <div className="stat-icon"><ClipboardList className="w-4 h-4 inline-block mr-2" /></div>
          <div className="stat-label">Vắng mặt hôm nay</div>
          <div className="stat-num">{stats.todayAbsences}</div>
          <div className="stat-foot down">Ghi nhận trong ngày</div>
        </Link>
        <Link to="/tuition" className="stat" style={{textDecoration:'none'}}>
          <div className="stat-top" style={{background:'linear-gradient(90deg,#6a1b9a,#ce93d8)'}}></div>
          <div className="stat-icon"><DollarSign className="w-4 h-4 inline-block mr-2" /></div>
          <div className="stat-label">Công nợ học phí</div>
          <div className="stat-num">{stats.totalTuitionDebt ? stats.totalTuitionDebt.toLocaleString('vi-VN') : 0}đ</div>
          <div className="stat-foot up">Thống kê toàn khóa</div>
        </Link>
      </div>

      <div style={{display:'grid', gridTemplateColumns:'1fr 1fr 300px', gap:'16px', marginBottom:'16px'}}>
        <div className="card">
          <div className="card-hd">
            <div>
              <div className="card-title">Lịch học hôm nay</div>
              <div className="card-sub">{new Date().toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</div>
            </div>
            <Link to="/schedule" className="btn btn-ghost btn-sm" style={{textDecoration:'none'}}>Xem tuần →</Link>
          </div>
          <div className="card-body" style={{textAlign:'center', padding:'30px', color:'var(--muted)'}}>
            <Info className="w-4 h-4 inline-block mr-2" /> Module Lịch học sẽ được tự động đồng bộ dựa trên dữ liệu lớp học
          </div>
        </div>

        <div className="card">
          <div className="card-hd">
            <div className="card-title">Tình trạng lớp học</div>
            <Link to="/classes" className="btn btn-ghost btn-sm" style={{textDecoration:'none'}}>Chi tiết →</Link>
          </div>
          <div className="card-body">
            <div style={{display:'flex', flexDirection:'column', gap:'14px'}}>
              <div style={{fontSize:'13px', color:'var(--muted)', textAlign:'center', marginTop:'20px'}}>
                Biểu đồ sẽ tự động cập nhật khi có lớp học được tạo và sinh viên ghi danh.
              </div>
            </div>
            <hr className="divider" style={{marginTop:'30px'}}/>
            <div style={{display:'flex', gap:'16px', fontSize:'12px'}}>
              <div style={{textAlign:'center'}}><div style={{fontSize:'20px', fontWeight:800, color:'var(--blue)'}}>{stats.totalClasses}</div><div style={{color:'var(--muted)'}}>Tổng lớp</div></div>
              <div style={{textAlign:'center'}}><div style={{fontSize:'20px', fontWeight:800, color:'var(--green)'}}>{stats.totalStudents}</div><div style={{color:'var(--muted)'}}>Tổng SV</div></div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="card-hd"><div className="card-title">Hoạt động gần đây</div></div>
          <div style={{padding:'0 16px', maxHeight:'340px', overflowY:'auto'}}>
            <div className="feed-item">
              <div className="feed-dot" style={{background:'#06b6d4'}}></div>
              <div><div style={{fontSize:'12px'}}>Hệ thống <strong>Learning Management</strong> online</div><div style={{fontSize:'10px', color:'var(--muted)'}}>Hôm nay</div></div>
            </div>
            <div className="feed-item">
              <div className="feed-dot" style={{background:'#22c55e'}}></div>
              <div><div style={{fontSize:'12px'}}>Kết nối <strong>Database</strong> thành công</div><div style={{fontSize:'10px', color:'var(--muted)'}}>Hôm nay</div></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
