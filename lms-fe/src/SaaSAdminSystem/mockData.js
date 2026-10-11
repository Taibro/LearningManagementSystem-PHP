export const TENANTS = [
  { id:1, name:'ĐH Bách Khoa TP.HCM', code:'HCMUT', type:'university', plan:'Enterprise', students:18420, teachers:1240, storage:'312GB', expires:'2025-09-01', active:true, email:'it@hcmut.edu.vn' },
  { id:2, name:'ĐH Kinh tế Quốc dân', code:'NEU', type:'university', plan:'Enterprise', students:21000, teachers:1380, storage:'480GB', expires:'2025-05-04', active:true, email:'admin@neu.edu.vn' },
  { id:3, name:'CĐ FPT Polytechnic', code:'FPOLY', type:'college', plan:'Pro', students:4100, teachers:290, storage:'87GB', expires:'2025-06-18', active:true, email:'admin@fpt.edu.vn' },
  { id:4, name:'TT Ngoại ngữ IELTS Pro', code:'IELTS_PRO', type:'language_center', plan:'Pro', students:620, teachers:42, storage:'15GB', expires:'2025-05-14', active:true, email:'hi@ieltspro.vn' },
  { id:5, name:'THPT Chuyên Lê Hồng Phong', code:'LHP', type:'high_school', plan:'Starter', students:890, teachers:78, storage:'8.2GB', expires:'2025-06-28', active:true, email:'admin@lhp.edu.vn' },
  { id:6, name:'TT Gia sư Học Mãi', code:'HOCMAI', type:'tutoring_center', plan:'Starter', students:430, teachers:55, storage:'4.1GB', expires:'2025-04-10', active:false, email:'contact@hocmai.vn' },
  { id:7, name:'ĐH Sư phạm TP.HCM', code:'HCMUE', type:'university', plan:'Enterprise', students:9800, teachers:620, storage:'198GB', expires:'2025-12-01', active:true, email:'admin@hcmue.edu.vn' },
  { id:8, name:'Viện Đại học Mở HN', code:'VDHMHN', type:'university', plan:'Pro', students:3200, teachers:185, storage:'62GB', expires:'2025-08-15', active:true, email:'admin@vdmhn.edu.vn' },
];

export const INVOICES = [
  { id:'INV-0124', school:'ĐH Bách Khoa HCM', plan:'Enterprise', cycle:'yearly', amount:'₫150,000,000', method:'bank_transfer', date:'2025-01-15', status:'paid' },
  { id:'INV-0125', school:'ĐH Kinh tế Quốc dân', plan:'Enterprise', cycle:'monthly', amount:'₫12,500,000', method:'momo', date:'2025-05-01', status:'pending' },
  { id:'INV-0126', school:'CĐ FPT Polytechnic', plan:'Pro', cycle:'monthly', amount:'₫5,800,000', method:'vnpay', date:'2025-05-01', status:'paid' },
  { id:'INV-0127', school:'TT IELTS Pro', plan:'Pro', cycle:'monthly', amount:'₫5,800,000', method:'momo', date:'2025-04-15', status:'pending' },
  { id:'INV-0128', school:'THPT Lê Hồng Phong', plan:'Starter', cycle:'yearly', amount:'₫15,000,000', method:'bank_transfer', date:'2025-05-02', status:'paid' },
  { id:'INV-0129', school:'TT Gia sư Học Mãi', plan:'Starter', cycle:'monthly', amount:'₫1,500,000', method:'cash', date:'2025-04-10', status:'failed' },
  { id:'INV-0130', school:'ĐH Sư phạm HCM', plan:'Enterprise', cycle:'yearly', amount:'₫120,000,000', method:'bank_transfer', date:'2025-05-03', status:'paid' },
];

export const LOGS = [
  { id:4729, endpoint:'POST /api/v1/enrollments', error:'Duplicate entry for student_id+class_id', school:'ĐH Bách Khoa HCM', time:'2025-05-10 14:32:18', resolved:false },
  { id:4728, endpoint:'GET /api/v1/schedules/weekly', error:'NullPointerException at ScheduleService.java:142', school:'ĐH Kinh tế QD', time:'2025-05-10 11:08:44', resolved:false },
  { id:4727, endpoint:'POST /api/v1/salary/generate', error:'salary_grade_id not found for degree=PGS.TS', school:'ĐH Sư phạm HCM', time:'2025-05-10 09:21:03', resolved:false },
  { id:4726, endpoint:'PUT /api/v1/classes/471/status', error:'Foreign key constraint fails on teacher_id', school:'CĐ FPT Poly', time:'2025-05-09 17:55:12', resolved:true },
  { id:4725, endpoint:'GET /api/v1/reports/attendance', error:'Query timeout after 30s', school:'ĐH Bách Khoa HCM', time:'2025-05-09 14:01:09', resolved:true },
  { id:4724, endpoint:'POST /api/v1/auth/login', error:'Too many login attempts from 118.70.x.x', school:'IELTS Pro', time:'2025-05-08 22:14:37', resolved:true },
];

export const AUDITS = [
  { time:'2025-05-10 15:44:22', user:'admin.hcmut@edu.vn', school:'ĐH Bách Khoa HCM', action:'UPDATE', table:'classes', record:471, ip:'203.113.x.x' },
  { time:'2025-05-10 14:30:11', user:'gv.nguyen@neu.edu.vn', school:'ĐH Kinh tế QD', action:'INSERT', table:'attendance_records', record:98234, ip:'14.225.x.x' },
  { time:'2025-05-10 13:22:09', user:'admin@lhp.edu.vn', school:'THPT Lê Hồng Phong', action:'DELETE', table:'schedule_exceptions', record:312, ip:'27.72.x.x' },
  { time:'2025-05-10 11:05:38', user:'admin@hcmut.edu.vn', school:'ĐH Bách Khoa HCM', action:'LOGIN', table:'users', record:1, ip:'203.113.x.x' },
  { time:'2025-05-10 09:48:14', user:'admin.fpoly@fpt.edu.vn', school:'CĐ FPT Poly', action:'UPDATE', table:'salary_grade', record:5, ip:'117.4.x.x' },
  { time:'2025-05-09 22:31:07', user:'gv.tran@ieltspro.vn', school:'TT IELTS Pro', action:'INSERT', table:'class_materials', record:1041, ip:'118.70.x.x' },
];