import React, { useEffect, useState } from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import {
  PORTAL_STORAGE_KEYS,
  verifyOrRefreshPortalSession,
} from '../config/apiConfig';

export default function PortalProtectedRoute({
  portal,
  loginPath = '/login',
  children,
}) {
  const storageKeys = PORTAL_STORAGE_KEYS[portal];
  const hasStoredSession = Boolean(
    storageKeys &&
      (localStorage.getItem(storageKeys.tokenKey) ||
        localStorage.getItem(storageKeys.refreshTokenKey))
  );

  const [isAuthenticated, setIsAuthenticated] = useState(hasStoredSession);

  useEffect(() => {
    let isMounted = true;

    if (!hasStoredSession) {
      return undefined;
    }

    verifyOrRefreshPortalSession(portal).then((result) => {
      if (isMounted && !result.authenticated) {
        setIsAuthenticated(false);
      }
    });

    return () => {
      isMounted = false;
    };
  }, [portal, hasStoredSession]);

  if (!hasStoredSession || !isAuthenticated) {
    return <Navigate to={loginPath} replace />;
  }

  return children ?? <Outlet />;
}
