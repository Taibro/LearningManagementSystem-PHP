/**
 * Format số tiền sang định dạng tiền tệ Việt Nam (VNĐ)
 * @example formatCurrency(450000) => "450.000 đ"
 */
export const formatCurrency = (amount: number | string | null | undefined): string => {
  if (amount == null || amount === '') return '0 đ';
  const num = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (isNaN(num)) return '0 đ';
  return `${num.toLocaleString('vi-VN')} đ`;
};

/**
 * Format số sang chuỗi hiển thị có dấu phân cách hàng nghìn
 * @example formatNumber(1250000) => "1.250.000"
 */
export const formatNumber = (num: number | string | null | undefined): string => {
  if (num == null || num === '') return '0';
  const n = typeof num === 'string' ? parseFloat(num) : num;
  if (isNaN(n)) return '0';
  return n.toLocaleString('vi-VN');
};

/**
 * Format ngày tháng sang định dạng DD/MM/YYYY
 * @example formatDate("2026-10-30") => "30/10/2026"
 */
export const formatDate = (date: string | Date | null | undefined): string => {
  if (!date) return '';
  const d = typeof date === 'string' ? new Date(date) : date;
  if (isNaN(d.getTime())) return String(date);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = d.getFullYear();
  return `${day}/${month}/${year}`;
};

/**
 * Format điểm số thang 10 hoặc thang 4 (lấy 1-2 chữ số thập phân)
 * @example formatScore(8.55) => "8.6"
 */
export const formatScore = (score: number | string | null | undefined, decimals = 1): string => {
  if (score == null || score === '') return '—';
  const s = typeof score === 'string' ? parseFloat(score) : score;
  if (isNaN(s)) return '—';
  return s.toFixed(decimals);
};

/**
 * Phân loại học lực theo GPA thang 4.0
 */
export const getGradeClassification = (gpa: number): string => {
  if (gpa >= 3.6) return 'Xuất sắc';
  if (gpa >= 3.2) return 'Giỏi';
  if (gpa >= 2.5) return 'Khá';
  if (gpa >= 2.0) return 'Trung bình';
  return 'Yếu';
};

