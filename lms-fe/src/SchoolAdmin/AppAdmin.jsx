import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './admin.css';

import AdminLogin from './pages/Login/AdminLogin';
// import SaaSAdminLogin from '../SaaSAdminSystem/pages/Login/SaaSAdminLogin';
import MainLayout from './components/Layout/MainLayout';
import Dashboard from './pages/Dashboard/Dashboard';
import BranchesRooms from './pages/BranchesRooms/BranchesRooms';
import Departments from './pages/Departments/Departments';
import Semesters from './pages/Semesters/Semesters';
import Courses from './pages/Courses/Courses';
import Classes from './pages/Classes/Classes';
import Schedule from './pages/Schedule/Schedule';
import Exceptions from './pages/Exceptions/Exceptions';
import Teachers from './pages/Teachers/Teachers';
import Students from './pages/Students/Students';
import Users from './pages/Users/Users';
import Enrollments from './pages/Enrollments/Enrollments';
import Attendance from './pages/Attendance/Attendance';
import Grades from './pages/Grades/Grades';
import Tuition from './pages/Tuition/Tuition';
import Payments from './pages/Payments/Payments';
import Notifications from './pages/Notifications/Notifications';
import Settings from './pages/Settings/Settings';

const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem('adminToken');
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return children;
};

export default function AppAdmin({ schoolName, roleName }) {
  const basename = schoolName ? `/${schoolName}/${roleName}` : `/${roleName}`;
  return (
    <Router basename={basename}>
      <Routes>
        <Route path="/login" element={<AdminLogin initialSchool={schoolName} />} />
        
        <Route path="/" element={
          <ProtectedRoute>
            <MainLayout />
          </ProtectedRoute>
        }>
          <Route index element={<Navigate to="dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="branches" element={<BranchesRooms />} />
          <Route path="departments" element={<Departments />} />
          <Route path="semesters" element={<Semesters />} />
          <Route path="courses" element={<Courses />} />
          <Route path="classes" element={<Classes />} />
          <Route path="schedule" element={<Schedule />} />
          <Route path="exceptions" element={<Exceptions />} />
          <Route path="teachers" element={<Teachers />} />
          <Route path="students" element={<Students />} />
          <Route path="users" element={<Users />} />
          <Route path="enrollments" element={<Enrollments />} />
          <Route path="attendance" element={<Attendance />} />
          <Route path="grades" element={<Grades />} />
          <Route path="tuition" element={<Tuition />} />
          <Route path="payments" element={<Payments />} />
          <Route path="notifications" element={<Notifications />} />
          <Route path="settings" element={<Settings />} />
        </Route>
      </Routes>
    </Router>
  );
}
