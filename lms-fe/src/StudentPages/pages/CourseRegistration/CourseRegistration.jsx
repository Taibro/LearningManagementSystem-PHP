import React, { useEffect, useState, useCallback, useMemo } from 'react';
import { getCourseRegList, registerCourse, getSemesters, getEnrolledClasses, cancelCourseReg, getProfile } from '../../studentApi';

const DAY_NAMES = ['', 'CN', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];

const TYPE_OPTIONS = [
  { value: 'NORMAL',  label: 'HỌC MỚI' },
  { value: 'RETAKE',  label: 'HỌC LẠI' },
  { value: 'IMPROVE', label: 'HỌC CẢI THIỆN' },
];

export default function CourseRegistration() {
  const [profile, setProfile] = useState(null);
  const [activeTab, setActiveTab] = useState('REGISTRATION'); // 'INFO' or 'REGISTRATION'

  const [semesters, setSemesters] = useState([]);
  const [semId, setSemId] = useState('');
  const [type, setType] = useState('NORMAL');

  const [flatClasses, setFlatClasses] = useState([]);
  const [enrolled, setEnrolled] = useState([]);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState(null);

  const [selectedCourseId, setSelectedCourseId] = useState(null);
  const [selectedClassId, setSelectedClassId] = useState(null);
  const [hideConflict, setHideConflict] = useState(false);

  const [activeMenuId, setActiveMenuId] = useState(null);

  const [teacherModal, setTeacherModal] = useState(null);
  const [conflictModal, setConflictModal] = useState(null);
  const [cancelModal, setCancelModal] = useState(null);
  const [viewModal, setViewModal] = useState(null);

  // 1. Fetch Profile & Semesters
  useEffect(() => {
    getProfile().then(res => setProfile(res)).catch(() => {});
    getSemesters().then(data => {
      setSemesters(data);
      if (data.length > 0) setSemId(String(data[0].id));
    }).catch(() => {});
  }, []);

  // 2. Fetch Classes and Enrolled whenever semId or type changes
  const loadData = useCallback(() => {
    if (semId === null || semId === undefined) return;
    setLoading(true);
    
    Promise.all([
      getCourseRegList(semId === '0' ? 0 : semId, type),
      getEnrolledClasses(semId === '0' ? 0 : semId)
    ]).then(([classesRes, enrolledRes]) => {
      setFlatClasses(classesRes || []);
      setEnrolled(enrolledRes || []);
      setLoading(false);
    }).catch(() => {
      setLoading(false);
    });
  }, [semId, type]);

  useEffect(() => {
    loadData();
    setSelectedCourseId(null);
    setSelectedClassId(null);
  }, [loadData]);

  const showToast = (t, msg) => {
    setToast({ type: t, msg });
    setTimeout(() => setToast(null), 3500);
  };

  // Group classes into courses for Table 1
  const courses = useMemo(() => {
    const map = new Map();
    flatClasses.forEach(c => {
      if (!map.has(c.courseId)) {
        map.set(c.courseId, {
          courseId: c.courseId,
          courseCode: c.courseCode,
          courseName: c.courseName,
          credits: c.credits,
          classes: []
        });
      }
      if (c.classId) {
        map.get(c.courseId).classes.push(c);
      }
    });
    return Array.from(map.values());
  }, [flatClasses]);

  // Classes for Table 2
  const selectedCourseClasses = useMemo(() => {
    if (!selectedCourseId) return [];
    const crs = courses.find(c => c.courseId === selectedCourseId);
    let clsList = crs ? crs.classes : [];

    // Lọc trùng lịch
    if (hideConflict) {
      clsList = clsList.filter(cls => {
        // Kiểm tra xem cls có trùng lịch với bất kỳ lớp nào trong enrolled không
        const isConflict = enrolled.some(e => {
          if (e.dayOfWeek && cls.dayOfWeek && e.dayOfWeek === cls.dayOfWeek) {
            if (cls.startPeriod <= e.endPeriod && cls.endPeriod >= e.startPeriod) {
              return true;
            }
          }
          return false;
        });
        return !isConflict; // Giữ lại những lớp KHÔNG trùng
      });
    }
    return clsList;
  }, [selectedCourseId, courses, hideConflict, enrolled]);

  const selectedClass = useMemo(() => {
    return selectedCourseClasses.find(c => c.classId === selectedClassId);
  }, [selectedClassId, selectedCourseClasses]);

  // Actions
  const handleRegister = async (cls) => {
    try {
      await registerCourse(cls.classId, type);
      showToast('success', '✅ Đăng ký môn học thành công!');
      loadData();
    } catch (err) {
      const msg = err?.response?.data?.message || 'Đăng ký thất bại.';
      showToast('error', `❌ ${msg}`);
    }
  };

  const handleCancel = async (cls) => {
    try {
      await cancelCourseReg(cls.classId);
      showToast('success', '✅ Hủy môn học thành công!');
      setCancelModal(null);
      loadData();
    } catch (err) {
      const msg = err?.response?.data?.message || 'Hủy thất bại.';
      showToast('error', `❌ ${msg}`);
      setCancelModal(null);
    }
  };

  const checkConflict = (cls) => {
    const conflicts = enrolled.filter(e => {
      if (e.dayOfWeek && cls.dayOfWeek && e.dayOfWeek === cls.dayOfWeek) {
        if (cls.startPeriod <= e.endPeriod && cls.endPeriod >= e.startPeriod) {
          return true;
        }
      }
      return false;
    });
    setConflictModal(conflicts);
  };

  // UI components
  return (
    <div className="page active" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {toast && (
        <div style={{
          position: 'fixed', top: 20, right: 20, zIndex: 9999,
          background: toast.type === 'success' ? '#4caf50' : '#f44336',
          color: 'white', padding: '12px 24px', borderRadius: 4, fontWeight: 'bold',
          boxShadow: '0 2px 10px rgba(0,0,0,0.2)'
        }}>
          {toast.msg}
        </div>
      )}

      {/* TOP TITLE */}
      <div style={{ background: 'var(--blue)', color: 'white', padding: '15px 20px', borderRadius: '8px', fontWeight: 'bold', fontSize: '18px', textAlign: 'center', boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
        CỔNG ĐĂNG KÝ HỌC PHẦN SINH VIÊN
      </div>

      <div style={{ display: 'flex', gap: 20 }}>
        {/* LEFT COLUMN */}
        <div style={{ width: 250, flexShrink: 0 }}>
          <div style={{ background: '#456bd9', padding: 20, color: 'white', borderTopLeftRadius: 8, borderTopRightRadius: 8 }}>
            <h3 style={{ margin: '0 0 10px 0', fontSize: 14, fontWeight: 'normal', opacity: 0.9 }}>Xin chào!</h3>
            <h2 style={{ margin: '0 0 20px 0', fontSize: 18, fontWeight: '600' }}>{profile?.fullName || 'Sinh viên'}</h2>
            <div style={{ fontSize: 13, marginBottom: 8, display: 'flex', justifyContent: 'space-between' }}>
              <span>Giới tính:</span> <strong>{profile?.gender || 'Nam'}</strong>
            </div>
            <div style={{ fontSize: 13, marginBottom: 8, display: 'flex', justifyContent: 'space-between' }}>
              <span>MSSV:</span> <strong>{profile?.studentCode}</strong>
            </div>
            <div style={{ fontSize: 13, display: 'flex', justifyContent: 'space-between' }}>
              <span>Trạng thái:</span> <strong>Đang học</strong>
            </div>
          </div>
          <div style={{ background: 'white', border: '1px solid #ddd', borderTop: 'none', padding: 15, borderBottomLeftRadius: 8, borderBottomRightRadius: 8 }}>
            <div style={{ width: '100%', aspectRatio: '3/4', background: '#f8f9fa', borderRadius: 4, overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
               <img src={`https://ui-avatars.com/api/?name=${encodeURIComponent(profile?.fullName || 'SV')}&size=200&background=e0e7ff&color=456bd9`} alt="Avatar" style={{width:'100%', height:'100%', objectFit:'cover'}} />
            </div>
          </div>
        </div>

        {/* RIGHT COLUMN */}
        <div className="card" style={{ flex: 1, minHeight: 600, padding: 0 }}>
          
          {/* TABS */}
          <div style={{ display: 'flex', borderBottom: '1px solid #ddd', background: '#f8f9fa', borderTopLeftRadius: 8, borderTopRightRadius: 8 }}>
            <div 
              style={{ padding: '15px 30px', cursor: 'pointer', fontWeight: 600, color: activeTab === 'INFO' ? '#1a73e8' : '#64748b', borderBottom: activeTab === 'INFO' ? '3px solid #1a73e8' : '3px solid transparent', transition: 'all 0.2s' }}
              onClick={() => setActiveTab('INFO')}
            >
              THÔNG TIN SINH VIÊN
            </div>
            <div 
              style={{ padding: '15px 30px', cursor: 'pointer', fontWeight: 600, color: activeTab === 'REGISTRATION' ? '#1a73e8' : '#64748b', borderBottom: activeTab === 'REGISTRATION' ? '3px solid #1a73e8' : '3px solid transparent', transition: 'all 0.2s' }}
              onClick={() => setActiveTab('REGISTRATION')}
            >
              ĐĂNG KÝ HỌC PHẦN
            </div>
          </div>

          <div style={{ padding: 20 }}>
            {activeTab === 'INFO' && (
              <div>
                <h3 style={{ color: '#1a73e8', borderBottom: '2px solid #eee', paddingBottom: 10 }}>THÔNG TIN SINH VIÊN</h3>
                <div style={{ display: 'flex', flexWrap: 'wrap', marginTop: 20, lineHeight: '2' }}>
                  <div style={{ width: '50%' }}><b>Khóa:</b> 2023</div>
                  <div style={{ width: '50%' }}><b>Lớp:</b> 14DHTH05</div>
                  <div style={{ width: '50%' }}><b>Bậc đào tạo:</b> Đại học</div>
                  <div style={{ width: '50%' }}><b>Loại hình đào tạo:</b> Chính quy</div>
                  <div style={{ width: '50%' }}><b>Ngành:</b> Công nghệ thông tin</div>
                  <div style={{ width: '50%' }}><b>Chuyên ngành:</b> Công nghệ phần mềm</div>
                  <div style={{ width: '50%' }}><b>Khoa:</b> Khoa Công nghệ Thông tin</div>
                  <div style={{ width: '50%' }}><b>Cơ sở:</b> ĐHCT TP.HCM</div>
                </div>
              </div>
            )}

            {activeTab === 'REGISTRATION' && (
              <div>
                <h3 style={{ color: '#1a73e8', textAlign: 'center', marginBottom: 20, fontSize: 18, marginTop: 10 }}>ĐĂNG KÝ HỌC PHẦN</h3>
                
                {/* FILTER ROW */}
                <div style={{ display: 'flex', alignItems: 'center', gap: 20, marginBottom: 25, justifyContent: 'center', flexWrap: 'wrap' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <b style={{ color: '#334155' }}>Đợt đăng ký</b>
                    <select className="form-ctrl" value={semId} onChange={e => setSemId(e.target.value)} style={{ padding: '6px 12px', minWidth: 150 }}>
                      <option value="0">Tất cả đợt (Không có học kỳ)</option>
                      {semesters.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                    </select>
                  </div>
                  <div style={{ display: 'flex', gap: 20, background: '#f8fafc', padding: '6px 16px', borderRadius: 20, border: '1px solid #e2e8f0' }}>
                    {TYPE_OPTIONS.map(opt => (
                      <label key={opt.value} style={{ cursor: 'pointer', color: type === opt.value ? '#d97706' : '#64748b', fontWeight: type === opt.value ? 'bold' : 'normal', display: 'flex', alignItems: 'center', gap: 6 }}>
                        <input type="radio" name="regType" value={opt.value} checked={type === opt.value} onChange={() => setType(opt.value)} style={{ accentColor: '#d97706', width: 16, height: 16 }} />
                        {opt.label}
                      </label>
                    ))}
                  </div>
                </div>

                {loading ? <div style={{ textAlign: 'center', padding: 50, color: '#64748b' }}>Đang tải dữ liệu...</div> : (
                  <>
                    {/* TABLE 1: MÔN HỌC CHỜ ĐĂNG KÝ */}
                    <div style={{ borderLeft: '4px solid #f59e0b', paddingLeft: 10, color: '#d97706', fontWeight: 'bold', marginBottom: 12, textTransform: 'uppercase' }}>
                      Môn học phần đang chờ đăng ký
                    </div>
                    <div style={{ overflowX: 'auto', marginBottom: 30 }}>
                      <table className="tbl" style={{ width: '100%', fontSize: 13, border: '1px solid #e2e8f0' }}>
                        <thead>
                          <tr style={{ background: '#456bd9', color: 'white' }}>
                            <th style={{ padding: 10, borderBottom: 'none' }}>STT</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>Mã HP</th>
                            <th style={{ padding: 10, borderBottom: 'none', textAlign: 'left' }}>Tên môn học</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>TC</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>Bắt buộc</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>Học kỳ</th>
                          </tr>
                        </thead>
                        <tbody>
                          {courses.map((crs, idx) => (
                            <tr key={crs.courseId} 
                                style={{ cursor: 'pointer', background: selectedCourseId === crs.courseId ? '#fef3c7' : 'white', transition: 'background 0.2s' }}
                                onClick={() => { setSelectedCourseId(crs.courseId); setSelectedClassId(null); }}
                                className="hover-row">
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>
                                <input type="radio" checked={selectedCourseId === crs.courseId} readOnly style={{ accentColor: '#f59e0b' }} /> {idx + 1}
                              </td>
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0', color: '#1a73e8', fontWeight: 600 }}>{crs.courseCode}</td>
                              <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', fontWeight: 500 }}>{crs.courseName}</td>
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>{crs.credits}</td>
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0', color: '#ef4444' }}>✖</td>
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>{semId === '0' ? '-' : semId}</td>
                            </tr>
                          ))}
                          {courses.length === 0 && <tr><td colSpan="6" style={{ padding: 30, textAlign: 'center', color: '#94a3b8' }}>Không tìm thấy dữ liệu</td></tr>}
                        </tbody>
                      </table>
                    </div>

                    {/* TABLE 2: LỚP HỌC PHẦN CHỜ ĐĂNG KÝ */}
                    {selectedCourseId && (
                      <>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
                          <div style={{ borderLeft: '4px solid #f59e0b', paddingLeft: 10, color: '#d97706', fontWeight: 'bold', textTransform: 'uppercase' }}>
                            Lớp học phần chờ đăng ký
                          </div>
                          <label style={{ fontSize: 13, cursor: 'pointer', color: '#1e293b', display: 'flex', alignItems: 'center', gap: 6, fontWeight: 500 }}>
                            <input type="checkbox" checked={hideConflict} onChange={e => setHideConflict(e.target.checked)} style={{ width: 16, height: 16, accentColor: '#456bd9' }} />
                            Hiển thị lớp học phần không trùng lịch
                          </label>
                        </div>
                        <div style={{ overflowX: 'auto', marginBottom: 30 }}>
                          <table className="tbl" style={{ width: '100%', fontSize: 13, border: '1px solid #e2e8f0' }}>
                            <thead>
                              <tr style={{ background: '#456bd9', color: 'white' }}>
                                <th style={{ padding: 10, borderBottom: 'none' }}>STT</th>
                                <th style={{ padding: 10, borderBottom: 'none' }}>Mã LHP</th>
                                <th style={{ padding: 10, borderBottom: 'none', textAlign: 'left' }}>Tên lớp học phần</th>
                                <th style={{ padding: 10, borderBottom: 'none' }}>Sĩ số tối đa</th>
                                <th style={{ padding: 10, borderBottom: 'none' }}>Đã đăng ký</th>
                                <th style={{ padding: 10, borderBottom: 'none' }}>Trạng thái</th>
                              </tr>
                            </thead>
                            <tbody>
                              {selectedCourseClasses.map((cls, idx) => (
                                <tr key={cls.classId}
                                    style={{ cursor: 'pointer', background: selectedClassId === cls.classId ? '#fef3c7' : 'white', transition: 'background 0.2s' }}
                                    onClick={() => setSelectedClassId(cls.classId)}
                                    className="hover-row">
                                  <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>
                                    <input type="radio" checked={selectedClassId === cls.classId} readOnly style={{ accentColor: '#f59e0b' }} /> {idx + 1}
                                  </td>
                                  <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0', color: '#1a73e8', fontWeight: 600 }}>{cls.classCode}</td>
                                  <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', fontWeight: 500 }}>{cls.courseName}</td>
                                  <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>{cls.maxStudents}</td>
                                  <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0', color: cls.enrolledCount >= cls.maxStudents ? '#ef4444' : '#22c55e', fontWeight: 600 }}>{cls.enrolledCount}</td>
                                  <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>
                                    {cls.alreadyEnrolled === 1 ? <span style={{color: '#16a34a', fontWeight: 'bold'}}>Đã Đ.Ký</span> : <span style={{color: '#64748b'}}>Chờ đăng ký</span>}
                                  </td>
                                </tr>
                              ))}
                              {selectedCourseClasses.length === 0 && <tr><td colSpan="6" style={{ padding: 30, textAlign: 'center', color: '#94a3b8' }}>Không tìm thấy lớp học phần phù hợp</td></tr>}
                            </tbody>
                          </table>
                        </div>
                      </>
                    )}

                    {/* CHI TIẾT LỚP HỌC PHẦN */}
                    {selectedClassId && selectedClass && (
                      <div style={{ background: '#f8fafc', padding: 20, borderRadius: 8, border: '1px solid #e2e8f0', marginBottom: 30 }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 15 }}>
                          <div style={{ color: '#d97706', fontWeight: 'bold', textTransform: 'uppercase', fontSize: 14 }}>CHI TIẾT LỚP HỌC PHẦN</div>
                          <button className="btn btn-blue" style={{ background: '#f59e0b', borderColor: '#f59e0b', color: 'white' }}
                                  onClick={() => checkConflict(selectedClass)}>
                            Xem lịch trùng
                          </button>
                        </div>
                        
                        <div style={{ overflowX: 'auto', marginBottom: 20 }}>
                          <table className="tbl" style={{ width: '100%', fontSize: 13, background: 'white' }}>
                            <thead>
                              <tr style={{ background: '#456bd9', color: 'white' }}>
                                <th style={{ padding: 10 }}>STT</th>
                                <th style={{ padding: 10 }}>Lịch học</th>
                                <th style={{ padding: 10 }}>Phòng</th>
                                <th style={{ padding: 10 }}>Dãy nhà</th>
                                <th style={{ padding: 10 }}>Cơ sở</th>
                                <th style={{ padding: 10 }}>Giảng viên</th>
                                <th style={{ padding: 10 }}>Thao tác</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', textAlign: 'center' }}>1</td>
                                <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', textAlign: 'center' }}>
                                  {DAY_NAMES[selectedClass.dayOfWeek]} (T{selectedClass.startPeriod} - T{selectedClass.endPeriod})
                                </td>
                                <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', textAlign: 'center' }}>{selectedClass.roomNumber}</td>
                                <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', textAlign: 'center' }}>{selectedClass.building}</td>
                                <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', textAlign: 'center' }}>ĐHCT TP.HCM</td>
                                <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', textAlign: 'center' }}>{selectedClass.teacherName}</td>
                                <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', textAlign: 'center' }}>
                                  <button style={{ background: '#456bd9', color: 'white', border: 'none', padding: '5px 12px', borderRadius: 4, cursor: 'pointer', fontSize: 12 }}
                                          onClick={() => setTeacherModal(selectedClass.teacherName)}>Xem</button>
                                </td>
                              </tr>
                            </tbody>
                          </table>
                        </div>
                        <div style={{ textAlign: 'center' }}>
                          <button className="btn" style={{ background: '#d97706', borderColor: '#d97706', color: 'white', padding: '10px 30px', fontSize: 15, fontWeight: 'bold' }}
                                  onClick={() => handleRegister(selectedClass)}
                                  disabled={selectedClass.alreadyEnrolled === 1 || loading}>
                            {selectedClass.alreadyEnrolled === 1 ? 'Đã đăng ký' : 'Đăng ký môn học'}
                          </button>
                        </div>
                      </div>
                    )}

                    {/* LỚP HỌC PHẦN ĐÃ ĐĂNG KÝ TRONG HỌC KỲ NÀY */}
                    <div style={{ borderLeft: '4px solid #f59e0b', paddingLeft: 10, color: '#d97706', fontWeight: 'bold', marginBottom: 12, textTransform: 'uppercase' }}>
                      Lớp học phần đã đăng ký trong học kỳ này
                    </div>
                    <div style={{ overflowX: 'auto', paddingBottom: 50 }}>
                      <table className="tbl" style={{ width: '100%', fontSize: 13, border: '1px solid #e2e8f0' }}>
                        <thead>
                          <tr style={{ background: '#456bd9', color: 'white' }}>
                            <th style={{ padding: 10, borderBottom: 'none' }}>STT</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>Mã LHP</th>
                            <th style={{ padding: 10, borderBottom: 'none', textAlign: 'left' }}>Tên môn học</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>TC</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>Học phí</th>
                            <th style={{ padding: 10, borderBottom: 'none' }}>Thao tác</th>
                          </tr>
                        </thead>
                        <tbody>
                          {enrolled.map((e, idx) => (
                            <tr key={e.classId} className="hover-row">
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>{idx + 1}</td>
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0', color: '#1a73e8', fontWeight: 600 }}>{e.classCode}</td>
                              <td style={{ padding: 10, borderTop: '1px solid #e2e8f0', fontWeight: 500 }}>{e.courseName}</td>
                              <td style={{ padding: 10, textAlign: 'center', borderTop: '1px solid #e2e8f0' }}>{e.credits}</td>
                              <td style={{ padding: 10, textAlign: 'right', borderTop: '1px solid #e2e8f0', color: '#d97706', fontWeight: 'bold' }}>
                              {(e.credits * 1135000).toLocaleString('vi-VN')} đ
                            </td>
                            <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center', position: 'relative' }}>
                              <button 
                                style={{ background: 'none', border: 'none', fontSize: 20, cursor: 'pointer', color: '#666' }}
                                onClick={() => setActiveMenuId(activeMenuId === e.classId ? null : e.classId)}
                              >
                                ...
                              </button>
                              {activeMenuId === e.classId && (
                                <div style={{
                                  position: 'absolute', top: 30, right: 0, zIndex: 100,
                                  background: 'white', border: '1px solid #ccc', borderRadius: 4,
                                  boxShadow: '0 4px 8px rgba(0,0,0,0.1)', overflow: 'hidden'
                                }}>
                                  <div 
                                    style={{ padding: '8px 20px', cursor: 'pointer', background: '#456bd9', color: 'white', fontSize: 13, textAlign: 'center' }}
                                    onClick={() => { setViewModal(e); setActiveMenuId(null); }}
                                  >
                                    Xem
                                  </div>
                                  <div 
                                    style={{ padding: '8px 20px', cursor: 'pointer', background: '#f28b18', color: 'white', fontSize: 13, textAlign: 'center' }}
                                    onClick={() => { setCancelModal(e); setActiveMenuId(null); }}
                                  >
                                    Hủy đăng ký
                                  </div>
                                </div>
                              )}
                            </td>
                          </tr>
                        ))}
                        {enrolled.length === 0 && <tr><td colSpan="6" style={{ padding: 30, textAlign: 'center', color: '#94a3b8' }}>Chưa đăng ký môn học nào</td></tr>}
                      </tbody>
                    </table>
                    </div>
                  </>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* MODALS */}
      {teacherModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
          <div style={{ background: 'white', padding: 20, borderRadius: 8, width: 600 }}>
            <h3 style={{ borderBottom: '1px solid #eee', paddingBottom: 10, margin: '0 0 20px 0' }}>THÔNG TIN GIẢNG VIÊN</h3>
            <h2 style={{ color: 'orange', textAlign: 'center' }}>{teacherModal.toUpperCase()}</h2>
            <div style={{ textAlign: 'center', marginTop: 30 }}>
              <button onClick={() => setTeacherModal(null)} style={{ padding: '5px 20px', cursor: 'pointer' }}>Đóng</button>
            </div>
          </div>
        </div>
      )}

      {conflictModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
          <div style={{ background: 'white', padding: 20, borderRadius: 8, width: 800 }}>
            <h3 style={{ margin: '0 0 20px 0' }}>DANH SÁCH LỊCH HỌC BỊ TRÙNG</h3>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13, marginBottom: 20 }}>
              <thead>
                <tr style={{ background: '#456bd9', color: 'white' }}>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Mã LHP</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Tên môn học</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Thứ</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Tiết</th>
                </tr>
              </thead>
              <tbody>
                {conflictModal.length === 0 ? (
                  <tr><td colSpan="4" style={{ padding: 20, textAlign: 'center' }}>Không tìm thấy lịch học trùng</td></tr>
                ) : conflictModal.map(c => (
                  <tr key={c.classId}>
                    <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{c.classCode}</td>
                    <td style={{ padding: 10, border: '1px solid #ddd' }}>{c.courseName}</td>
                    <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{DAY_NAMES[c.dayOfWeek]}</td>
                    <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>T{c.startPeriod} - T{c.endPeriod}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div style={{ textAlign: 'right' }}>
              <button onClick={() => setConflictModal(null)} style={{ padding: '5px 20px', cursor: 'pointer' }}>Đóng</button>
            </div>
          </div>
        </div>
      )}

      {cancelModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
          <div style={{ background: 'white', padding: 30, borderRadius: 8, width: 450, textAlign: 'center', boxShadow: '0 4px 15px rgba(0,0,0,0.2)' }}>
            <div style={{ width: 60, height: 60, borderRadius: '50%', border: '2px solid orange', color: 'orange', fontSize: 40, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 15px auto' }}>!</div>
            <h3 style={{ margin: '0 0 10px 0', fontSize: 18, color: '#333' }}>HỦY ĐĂNG KÝ</h3>
            <p style={{ color: '#666', fontSize: 14, marginBottom: 25 }}>Bạn muốn hủy đăng ký lớp học [{cancelModal.courseName}] ?</p>
            <div style={{ display: 'flex', justifyContent: 'center', gap: 10 }}>
              <button onClick={() => handleCancel(cancelModal)} style={{ padding: '8px 25px', background: '#456bd9', color: 'white', border: 'none', borderRadius: 4, cursor: 'pointer', fontWeight: 'bold' }}>OK</button>
              <button onClick={() => setCancelModal(null)} style={{ padding: '8px 25px', background: '#d32f2f', color: 'white', border: 'none', borderRadius: 4, cursor: 'pointer', fontWeight: 'bold' }}>Cancel</button>
            </div>
          </div>
        </div>
      )}

      {viewModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10000 }}>
          <div style={{ background: 'white', padding: '20px', borderRadius: 8, width: 850, boxShadow: '0 4px 15px rgba(0,0,0,0.2)' }}>
            <h3 style={{ margin: '0 0 20px 0', fontSize: 16 }}>CHI TIẾT LỚP HỌC ĐÃ ĐĂNG KÝ</h3>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13, marginBottom: 20 }}>
              <thead>
                <tr style={{ background: '#456bd9', color: 'white' }}>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>STT</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Lịch học</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Nhóm</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Phòng</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Dãy nhà</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Cơ sở</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Giảng viên</th>
                  <th style={{ padding: 10, border: '1px solid #ddd' }}>Thời gian</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>1</td>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>
                    LT - {DAY_NAMES[viewModal.dayOfWeek]} (T{viewModal.startPeriod} - T{viewModal.endPeriod})
                  </td>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}></td>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{viewModal.roomNumber}</td>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{viewModal.building}</td>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>ĐHCT TP.HCM</td>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>{viewModal.teacherName}</td>
                  <td style={{ padding: 10, border: '1px solid #ddd', textAlign: 'center' }}>06/07/2026 - 03/08/2026</td>
                </tr>
              </tbody>
            </table>
            <div style={{ textAlign: 'right' }}>
              <button onClick={() => setViewModal(null)} style={{ padding: '6px 20px', border: '1px solid #ccc', background: 'white', borderRadius: 4, cursor: 'pointer' }}>Đóng</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
