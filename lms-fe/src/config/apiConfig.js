const ENV = typeof import.meta !== 'undefined' && import.meta.env ? import.meta.env : {};

const PUBLIC_MULTI_TENANT_SUFFIXES = [
  'pages.dev',
  'duckdns.org',
  'vercel.app',
  'netlify.app',
  'onrender.com',
  'github.io',
  'workers.dev',
  'herokuapp.com',
  'appspot.com',
];

const TWO_PART_CC_TLDS = [
  'edu.vn',
  'com.vn',
  'org.vn',
  'gov.vn',
  'net.vn',
  'ac.vn',
  'co.uk',
  'org.uk',
  'ac.uk',
  'com.au',
  'net.au',
];

export const API_VERSION =
  (ENV.VITE_API_VERSION || 'v1').trim().replace(/^\/+|\/+$/g, '') || 'v1';

/**
 * Normalize the API base URL so it always targets `/api/{version}` without
 * duplicating `/api/vN` when already included in `.env`.
 *
 * @param {string} rawBaseUrl
 * @param {string} [version]
 * @returns {string}
 */
export function buildVersionedApiBaseUrl(rawBaseUrl, version = 'v1') {
  const cleanVersion =
    (version || 'v1').toString().trim().replace(/^\/+|\/+$/g, '') || 'v1';
  const trimmed = (rawBaseUrl || 'http://localhost:8000')
    .toString()
    .trim()
    .replace(/\/+$/, '');

  if (/\/api\/v\d+$/i.test(trimmed)) {
    return trimmed;
  }
  if (/\/api$/i.test(trimmed)) {
    return `${trimmed}/${cleanVersion}`;
  }
  return `${trimmed}/api/${cleanVersion}`;
}

export const API_BASE_URL = buildVersionedApiBaseUrl(
  ENV.VITE_API_BASE_URL,
  API_VERSION
);

function isIpLiteral(hostname) {
  return /^\d{1,3}(\.\d{1,3}){3}$/.test(hostname) || hostname.includes(':');
}

function extractRegistrableDomain(hostname) {
  const parts = hostname.toLowerCase().split('.').filter(Boolean);
  if (parts.length <= 2) {
    return parts.join('.');
  }

  const lastTwo = parts.slice(-2).join('.');
  if (TWO_PART_CC_TLDS.includes(lastTwo) && parts.length >= 3) {
    return parts.slice(-3).join('.');
  }

  return lastTwo;
}

/**
 * Determine whether the API URL shares the same site (eTLD+1) as the current page
 * so HttpOnly cookies work reliably across Safari ITP, Brave, and Chrome.
 *
 * @param {string} apiUrl
 * @param {string} [pageOrigin]
 * @returns {boolean}
 */
export function isSameSiteOrigin(apiUrl, pageOrigin) {
  if (!apiUrl || typeof apiUrl !== 'string') {
    return false;
  }

  const trimmedApi = apiUrl.trim();
  if (trimmedApi.startsWith('/')) {
    return true;
  }

  const resolvedPageOrigin =
    pageOrigin ??
    (typeof window !== 'undefined' && window.location ? window.location.origin : '');
  if (!resolvedPageOrigin) {
    return false;
  }

  try {
    const apiHost = new URL(trimmedApi).hostname.toLowerCase();
    const pageHost = new URL(resolvedPageOrigin).hostname.toLowerCase();

    if (!apiHost || !pageHost) {
      return false;
    }

    if (apiHost === pageHost) {
      return true;
    }

    if (isIpLiteral(apiHost) || isIpLiteral(pageHost)) {
      return false;
    }

    const usesPublicSuffix = PUBLIC_MULTI_TENANT_SUFFIXES.some(
      (suffix) =>
        apiHost === suffix ||
        apiHost.endsWith(`.${suffix}`) ||
        pageHost === suffix ||
        pageHost.endsWith(`.${suffix}`)
    );

    if (usesPublicSuffix) {
      return false;
    }

    return extractRegistrableDomain(apiHost) === extractRegistrableDomain(pageHost);
  } catch {
    return false;
  }
}

