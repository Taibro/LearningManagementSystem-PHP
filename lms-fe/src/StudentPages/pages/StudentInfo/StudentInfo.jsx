import React, { useEffect, useState } from 'react';
import { getProfile } from '../../studentApi';

export default function StudentInfo() {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    getProfile()
      .then(data => { setProfile(data); setLoading(false); })
      .catch(() => { setError('Không thể tải thông tin sinh viên'); setLoading(false); });
  }, []);

  if (loading) return <div className="page active"><div className="page-title">Đang tải...</div></div>;
  if (error)   return <div className="page active"><div className="page-title" style={{color:'var(--red)'}}>{error}</div></div>;
  if (!profile) return null;

  const initials = profile.fullName
    ? profile.fullName.split(' ').slice(-2).map(w => w[0]).join('').toUpperCase()
    : '??';

  const formatDate = (d) => d ? new Date(d).toLocaleDateString('vi-VN') : '';
  const genderLabel = profile.gender === 'MALE' ? 'Nam' : profile.gender === 'FEMALE' ? 'Nữ' : '';

  return (
    <div className="page active">
      <div className="page-title">Thông tin sinh viên</div>
      <div className="card"><div className="card-body">
        <div style={{display:'flex',gap:'24px'}}>
          <div style={{textAlign:'center',flexShrink:0}}>
            <div style={{width:'100px',height:'100px',borderRadius:'50%',background:'linear-gradient(135deg,#1a6fb5,#60a5fa)',display:'flex',alignItems:'center',justifyContent:'center',color:'white',fontSize:'32px',fontWeight:700,margin:'0 auto 8px'}}>
              {initials}
            </div>
            <div style={{fontSize:'12px',color:'var(--text-light)'}}>MSSV: {profile.studentCode}</div>
            <div style={{fontSize:'13px',fontWeight:600}}>{profile.fullName}</div>
            <div style={{fontSize:'12px',color:'var(--text-light)'}}>Giới tính: {genderLabel}</div>
          </div>
          <div style={{flex:1}}>
            <h3 style={{fontSize:'15px',fontWeight:700,color:'var(--blue)',marginBottom:'12px'}}>Thông tin học vấn</h3>
            <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:'6px 0'}}>
              <div className="info-row"><span className="lbl">Lớp học:</span><span className="val">{profile.className}</span></div>
              <div className="info-row"><span className="lbl">Ngành:</span><span className="val">{profile.major || profile.departmentName}</span></div>
              <div className="info-row"><span className="lbl">Khóa học:</span><span className="val">{profile.enrollmentYear}</span></div>
              <div className="info-row"><span className="lbl">Khoa:</span><span className="val">{profile.departmentName}</span></div>
            </div>
          </div>
        </div>
        <hr style={{margin:'20px 0',borderColor:'#f0f2f5'}}/>
        <h3 style={{fontSize:'15px',fontWeight:700,color:'var(--blue)',marginBottom:'12px'}}>Thông tin cá nhân</h3>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr 1fr',gap:'8px 0'}}>
          <div className="info-row"><span className="lbl">Ngày sinh:</span><span className="val">{formatDate(profile.dateOfBirth)}</span></div>
          <div className="info-row"><span className="lbl">Giới tính:</span><span className="val">{genderLabel}</span></div>
          <div className="info-row"><span className="lbl">Email:</span><span className="val">{profile.email}</span></div>
          <div className="info-row"><span className="lbl">Điện thoại:</span><span className="val">{profile.phone || '—'}</span></div>
          <div className="info-row"><span className="lbl">Số CCCD:</span><span className="val">{profile.citizenIdNumber}</span></div>
          <div className="info-row" style={{gridColumn:'1/-1'}}><span className="lbl">Địa chỉ:</span><span className="val">{profile.address || '—'}</span></div>
        </div>
      </div></div>
    </div>
  );
}