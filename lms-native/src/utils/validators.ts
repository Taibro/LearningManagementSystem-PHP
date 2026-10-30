export interface ValidationResult {
  isValid: boolean;
  message?: string;
}

/**
 * Kiểm tra tính hợp lệ của Mã số sinh viên
 */
export const validateStudentCode = (code: string): ValidationResult => {
  const trimmed = code.trim();
  if (!trimmed) {
    return { isValid: false, message: 'Vui lòng nhập Mã số sinh viên.' };
  }
  if (trimmed.length < 5) {
    return { isValid: false, message: 'Mã số sinh viên không hợp lệ (tối thiểu 5 ký tự).' };
  }
  return { isValid: true };
};

/**
 * Kiểm tra tính hợp lệ của mật khẩu
 */
export const validatePassword = (password: string): ValidationResult => {
  if (!password) {
    return { isValid: false, message: 'Vui lòng nhập mật khẩu.' };
  }
  if (password.length < 6) {
    return { isValid: false, message: 'Mật khẩu phải có ít nhất 6 ký tự.' };
  }
  return { isValid: true };
};