/**
 * Resolve authentication transport mode: `'cookie'` (HttpOnly cookie) or `'bearer'`.
 *
 * @param {string} [apiBaseUrl]
 * @param {string} [pageOrigin]
 * @param {string} [configuredMode]
 * @returns {'cookie'|'bearer'}
 */
export function resolveAuthMode(
  apiBaseUrl = API_BASE_URL,
  pageOrigin = undefined,
  configuredMode = ENV.VITE_AUTH_MODE
) {
  const normalized = (configuredMode || 'auto').toString().trim().toLowerCase();
  if (normalized === 'cookie') {
    return 'cookie';
  }
  if (normalized === 'bearer') {
    return 'bearer';
  }

  return isSameSiteOrigin(apiBaseUrl, pageOrigin) ? 'cookie' : 'bearer';
}

export const AUTH_MODE = resolveAuthMode();

export function isCookieAuthMode(mode = AUTH_MODE) {
  return mode === 'cookie';
}

export function isValidTokenString(token) {
  if (typeof token !== 'string') {
    return false;
  }
  const trimmed = token.trim();
  return trimmed !== '' && trimmed !== 'null' && trimmed !== 'undefined';
}

/**
 * Verify that an auth response represents an authenticated session
 * (supports both Cookie mode where tokens are `null` with `expiresIn` set,
 * and Bearer mode where `accessToken`/`token` is present).
 */
export function hasAuthenticatedUserPayload(data) {
  return Boolean(
    data &&
      (isValidTokenString(data.accessToken) ||
        isValidTokenString(data.token) ||
        data.expiresIn != null)
  );
}

export function isRoleAllowedForPortal(user, portal) {
  const rawRoles = Array.isArray(user?.roles)
    ? user.roles
    : user?.role
      ? [user.role]
      : [];
  const roles = rawRoles
    .map((role) => String(role || '').trim().toUpperCase())
    .filter(Boolean);

  if (roles.length === 0 || roles.includes('SAAS_ADMIN')) {
    return true;
  }

  switch (portal) {
    case 'student':
      return roles.includes('STUDENT');
    case 'lecturer':
      return roles.some((r) =>
        ['LECTURER', 'DEAN_OF_FACULTY', 'DEAN_OF_DEPARTMENT'].includes(r)
      );
    case 'admin':
      return roles.some((r) =>
        ['SCHOOL_ADMIN', 'DEAN_OF_FACULTY', 'DEAN_OF_DEPARTMENT'].includes(r)
      );
    case 'saas':
      return roles.includes('SAAS_ADMIN');
    default:
      return true;
  }
}

function extractErrorMessage(data, fallback) {
  if (typeof data?.message === 'string' && data.message.trim()) {
    return data.message;
  }
  if (data?.errors && typeof data.errors === 'object') {
    const firstError = Object.values(data.errors)
      .flat()
      .find((msg) => typeof msg === 'string' && msg.trim());
    if (firstError) {
      return firstError;
    }
  }
  return fallback;
}

function stripEmptyFields(obj) {
  return Object.fromEntries(
    Object.entries(obj || {}).filter(
      ([, value]) => value !== undefined && value !== null && value !== ''
    )
  );
}

function createApiError(status, message, data) {
  const err = new Error(message);
  err.status = status;
  err.data = data;
  return err;
}

function sanitizeUserMetadata(data) {
  if (!data || typeof data !== 'object') {
    return data;
  }
  const clone = { ...data };
  delete clone.token;
  delete clone.accessToken;
  delete clone.refreshToken;
  return clone;
}

