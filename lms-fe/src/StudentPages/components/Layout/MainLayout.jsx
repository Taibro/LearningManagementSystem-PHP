import React from 'react';
import { Outlet } from 'react-router-dom';
import Topbar from './Topbar';
import Sidebar from './Sidebar';

export default function MainLayout() {
  return (
    <div className="student-portal-wrapper">
      <Topbar />
      <div className="layout">
        <Sidebar />
        <main className="main">
         
          <Outlet />
        </main>
      </div>
    </div>
  );
}