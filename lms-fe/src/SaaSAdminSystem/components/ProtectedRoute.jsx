import React from 'react';
import PortalProtectedRoute from '../../components/PortalProtectedRoute';

const ProtectedRoute = () => {
  return <PortalProtectedRoute portal="saas" loginPath="/saas/login" />;
};

export default ProtectedRoute;