async function requestAuthJson(
  path,
  {
    method = 'POST',
    body,
    accessToken,
    useAuthModeHeader = false,
    authMode = AUTH_MODE,
    fallbackError,
  }
) {
  const headers = { Accept: 'application/json' };
  if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
  }
  if (useAuthModeHeader && isCookieAuthMode(authMode)) {
    headers['X-Auth-Mode'] = 'cookie';
  }
  if (isValidTokenString(accessToken)) {
    headers.Authorization = `Bearer ${accessToken}`;
  }

  const res = await fetch(`${API_BASE_URL}${path}`, {
    method,
    credentials: 'include',
    headers,
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });

  const data = await res.json().catch(() => null);
  if (!res.ok) {
    throw createApiError(
      res.status,
      extractErrorMessage(data, fallbackError),
      data
    );
  }
  return data;
}

/**
 * Fetch active schools from `GET /api/{version}/schools/active`.
 *
 * @returns {Promise<Array<{id: number, value: string, code: string, label: string, name: string}>>}
 */
export async function fetchActiveSchools() {
  try {
    const res = await fetch(`${API_BASE_URL}/schools/active`, {
      credentials: 'include',
      headers: { Accept: 'application/json' },
    });
    if (!res.ok) {
      console.error('Failed to fetch active schools:', res.status);
      return [];
    }
    const data = await res.json().catch(() => []);
    const list = Array.isArray(data)
      ? data
      : Array.isArray(data?.data)
        ? data.data
        : [];
    return list.map((school) => ({
      id: school.id,
      value: school.value || school.code || '',
      code: school.code || school.value || '',
      label: school.label || school.name || school.code || '',
      name: school.name || school.label || '',
    }));
  } catch (err) {
    console.error('Failed to fetch active schools:', err);
    return [];
  }
}

/**
 * Authenticate via `POST /api/{version}/auth/login`.
 */
export async function loginViaApi({ loginCode, password, userType, school }, options = {}) {
  const payload = stripEmptyFields({ loginCode, password, userType, school });
  return requestAuthJson('/auth/login', {
    method: 'POST',
    body: payload,
    useAuthModeHeader: true,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Tài khoản hoặc mật khẩu không chính xác.',
  });
}

/**
 * Register a new account via `POST /api/{version}/auth/register`.
 */
export async function registerViaApi(payload, options = {}) {
  return requestAuthJson('/auth/register', {
    method: 'POST',
    body: stripEmptyFields(payload),
    useAuthModeHeader: true,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Đăng ký tài khoản thất bại.',
  });
}

/**
 * Refresh access token via `POST /api/{version}/auth/refresh`.
 */
export async function refreshTokenViaApi(refreshToken, options = {}) {
  return requestAuthJson('/auth/refresh', {
    method: 'POST',
    body: isValidTokenString(refreshToken) ? { refreshToken } : {},
    useAuthModeHeader: true,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Không thể làm mới phiên đăng nhập.',
  });
}

/**
 * Revoke session via `POST /api/{version}/auth/logout`.
 */
export async function logoutViaApi(refreshToken, accessToken, options = {}) {
  return requestAuthJson('/auth/logout', {
    method: 'POST',
    body: isValidTokenString(refreshToken) ? { refreshToken } : {},
    accessToken,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Đăng xuất thất bại.',
  });
}

/**
 * Fetch current authenticated user via `GET /api/{version}/auth/me`.
 */
export async function fetchCurrentUser(accessToken, options = {}) {
  return requestAuthJson('/auth/me', {
    method: 'GET',
    accessToken,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Không thể xác thực thông tin tài khoản.',
  });
}

/**
 * Request TOTP 2FA QR setup via `POST /api/{version}/auth/2fa/setup`.
 */
export async function setup2faViaApi(email, accessToken, options = {}) {
  return requestAuthJson('/auth/2fa/setup', {
    method: 'POST',
    body: { email },
    accessToken,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Không thể khởi tạo mã QR xác thực 2 bước.',
  });
}

/**
 * Confirm TOTP 2FA setup via `POST /api/{version}/auth/2fa/verify-setup`.
 */
