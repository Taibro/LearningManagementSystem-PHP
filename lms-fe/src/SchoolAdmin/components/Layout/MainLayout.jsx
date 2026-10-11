import React from 'react';
import { Outlet } from 'react-router-dom';
import Topbar from './Topbar';
import Sidebar from './Sidebar';

export default function MainLayout() {
  return (
    <div>
      <Sidebar />
      <Topbar />
      <main className="admin-main">
        <Outlet />
      </main>
    </div>
  );
}
