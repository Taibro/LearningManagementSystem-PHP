export const API_BASE_URL = (
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api'
).replace(/\/+$/, '');

/**
 * Fetch active schools from Backend API for login/register dropdowns.
 */
export async function fetchActiveSchools() {
  try {
    const res = await fetch(`${API_BASE_URL}/schools/active`);
    if (res.ok) {
      return await res.json();
    }
  } catch (err) {
    console.error('Failed to fetch active schools:', err);
  }
  return [
    { id: 1, value: 'HUIT', code: 'HUIT', label: 'Trường ĐH Công Thương TP.HCM (HUIT)' },
    { id: 2, value: 'HCMUT', code: 'HCMUT', label: 'Trường ĐH Bách Khoa TP.HCM (HCMUT)' },
  ];
}

/**
 * Authenticate via Backend API -> Keycloak Direct Access Grant (no browser redirect).
 */
export async function loginViaApi({ loginCode, password, userType, school }) {
  const res = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ loginCode, password, userType, school }),
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data.message || 'Tài khoản hoặc mật khẩu không chính xác.');
  }
  return data;
}

/**
 * Register a new user account via Backend API -> Keycloak Admin REST API + PostgreSQL.
 */
export async function registerViaApi(payload) {
  const res = await fetch(`${API_BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify(payload),
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data.message || 'Đăng ký tài khoản thất bại.');
  }
  return data;
}
