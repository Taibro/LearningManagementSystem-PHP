import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './styles/student.css'; 

import MainLayout from './components/Layout/MainLayout';
import ProtectedRoute from './components/ProtectedRoute';

// ── BARREL IMPORTS THEO TỪNG MODULE NGHIỆP VỤ ──────────────────────────────
import { StudentLogin } from './pages/Auth';
import { Dashboard } from './pages/Dashboard';
import { WeeklySchedule, ProgressSchedule, Attendance } from './pages/Schedule';
import { Curriculum, CourseRegistration } from './pages/Academics';
import { 
  TuitionFee, 
  OnlinePayment, 
  PaymentProcessing, 
  Receipts as OnlineReceipts, 
  GeneralReceipts 
} from './pages/Finance';
import { Grades, ConductScore, Scholarships } from './pages/Results';
import { StudentInfo, StudentDeclaration } from './pages/Profile';
import { Notifications, Surveys, DefaultPage } from './pages/Utilities';

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
