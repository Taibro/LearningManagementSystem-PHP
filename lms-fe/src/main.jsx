import React from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'
import AppSaaS from './SaaSAdminSystem/AppSaaS.jsx'
import AppStudent from './StudentPages/AppStudent.jsx'
import AppAdmin from './SchoolAdmin/AppAdmin.jsx'
import AppLecturer from './LecturerPages/AppLecturer.jsx'

const currentPath = window.location.pathname;
const pathParts = currentPath.split('/').filter(Boolean);

let schoolName = '';
let role = '';

if (pathParts.length >= 2 && !['saas', 'admin', 'school-admin', 'lecturer', 'student'].includes(pathParts[0])) {
  schoolName = pathParts[0];
  role = pathParts[1];
} else if (pathParts.length >= 1) {
  role = pathParts[0];
}

let AppToRender;

if (role === 'saas') {
  AppToRender = <AppSaaS />;
} else if (role === 'admin' || role === 'school-admin') {
  AppToRender = <AppAdmin schoolName={schoolName} roleName={role} />;
} else if (role === 'lecturer') {
  AppToRender = <AppLecturer schoolName={schoolName} />;
} else if (role === 'student') {
  AppToRender = <AppStudent schoolName={schoolName} />;
} else {
  if (schoolName) {
    window.location.replace(`/${schoolName}/student`);
  } else {
    window.location.replace('/HUIT/student');
  }
}

if (AppToRender) {
  ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
      {AppToRender}
    </React.StrictMode>,
  )
}