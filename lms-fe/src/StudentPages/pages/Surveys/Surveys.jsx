import React, { useEffect, useState } from 'react';
import { getSurveys } from '../../studentApi';
import SurveyDetail from './SurveyDetail';
import './Surveys.css';
import { Check, ClipboardList, CheckCircle2, PartyPopper } from 'lucide-react';

export default function Surveys() {
  const [tab, setTab] = useState('chua');
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null); // lớp đang mở form khảo sát

  const loadSurveys = () => {
    setLoading(true);
    getSurveys()
      .then(data => { setItems(data); setLoading(false); })
      .catch(() => setLoading(false));
  };

  useEffect(() => { loadSurveys(); }, []);

  const pending   = items.filter(s => !s.isCompleted);
  const completed = items.filter(s => s.isCompleted);
  const list = tab === 'chua' ? pending : completed;

  // Nếu đang mở form khảo sát, render SurveyDetail
  if (selected) {
    return (
      <SurveyDetail
        survey={selected}
        onBack={() => setSelected(null)}
        onSuccess={() => { setSelected(null); loadSurveys(); }}
      />
    );
  }

  return (
    <div className="page active">
      <div className="page-title-bar">
        <div className="page-title" style={{ margin: 0 }}>Khảo sát sự kiện</div>
        <div className="survey-stats">
          <span className="survey-badge pending">{pending.length} chưa khảo sát</span>
          <span className="survey-badge done">{completed.length} đã khảo sát</span>
        </div>
      </div>

      {/* Tabs */}
      <div className="tabs" style={{ marginBottom: 0 }}>
        <div
          className={`tab-btn ${tab === 'chua' ? 'active' : ''}`}
          onClick={() => setTab('chua')}
        >
          <ClipboardList className="w-4 h-4 inline-block mr-2" /> Danh sách phiếu chưa khảo sát
          {pending.length > 0 && (
            <span className="tab-count">{pending.length}</span>
          )}
        </div>
        <div
          className={`tab-btn ${tab === 'da' ? 'active' : ''}`}
          onClick={() => setTab('da')}
        >
          <CheckCircle2 className="w-4 h-4 inline-block mr-2" /> Danh sách phiếu đã khảo sát
        </div>
      </div>

      <div className="card" style={{ borderTopLeftRadius: 0 }}>
        {loading && (
          <div className="survey-empty">Đang tải...</div>
        )}

        {!loading && list.length === 0 && (
          <div className="survey-empty">
            {tab === 'chua'
              ? <><PartyPopper className="w-4 h-4 inline-block mr-2" /> Bạn đã hoàn thành tất cả phiếu khảo sát!</>
              : 'Chưa có phiếu khảo sát nào được hoàn thành.'}
          </div>
        )}

        {!loading && list.map((s, i) => (
          <div
            key={s.classId}
            className={`survey-item ${s.isCompleted ? 'completed' : ''}`}
            onClick={() => !s.isCompleted && setSelected(s)}
          >
            <div className="survey-item-left">
              <div className="survey-item-index">{i + 1}</div>
            </div>
            <div className="survey-item-content">
              <div className="survey-item-title">
                {s.isCompleted
              ? `[ĐÃ KHẢO SÁT] PHIẾU THĂM DÒ MỨC HÀI LÒNG CỦA NGƯỜI HỌC`
                  : `PHIẾU THĂM DÒ MỨC HÀI LÒNG CỦA NGƯỜI HỌC VỀ HỌC PHẦN THỰC HÀNH`}
                {' – '}
                <span style={{ color: 'var(--text)' }}>{s.courseName}</span>
              </div>
              <div className="survey-item-meta">
                <span className="survey-tag">{s.semesterName}</span>
                <span className="survey-tag" style={{ background: '#fef9c3', color: '#92400e' }}>
                  {s.courseCode}
                </span>
                {!s.isCompleted && (
                  <span className="survey-tag required">Bắt buộc</span>
                )}
              </div>
              <div className="survey-item-teacher">
                Giảng viên: <strong>{s.teacherName || '—'}</strong>
                &nbsp;|&nbsp; Lớp HP: <strong>{s.classCode}</strong>
              </div>
            </div>
            <div className="survey-item-action">
              {s.isCompleted ? (
                <span className="survey-status-done"><Check className="w-4 h-4 inline-block mr-2" /> Đã hoàn thành</span>
              ) : (
                <button className="btn btn-blue btn-sm">Làm khảo sát →</button>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}