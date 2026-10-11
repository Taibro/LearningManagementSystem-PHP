import React, { useState } from 'react';
import { submitSurvey } from '../../studentApi';
import { AlertTriangle } from 'lucide-react';

// 5 mức đánh giá
const SCALE_5 = [
  { value: 1, label: 'Không hài lòng' },
  { value: 2, label: 'Chưa hài lòng' },
  { value: 3, label: 'Tương đối hài lòng' },
  { value: 4, label: 'Hài lòng' },
  { value: 5, label: 'Rất hài lòng' },
];

const SCALE_4_FINAL = [
  { value: 1, label: 'Rất không hài lòng' },
  { value: 2, label: 'Không hài lòng' },
  { value: 3, label: 'Phân vân' },
  { value: 4, label: 'Hài lòng' },
  { value: 5, label: 'Rất hài lòng' },
];

// Câu hỏi theo từng nhóm (như ảnh chụp từ HUIT thật)
const QUESTIONS = [
  // scoreKnowledge (câu 1-3)
  {
    id: 'q1', group: 'scoreKnowledge',
    text: 'Mục tiêu chuẩn đầu ra và đề cương học phần thực hành được giảng viên giới thiệu rõ ràng ngay từ buổi học đầu tiên của học phần.',
    scale: SCALE_5,
  },
  {
    id: 'q2', group: 'scoreKnowledge',
    text: 'Giảng viên nêu cụ thể các yêu cầu về nội dung, cách đánh giá, cách viết báo cáo kết quả thực hành, thời gian thực hành trước khi thực hành và có nhận xét chi tiết sau khi kết thúc thực hành.',
    scale: SCALE_5,
  },
  {
    id: 'q3', group: 'scoreKnowledge',
    text: 'Tiến độ học phần luôn theo đúng đề cương ban đầu và theo thời khóa biểu lên lớp của trường.',
    scale: SCALE_5,
  },
  // scoreMethod (câu 4-6)
  {
    id: 'q4', group: 'scoreMethod',
    text: 'Giảng viên chuẩn bị sẵn sàng trang thiết bị, dụng cụ, vật liệu, hóa chất và vật làm mẫu cho buổi học thực hành.',
    scale: SCALE_5,
  },
  {
    id: 'q5', group: 'scoreMethod',
    text: 'Giảng viên có phương pháp truyền đạt tốt, dễ hiểu, hướng dẫn thành thạo, thao tác chuẩn xác, hỗ trợ kịp thời khi người học thực hành.',
    scale: SCALE_5,
  },
  {
    id: 'q6', group: 'scoreMethod',
    text: 'Giảng viên tạo điều kiện cho người học tích cực tham gia thảo luận, phát biểu, nêu câu hỏi trên lớp, kích thích sự dụng não và suy nghĩ sáng tạo.',
    scale: SCALE_5,
  },
  // scoreInteraction (câu 7-8)
  {
    id: 'q7', group: 'scoreInteraction',
    text: 'Giảng viên xử lý tình huống hợp lý, nêu rõ nguyên nhân và cách khắc phục các sự cố, hỏng hóc trong thời gian thực hành.',
    scale: SCALE_5,
  },
  {
    id: 'q8', group: 'scoreInteraction',
    text: 'Giảng viên đối xử nhiệt tình, thân thiện và công bằng trong kiểm tra đánh giá quá trình và kiểm tra đánh giá kết quả học tập của người học.',
    scale: SCALE_5,
  },
  // scoreMaterials (câu 9)
  {
    id: 'q9', group: 'scoreMaterials',
    text: 'Cảm nhận của người học về tiếp thu nội dung và mức độ thành thạo các kỹ năng thực hành.',
    scale: SCALE_5,
  },
  // scorePunctuality (câu 10)
  {
    id: 'q10', group: 'scorePunctuality',
    text: 'Anh/Chị hài lòng như thế nào về chất lượng, hiệu quả giảng dạy, hướng dẫn của giảng viên đối với tiến bộ học tập của bản thân?',
    scale: SCALE_4_FINAL,
  },
];

