import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './student.css'; 

import MainLayout from './components/Layout/MainLayout';
import Dashboard from './pages/Dashboard/Dashboard';
import StudentInfo from './pages/StudentInfo/StudentInfo';
import Notifications from './pages/Notifications/Notifications';
import Surveys from './pages/Surveys/Surveys';
import Grades from './pages/Grades/Grades';
import WeeklySchedule from './pages/WeeklySchedule/WeeklySchedule';
import ProgressSchedule from './pages/ProgressSchedule/ProgressSchedule';
import Attendance from './pages/Attendance/Attendance';
import ConductScore from './pages/ConductScore/ConductScore';
import Scholarships from './pages/Scholarships/Scholarships';
import Curriculum from './pages/Curriculum/Curriculum';
import TuitionFee from './pages/TuitionFee/TuitionFee';
import OnlinePayment from './pages/OnlinePayment/OnlinePayment';
import PaymentProcessing from './pages/OnlinePayment/PaymentProcessing';
import GeneralReceipts from './pages/GeneralReceipts/GeneralReceipts';
import OnlineReceipts from './pages/OnlinePayment/Receipts';
import DefaultPage from './pages/DefaultPage/DefaultPage';
import CourseRegistration from './pages/CourseRegistration/CourseRegistration';
import StudentDeclaration from './pages/Declaration/StudentDeclaration';
import StudentLogin from './pages/Login/StudentLogin';

// Component Bảo vệ: Chưa có token thì bắt quay lại trang login
const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem('token');
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return children;
};

export default function AppStudent({ schoolName }) {
  const basename = schoolName ? `/${schoolName}/student` : '/student';
  return (
    <Router basename={basename}>
      <Routes>
        <Route path="/login" element={<StudentLogin initialSchool={schoolName} />} />
        
        <Route path="/" element={
          <ProtectedRoute>
            <MainLayout />
          </ProtectedRoute>
        }>
          
          <Route index element={<Navigate to="/dashboard" />} />

          <Route path="dashboard" element={<Dashboard />} />
          <Route path="student-info" element={<StudentInfo />} />
          <Route path="notifications" element={<Notifications />} />
          <Route path="surveys" element={<Surveys />} />
          <Route path="grades" element={<Grades />} />
          <Route path="weekly-schedule" element={<WeeklySchedule />} />
          <Route path="progress-schedule" element={<ProgressSchedule />} />
          <Route path="attendance" element={<Attendance />} />
          <Route path="conduct-score" element={<ConductScore />} />
          <Route path="scholarships" element={<Scholarships />} />
          <Route path="curriculum" element={<Curriculum />} />
          <Route path="tuition-fee" element={<TuitionFee />} />
          <Route path="online-payment" element={<OnlinePayment />} />
          <Route path="payment-processing/:id" element={<PaymentProcessing />} />
          <Route path="online-receipts" element={<OnlineReceipts />} />
          <Route path="student/course-registration" element={<CourseRegistration />} />

          
          <Route path="declaration" element={<StudentDeclaration />} />
          <Route path="services" element={<DefaultPage title="Dịch vụ trực tuyến" />} />
          <Route path="certificates" element={<DefaultPage title="Đề xuất chứng chỉ" />} />
          <Route path="student-profile" element={<DefaultPage title="Hồ sơ sinh viên" />} />
          <Route path="certificate-approval" element={<DefaultPage title="Đề xuất xét cấp chứng chỉ SV" />} />
          <Route path="graduation-approval" element={<DefaultPage title="Đề xuất xét tốt nghiệp" />} />
          <Route path="bachelor-registration" element={<DefaultPage title="Đăng ký CT Cử nhân/Kỹ sư" />} />
          
          <Route path="prerequisite-registration" element={<DefaultPage title="Đăng ký môn học điều kiện" />} />
        </Route>

      </Routes>
    </Router>
  );
}