export async function verifySetup2faViaApi(code, accessToken, options = {}) {
  const result = await requestAuthJson('/auth/2fa/verify-setup', {
    method: 'POST',
    body: { code },
    accessToken,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Xác nhận thiết lập 2FA thất bại.',
  });
  return typeof result === 'boolean'
    ? result
    : Boolean(result?.valid ?? result?.success ?? result);
}

/**
 * Verify OTP during 2FA login via `POST /api/{version}/auth/login/verify-2fa`.
 */
export async function verifyLogin2faViaApi({ email, code }, tempToken, options = {}) {
  return requestAuthJson('/auth/login/verify-2fa', {
    method: 'POST',
    body: { email, code },
    accessToken: tempToken,
    authMode: options.authMode ?? AUTH_MODE,
    fallbackError: 'Mã OTP không chính xác hoặc đã hết hạn.',
  });
}

export const PORTAL_STORAGE_KEYS = {
  student: {
    tokenKey: 'token',
    refreshTokenKey: 'refreshToken',
    userKey: 'user',
    expiresAtKey: 'tokenExpiresAt',
    extraKeys: ['role', 'schoolId', 'schoolName', 'schoolShortName'],
  },
  lecturer: {
    tokenKey: 'lecturerToken',
    refreshTokenKey: 'lecturerRefreshToken',
    userKey: 'lecturerUser',
    nameKey: 'lecturerName',
    expiresAtKey: 'lecturerTokenExpiresAt',
    extraKeys: ['schoolId', 'schoolName', 'schoolShortName'],
  },
  admin: {
    tokenKey: 'adminToken',
    refreshTokenKey: 'adminRefreshToken',
    userKey: 'adminUser',
    nameKey: 'adminName',
    emailKey: 'adminEmail',
    expiresAtKey: 'adminTokenExpiresAt',
    extraKeys: [
      'school_token',
      'school_user',
      'schoolId',
      'schoolName',
      'schoolShortName',
    ],
  },
  saas: {
    tokenKey: 'saas_token',
    refreshTokenKey: 'saas_refresh_token',
    userKey: 'saas_user',
    expiresAtKey: 'saasTokenExpiresAt',
    extraKeys: [],
  },
};

/**
 * Build Axios request config for a portal (`withCredentials: true`, plus `Authorization`
 * only when running in bearer mode with a valid token).
 */
export function getPortalRequestConfig(portal, extraHeaders = {}, mode = AUTH_MODE) {
  const headers = { ...extraHeaders };
  const config = PORTAL_STORAGE_KEYS[portal];

  if (!isCookieAuthMode(mode) && config?.tokenKey) {
    const token = localStorage.getItem(config.tokenKey);
    if (isValidTokenString(token)) {
      headers.Authorization = `Bearer ${token}`;
    }
  }

  return {
    withCredentials: true,
    headers,
  };
}

export function hasStoredPortalSessionHint(portal, mode = AUTH_MODE) {
  const config = PORTAL_STORAGE_KEYS[portal];
  if (!config) {
    return false;
  }

  if (isCookieAuthMode(mode)) {
    return Boolean(localStorage.getItem(config.userKey));
  }

  return Boolean(
    isValidTokenString(localStorage.getItem(config.tokenKey)) ||
      isValidTokenString(localStorage.getItem(config.refreshTokenKey))
  );
}

/**
 * Persist login/register session payload into portal-specific localStorage keys.
 * In Cookie auth mode, tokens are never stored in localStorage and stale tokens are purged.
 */
