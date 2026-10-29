/**
 * Format số sang chuỗi hiển thị có phân cách hàng nghìn (VD: 450000 -> "450.000")
 * @param {number|string} amount
 * @returns {string}
 */
export const formatNumber = (amount) => {
  if (amount == null || isNaN(amount)) return '0';
  return Number(amount).toLocaleString('vi-VN');
};

/**
 * Format số tiền sang định dạng tiền tệ Việt Nam (VNĐ) (VD: 450000 -> "450.000 đ")
 * @param {number|string} amount
 * @returns {string}
 */
export const formatCurrency = (amount) => {
  if (amount == null || isNaN(amount)) return '0 đ';
  return `${Number(amount).toLocaleString('vi-VN')} đ`;
};

/**
 * Format ngày tháng sang định dạng DD/MM/YYYY (VD: "2026-10-29" -> "29/10/2026")
 * @param {string|Date} date
 * @returns {string}
 */
export const formatDate = (date) => {
  if (!date) return '';
  const d = new Date(date);
  if (isNaN(d.getTime())) return String(date);
  return d.toLocaleDateString('vi-VN');
};

// Alias fmt để tương thích đồng bộ với các component tài chính
export const fmt = formatNumber;