export default function SurveyDetail({ survey, onBack, onSuccess }) {
  // answers: { q1: null, q2: null, ... }
  const initAnswers = Object.fromEntries(QUESTIONS.map(q => [q.id, null]));
  const [answers, setAnswers] = useState(initAnswers);
  const [comment, setComment] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  const setAnswer = (qId, val) => setAnswers(prev => ({ ...prev, [qId]: val }));

  // Tính trung bình điểm theo nhóm
  const avg = (groupIds) => {
    const vals = groupIds.map(id => answers[id]).filter(v => v !== null);
    if (!vals.length) return null;
    return vals.reduce((a, b) => a + b, 0) / vals.length;
  };

  const handleSubmit = async () => {
    // Kiểm tra đã trả lời hết chưa
    const unanswered = QUESTIONS.filter(q => answers[q.id] === null);
    if (unanswered.length > 0) {
      setError(`Vui lòng trả lời ${unanswered.length} câu hỏi còn lại trước khi nộp.`);
      return;
    }

    setSubmitting(true);
    setError('');
    try {
      await submitSurvey({
        classId: survey.classId,
        scoreKnowledge:   avg(['q1', 'q2', 'q3']),
        scoreMethod:      avg(['q4', 'q5', 'q6']),
        scoreInteraction: avg(['q7', 'q8']),
        scoreMaterials:   avg(['q9']),
        scorePunctuality: avg(['q10']),
        comment,
      });
      onSuccess();
    } catch (err) {
      setError(err.response?.data?.message || 'Đã xảy ra lỗi, vui lòng thử lại.');
      setSubmitting(false);
    }
  };

  return (
    <div className="page active">
      {/* Header */}
      <div className="survey-detail-header">
        <button className="btn btn-outline btn-sm" onClick={onBack} style={{ marginRight: 12 }}>
          ← Quay lại
        </button>
        <div>
          <div className="survey-detail-title">
            PHIẾU THĂM DÒ MỨC HÀI LÒNG CỦA NGƯỜI HỌC VỀ HỌC PHẦN THỰC HÀNH
          </div>
          <div className="survey-detail-sub">
            {survey.courseName} &nbsp;|&nbsp; Lớp: <strong>{survey.classCode}</strong>
            &nbsp;|&nbsp; GV: <strong>{survey.teacherName}</strong>
          </div>
        </div>
      </div>

      {/* Mô tả */}
      <div className="card" style={{ marginBottom: 12, padding: '14px 20px', fontSize: 13, color: 'var(--text-light)', lineHeight: 1.7 }}>
        Để nâng cao chất lượng giảng dạy của giảng viên về các học phần thực hành, Anh/Chị vui lòng đọc kỹ bảng hỏi và cho ý kiến của mình tương ứng với từng câu. Các câu trả lời của mỗi cá nhân sẽ được giữ kín, chúng tôi chỉ công bố kết quả tổng hợp.
      </div>

      {/* Câu hỏi */}
      <div className="card">
        <div style={{ padding: '14px 20px', fontWeight: 700, color: 'var(--blue)', borderBottom: '1px solid var(--border)' }}>
          Câu hỏi khảo sát
        </div>

        {QUESTIONS.map((q, idx) => (
          <div key={q.id} className="survey-question">
            <div className="survey-q-text">
              {idx + 1}. {q.text}
            </div>
            <div className="survey-options">
              {q.scale.map(opt => (
                <label
                  key={opt.value}
                  className={`survey-option ${answers[q.id] === opt.value ? 'selected' : ''}`}
                >
                  <input
                    type="radio"
                    name={q.id}
                    value={opt.value}
                    checked={answers[q.id] === opt.value}
                    onChange={() => setAnswer(q.id, opt.value)}
                  />
                  <span className="survey-radio-circle" />
                  <span className="survey-option-label">{opt.label}</span>
                </label>
              ))}
            </div>
          </div>
        ))}

        {/* Câu 11: góp ý */}
        <div className="survey-question">
          <div className="survey-q-text">
            11. Theo Anh/Chị, để nâng cao hơn nữa chất lượng dạy và học của học phần, cần (góp ý cho GV, góp ý cho Khoa/Bộ môn, góp ý cho người học):
          </div>
          <textarea
            className="survey-textarea form-ctrl"
            rows={4}
            placeholder="Nhập góp ý của bạn tại đây..."
            value={comment}
            onChange={e => setComment(e.target.value)}
          />
        </div>

        {/* Lỗi */}
        {error && (
          <div style={{ margin: '0 20px 16px', background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 8, padding: '10px 14px', color: '#b91c1c', fontSize: 13 }}>
            <AlertTriangle className="w-4 h-4 inline-block mr-2" /> {error}
          </div>
        )}

        {/* Submit */}
        <div style={{ padding: '16px 20px', display: 'flex', justifyContent: 'flex-end', gap: 12, borderTop: '1px solid var(--border)' }}>
          <button className="btn btn-outline" onClick={onBack}>Hủy</button>
          <button className="btn btn-blue" onClick={handleSubmit} disabled={submitting}>
            {submitting ? 'Đang gửi...' : '📩 Nộp phiếu khảo sát'}
          </button>
        </div>

        <div style={{ padding: '0 20px 16px', textAlign: 'center', fontSize: 12, color: 'var(--text-light)', fontStyle: 'italic' }}>
          Trân trọng cảm ơn và chúc Anh/Chị luôn học tốt!
        </div>
      </div>
    </div>
  );
}
