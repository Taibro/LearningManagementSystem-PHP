import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getProfile, getWeeklySchedule, getNotifications, getGrades } from '../../studentApi';
import { BarChart, DollarSign, LineChart, Calendar, ClipboardList, CheckCircle2, GraduationCap, Medal } from 'lucide-react';

export default function Dashboard() {
  const [profile, setProfile] = useState(null);
  const [schedule, setSchedule] = useState([]);
  const [notifications, setNotifications] = useState([]);
  const [grades, setGrades] = useState([]);

  useEffect(() => {
    getProfile().then(setProfile).catch(() => {});
    getWeeklySchedule().then(setSchedule).catch(() => {});
    getNotifications().then(setNotifications).catch(() => {});
    getGrades().then(setGrades).catch(() => {});
  }, []);

  const initials = profile?.fullName
    ? profile.fullName.split(' ').slice(-2).map(w => w[0]).join('').toUpperCase()
    : '??';

  const genderLabel = profile?.gender === 'MALE' ? 'Nam' : profile?.gender === 'FEMALE' ? 'Nữ' : '';
  const unreadCount = notifications.filter(n => !n.isRead).length;

  // Lớp HP đang học tuần này (unique theo classCode)
  const uniqueClasses = [...new Map(schedule.map(s => [s.classCode, s])).values()];

  // Thống kê điểm
  const currentSemGrades = grades.slice(0, Math.min(3, grades.length));

  return (
    <div className="page active">
      <div className="grid" style={{display:'grid', gridTemplateColumns:'1fr 320px', gap:'16px'}}>

        <div>
          {/* Thông tin sinh viên */}
          <div className="card mb-4" style={{marginBottom:'16px'}}>
            <div className="card-body">
              <h2 style={{fontSize:'16px', fontWeight:700, marginBottom:'12px', color:'var(--text)'}}>Thông tin sinh viên</h2>
              <div style={{display:'flex', gap:'20px', alignItems:'flex-start'}}>
                <div style={{textAlign:'center'}}>
                  <div style={{width:'80px', height:'80px', borderRadius:'50%', background:'linear-gradient(135deg,#1a6fb5,#60a5fa)', display:'flex', alignItems:'center', justifyContent:'center', color:'white', fontSize:'24px', fontWeight:700, margin:'0 auto 8px'}}>
                    {initials}
                  </div>
                  <Link to="/student-info" className="link">Xem chi tiết</Link>
                </div>
                <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:'4px 24px', flex:1}}>
                  <div style={{fontSize:'13px'}}><span style={{color:'var(--text-light)'}}>MSSV: </span><strong>{profile?.studentCode || '—'}</strong></div>
                  <div style={{fontSize:'13px'}}><span style={{color:'var(--text-light)'}}>Lớp học: </span><strong>{profile?.className || '—'}</strong></div>
                  <div style={{fontSize:'13px'}}><span style={{color:'var(--text-light)'}}>Họ tên: </span><strong>{profile?.fullName || '—'}</strong></div>
                  <div style={{fontSize:'13px'}}><span style={{color:'var(--text-light)'}}>Khoa: </span><strong>{profile?.departmentName || '—'}</strong></div>
                  <div style={{fontSize:'13px'}}><span style={{color:'var(--text-light)'}}>Giới tính: </span><strong>{genderLabel}</strong></div>
                  <div style={{fontSize:'13px'}}><span style={{color:'var(--text-light)'}}>Khóa học: </span><strong>{profile?.enrollmentYear || '—'}</strong></div>
                  <div style={{fontSize:'13px'}}><span style={{color:'var(--text-light)'}}>Email: </span><strong>{profile?.email || '—'}</strong></div>
                </div>
              </div>
            </div>
          </div>

          {/* Quick links */}
          <div className="card mb-4" style={{marginBottom:'16px'}}>
            <div className="card-body">
              <div className="quick-grid">
                <Link to="/notifications" className="quick-item">
                  <div className="qi-icon"><ClipboardList className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Nhắc nhở</div>
                </Link>
                <Link to="/grades" className="quick-item">
                  <div className="qi-icon"><BarChart className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Kết quả học tập</div>
                </Link>
                <Link to="/weekly-schedule" className="quick-item">
                  <div className="qi-icon"><Calendar className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Lịch theo tuần</div>
                </Link>
                <Link to="/progress-schedule" className="quick-item">
                  <div className="qi-icon"><LineChart className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Lịch theo tiến độ</div>
                </Link>
                <Link to="/attendance" className="quick-item">
                  <div className="qi-icon"><CheckCircle2 className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Điểm danh</div>
                </Link>
                <Link to="/conduct-score" className="quick-item">
                  <div className="qi-icon"><Medal className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Rèn luyện</div>
                </Link>
                <Link to="/tuition-fee" className="quick-item">
                  <div className="qi-icon"><DollarSign className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Tra cứu công nợ</div>
                </Link>
                <Link to="/scholarships" className="quick-item">
                  <div className="qi-icon"><GraduationCap className="w-4 h-4 inline-block mr-2" /></div><div className="qi-label">Học bổng</div>
                </Link>
              </div>
            </div>
          </div>

          {/* Lớp HP tuần này */}
          <div className="card">
            <div className="card-body">
              <h3 style={{fontSize:'14px', fontWeight:700, marginBottom:'10px'}}>Lớp học phần tuần này</h3>
              {uniqueClasses.length === 0 ? (
                <div style={{textAlign:'center', color:'var(--text-light)', fontSize:'12px', padding:'20px 0'}}>Không có lịch học trong tuần này</div>
              ) : (
                <table className="tbl" style={{fontSize:'12px'}}>
                  <tbody>
                    <tr><th>Môn học/học phần</th><th style={{width:'60px', textAlign:'center'}}>Số TC</th></tr>
                    {uniqueClasses.map((c, i) => (
                      <tr key={i}>
                        <td><Link to="/grades" className="link" style={{fontSize:'12px'}}>{c.classCode}</Link><br/>{c.courseName}</td>
                        <td style={{textAlign:'center'}}>{c.credits}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          </div>
        </div>

        {/* Cột phải */}
        <div>
          <div className="card" style={{marginBottom:'12px'}}>
            <div className="card-body">
              <div style={{fontSize:'14px', fontWeight:600, color:'var(--text-light)', marginBottom:'4px'}}>Nhắc nhở mới, chưa xem</div>
              <div style={{fontSize:'36px', fontWeight:800, color:'var(--text)'}}>{unreadCount}</div>
              <svg style={{float:'right', marginTop:'-40px'}} width="28" height="28" fill="none" stroke="#94a3b8" viewBox="0 0 24 24">
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
              </svg>
              <br/><Link to="/notifications" className="link">Xem chi tiết</Link>
            </div>
          </div>

          <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:'12px', marginBottom:'12px'}}>
            <div className="card" style={{border:'1px solid #bfdbfe'}}>
              <div className="card-body" style={{padding:'14px'}}>
                <div style={{fontSize:'12px', color:'var(--blue)', fontWeight:600}}>Lịch học trong tuần</div>
                <div style={{fontSize:'32px', fontWeight:800, color:'var(--blue)', margin:'6px 0'}}>{schedule.length}</div>
                <Link to="/weekly-schedule" className="link">Xem chi tiết</Link>
              </div>
            </div>
            <div className="card" style={{border:'1px solid #d1fae5'}}>
              <div className="card-body" style={{padding:'14px'}}>
                <div style={{fontSize:'12px', color:'var(--green)', fontWeight:600}}>Môn đang học</div>
                <div style={{fontSize:'32px', fontWeight:800, color:'var(--green)', margin:'6px 0'}}>{uniqueClasses.length}</div>
                <Link to="/progress-schedule" className="link" style={{color:'var(--green)'}}>Xem lịch</Link>
              </div>
            </div>
          </div>

          {/* Thông báo gần đây */}
          <div className="card">
            <div className="card-body">
              <h3 style={{fontSize:'14px', fontWeight:700, marginBottom:'10px'}}>Thông báo gần đây</h3>
              <div style={{display:'flex', flexDirection:'column', gap:'8px'}}>
                {notifications.slice(0, 4).map((n, i) => (
                  <div key={i} style={{padding:'8px', background:'#fff8f0', borderRadius:'6px', borderLeft:'3px solid var(--orange)'}}>
                    <div style={{fontSize:'12px', fontWeight:600, color:'var(--orange)'}}>{n.title}</div>
                    <div style={{fontSize:'11px', color:'var(--text-light)', marginTop:'2px'}}>{n.body}</div>
                  </div>
                ))}
                {notifications.length === 0 && (
                  <div style={{fontSize:'12px', color:'var(--text-light)', textAlign:'center'}}>Không có thông báo</div>
                )}
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  );
}