import axios from 'axios';
import {
  API_BASE_URL,
  AUTH_MODE,
  PORTAL_STORAGE_KEYS,
  isCookieAuthMode,
  isValidTokenString,
  refreshTokenViaApi,
} from './apiConfig';

const INVALID_BEARER_REGEX = /^Bearer(?:\s+(?:null|undefined))?$/i;
const AUTH_LIFECYCLE_SUFFIXES = [
  '/auth/login',
  '/auth/register',
  '/auth/refresh',
  '/auth/logout',
  '/schools/active',
];

let interceptorsInstalled = false;
let inFlightRefreshPromise = null;

/**
 * Resolve active portal key from current browser pathname.
 *
 * @param {string} [pathname]
 * @returns {'student'|'lecturer'|'admin'|'saas'}
 */
export function resolveActivePortalFromPath(pathname) {
  const path =
    pathname ??
    (typeof window !== 'undefined' && window.location ? window.location.pathname : '');
  const parts = String(path).split('/').filter(Boolean);
  const roleSegment = parts.find((segment) =>
    ['saas', 'admin', 'school-admin', 'lecturer', 'student'].includes(segment)
  );

  if (roleSegment === 'saas') return 'saas';
  if (roleSegment === 'admin' || roleSegment === 'school-admin') return 'admin';
  if (roleSegment === 'lecturer') return 'lecturer';
  return 'student';
}

/**
 * Strip placeholder `Bearer null` / `Bearer undefined` / empty Bearer headers
 * so backend Cookie fallback is never shadowed by malformed headers.
 *
 * @param {Record<string, any>|Headers|undefined} headers
 */
export function sanitizeAuthHeaders(headers) {
  if (!headers) {
    return headers;
  }

  if (typeof Headers !== 'undefined' && headers instanceof Headers) {
    const authValue = headers.get('Authorization');
    if (typeof authValue === 'string' && INVALID_BEARER_REGEX.test(authValue.trim())) {
      headers.delete('Authorization');
    }
    return headers;
  }

  if (typeof headers.get === 'function' && typeof headers.delete === 'function') {
    const authValue = headers.get('Authorization') ?? headers.get('authorization');
    if (typeof authValue === 'string' && INVALID_BEARER_REGEX.test(authValue.trim())) {
      headers.delete('Authorization');
      headers.delete('authorization');
    }
    return headers;
  }

  for (const key of ['Authorization', 'authorization']) {
    if (typeof headers[key] === 'string' && INVALID_BEARER_REGEX.test(headers[key].trim())) {
      delete headers[key];
    }
  }

  return headers;
}

export function isApiRequestUrl(url, apiBaseUrl = API_BASE_URL) {
  if (!url || typeof url !== 'string') {
    return false;
  }
  const trimmed = url.trim();
  if (trimmed.startsWith('/api/')) {
    return true;
  }

  const normalizedBase = apiBaseUrl.replace(/\/+$/, '');
  return trimmed.startsWith(normalizedBase);
}

export function isAuthLifecycleUrl(url) {
  if (!url || typeof url !== 'string') {
    return false;
  }
  const cleanUrl = url.split('?')[0].replace(/\/+$/, '');
  return AUTH_LIFECYCLE_SUFFIXES.some((suffix) => cleanUrl.endsWith(suffix));
}

function setHeaderValue(headers, name, value) {
  if (!headers) {
    return { [name]: value };
  }
  if (typeof Headers !== 'undefined' && headers instanceof Headers) {
    headers.set(name, value);
    return headers;
  }
  if (typeof headers.set === 'function') {
    headers.set(name, value);
    return headers;
  }
  headers[name] = value;
  return headers;
}

function findRefreshCandidate() {
  const activePortal = resolveActivePortalFromPath();
  const candidates = [
    activePortal,
    ...Object.keys(PORTAL_STORAGE_KEYS).filter((k) => k !== activePortal),
  ];

  for (const portal of candidates) {
    const cfg = PORTAL_STORAGE_KEYS[portal];
    const rt = cfg?.refreshTokenKey ? localStorage.getItem(cfg.refreshTokenKey) : null;
    if (isValidTokenString(rt)) {
      return { portal, cfg, refreshToken: rt };
    }
  }

  return null;
}

