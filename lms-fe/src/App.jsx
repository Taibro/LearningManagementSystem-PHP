import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import MainLayout from './components/Layout/MainLayout';

import Dashboard from './pages/Dashboard/Dashboard';
import Profile from './pages/Profile/Profile';
import Salary from './pages/Salary/Salary';
import Declaration from './pages/Declaration/Declaration';
import Documents from './pages/Documents/Documents';

import StudentAttendance from './pages/Attendance/StudentAttendance';
import QRCodeAttendance from './pages/Attendance/QRCodeAttendance';
import Assesment from './pages/Attendance/Assesment';

import Results from './pages/Results/Results';
import ProgressSchedule from './pages/Schedule/ProgressSchedule';
import WeeklySchedule from './pages/Schedule/WeeklySchedule';

import StopTeaching from './pages/Proposals/StopTeaching';
import MakeupTeaching from './pages/Proposals/MakeupTeaching';
import SubstituteTeaching from './pages/Proposals/SubstituteTeaching';

import Statistics from './pages/Statistics/Statistics';
import Survey from './pages/Survey/Survey';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<MainLayout />}>


          <Route index element={<Navigate to="/weekly-schedule" />} />

          <Route path="dashboard" element={<Dashboard />} />
          <Route path="profile" element={<Profile />} />
          <Route path="salary" element={<Salary />} />
          <Route path="declaration" element={<Declaration />} />
          <Route path="documents" element={<Documents />} />

          <Route path="attendance" element={<StudentAttendance />} />
          <Route path="qr-code" element={<QRCodeAttendance />} />
          <Route path="assessment" element={<Assesment />} />

          <Route path="results" element={<Results />} />
          <Route path="progress-schedule" element={<ProgressSchedule />} />
          <Route path="weekly-schedule" element={<WeeklySchedule />} />

          <Route path="stop-teaching" element={<StopTeaching />} />
          <Route path="makeup-teaching" element={<MakeupTeaching />} />
          <Route path="substitute-teaching" element={<SubstituteTeaching />} />

          <Route path="statistics" element={<Statistics />} />
          <Route path="survey" element={<Survey />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;