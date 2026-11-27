import React, { useEffect, useState } from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import {
  hasStoredPortalSessionHint,
  isCookieAuthMode,
  verifyOrRefreshPortalSession,
} from '../config/apiConfig';

export default function PortalProtectedRoute({
  portal,
  loginPath = '/login',
  children,
}) {
  const cookieMode = isCookieAuthMode();
  const hasStoredHint = hasStoredPortalSessionHint(portal);

  const [authState, setAuthState] = useState(() => {
    if (hasStoredHint) return 'authenticated';
    return cookieMode ? 'checking' : 'unauthenticated';
  });

  useEffect(() => {
    let isMounted = true;

    if (!hasStoredHint && !cookieMode) {
      return undefined;
    }

    verifyOrRefreshPortalSession(portal).then((result) => {
      if (!isMounted) {
        return;
      }
      setAuthState(result.authenticated ? 'authenticated' : 'unauthenticated');
    });

    return () => {
      isMounted = false;
    };
  }, [portal, hasStoredHint, cookieMode]);

  if (authState === 'checking') {
    return (
      <div
        style={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#64748b',
          fontSize: '14px',
        }}
      >
        Đang xác thực phiên đăng nhập...
      </div>
    );
  }

  if (authState === 'unauthenticated') {
    return <Navigate to={loginPath} replace />;
  }

  return children ?? <Outlet />;
}
