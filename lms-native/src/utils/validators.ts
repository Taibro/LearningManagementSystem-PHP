export interface ValidationResult {
  isValid: boolean;
  message?: string;
}


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


export const validatePassword = (password: string): ValidationResult => {
  if (!password) {
    return { isValid: false, message: 'Vui lòng nhập mật khẩu.' };
  }
  if (password.length < 6) {
    return { isValid: false, message: 'Mật khẩu phải có ít nhất 6 ký tự.' };
  }
  return { isValid: true };
};

