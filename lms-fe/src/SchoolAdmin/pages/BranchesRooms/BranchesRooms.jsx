import React, { useState, useEffect } from 'react';
import { Building, Save } from 'lucide-react';
import { API_BASE_URL } from '../../../config/apiConfig';


export default function BranchesRooms() {
  const [branches, setBranches] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [toast, setToast] = useState(null);

  // Modals state
  const [branchModalOpen, setBranchModalOpen] = useState(false);
  const [roomModalOpen, setRoomModalOpen] = useState(false);

  // Form state
  const [currentBranch, setCurrentBranch] = useState({ id: null, code: '', name: '', address: '', city: '', district: '', phone: '', email: '', isMain: false, isActive: true });
  const [currentRoom, setCurrentRoom] = useState({ id: null, schoolBranchId: '', roomNumber: '', building: '', roomType: 'CLASSROOM', capacity: 40, equipments: '', isActive: true });

  const SCHOOL_ID = localStorage.getItem('schoolId') || 1;
  const token = localStorage.getItem('adminToken');

  useEffect(() => {
    fetchBranches();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchBranches = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/branches/school/${SCHOOL_ID}`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setBranches(data);
        fetchAllRooms(data);
      }
    } catch (error) {
      showToast('Lỗi khi tải cơ sở!', 'error');
    }
  };

  const fetchAllRooms = async (branchesList) => {
    let allRooms = [];
    for (let branch of branchesList) {
      try {
        const res = await fetch(`${API_BASE_URL}/school-admin/rooms/branch/${branch.id}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          allRooms = [...allRooms, ...data];
        }
      } catch (error) {
        console.error("Lỗi tải phòng học", error);
      }
    }
    setRooms(allRooms);
  };

  // --- BRANCH LOGIC ---
  const handleSaveBranch = async () => {
    const payload = { ...currentBranch, schoolId: SCHOOL_ID };
    const method = currentBranch.id ? 'PUT' : 'POST';
    const url = currentBranch.id
      ? `${API_BASE_URL}/school-admin/branches/${currentBranch.id}`
      : `${API_BASE_URL}/school-admin/branches`;

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast(currentBranch.id ? 'Cập nhật cơ sở thành công!' : 'Thêm cơ sở thành công!');
        setBranchModalOpen(false);
        fetchBranches();
      } else {
        showToast('Lỗi khi lưu cơ sở!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDeleteBranch = async (id) => {
    if (!window.confirm("Bạn có chắc muốn xóa cơ sở này?")) return;
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/branches/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        showToast('Đã xóa cơ sở!');
        fetchBranches();
      }
    } catch (err) {
      showToast('Lỗi khi xóa cơ sở!', 'error');
    }
  };

  const openBranchModal = (branch = null) => {
    setCurrentBranch(branch ? { ...branch } : { id: null, code: '', name: '', address: '', city: '', district: '', phone: '', email: '', isMain: false, isActive: true });
    setBranchModalOpen(true);
  };

  // --- ROOM LOGIC ---
  const handleSaveRoom = async () => {
    const equipmentArray = currentRoom.equipments
      ? currentRoom.equipments.split(',').map(e => e.trim()).filter(e => e !== '')
      : [];

    const payload = {
      ...currentRoom,
      equipment: equipmentArray
    };

    const method = currentRoom.id ? 'PUT' : 'POST';
    const url = currentRoom.id
      ? `${API_BASE_URL}/school-admin/rooms/${currentRoom.id}`
      : `${API_BASE_URL}/school-admin/rooms`;

    try {
      const res = await fetch(url, {
        
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        showToast(currentRoom.id ? 'Cập nhật phòng học thành công!' : 'Thêm phòng học thành công!');
        setRoomModalOpen(false);
        fetchBranches();
      } else {
        showToast('Lỗi khi lưu phòng học!', 'error');
      }
    } catch (err) {
      showToast('Lỗi kết nối mạng!', 'error');
    }
  };

  const handleDeleteRoom = async (id) => {
    if (!window.confirm("Bạn có chắc muốn xóa phòng học này?")) return;
    try {
      const res = await fetch(`${API_BASE_URL}/school-admin/rooms/${id}`, {
        
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        showToast('Đã xóa phòng học!');
        fetchBranches();
      }
    } catch (err) {
      showToast('Lỗi khi xóa phòng học!', 'error');
    }
  };

  const openRoomModal = (room = null) => {
    setCurrentRoom(room ? {
      ...room,
      equipments: room.equipment ? room.equipment.join(', ') : ''
    } : { id: null, schoolBranchId: branches[0]?.id || '', roomNumber: '', building: '', roomType: 'CLASSROOM', capacity: 40, equipments: '', isActive: true });
    setRoomModalOpen(true);
  };

  const gradients = [
    'linear-gradient(90deg,#1976d2,#42a5f5)',
    'linear-gradient(90deg,#00897b,#4db6ac)',
    'linear-gradient(90deg,#e65100,#ffb74d)',
    'linear-gradient(90deg,#6a1b9a,#ce93d8)'
  ];

  return (
    <div className="page" style={{ position: 'relative' }}>

      {/* TOAST NOTIFICATION */}
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

      <div className="ph" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <div className="ph-title">Cơ sở & Phòng học</div>
          <div className="ph-sub">Quản lý các cơ sở và phòng học của trường</div>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="btn btn-ghost" style={{ border: '1px solid #ccc' }} onClick={() => openBranchModal()}>+ Thêm Cơ sở</button>
          <button className="btn btn-blue" onClick={() => openRoomModal()}>+ Thêm Phòng học</button>
        </div>
      </div>

      {/* DANH SÁCH CƠ SỞ (THẺ) */}
      <div className="grid4 mb4">
        {branches.map((branch, index) => (
          <div className="stat" style={{ cursor: 'pointer' }} key={branch.id} onClick={() => openBranchModal(branch)}>
            <div className="stat-top" style={{ background: gradients[index % gradients.length] }}></div>
            <div className="stat-icon"><Building className="w-4 h-4 inline-block mr-2" /></div>
            <div className="stat-label">{branch.name}</div>
            <div style={{ fontSize: '11px', color: 'var(--muted)', marginTop: '6px' }}>{branch.address}, {branch.district}, {branch.city}</div>
            <div style={{ marginTop: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              {branch.isMain ? <span className="badge b-green">Cơ sở chính</span> : <span className="badge b-gray">Cơ sở phụ</span>}
              <button className="btn btn-danger btn-xs" onClick={(e) => { e.stopPropagation(); handleDeleteBranch(branch.id); }}>Xóa</button>
            </div>
          </div>
        ))}
      </div>

      {/* DANH SÁCH PHÒNG HỌC */}
      <div className="card">
        <div className="card-hd">
          <div className="card-title">Danh sách phòng học</div>
        </div>
        <table className="tbl">
          <thead>
            <tr>
              <th>Số phòng</th>
              <th>Tòa</th>
              <th>Cơ sở</th>
              <th>Loại phòng</th>
              <th>Sức chứa</th>
              <th>Thiết bị</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {rooms.map(room => (
              <tr key={room.id}>
                <td style={{ fontWeight: 700 }}>{room.roomNumber}</td>
                <td>{room.building}</td>
                <td>{room.schoolBranchName}</td>
                <td><span className="badge b-blue">{room.roomType}</span></td>
                <td><strong>{room.capacity}</strong></td>
                <td>
                  {room.equipment && room.equipment.map((eq, i) => (
                    <span key={i} className="badge b-gray" style={{ marginRight: '4px' }}>{eq}</span>
                  ))}
                </td>
                <td>
                  {room.isActive
                    ? <span className="badge b-green"><span className="dot-on"></span> Active</span>
                    : <span className="badge b-gray"><span className="dot-off"></span> Inactive</span>}
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '4px' }}>
                    <button className="btn btn-ghost btn-xs" onClick={() => openRoomModal(room)}>Sửa</button>
                    <button className="btn btn-danger btn-xs" onClick={() => handleDeleteRoom(room.id)}>Xóa</button>
                  </div>
                </td>
              </tr>
            ))}
            {rooms.length === 0 && <tr><td colSpan="8" style={{ textAlign: 'center' }}>Chưa có phòng học nào</td></tr>}
          </tbody>
        </table>
      </div>

      {/* MODAL CƠ SỞ */}
      {branchModalOpen && (
        <div className="ov open">
          <div className="modal">
            <div className="modal-hd">
              <span className="modal-title">{currentBranch.id ? 'Sửa Cơ sở' : 'Thêm Cơ sở'}</span>
              <button className="close-btn" onClick={() => setBranchModalOpen(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Mã cơ sở</label>
                  <input className="fc" maxLength="20" value={currentBranch.code} onChange={e => setCurrentBranch({ ...currentBranch, code: e.target.value })} placeholder="VD: CS1" />
                </div>
                <div className="fg">
                  <label className="fl">Tên cơ sở</label>
                  <input className="fc" value={currentBranch.name} onChange={e => setCurrentBranch({ ...currentBranch, name: e.target.value })} placeholder="VD: Lý Thường Kiệt" />
                </div>
              </div>
              <div className="fg">
                <label className="fl">Địa chỉ</label>
                <input className="fc" value={currentBranch.address} onChange={e => setCurrentBranch({ ...currentBranch, address: e.target.value })} />
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Quận/Huyện</label>
                  <input className="fc" value={currentBranch.district} onChange={e => setCurrentBranch({ ...currentBranch, district: e.target.value })} />
                </div>
                <div className="fg">
                  <label className="fl">Tỉnh/Thành phố</label>
                  <input className="fc" value={currentBranch.city} onChange={e => setCurrentBranch({ ...currentBranch, city: e.target.value })} />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Điện thoại</label>
                  <input className="fc" value={currentBranch.phone} onChange={e => setCurrentBranch({ ...currentBranch, phone: e.target.value })} />
                </div>
                <div className="fg">
                  <label className="fl">Email</label>
                  <input className="fc" value={currentBranch.email} onChange={e => setCurrentBranch({ ...currentBranch, email: e.target.value })} />
                </div>
              </div>
              <div className="grid2">
                <div className="fg" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <input type="checkbox" checked={currentBranch.isMain} onChange={e => setCurrentBranch({ ...currentBranch, isMain: e.target.checked })} />
                  <label>Là cơ sở chính</label>
                </div>
                <div className="fg" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <input type="checkbox" checked={currentBranch.isActive} onChange={e => setCurrentBranch({ ...currentBranch, isActive: e.target.checked })} />
                  <label>Đang hoạt động</label>
                </div>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setBranchModalOpen(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveBranch}><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL PHÒNG HỌC */}
      {roomModalOpen && (
        <div className="ov open">
          <div className="modal">
            <div className="modal-hd">
              <span className="modal-title">{currentRoom.id ? 'Sửa Phòng học' : 'Thêm Phòng học'}</span>
              <button className="close-btn" onClick={() => setRoomModalOpen(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Cơ sở</label>
                  <select className="fc" value={currentRoom.schoolBranchId} onChange={e => setCurrentRoom({ ...currentRoom, schoolBranchId: e.target.value })}>
                    <option value="">-- Chọn cơ sở --</option>
                    {branches.map(br => (
                      <option key={br.id} value={br.id}>{br.name}</option>
                    ))}
                  </select>
                </div>
                <div className="fg">
                  <label className="fl">Tòa nhà</label>
                  <input className="fc" value={currentRoom.building} onChange={e => setCurrentRoom({ ...currentRoom, building: e.target.value })} placeholder="A, B, C..." />
                </div>
              </div>
              <div className="grid2">
                <div className="fg">
                  <label className="fl">Số phòng</label>
                  <input className="fc" value={currentRoom.roomNumber} onChange={e => setCurrentRoom({ ...currentRoom, roomNumber: e.target.value })} placeholder="101, 301..." />
                </div>
                <div className="fg">
                  <label className="fl">Sức chứa (người)</label>
                  <input type="number" className="fc" value={currentRoom.capacity} onChange={e => setCurrentRoom({ ...currentRoom, capacity: parseInt(e.target.value) || 0 })} placeholder="40" />
                </div>
              </div>
              <div className="fg">
                <label className="fl">Loại phòng</label>
                <select className="fc" value={currentRoom.roomType} onChange={e => setCurrentRoom({ ...currentRoom, roomType: e.target.value })}>
                  <option value="CLASSROOM">Classroom</option>
                  <option value="LAB">Lab</option>
                  <option value="SEMINAR">Seminar</option>
                  <option value="LECTURE_HALL">Lecture Hall</option>
                  <option value="ONLINE">Online</option>
                </select>
              </div>
              <div className="fg">
                <label className="fl">Thiết bị (phân cách bằng dấu phẩy)</label>
                <input className="fc" value={currentRoom.equipments} onChange={e => setCurrentRoom({ ...currentRoom, equipments: e.target.value })} placeholder="projector, ac, whiteboard..." />
              </div>
              <div className="fg" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <input type="checkbox" checked={currentRoom.isActive} onChange={e => setCurrentRoom({ ...currentRoom, isActive: e.target.checked })} />
                <label>Đang hoạt động</label>
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={() => setRoomModalOpen(false)}>Hủy</button>
              <button className="btn btn-blue" onClick={handleSaveRoom}><Save className="w-4 h-4 inline-block mr-2" /> Lưu</button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
