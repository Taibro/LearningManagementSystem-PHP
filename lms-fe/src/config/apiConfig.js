const ENV = typeof import.meta !== 'undefined' && import.meta.env ? import.meta.env : {};

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

async function requestAuthJson(
  path,
  { method = 'POST', body, accessToken, fallbackError }
) {
  const headers = { Accept: 'application/json' };
  if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
  }
  if (accessToken) {
    headers.Authorization = `Bearer ${accessToken}`;
  }

  const res = await fetch(`${API_BASE_URL}${path}`, {
    method,
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
export async function loginViaApi({ loginCode, password, userType, school }) {
  const payload = stripEmptyFields({ loginCode, password, userType, school });
  return requestAuthJson('/auth/login', {
    method: 'POST',
    body: payload,
    fallbackError: 'Tài khoản hoặc mật khẩu không chính xác.',
  });
}

/**
 * Register a new account via `POST /api/{version}/auth/register`.
 */
export async function registerViaApi(payload) {
  return requestAuthJson('/auth/register', {
    method: 'POST',
    body: stripEmptyFields(payload),
    fallbackError: 'Đăng ký tài khoản thất bại.',
  });
}

/**
 * Refresh access token via `POST /api/{version}/auth/refresh`.
 */
export async function refreshTokenViaApi(refreshToken) {
  return requestAuthJson('/auth/refresh', {
    method: 'POST',
    body: { refreshToken },
    fallbackError: 'Không thể làm mới phiên đăng nhập.',
  });
}

/**
 * Revoke session via `POST /api/{version}/auth/logout`.
 */
export async function logoutViaApi(refreshToken, accessToken) {
  return requestAuthJson('/auth/logout', {
    method: 'POST',
    body: { refreshToken: refreshToken || '' },
    accessToken,
    fallbackError: 'Đăng xuất thất bại.',
  });
}

/**
 * Fetch current authenticated user via `GET /api/{version}/auth/me`.
 */
export async function fetchCurrentUser(accessToken) {
  return requestAuthJson('/auth/me', {
    method: 'GET',
    accessToken,
    fallbackError: 'Không thể xác thực thông tin tài khoản.',
  });
}

/**
 * Request TOTP 2FA QR setup via `POST /api/{version}/auth/2fa/setup`.
 */
export async function setup2faViaApi(email, accessToken) {
  return requestAuthJson('/auth/2fa/setup', {
    method: 'POST',
    body: { email },
    accessToken,
    fallbackError: 'Không thể khởi tạo mã QR xác thực 2 bước.',
  });
}

/**
 * Confirm TOTP 2FA setup via `POST /api/{version}/auth/2fa/verify-setup`.
 */
export async function verifySetup2faViaApi(code, accessToken) {
  const result = await requestAuthJson('/auth/2fa/verify-setup', {
    method: 'POST',
    body: { code },
    accessToken,
    fallbackError: 'Xác nhận thiết lập 2FA thất bại.',
  });
  return typeof result === 'boolean'
    ? result
    : Boolean(result?.valid ?? result?.success ?? result);
}

/**
 * Verify OTP during 2FA login via `POST /api/{version}/auth/login/verify-2fa`.
 */
export async function verifyLogin2faViaApi({ email, code }, tempToken) {
  return requestAuthJson('/auth/login/verify-2fa', {
    method: 'POST',
    body: { email, code },
    accessToken: tempToken,
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
 * Persist login/register session payload into portal-specific localStorage keys.
 */
export function savePortalSession(portal, data, selectedSchool = null) {
  const config = PORTAL_STORAGE_KEYS[portal];
  if (!config || !data) {
    return;
  }

  const accessToken = data.accessToken || data.token || '';
  if (accessToken) {
    localStorage.setItem(config.tokenKey, accessToken);
  }
  if (data.refreshToken) {
    localStorage.setItem(config.refreshTokenKey, data.refreshToken);
  }
  if (data.expiresIn != null && config.expiresAtKey) {
    localStorage.setItem(
      config.expiresAtKey,
      String(Date.now() + Number(data.expiresIn) * 1000)
    );
  }
  if (config.userKey) {
    localStorage.setItem(config.userKey, JSON.stringify(data));
  }
  if (config.nameKey && data.fullName) {
    localStorage.setItem(config.nameKey, data.fullName);
  }
  if (config.emailKey && data.email) {
    localStorage.setItem(config.emailKey, data.email);
  }

  if (portal === 'admin') {
    if (accessToken) {
      localStorage.setItem('school_token', accessToken);
    }
    localStorage.setItem('school_user', JSON.stringify(data));
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
 * Revoke Keycloak/backend session via `/auth/logout` and clear local storage for the portal.
 */
export async function logoutPortal(portal) {
  const config = PORTAL_STORAGE_KEYS[portal];
  if (!config) {
    return;
  }

  const accessToken = localStorage.getItem(config.tokenKey) || '';
  const refreshToken = localStorage.getItem(config.refreshTokenKey) || '';

  if (refreshToken || accessToken) {
    try {
      await logoutViaApi(refreshToken, accessToken);
    } catch (err) {
      console.warn('Logout API warning:', err);
    }
  }

  clearPortalSession(portal);
}

function mergePortalUserProfile(portal, config, me) {
  if (!me) {
    return;
  }

  let existing = {};
  if (config.userKey) {
    try {
      const raw = localStorage.getItem(config.userKey);
      if (raw) {
        existing = JSON.parse(raw) || {};
      }
    } catch {
      existing = {};
    }
    const merged = { ...existing, ...me };
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
 * Does not wipe localStorage on transient network/5xx errors.
 */
export async function verifyOrRefreshPortalSession(portal) {
  if (inFlightSessionChecks.has(portal)) {
    return inFlightSessionChecks.get(portal);
  }

  const runCheck = async () => {
    const config = PORTAL_STORAGE_KEYS[portal];
    if (!config) {
      return { authenticated: false };
    }

    const token = localStorage.getItem(config.tokenKey);
    const refreshToken = localStorage.getItem(config.refreshTokenKey);
    if (!token && !refreshToken) {
      return { authenticated: false };
    }

    const refreshAndLoadUser = async () => {
      if (!refreshToken) {
        clearPortalSession(portal);
        return { authenticated: false };
      }

      try {
        const refreshed = await refreshTokenViaApi(refreshToken);
        const newToken = refreshed?.accessToken || refreshed?.token || '';
        if (!newToken) {
          clearPortalSession(portal);
          return { authenticated: false };
        }

        localStorage.setItem(config.tokenKey, newToken);
        if (portal === 'admin') {
          localStorage.setItem('school_token', newToken);
        }
        if (refreshed.refreshToken) {
          localStorage.setItem(config.refreshTokenKey, refreshed.refreshToken);
        }
        if (refreshed.expiresIn != null && config.expiresAtKey) {
          localStorage.setItem(
            config.expiresAtKey,
            String(Date.now() + Number(refreshed.expiresIn) * 1000)
          );
        }

        const me = await fetchCurrentUser(newToken);
        mergePortalUserProfile(portal, config, me);
        return { authenticated: true, user: me };
      } catch {
        clearPortalSession(portal);
        return { authenticated: false };
      }
    };

    if (!token) {
      return refreshAndLoadUser();
    }

    try {
      const me = await fetchCurrentUser(token);
      mergePortalUserProfile(portal, config, me);
      return { authenticated: true, user: me };
    } catch (err) {
      if (err?.status === 401 || err?.status === 403) {
        return refreshAndLoadUser();
      }
      return { authenticated: true, user: null };
    }
  };

  const promise = runCheck().finally(() => {
    inFlightSessionChecks.delete(portal);
  });
  inFlightSessionChecks.set(portal, promise);
  return promise;
}