export function savePortalSession(portal, data, selectedSchool = null, mode = AUTH_MODE) {
  const config = PORTAL_STORAGE_KEYS[portal];
  if (!config || !data) {
    return;
  }

  const cookieMode = isCookieAuthMode(mode);
  const accessToken = data.accessToken || data.token || '';

  if (cookieMode) {
    if (config.tokenKey) localStorage.removeItem(config.tokenKey);
    if (config.refreshTokenKey) localStorage.removeItem(config.refreshTokenKey);
    if (portal === 'admin') {
      localStorage.removeItem('school_token');
    }
  } else {
    if (isValidTokenString(accessToken) && config.tokenKey) {
      localStorage.setItem(config.tokenKey, accessToken);
    }
    if (isValidTokenString(data.refreshToken) && config.refreshTokenKey) {
      localStorage.setItem(config.refreshTokenKey, data.refreshToken);
    }
    if (portal === 'admin' && isValidTokenString(accessToken)) {
      localStorage.setItem('school_token', accessToken);
    }
  }

  if (data.expiresIn != null && config.expiresAtKey) {
    localStorage.setItem(
      config.expiresAtKey,
      String(Date.now() + Number(data.expiresIn) * 1000)
    );
  }

  const storedProfile = cookieMode ? sanitizeUserMetadata(data) : data;
  if (config.userKey) {
    localStorage.setItem(config.userKey, JSON.stringify(storedProfile));
  }
  if (portal === 'admin') {
    localStorage.setItem('school_user', JSON.stringify(storedProfile));
  }
  if (config.nameKey && data.fullName) {
    localStorage.setItem(config.nameKey, data.fullName);
  }
  if (config.emailKey && data.email) {
    localStorage.setItem(config.emailKey, data.email);
  }

  if (portal !== 'saas') {
    if (data.schoolId != null) {
      localStorage.setItem('schoolId', String(data.schoolId));
    }
    const resolvedSchoolName =
      data.schoolName || selectedSchool?.label || selectedSchool?.name;
    if (resolvedSchoolName) {
      localStorage.setItem('schoolName', resolvedSchoolName);
    }
    const resolvedSchoolCode =
      data.schoolCode || selectedSchool?.code || selectedSchool?.value;
    if (resolvedSchoolCode) {
      localStorage.setItem('schoolShortName', resolvedSchoolCode);
    }
  }
}

/**
 * Clear only the localStorage keys belonging to the given portal.
 */
export function clearPortalSession(portal) {
  const config = PORTAL_STORAGE_KEYS[portal];
  if (!config) {
    return;
  }

  const keys = [
    config.tokenKey,
    config.refreshTokenKey,
    config.userKey,
    config.nameKey,
    config.emailKey,
    config.expiresAtKey,
    ...(config.extraKeys || []),
  ].filter(Boolean);

  for (const key of keys) {
    localStorage.removeItem(key);
  }
}

/**
 * Revoke Keycloak/backend session and HttpOnly cookies via `/auth/logout`,
 * then clear localStorage metadata for the portal.
 */
export async function logoutPortal(portal, mode = AUTH_MODE) {
  const config = PORTAL_STORAGE_KEYS[portal];
  if (!config) {
    return;
  }

  const accessToken = localStorage.getItem(config.tokenKey) || '';
  const refreshToken = localStorage.getItem(config.refreshTokenKey) || '';

  if (isCookieAuthMode(mode) || isValidTokenString(refreshToken) || isValidTokenString(accessToken)) {
    try {
      await logoutViaApi(refreshToken, accessToken, { authMode: mode });
    } catch (err) {
      console.warn('Logout API warning:', err);
    }
  }

  clearPortalSession(portal);
}

function mergePortalUserProfile(portal, config, me, mode = AUTH_MODE) {
  if (!me) {
    return;
  }

  const sanitizedMe = isCookieAuthMode(mode) ? sanitizeUserMetadata(me) : me;

  if (config.userKey) {
    let existing = {};
    try {
      const raw = localStorage.getItem(config.userKey);
      if (raw) {
        existing = JSON.parse(raw) || {};
      }
    } catch {
      existing = {};
    }
    const merged = isCookieAuthMode(mode)
      ? sanitizeUserMetadata({ ...existing, ...sanitizedMe })
      : { ...existing, ...sanitizedMe };
    localStorage.setItem(config.userKey, JSON.stringify(merged));
    if (portal === 'admin') {
      localStorage.setItem('school_user', JSON.stringify(merged));
    }
  }

  if (config.nameKey && me.fullName) {
    localStorage.setItem(config.nameKey, me.fullName);
  }
  if (config.emailKey && me.email) {
    localStorage.setItem(config.emailKey, me.email);
  }

  if (portal !== 'saas') {
    if (me.schoolId != null) {
      localStorage.setItem('schoolId', String(me.schoolId));
    }
    if (me.schoolName) {
      localStorage.setItem('schoolName', me.schoolName);
    }
    if (me.schoolCode) {
      localStorage.setItem('schoolShortName', me.schoolCode);
    }
  }
}

