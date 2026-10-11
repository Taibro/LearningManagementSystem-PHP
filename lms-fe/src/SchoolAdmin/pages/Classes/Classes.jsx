import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { GraduationCap, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Classes() {
  const [classes, setClasses] = useState([]);
  const [courses, setCourses] = useState([]);
  const [semesters, setSemesters] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [toast, setToast] = useState(null);

  const [cModal, setCModal] = useState(false);
  const [currentClass, setCurrentClass] = useState({
    id: null, code: '', courseId: '', semesterId: '', maxStudents: 40, status: 'OPEN', notes: '', startDate: '', endDate: ''
  });
  const [newSchedules, setNewSchedules] = useState([]);

  useEffect(() => {
    fetchClasses();
    fetchCourses();
    fetchSemesters();
    fetchRooms();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchClasses = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/classes`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setClasses(data);
      }
    } catch (error) {
      showToast('Lỗi tải danh sách lớp học!', 'error');
    }
  };

  const fetchCourses = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/courses/get-all`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) setCourses(await res.json());
    } catch (error) { console.error('Lỗi tải môn học'); }
  };

  const fetchSemesters = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/semesters/get-all`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) setSemesters(await res.json());
    } catch (error) { console.error('Lỗi tải học kỳ'); }
  };

  const fetchRooms = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/rooms/get-all`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) setRooms(await res.json());
    } catch (error) { console.error('Lỗi tải phòng học'); }
  };

  const handleSaveClass = async () => {
    const method = currentClass.id ? 'PUT' : 'POST';
    const url = currentClass.id 
      ? `${API_BASE_URL}/school-admin/classes/${currentClass.id}`
      : `${API_BASE_URL}/school-admin/classes`;

    const payload = {
      code: currentClass.code,
      courseId: parseInt(currentClass.courseId),
      semesterId: parseInt(currentClass.semesterId),
      maxStudents: parseInt(currentClass.maxStudents),
      status: currentClass.status,
      notes: currentClass.notes,
      startDate: currentClass.startDate || null,
      endDate: currentClass.endDate || null
    };

    try {
      const res = await fetch(url, {
        method,
        
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        const savedClass = await res.json();
        // Lưu lịch học nếu là tạo mới và có lịch học
        if (!currentClass.id && newSchedules.length > 0) {
          for (const sched of newSchedules) {
            await fetch(`${API_BASE_URL}/school-admin/schedules`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
              },
              body: JSON.stringify({
                classId: savedClass.id,
                roomId: parseInt(sched.roomId),
                dayOfWeek: parseInt(sched.dayOfWeek),
                type: 'REGULAR',
                startPeriod: parseInt(sched.startPeriod),
                endPeriod: parseInt(sched.endPeriod),
                startDate: currentClass.startDate || null,
                endDate: currentClass.endDate || null
              })
            });
          }
        }

        showToast(currentClass.id ? 'Cập nhật lớp thành công!' : 'Tạo lớp thành công!');
        setCModal(false);
        fetchClasses();
      } else {
        showToast('Lỗi khi lưu lớp học!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const generateClassCode = (cId, sId) => {
    if (!cId || !sId) return '';
    const course = courses.find(c => c.id === parseInt(cId));
    const semester = semesters.find(s => s.id === parseInt(sId));
    if (!course || !semester) return '';
    
    // Find sequence
    const existingCount = classes.filter(c => c.courseId === parseInt(cId) && c.semesterId === parseInt(sId)).length;
    const seq = String(existingCount + 1).padStart(2, '0');
    
    // Extract a short code for semester if name is like "Học kỳ 2"
    let semCode = semester.name.replace(/\s/g, '').toUpperCase();
    if (semCode.includes('HỌCKỲ')) semCode = semCode.replace('HỌCKỲ', 'HK');
    
    return `${course.code}-${semCode}-${seq}`;
  };

  const handleCourseSemesterChange = (field, value) => {
    const updated = { ...currentClass, [field]: value };
    if (!currentClass.id) { // Only auto-generate if creating new
      updated.code = generateClassCode(updated.courseId, updated.semesterId);
    }
    setCurrentClass(updated);
  };

  const openModal = (c = null) => {
    setCurrentClass(c ? { ...c, startDate: c.startDate || '', endDate: c.endDate || '' } : {
      id: null, code: '', courseId: '', semesterId: '', maxStudents: 40, status: 'OPEN', notes: '', startDate: '', endDate: ''
    });
    setNewSchedules([]);
    setCModal(true);
  };

  const renderStatusBadge = (status) => {
    if (status === 'OPEN') return <span className="badge b-green">MỞ ĐĂNG KÝ</span>;
    if (status === 'IN_PROGRESS') return <span className="badge b-blue">ĐANG HỌC</span>;
    if (status === 'COMPLETED') return <span className="badge b-gray">ĐÃ KẾT THÚC</span>;
    if (status === 'CLOSED') return <span className="badge b-amber">ĐÃ ĐÓNG</span>;
    if (status === 'CANCELLED') return <span className="badge b-red">HỦY LỚP</span>;
    return <span className="badge b-gray">{status}</span>;
  };

  return (
    <div className="page" style={{ position: 'relative' }}>

      {toast && (
        <div style={{
          position: 'fixed', top: '20px', right: '20px', zIndex: 9999,
          padding: '12px 20px', borderRadius: '4px', color: '#fff',
          boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
          background: toast.type === 'success' ? '#4caf50' : '#f44336'
        }}>
          {toast.msg}
        </div>
      )}

      <div className="ph">
        <div>
          <div className="ph-title">Quản lý Lớp học</div>
          <div className="ph-sub">Tạo lớp · Phân công giảng viên · Quản lý sĩ số</div>
        </div>
        <button className="btn btn-blue" onClick={() => openModal()}>+ Tạo lớp học</button>
      </div>
      
      <div className="card">
        {classes.length === 0 ? (
          <div className="card-body" style={{textAlign:'center', padding:'50px', color:'var(--muted)'}}>
            <div style={{fontSize:'48px', marginBottom:'12px'}}><GraduationCap className="w-4 h-4 inline-block mr-2" /></div>
            <div style={{fontSize:'16px', fontWeight:700, marginBottom:'8px'}}>Chưa có lớp học nào</div>
            <button className="btn btn-blue" style={{marginTop:'16px'}} onClick={() => openModal()}>+ Tạo lớp đầu tiên</button>
          </div>
        ) : (
          <table className="tbl">
            <thead>
              <tr>
                <th>Mã lớp</th>
                <th>Môn học (ID)</th>
                <th>Học kỳ (ID)</th>
                <th>Giảng viên</th>
                <th>Sĩ số</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {classes.map(c => (
                <tr key={c.id}>
                  <td style={{fontFamily:'monospace', fontSize:'12px', color:'var(--blue)', fontWeight:700}}>{c.code}</td>
                  <td><div style={{fontWeight:600}}>{c.courseName || `Course ID: ${c.courseId}`}</div></td>
                  <td>{c.semesterName || `Semester ID: ${c.semesterId}`}</td>
                  <td>
                    <div style={{display:'flex', flexDirection:'column', gap:'3px'}}>
                      {c.teachers && c.teachers.length > 0 ? c.teachers.map((t, idx) => (
                        <span key={idx} className={t.includes('main') ? "badge b-blue" : "badge b-cyan"}>{t}</span>
                      )) : <span className="badge b-gray">Chưa phân công</span>}
                    </div>
                  </td>
                  <td>
                    <span style={{fontWeight:700, color: c.enrolledStudents >= c.maxStudents ? 'var(--red)' : 'var(--blue)'}}>
                      {c.enrolledStudents || 0}
                    </span>
                    <span style={{color:'var(--muted)'}}>/{c.maxStudents}</span>
                  </td>
                  <td>{renderStatusBadge(c.status)}</td>
                  <td>
                    <div style={{display:'flex', gap:'4px'}}>
                      <button className="btn btn-ghost btn-xs" onClick={() => openModal(c)}>Sửa</button>
                      <Link to="/attendance" className="btn btn-ghost btn-xs" style={{textDecoration:'none'}}>Điểm danh</Link>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {cModal && (
        <div className="ov open">
          <div className="modal" style={{maxHeight:'90vh', overflowY:'auto'}}>
            <div className="modal-hd">
              <span className="modal-title">{currentClass.id ? <><GraduationCap className="w-4 h-4 inline-block mr-2" /> Sửa Lớp học</> : <><GraduationCap className="w-4 h-4 inline-block mr-2" /> Tạo Lớp học</>}</span>
              <button className="close-btn" onClick={() => setCModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="fg">
                <label className="fl">Mã lớp</label>
                <input className="fc" value={currentClass.code} onChange={e => setCurrentClass({...currentClass, code: e.target.value})} placeholder="Tự động tạo..." readOnly={!currentClass.id ? true : false} style={!currentClass.id ? {backgroundColor: '#f1f5f9'} : {}} />
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Môn học</label>
                  <select className="fc" value={currentClass.courseId} onChange={e => handleCourseSemesterChange('courseId', e.target.value)}>
                    <option value="">-- Chọn Môn học --</option>
                    {courses.map(c => <option key={c.id} value={c.id}>{c.name} ({c.code})</option>)}
                  </select>
                </div>
                <div className="fg">
                  <label className="fl">Học kỳ</label>
                  <select className="fc" value={currentClass.semesterId} onChange={e => handleCourseSemesterChange('semesterId', e.target.value)}>
                    <option value="">-- Chọn Học kỳ --</option>
                    {semesters.map(s => <option key={s.id} value={s.id}>{s.name} ({s.academicYearName})</option>)}
                  </select>
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Ngày bắt đầu</label>
                  <input type="date" className="fc" value={currentClass.startDate} onChange={e => setCurrentClass({...currentClass, startDate: e.target.value})} />
                </div>
                <div className="fg">
                  <label className="fl">Ngày kết thúc</label>
                  <input type="date" className="fc" value={currentClass.endDate} onChange={e => setCurrentClass({...currentClass, endDate: e.target.value})} />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Sĩ số tối đa</label>
                  <input type="number" className="fc" value={currentClass.maxStudents} onChange={e => setCurrentClass({...currentClass, maxStudents: e.target.value})} min="1" />
                </div>
                <div className="fg">
                  <label className="fl">Trạng thái</label>
                  <select className="fc" value={currentClass.status} onChange={e => setCurrentClass({...currentClass, status: e.target.value})}>
                    <option value="OPEN">Mở đăng ký</option>
                    <option value="IN_PROGRESS">Đang học</option>
                    <option value="COMPLETED">Đã kết thúc</option>
                    <option value="CLOSED">Đã đóng</option>
                    <option value="CANCELLED">Hủy lớp</option>
                  </select>
                </div>
              </div>
              
              {!currentClass.id && (
                <div className="fg" style={{border: '1px solid var(--border)', padding: '12px', borderRadius: '8px'}}>
                  <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom: '8px'}}>
                    <label className="fl" style={{margin:0}}>Các buổi học dự kiến</label>
                    <button type="button" className="btn btn-outline btn-xs" onClick={() => setNewSchedules([...newSchedules, {dayOfWeek: 2, startPeriod: 1, endPeriod: 3, roomId: rooms[0]?.id || ''}])}>+ Thêm buổi</button>
                  </div>
                  {newSchedules.length === 0 ? <div style={{fontSize:'12px', color:'var(--muted)'}}>Chưa có lịch học nào.</div> : (
                    <div style={{display:'flex', flexDirection:'column', gap:'8px'}}>
                      {newSchedules.map((s, idx) => (
                        <div key={idx} style={{display:'flex', gap:'8px', alignItems:'center'}}>
                          <select className="fc" style={{padding:'4px'}} value={s.dayOfWeek} onChange={e => { const updated = [...newSchedules]; updated[idx].dayOfWeek = e.target.value; setNewSchedules(updated); }}>
                            {[2,3,4,5,6,7,1].map(d => <option key={d} value={d}>{d === 1 ? 'CN' : `Thứ ${d}`}</option>)}
                          </select>
                          <span style={{fontSize:'12px'}}>Tiết</span>
                          <input type="number" className="fc" style={{width:'60px', padding:'4px'}} value={s.startPeriod} min="1" max="15" onChange={e => { const updated = [...newSchedules]; updated[idx].startPeriod = e.target.value; setNewSchedules(updated); }} />
                          <span>-</span>
                          <input type="number" className="fc" style={{width:'60px', padding:'4px'}} value={s.endPeriod} min="1" max="15" onChange={e => { const updated = [...newSchedules]; updated[idx].endPeriod = e.target.value; setNewSchedules(updated); }} />
                          <select className="fc" style={{padding:'4px'}} value={s.roomId} onChange={e => { const updated = [...newSchedules]; updated[idx].roomId = e.target.value; setNewSchedules(updated); }}>
                            <option value="">- Chọn Phòng -</option>
                            {rooms.map(r => <option key={r.id} value={r.id}>{r.roomNumber} ({r.building})</option>)}
                          </select>
                          <button type="button" style={{color:'red', background:'none', border:'none', cursor:'pointer'}} onClick={() => { const updated = newSchedules.filter((_, i) => i !== idx); setNewSchedules(updated); }}>X</button>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              <div className="fg">
                <label className="fl">Ghi chú</label>
                <textarea className="fc" rows="2" value={currentClass.notes} onChange={e => setCurrentClass({...currentClass, notes: e.target.value})} placeholder="Ghi chú về lớp học..."></textarea>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setCModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveClass}><Save className="w-4 h-4 inline-block mr-2" /> Lưu lớp học</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
