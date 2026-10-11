import React, { useState, useEffect } from 'react';
import { BarChart, Check, CheckCircle2, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function Enrollments() {
  const [enrollments, setEnrollments] = useState([]);
  const [toast, setToast] = useState(null);

  // Modal states
  const [eModal, setEModal] = useState(false);
  const [gModal, setGModal] = useState(false);

  // Form states
  const [currentEnrollment, setCurrentEnrollment] = useState({ id: null, studentId: '', classId: '', status: 'ENROLLED' });
  const [currentGrades, setCurrentGrades] = useState({ id: null, gradeMidterm: '', gradeFinal: '', gradeTotal: '', gradeLetter: '' });
  const [selectedStudentName, setSelectedStudentName] = useState('');
  const [selectedClassCode, setSelectedClassCode] = useState('');

  useEffect(() => {
    fetchEnrollments();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchEnrollments = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/enrollments`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('adminToken')}` }
      });
      if (res.ok) {
        const data = await res.json();
        setEnrollments(data);
      }
    } catch (error) {
      showToast('Lỗi khi tải danh sách đăng ký!', 'error');
    }
  };

  const handleSaveEnrollment = async () => {
    const method = currentEnrollment.id ? 'PUT' : 'POST';
    const url = currentEnrollment.id 
      ? `${API_BASE_URL}/school-admin/enrollments/${currentEnrollment.id}`
      : `${API_BASE_URL}/school-admin/enrollments`;

    const payload = {
      studentId: parseInt(currentEnrollment.studentId),
      classId: parseInt(currentEnrollment.classId),
      status: currentEnrollment.status,
      // Khi tạo mới thì điểm bằng rỗng
    };

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast('Lưu đăng ký thành công!');
        setEModal(false);
        fetchEnrollments();
      } else {
        showToast('Lỗi khi lưu đăng ký!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleSaveGrades = async () => {
    if (!currentGrades.id) return;
    
    // Điểm phải gộp vào đối tượng Enrollment đang sửa
    const originalEnrollment = enrollments.find(e => e.id === currentGrades.id);
    if (!originalEnrollment) return;

    const payload = {
      studentId: originalEnrollment.studentId,
      classId: originalEnrollment.classId,
      status: originalEnrollment.status,
      gradeMidterm: currentGrades.gradeMidterm ? parseFloat(currentGrades.gradeMidterm) : null,
      gradeFinal: currentGrades.gradeFinal ? parseFloat(currentGrades.gradeFinal) : null,
      gradeTotal: currentGrades.gradeTotal ? parseFloat(currentGrades.gradeTotal) : null,
      gradeLetter: currentGrades.gradeLetter && currentGrades.gradeLetter !== '— Tự động —' ? currentGrades.gradeLetter : null
    };

    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/enrollments/${currentGrades.id}`, {
        
        method: 'PUT',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast('Lưu điểm thành công!');
        setGModal(false);
        fetchEnrollments();
      } else {
        showToast('Lỗi khi lưu điểm!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const openEnrollmentModal = () => {
    setCurrentEnrollment({ id: null, studentId: '', classId: '', status: 'ENROLLED' });
    setEModal(true);
  };

  const openGradeModal = (enrollment) => {
    setCurrentGrades({
      id: enrollment.id,
      gradeMidterm: enrollment.gradeMidterm || '',
      gradeFinal: enrollment.gradeFinal || '',
      gradeTotal: enrollment.gradeTotal || '',
      gradeLetter: enrollment.gradeLetter || ''
    });
    setSelectedStudentName(enrollment.studentName || enrollment.studentCode);
    setSelectedClassCode(enrollment.classCode);
    setGModal(true);
  };

  const formatDate = (dateString) => {
    if (!dateString) return '—';
    const d = new Date(dateString);
    return d.toLocaleDateString('vi-VN');
  };

  const renderStatusBadge = (status) => {
    if (status === 'ENROLLED') return <span className="badge b-green">ENROLLED</span>;
    if (status === 'PENDING') return <span className="badge b-amber">PENDING</span>;
    if (status === 'DROPPED') return <span className="badge b-gray">DROPPED</span>;
    if (status === 'COMPLETED') return <span className="badge b-blue">COMPLETED</span>;
    if (status === 'FAILED') return <span className="badge b-danger">FAILED</span>;
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
          <div className="ph-title">Đăng ký học phần</div>
          <div className="ph-sub">{enrollments.length} lượt đăng ký</div>
        </div>
        <button className="btn btn-blue" onClick={openEnrollmentModal}>+ Đăng ký thủ công</button>
      </div>
      
      <div className="card">
        <table className="tbl">
          <thead>
            <tr>
              <th>#</th>
              <th>Sinh viên</th>
              <th>Lớp học phần</th>
              <th>Ngày ĐK</th>
              <th>Trạng thái</th>
              <th>Điểm GK</th>
              <th>Điểm CK</th>
              <th>Điểm TK</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {enrollments.map((en, index) => (
              <tr key={en.id}>
                <td style={{color:'var(--muted)'}}>{index + 1}</td>
                <td>{en.studentName || en.studentCode || `Student #${en.studentId}`}</td>
                <td style={{fontFamily:'monospace', fontSize:'12px', color:'var(--blue)'}}>{en.classCode || `Class #${en.classId}`}</td>
                <td>{formatDate(en.enrollmentDate)}</td>
                <td>{renderStatusBadge(en.status)}</td>
                <td>{en.gradeMidterm != null ? en.gradeMidterm : '—'}</td>
                <td>{en.gradeFinal != null ? en.gradeFinal : '—'}</td>
                <td>{en.gradeTotal != null ? en.gradeTotal : '—'}</td>
                <td>
                  <button className="btn btn-ghost btn-xs" onClick={() => openGradeModal(en)}>Nhập điểm</button>
                </td>
              </tr>
            ))}
            {enrollments.length === 0 && <tr><td colSpan="9" style={{textAlign:'center'}}>Chưa có lượt đăng ký nào</td></tr>}
          </tbody>
        </table>
      </div>

      {eModal && (
        <div className="ov open">
          <div className="modal" style={{width:'440px'}}>
            <div className="modal-hd">
              <span className="modal-title"><CheckCircle2 className="w-4 h-4 inline-block mr-2" /> Đăng ký học phần thủ công</span>
              <button className="close-btn" onClick={() => setEModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="fg">
                <label className="fl">Mã Sinh viên (ID Tạm thời)</label>
                <input type="number" className="fc" value={currentEnrollment.studentId} onChange={e => setCurrentEnrollment({...currentEnrollment, studentId: e.target.value})} placeholder="Nhập ID sinh viên..." />
              </div>
              <div className="fg">
                <label className="fl">Mã Lớp (ID Tạm thời)</label>
                <input type="number" className="fc" value={currentEnrollment.classId} onChange={e => setCurrentEnrollment({...currentEnrollment, classId: e.target.value})} placeholder="Nhập ID lớp..." />
              </div>
              <div className="fg">
                <label className="fl">Trạng thái đăng ký</label>
                <select className="fc" value={currentEnrollment.status} onChange={e => setCurrentEnrollment({...currentEnrollment, status: e.target.value})}>
                  <option value="ENROLLED">ENROLLED</option>
                  <option value="PENDING">PENDING</option>
                  <option value="DROPPED">DROPPED</option>
                  <option value="COMPLETED">COMPLETED</option>
                  <option value="FAILED">FAILED</option>
                </select>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setEModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveEnrollment}><Check className="w-4 h-4 inline-block mr-2" /> Đăng ký</button>
            </div>
          </div>
        </div>
      )}

      {gModal && (
        <div className="ov open">
          <div className="modal" style={{width:'440px'}}>
            <div className="modal-hd">
              <span className="modal-title"><BarChart className="w-4 h-4 inline-block mr-2" /> Nhập điểm</span>
              <button className="close-btn" onClick={() => setGModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div style={{background:'#eff6ff', borderRadius:'8px', padding:'10px 14px', marginBottom:'16px', fontSize:'13px'}}>
                <strong>Sinh viên:</strong> {selectedStudentName} · <strong>Lớp:</strong> {selectedClassCode}
              </div>
              <div className="grid3">
                <div className="fg">
                  <label className="fl">Điểm GK</label>
                  <input type="number" className="fc" value={currentGrades.gradeMidterm} onChange={e => setCurrentGrades({...currentGrades, gradeMidterm: e.target.value})} placeholder="0.00" min="0" max="10" step="0.01" />
                </div>
                <div className="fg">
                  <label className="fl">Điểm CK</label>
                  <input type="number" className="fc" value={currentGrades.gradeFinal} onChange={e => setCurrentGrades({...currentGrades, gradeFinal: e.target.value})} placeholder="0.00" min="0" max="10" step="0.01" />
                </div>
                <div className="fg">
                  <label className="fl">Điểm TK</label>
                  <input type="number" className="fc" value={currentGrades.gradeTotal} onChange={e => setCurrentGrades({...currentGrades, gradeTotal: e.target.value})} placeholder="0.00" min="0" max="10" step="0.01" />
                </div>
              </div>
              <div className="fg">
                <label className="fl">Xếp loại (chữ)</label>
                <select className="fc" value={currentGrades.gradeLetter} onChange={e => setCurrentGrades({...currentGrades, gradeLetter: e.target.value})}>
                  <option value="">— Tự động —</option>
                  <option value="A+">A+</option>
                  <option value="A">A</option>
                  <option value="B+">B+</option>
                  <option value="B">B</option>
                  <option value="C+">C+</option>
                  <option value="C">C</option>
                  <option value="D+">D+</option>
                  <option value="D">D</option>
                  <option value="F">F</option>
                </select>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setGModal(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveGrades}><Save className="w-4 h-4 inline-block mr-2" /> Lưu điểm</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
