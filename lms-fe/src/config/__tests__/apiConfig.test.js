import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  buildVersionedApiBaseUrl,
  fetchCurrentUser,
  getPortalRequestConfig,
  hasAuthenticatedUserPayload,
  hasStoredPortalSessionHint,
  isRoleAllowedForPortal,
  isSameSiteOrigin,
  loginViaApi,
  logoutPortal,
  logoutViaApi,
  PORTAL_STORAGE_KEYS,
  refreshTokenViaApi,
  resolveAuthMode,
  savePortalSession,
  verifyOrRefreshPortalSession,
} from '../apiConfig';
import {
  isApiRequestUrl,
  isAuthLifecycleUrl,
  sanitizeAuthHeaders,
} from '../httpClient';

function createMemoryStorage() {
  const store = new Map();
  return {
    getItem: (key) => (store.has(key) ? store.get(key) : null),
    setItem: (key, val) => store.set(key, String(val)),
    removeItem: (key) => store.delete(key),
    clear: () => store.clear(),
  };
}

describe('lms-fe Hybrid Auth config & session helpers', () => {
  const originalLocalStorage = globalThis.localStorage;
  const originalFetch = globalThis.fetch;

  beforeEach(() => {
    globalThis.localStorage = createMemoryStorage();
  });

  afterEach(() => {
    globalThis.localStorage = originalLocalStorage;
    globalThis.fetch = originalFetch;
    vi.restoreAllMocks();
  });

  it('normalizes versioned API base URL cleanly', () => {
    expect(buildVersionedApiBaseUrl('http://localhost:8000')).toBe('http://localhost:8000/api/v1');
    expect(buildVersionedApiBaseUrl('https://api.example.com/api')).toBe('https://api.example.com/api/v1');
    expect(buildVersionedApiBaseUrl('https://api.example.com/api/v1/')).toBe('https://api.example.com/api/v1');
  });

  it('detects same-site origins vs cross-site public suffixes and respects explicit overrides', () => {
    expect(isSameSiteOrigin('/api/v1', 'https://lms-fe.pages.dev')).toBe(true);
    expect(isSameSiteOrigin('http://localhost:8000/api/v1', 'http://localhost:5173')).toBe(true);
    expect(isSameSiteOrigin('https://api.huit.edu.vn/api/v1', 'https://app.huit.edu.vn')).toBe(true);
    expect(isSameSiteOrigin('https://lms-dev-api.duckdns.org/api/v1', 'https://lms-fe.pages.dev')).toBe(false);

    expect(resolveAuthMode('http://localhost:8000/api/v1', 'http://localhost:5173', 'auto')).toBe('cookie');
    expect(resolveAuthMode('https://lms-dev-api.duckdns.org/api/v1', 'https://lms-fe.pages.dev', 'auto')).toBe('bearer');
    expect(resolveAuthMode('https://lms-dev-api.duckdns.org/api/v1', 'https://lms-fe.pages.dev', 'cookie')).toBe('cookie');
    expect(resolveAuthMode('http://localhost:8000/api/v1', 'http://localhost:5173', 'bearer')).toBe('bearer');
  });

  it('recognizes authenticated payloads for both cookie mode and bearer mode', () => {
    expect(hasAuthenticatedUserPayload({ token: null, accessToken: null, expiresIn: 900 })).toBe(true);
    expect(hasAuthenticatedUserPayload({ accessToken: 'jwt-abc', expiresIn: null })).toBe(true);
    expect(hasAuthenticatedUserPayload({ token: null, accessToken: null, expiresIn: null })).toBe(false);
    expect(hasAuthenticatedUserPayload(null)).toBe(false);
  });

  it('validates portal roles consistently with backend RBAC', () => {
    expect(isRoleAllowedForPortal({ role: 'STUDENT', roles: ['STUDENT'] }, 'student')).toBe(true);
    expect(isRoleAllowedForPortal({ role: 'LECTURER', roles: ['LECTURER'] }, 'student')).toBe(false);
    expect(isRoleAllowedForPortal({ role: 'DEAN_OF_FACULTY', roles: ['DEAN_OF_FACULTY'] }, 'lecturer')).toBe(true);
    expect(isRoleAllowedForPortal({ role: 'DEAN_OF_FACULTY', roles: ['DEAN_OF_FACULTY'] }, 'admin')).toBe(true);
    expect(isRoleAllowedForPortal({ role: 'SAAS_ADMIN', roles: ['SAAS_ADMIN'] }, 'student')).toBe(true);
    expect(isRoleAllowedForPortal({ role: 'SCHOOL_ADMIN', roles: ['SCHOOL_ADMIN'] }, 'saas')).toBe(false);
  });

  it('strips tokens in localStorage when saving portal session in cookie mode and keeps them in bearer mode', () => {
    localStorage.setItem(PORTAL_STORAGE_KEYS.student.tokenKey, 'old-token');
    localStorage.setItem(PORTAL_STORAGE_KEYS.student.refreshTokenKey, 'old-refresh');

    savePortalSession(
      'student',
      {
        token: 'jwt-should-not-persist',
        accessToken: 'jwt-should-not-persist',
        refreshToken: 'refresh-should-not-persist',
        expiresIn: 900,
        fullName: 'Nguyễn Thành Tài',
        role: 'STUDENT',
        schoolId: 1,
        schoolCode: 'HUIT',
        schoolName: 'ĐH Công Thương',
      },
      null,
      'cookie'
    );

    expect(localStorage.getItem(PORTAL_STORAGE_KEYS.student.tokenKey)).toBeNull();
    expect(localStorage.getItem(PORTAL_STORAGE_KEYS.student.refreshTokenKey)).toBeNull();
    expect(hasStoredPortalSessionHint('student', 'cookie')).toBe(true);
    const savedCookieUser = JSON.parse(localStorage.getItem(PORTAL_STORAGE_KEYS.student.userKey));
    expect(savedCookieUser.accessToken).toBeUndefined();
    expect(savedCookieUser.fullName).toBe('Nguyễn Thành Tài');
    expect(getPortalRequestConfig('student', {}, 'cookie')).toEqual({
      withCredentials: true,
      headers: {},
    });

    savePortalSession(
      'student',
      {
        accessToken: 'jwt-bearer-1',
        refreshToken: 'refresh-bearer-1',
        expiresIn: 900,
        fullName: 'Nguyễn Thành Tài',
      },
      null,
      'bearer'
    );
    expect(localStorage.getItem(PORTAL_STORAGE_KEYS.student.tokenKey)).toBe('jwt-bearer-1');
    expect(getPortalRequestConfig('student', {}, 'bearer')).toEqual({
      withCredentials: true,
      headers: { Authorization: 'Bearer jwt-bearer-1' },
    });
  });

  it('sends credentials=include and X-Auth-Mode=cookie on auth endpoints in cookie mode', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ token: null, accessToken: null, refreshToken: null, expiresIn: 900, role: 'STUDENT' }),
    });
    globalThis.fetch = fetchMock;

    await loginViaApi({ loginCode: '2001230773', password: 'Password@123', school: 'HUIT' }, { authMode: 'cookie' });
    expect(fetchMock).toHaveBeenCalledTimes(1);
    const [loginUrl, loginInit] = fetchMock.mock.calls[0];
    expect(loginUrl).toMatch(/\/auth\/login$/);
    expect(loginInit.credentials).toBe('include');
    expect(loginInit.headers['X-Auth-Mode']).toBe('cookie');

    await refreshTokenViaApi(null, { authMode: 'cookie' });
    const [refreshUrl, refreshInit] = fetchMock.mock.calls[1];
    expect(refreshUrl).toMatch(/\/auth\/refresh$/);
    expect(refreshInit.credentials).toBe('include');
    expect(refreshInit.headers['X-Auth-Mode']).toBe('cookie');
    expect(refreshInit.body).toBe('{}');

    await logoutPortal('student', 'cookie');
    const [logoutUrl, logoutInit] = fetchMock.mock.calls[2];
    expect(logoutUrl).toMatch(/\/auth\/logout$/);
    expect(logoutInit.credentials).toBe('include');
    expect(logoutInit.body).toBe('{}');

    await logoutViaApi('explicit-rt', 'explicit-at', { authMode: 'bearer' });
    const [, bearerLogoutInit] = fetchMock.mock.calls[3];
    expect(bearerLogoutInit.headers.Authorization).toBe('Bearer explicit-at');
    expect(bearerLogoutInit.body).toBe(JSON.stringify({ refreshToken: 'explicit-rt' }));

    await fetchCurrentUser(null, { authMode: 'cookie' });
    const [meUrl, meInit] = fetchMock.mock.calls[4];
    expect(meUrl).toMatch(/\/auth\/me$/);
    expect(meInit.credentials).toBe('include');
    expect(meInit.headers.Authorization).toBeUndefined();
  });

  it('verifies and refreshes cookie session cleanly on 401 and rejects mismatched portal roles', async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce({
        ok: false,
        status: 401,
        json: async () => ({ message: 'Expired' }),
      })
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ token: null, accessToken: null, refreshToken: null, expiresIn: 900 }),
      })
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ id: 5, fullName: 'SV Tài', role: 'STUDENT', roles: ['STUDENT'], schoolId: 1 }),
      });

    globalThis.fetch = fetchMock;

    const okResult = await verifyOrRefreshPortalSession('student', 'cookie');
    expect(okResult.authenticated).toBe(true);
    expect(okResult.user.fullName).toBe('SV Tài');

    const mismatchFetch = vi.fn().mockResolvedValueOnce({
      ok: true,
      status: 200,
      json: async () => ({ id: 3, fullName: 'GV A', role: 'LECTURER', roles: ['LECTURER'], schoolId: 1 }),
    });
    globalThis.fetch = mismatchFetch;

    const deniedResult = await verifyOrRefreshPortalSession('student', 'cookie');
    expect(deniedResult.authenticated).toBe(false);
  });

  it('sanitizes bogus Bearer null/undefined headers without touching real JWT headers', () => {
    expect(sanitizeAuthHeaders({ Authorization: 'Bearer null', Accept: 'application/json' })).toEqual({
      Accept: 'application/json',
    });
    expect(sanitizeAuthHeaders({ Authorization: 'Bearer undefined' })).toEqual({});
    expect(sanitizeAuthHeaders({ Authorization: 'Bearer ' })).toEqual({});
    expect(sanitizeAuthHeaders({ Authorization: 'Bearer real.jwt.token' })).toEqual({
      Authorization: 'Bearer real.jwt.token',
    });

    expect(isApiRequestUrl('/api/v1/student/profile')).toBe(true);
    expect(isApiRequestUrl('https://example.com/public')).toBe(false);
    expect(isAuthLifecycleUrl('http://localhost:8000/api/v1/auth/refresh')).toBe(true);
    expect(isAuthLifecycleUrl('http://localhost:8000/api/v1/auth/me')).toBe(false);
  });
});