async function refreshActiveSessionOnce(mode = AUTH_MODE) {
  if (inFlightRefreshPromise) {
    return inFlightRefreshPromise;
  }

  inFlightRefreshPromise = (async () => {
    if (isCookieAuthMode(mode)) {
      await refreshTokenViaApi(null, { authMode: mode });
      return null;
    }

    const candidate = findRefreshCandidate();
    if (!candidate) {
      return null;
    }

    const { portal, cfg, refreshToken } = candidate;
    const refreshed = await refreshTokenViaApi(refreshToken, { authMode: mode });
    const newAccessToken = refreshed?.accessToken || refreshed?.token || '';

    if (isValidTokenString(newTokenOrEmpty(newAccessToken)) && cfg.tokenKey) {
      localStorage.setItem(cfg.tokenKey, newAccessToken);
      if (portal === 'admin') {
        localStorage.setItem('school_token', newAccessToken);
      }
      if (isValidTokenString(refreshed.refreshToken) && cfg.refreshTokenKey) {
        localStorage.setItem(cfg.refreshTokenKey, refreshed.refreshToken);
      }
      if (refreshed.expiresIn != null && cfg.expiresAtKey) {
        localStorage.setItem(
          cfg.expiresAtKey,
          String(Date.now() + Number(refreshed.expiresIn) * 1000)
        );
      }
      return newAccessToken;
    }

    return null;
  })().finally(() => {
    inFlightRefreshPromise = null;
  });

  return inFlightRefreshPromise;
}

function newTokenOrEmpty(value) {
  return typeof value === 'string' ? value : '';
}

/**
 * Install global Axios + fetch interceptors so all legacy portal pages
 * automatically carry HttpOnly cookies, omit bogus Bearer placeholders,
 * and refresh expired sessions cleanly once on 401.
 */
export function setupHttpAuthInterceptors() {
  if (interceptorsInstalled) {
    return;
  }
  interceptorsInstalled = true;

  axios.defaults.withCredentials = true;

  axios.interceptors.request.use((config) => {
    const requestUrl = config.baseURL
      ? `${String(config.baseURL).replace(/\/+$/, '')}/${String(config.url || '').replace(/^\/+/, '')}`
      : String(config.url || '');

    if (isApiRequestUrl(requestUrl)) {
      config.withCredentials = true;
      config.headers = sanitizeAuthHeaders(config.headers);
    }

    return config;
  });

  axios.interceptors.response.use(
    (response) => response,
    async (error) => {
      const original = error?.config;
      const status = error?.response?.status;
      const requestUrl = String(original?.url || '');

      if (
        status !== 401 ||
        !original ||
        original._authRetried ||
        !isApiRequestUrl(requestUrl) ||
        isAuthLifecycleUrl(requestUrl)
      ) {
        return Promise.reject(error);
      }

      original._authRetried = true;
      try {
        const refreshedToken = await refreshActiveSessionOnce();
        if (isValidTokenString(refreshedToken)) {
          original.headers = setHeaderValue(
            original.headers,
            'Authorization',
            `Bearer ${refreshedToken}`
          );
        }
        return axios(original);
      } catch {
        return Promise.reject(error);
      }
    }
  );

  if (typeof window !== 'undefined' && typeof window.fetch === 'function') {
    const originalFetch = window.fetch.bind(window);

    window.fetch = async (input, init = undefined) => {
      const url = typeof input === 'string' ? input : input?.url || '';
      if (!isApiRequestUrl(url)) {
        return originalFetch(input, init);
      }

      const headers = new Headers(
        init?.headers ?? (input instanceof Request ? input.headers : undefined)
      );
      sanitizeAuthHeaders(headers);

      const nextInit = {
        ...init,
        credentials: init?.credentials ?? 'include',
        headers,
      };

      const response = await originalFetch(input, nextInit);
      if (response.status !== 401 || isAuthLifecycleUrl(url)) {
        return response;
      }

      try {
        const refreshedToken = await refreshActiveSessionOnce();
        const retryHeaders = new Headers(headers);
        if (isValidTokenString(refreshedToken)) {
          retryHeaders.set('Authorization', `Bearer ${refreshedToken}`);
        }
        return originalFetch(input, {
          ...nextInit,
          headers: retryHeaders,
        });
      } catch {
        return response;
      }
    };
  }
}