const inFlightSessionChecks = new Map();

/**
 * Validate the current portal session with `/auth/me`, refreshing via `/auth/refresh` on 401/403.
 * Supports both HttpOnly cookie sessions and Bearer token sessions.
 */
export async function verifyOrRefreshPortalSession(portal, mode = AUTH_MODE) {
  const checkKey = `${portal}:${mode}`;
  if (inFlightSessionChecks.has(checkKey)) {
    return inFlightSessionChecks.get(checkKey);
  }

  const cookieMode = isCookieAuthMode(mode);

  const runCheck = async () => {
    const config = PORTAL_STORAGE_KEYS[portal];
    if (!config) {
      return { authenticated: false };
    }

    const token = cookieMode ? null : localStorage.getItem(config.tokenKey);
    const refreshToken = cookieMode ? null : localStorage.getItem(config.refreshTokenKey);

    if (!cookieMode && !isValidTokenString(token) && !isValidTokenString(refreshToken)) {
      return { authenticated: false };
    }

    const finalizeAuthenticatedUser = (me) => {
      if (!isRoleAllowedForPortal(me, portal)) {
        clearPortalSession(portal);
        return { authenticated: false };
      }

      mergePortalUserProfile(portal, config, me, mode);
      return { authenticated: true, user: me };
    };

    const refreshAndLoadUser = async () => {
      if (!cookieMode && !isValidTokenString(refreshToken)) {
        clearPortalSession(portal);
        return { authenticated: false };
      }

      try {
        const refreshed = await refreshTokenViaApi(refreshToken, { authMode: mode });
        let newToken = null;

        if (!cookieMode) {
          newToken = refreshed?.accessToken || refreshed?.token || '';
          if (!isValidTokenString(newToken)) {
            clearPortalSession(portal);
            return { authenticated: false };
          }

          localStorage.setItem(config.tokenKey, newToken);
          if (portal === 'admin') {
            localStorage.setItem('school_token', newToken);
          }
          if (isValidTokenString(refreshed.refreshToken) && config.refreshTokenKey) {
            localStorage.setItem(config.refreshTokenKey, refreshed.refreshToken);
          }
        } else if (!hasAuthenticatedUserPayload(refreshed)) {
          clearPortalSession(portal);
          return { authenticated: false };
        }

        if (refreshed?.expiresIn != null && config.expiresAtKey) {
          localStorage.setItem(
            config.expiresAtKey,
            String(Date.now() + Number(refreshed.expiresIn) * 1000)
          );
        }

        const me = await fetchCurrentUser(newToken, { authMode: mode });
        return finalizeAuthenticatedUser(me);
      } catch {
        clearPortalSession(portal);
        return { authenticated: false };
      }
    };

    if (!cookieMode && !isValidTokenString(token)) {
      return refreshAndLoadUser();
    }

    try {
      const me = await fetchCurrentUser(token, { authMode: mode });
      return finalizeAuthenticatedUser(me);
    } catch (err) {
      if (err?.status === 401 || err?.status === 403) {
        return refreshAndLoadUser();
      }
      return {
        authenticated: hasStoredPortalSessionHint(portal, mode),
        user: null,
      };
    }
  };

  const promise = runCheck().finally(() => {
    inFlightSessionChecks.delete(checkKey);
  });
  inFlightSessionChecks.set(checkKey, promise);
  return promise;
}
