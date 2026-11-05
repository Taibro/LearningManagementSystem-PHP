import { 
  StudentProfile, 
  StudentOverview, 
  ScheduleItem, 
  SemesterSummary, 
  ConductScore, 
  Transaction, 
  Receipt, 
  NewsItem, 
  SurveyItem,
  CurriculumSemester,
  AttendanceCourseStat,
  AchievementItem
} from '../types/student.types';

export const mockStudentProfile: StudentProfile = {
  studentCode: '2001210001',
  fullName: 'Nguyễn Thành Tài',
  email: '2001210001@huit.edu.vn',
  phone: '0987654321',
  gender: 'MALE',
  birthDate: '15/08/2003',
  idCard: '079203001234',
  birthPlace: 'TP. Hồ Chí Minh',
  className: '12DHTH01',
  majorName: 'Công nghệ thông tin',
  facultyName: 'Khoa Công nghệ thông tin',
  enrollmentYear: '2023 - 2027',
  trainingDuration: 4.0,
  yearLevel: 3,
};

export const mockStudentOverview: StudentOverview = {
  fullName: 'Nguyễn Thành Tài',
  yearLevel: 3,
  academicYear: '2023 - 2027',
  trainingDuration: 4.0,
  gpa4: 3.54,
  gpa10: 8.29,
  classification: 'Xuất sắc',
  creditsRegistered: 88,
  creditsAccumulated: 85,
  creditsDebt: 0,
  percentDebt: 0.0,
  creditsRequired: 151.0,
};

export const mockNextClass: ScheduleItem = {
  id: 'current-1',
  subjectName: 'Thực hành phân tích thiết kế hệ thống',
  classCode: '12DHTH01_HP02',
  period: 'Tiết 7 - 11 (12:30 - 16:45)',
  room: 'A110 - Phòng máy tính (140 Lê Trọng Tấn)',
  lecturer: 'ThS. Đặng Đức Trung',
  date: '2026-04-20',
  type: 'practice',
};

export const mockWeeklySchedule: ScheduleItem[] = [
  {
    id: 'sch-1',
    subjectName: 'Thực hành phân tích thiết kế hệ thống',
    classCode: '12DHTH01_HP02',
    period: 'Tiết 7 - 11 (12:30 - 16:45)',
    room: 'A110 - Phòng máy tính - 140 Lê Trọng Tấn',
    lecturer: 'ThS. Đặng Đức Trung',
    date: '2026-04-20',
    type: 'practice',
  },
  {
    id: 'sch-2',
    subjectName: 'Khai phá dữ liệu',
    classCode: '12DHTH02',
    period: 'Tiết 1 - 3 (07:00 - 09:15)',
    room: 'A301 - 140 Lê Trọng Tấn',
    lecturer: 'TS. Nguyễn Minh Tuấn',
    date: '2026-04-20',
    type: 'online',
  },
  {
    id: 'sch-3',
    subjectName: 'Lập trình Web nâng cao',
    classCode: '12DHTH01',
    period: 'Tiết 4 - 6 (09:30 - 11:45)',
    room: 'B102 - 140 Lê Trọng Tấn',
    lecturer: 'ThS. Trần Thị Mai',
    date: '2026-04-20',
    type: 'theory',
  },
  {
    id: 'sch-4',
    subjectName: 'Công nghệ Java',
    classCode: '12DHTH03',
    period: 'Tiết 1 - 3 (07:00 - 09:15)',
    room: 'A202 - Phòng máy tính',
    lecturer: 'ThS. Nguyễn Văn An',
    date: '2026-04-21',
    type: 'practice',
  },
  {
    id: 'sch-5',
    subjectName: 'Mạng máy tính',
    classCode: '12DHTH01',
    period: 'Tiết 4 - 6 (09:30 - 11:45)',
    room: 'B301 - 140 Lê Trọng Tấn',
    lecturer: 'TS. Lê Văn Bình',
    date: '2026-04-22',
    type: 'theory',
  },
  {
    id: 'sch-6',
    subjectName: 'Trí tuệ nhân tạo',
    classCode: '12DHTH01',
    period: 'Tiết 10 - 12 (15:00 - 17:15)',
    room: 'B101 - 140 Lê Trọng Tấn',
    lecturer: 'TS. Hoàng Văn Em',
    date: '2026-04-23',
    type: 'theory',
  },
  {
    id: 'sch-7',
    subjectName: 'Kiến trúc máy tính & Vi xử lý',
    classCode: '12DHTH01',
    period: 'Tiết 1 - 3 (07:00 - 09:15)',
    room: 'B203 - 140 Lê Trọng Tấn',
    lecturer: 'TS. Nguyễn Văn Hùng',
    date: '2026-04-24',
    type: 'theory',
  },
];

export const mockAttendanceCourses: AttendanceCourseStat[] = [
  { code: '000002', name: 'Công Nghệ Java', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
  { code: '101956', name: 'Deep learning', total: 15, attended: 14, excused: 1, absent: 0, percent: 93.3 },
  { code: '101970', name: 'Khai phá dữ liệu', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
  { code: '101969', name: 'Lập trình di động', total: 15, attended: 13, excused: 1, absent: 1, percent: 86.7 },
  { code: '101976', name: 'Phân tích thiết kế hệ thống', total: 10, attended: 10, excused: 0, absent: 0, percent: 100 },
];

export const mockSemesterSummaries: SemesterSummary[] = [
  {
    semesterLabel: 'HK2 (2025 - 2026)',
    gpa: 3.55,
    conductScore: 88,
    classification: 'Giỏi',
    status: 'Bình thường',
    subjects: [
      { subjectCode: '000002', subjectName: 'Công Nghệ Java', credits: 3, midterm: 8.5, final: 9.0, average: 8.8, letterGrade: 'A' },
      { subjectCode: '101956', subjectName: 'Deep learning', credits: 3, midterm: 8.0, final: 8.5, average: 8.3, letterGrade: 'B+' },
      { subjectCode: '101970', subjectName: 'Khai phá dữ liệu', credits: 3, midterm: 8.5, final: 8.0, average: 8.2, letterGrade: 'B+' },
      { subjectCode: '101969', subjectName: 'Lập trình di động', credits: 3, midterm: 9.0, final: 9.5, average: 9.3, letterGrade: 'A+' },
      { subjectCode: '101976', subjectName: 'Phân tích thiết kế hệ thống', credits: 2, midterm: 7.5, final: 8.0, average: 7.8, letterGrade: 'B' },
      { subjectCode: '101977', subjectName: 'Thực hành PTTK hệ thống', credits: 1, midterm: 8.0, final: 8.5, average: 8.3, letterGrade: 'B+' },
    ],
  },
  {
    semesterLabel: 'HK1 (2025 - 2026)',
    gpa: 3.62,
    conductScore: 92,
    classification: 'Xuất sắc',
    status: 'Bình thường',
    subjects: [
      { subjectCode: '101966', subjectName: 'Ảo hóa và điện toán đám mây', credits: 3, midterm: 8.5, final: 8.8, average: 8.7, letterGrade: 'A' },
      { subjectCode: '101963', subjectName: 'Công nghệ phần mềm', credits: 3, midterm: 9.0, final: 9.2, average: 9.1, letterGrade: 'A+' },
      { subjectCode: '101960', subjectName: 'Hệ quản trị cơ sở dữ liệu', credits: 3, midterm: 8.5, final: 8.6, average: 8.6, letterGrade: 'A' },
      { subjectCode: '101962', subjectName: 'Thực hành hệ quản trị CSDL', credits: 1, midterm: 9.5, final: 9.0, average: 9.2, letterGrade: 'A+' },
    ],
  },
  {
    semesterLabel: 'HK2 (2024 - 2025)',
    gpa: 3.48,
    conductScore: 89,
    classification: 'Giỏi',
    status: 'Bình thường',
    subjects: [
      { subjectCode: '101925', subjectName: 'Mạng máy tính', credits: 3, midterm: 8.0, final: 8.5, average: 8.3, letterGrade: 'B+' },
      { subjectCode: '101920', subjectName: 'Kiến trúc máy tính', credits: 3, midterm: 7.5, final: 8.0, average: 7.8, letterGrade: 'B' },
      { subjectCode: '101915', subjectName: 'Cơ sở dữ liệu', credits: 3, midterm: 9.0, final: 9.0, average: 9.0, letterGrade: 'A+' },
    ],
  },
];

export const mockConductScores: ConductScore[] = [
  {
    semester: 'Học kỳ 1 - Năm 2025-2026',
    totalScore: 92,
    classification: 'Xuất sắc',
    details: [
      { title: 'Ý thức học tập', maxScore: 20, achievedScore: 20 },
      { title: 'Chấp hành nội quy, quy chế', maxScore: 25, achievedScore: 25 },
      { title: 'Tham gia hoạt động Đoàn - Hội', maxScore: 20, achievedScore: 20 },
      { title: 'Phẩm chất công dân & cộng đồng', maxScore: 25, achievedScore: 22 },
      { title: 'Ban cán sự lớp & khen thưởng', maxScore: 10, achievedScore: 5 },
    ],
  },
  {
    semester: 'Học kỳ 2 - Năm 2024-2025',
    totalScore: 88,
    classification: 'Tốt',
    details: [
      { title: 'Ý thức học tập', maxScore: 20, achievedScore: 18 },
      { title: 'Chấp hành nội quy, quy chế', maxScore: 25, achievedScore: 25 },
      { title: 'Tham gia hoạt động Đoàn - Hội', maxScore: 20, achievedScore: 18 },
      { title: 'Phẩm chất công dân & cộng đồng', maxScore: 25, achievedScore: 20 },
      { title: 'Ban cán sự lớp & khen thưởng', maxScore: 10, achievedScore: 7 },
    ],
  },
];

export const mockTransactions: Transaction[] = [
  { id: '1', type: 'Thu học phí HK2 (2025 - 2026)', dateTime: '30/12/2025 19:59', amount: 17205000, status: 'SUCCESS' },
  { id: '2', type: 'Thu học phí hè 2025', dateTime: '10/08/2025 18:54', amount: 2785000, status: 'SUCCESS' },
  { id: '3', type: 'Thu học phí hè (GD thử lại)', dateTime: '19/07/2025 10:35', amount: 2785000, status: 'CANCELLED' },
  { id: '4', type: 'Thu học phí HK1 (2025 - 2026)', dateTime: '18/07/2025 06:41', amount: 11280000, status: 'SUCCESS' },
];

export const mockReceipts: Receipt[] = [
  { receiptNumber: 'PT-193813', dateTime: '09:35, 20/01/2026', collector: 'Ngân hàng OCB (Cổng trực tuyến)', amount: 17205000, hasInvoice: true },
  { receiptNumber: 'PT-188204', dateTime: '14:20, 15/08/2025', collector: 'Ngân hàng VietinBank', amount: 2785000, hasInvoice: true },
  { receiptNumber: 'PT-174920', dateTime: '08:15, 10/01/2025', collector: 'Phòng Tài chính Kế toán HUIT', amount: 11280000, hasInvoice: true },
];

export const mockNewsList: NewsItem[] = [
  {
    id: '1',
    title: 'HUIT tổ chức Hội thảo Quốc tế về Trí tuệ Nhân tạo và Ứng dụng thực tiễn',
    date: '15/04/2026',
    category: 'Sự kiện',
    imageUrl: 'https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=600&q=80',
    summary: 'Hội thảo quy tụ hơn 50 chuyên gia quốc tế trao đổi về giải pháp ứng dụng AI trong quản trị giáo dục.',
    content: 'Sáng ngày 15/04/2026, Trường Đại học Công Thương TP.HCM (HUIT) đã long trọng tổ chức Hội thảo khoa học quốc tế về Trí tuệ Nhân tạo và Công nghệ chuyển đổi số trong giáo dục đại học. Hội thảo có sự tham gia của các giáo sư, nhà khoa học đầu ngành đến từ Nhật Bản, Hàn Quốc, Singapore và Việt Nam.',
  },
  {
    id: '2',
    title: 'Thông báo đăng ký học phần Học kỳ 1 Năm học 2026 - 2027',
    date: '10/04/2026',
    category: 'Thông báo',
    imageUrl: 'https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?w=600&q=80',
    summary: 'Sinh viên các khóa lưu ý thời gian mở cổng đăng ký học phần đợt 1 từ ngày 05/05/2026.',
    content: 'Phòng Quản lý Đào tạo thông báo kế hoạch đăng ký học phần cho học kỳ mới. Sinh viên lưu ý hoàn thành nghĩa vụ học phí trước ngày mở cổng đăng ký để đảm bảo quyền lợi theo quy định.',
  },
  {
    id: '3',
    title: 'Cuộc thi sáng tạo Robot & IoT sinh viên HUIT chính thức khởi tranh',
    date: '02/04/2026',
    category: 'Sinh viên',
    imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=600&q=80',
    summary: 'Giải thưởng lên tới 50 triệu đồng cùng cơ hội thực tập tại các tập đoàn công nghệ lớn.',
    content: 'Nhằm thúc đẩy phong trào nghiên cứu khoa học và sáng tạo kỹ thuật, Đoàn Thanh niên - Hội Sinh viên trường phối hợp cùng Khoa CNTT phát động cuộc thi IoT & Robotics HUIT 2026 dành cho tất cả sinh viên đam mê công nghệ.',
  },
];

export const mockSurveys: SurveyItem[] = [
  { id: '1', title: 'Khảo sát lấy ý kiến sinh viên về chất lượng giảng dạy HK2', deadline: '30/05/2026', isCompleted: false },
  { id: '2', title: 'Khảo sát nhu cầu sử dụng thư viện số và cơ sở vật chất HUIT', deadline: '15/05/2026', isCompleted: true },
  { id: '3', title: 'Khảo sát hoạt động Đoàn - Hội và phong trào tình nguyện', deadline: '10/05/2026', isCompleted: true },
];

export const mockCurriculumSemesters: CurriculumSemester[] = [
  {
    semester: 1,
    totalCredits: 16,
    subjects: [
      { code: '000001', name: 'Triết học Mác - Lênin', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '100002', name: 'Toán cao cấp 1', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101901', name: 'Nhập môn lập trình', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101902', name: 'Thực hành nhập môn lập trình', credits: 1, type: 'Bắt buộc', isCompleted: true },
      { code: '000005', name: 'Tiếng Anh 1', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '000010', name: 'Giáo dục thể chất 1', credits: 3, type: 'Bắt buộc', isCompleted: true },
    ],
  },
  {
    semester: 2,
    totalCredits: 18,
    subjects: [
      { code: '000003', name: 'Kinh tế chính trị Mác - Lênin', credits: 2, type: 'Bắt buộc', isCompleted: true },
      { code: '100003', name: 'Toán cao cấp 2', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101903', name: 'Kỹ thuật lập trình', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101904', name: 'Cấu trúc dữ liệu và giải thuật', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '000006', name: 'Tiếng Anh 2', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '000011', name: 'Giáo dục quốc phòng', credits: 4, type: 'Bắt buộc', isCompleted: true },
    ],
  },
  {
    semester: 3,
    totalCredits: 19,
    subjects: [
      { code: '101910', name: 'Lập trình hướng đối tượng', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101915', name: 'Cơ sở dữ liệu', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101920', name: 'Kiến trúc máy tính & HĐH', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101925', name: 'Mạng máy tính cơ bản', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '100005', name: 'Xác suất thống kê', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '000007', name: 'Tiếng Anh 3', credits: 4, type: 'Bắt buộc', isCompleted: true },
    ],
  },
  {
    semester: 4,
    totalCredits: 18,
    subjects: [
      { code: '101930', name: 'Lập trình Web nâng cao', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101935', name: 'Phân tích thiết kế hệ thống', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101936', name: 'Thực hành phân tích thiết kế HT', credits: 1, type: 'Bắt buộc', isCompleted: true },
      { code: '101940', name: 'Mạng máy tính nâng cao', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101945', name: 'An toàn thông tin cơ bản', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '000008', name: 'Kỹ năng giao tiếp & làm việc nhóm', credits: 2, type: 'Tự chọn', isCompleted: true },
      { code: '000009', name: 'Pháp luật đại cương', credits: 3, type: 'Bắt buộc', isCompleted: true },
    ],
  },
  {
    semester: 5,
    totalCredits: 20,
    subjects: [
      { code: '000002', name: 'Công nghệ Java', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101963', name: 'Công nghệ phần mềm', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101960', name: 'Hệ quản trị cơ sở dữ liệu', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101970', name: 'Khai phá dữ liệu', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101966', name: 'Ảo hóa và điện toán đám mây', credits: 3, type: 'Bắt buộc', isCompleted: true },
      { code: '101967', name: 'Thực hành điện toán đám mây', credits: 1, type: 'Bắt buộc', isCompleted: true },
      { code: '000015', name: 'Tư tưởng Hồ Chí Minh', credits: 2, type: 'Bắt buộc', isCompleted: true },
      { code: '000016', name: 'Lịch sử Đảng Cộng sản VN', credits: 2, type: 'Bắt buộc', isCompleted: true },
    ],
  },
  {
    semester: 6,
    totalCredits: 19,
    subjects: [
      { code: '101969', name: 'Lập trình di động (React Native / Flutter)', credits: 3, type: 'Bắt buộc', isCompleted: false },
      { code: '101956', name: 'Deep learning & Trí tuệ nhân tạo', credits: 3, type: 'Bắt buộc', isCompleted: false },
      { code: '101973', name: 'Quản trị hệ thống mạng', credits: 3, type: 'Bắt buộc', isCompleted: false },
      { code: '101980', name: 'Kiểm thử phần mềm & Đảm bảo chất lượng', credits: 3, type: 'Bắt buộc', isCompleted: false },
      { code: '101985', name: 'Xây dựng ứng dụng doanh nghiệp', credits: 3, type: 'Tự chọn', isCompleted: false },
      { code: '101990', name: 'Đồ án công nghệ thông tin', credits: 4, type: 'Bắt buộc', isCompleted: false },
    ],
  },
  {
    semester: 7,
    totalCredits: 19,
    subjects: [
      { code: '101995', name: 'DevOps & CI/CD tự động hóa', credits: 3, type: 'Tự chọn', isCompleted: false },
      { code: '101996', name: 'Kiến trúc vi dịch vụ (Microservices)', credits: 3, type: 'Tự chọn', isCompleted: false },
      { code: '101997', name: 'Thị giác máy tính (Computer Vision)', credits: 3, type: 'Tự chọn', isCompleted: false },
      { code: '101998', name: 'Xử lý ngôn ngữ tự nhiên (NLP)', credits: 3, type: 'Tự chọn', isCompleted: false },
      { code: '101999', name: 'Chuyên đề tốt nghiệp chuyên sâu', credits: 4, type: 'Bắt buộc', isCompleted: false },
      { code: '000020', name: 'Khởi nghiệp & Đổi mới sáng tạo', credits: 3, type: 'Bắt buộc', isCompleted: false },
    ],
  },
  {
    semester: 8,
    totalCredits: 22,
    subjects: [
      { code: '102001', name: 'Thực tập tốt nghiệp tại doanh nghiệp', credits: 10, type: 'Bắt buộc', isCompleted: false },
      { code: '102002', name: 'Khóa luận tốt nghiệp cử nhân CNTT', credits: 12, type: 'Bắt buộc', isCompleted: false },
    ],
  },
];

export const mockAchievements: AchievementItem[] = [
  {
    id: '1',
    title: 'Học bổng khuyến khích học tập Loại Xuất sắc',
    semester: 'Học kỳ 1 (2025 - 2026)',
    decision: 'Quyết định số 142/QĐ-DCT ngày 12/03/2026',
    amount: '9.500.000 đ',
    icon: 'trophy',
    color: '#D97706',
    bg: '#FFFBEB',
  },
  {
    id: '2',
    title: 'Danh hiệu Sinh viên 5 Tốt cấp Trường',
    semester: 'Năm học 2024 - 2025',
    decision: 'Đoàn trường ĐH Công Thương TP.HCM',
    amount: 'Giấy khen & Kỷ niệm chương',
    icon: 'star',
    color: '#DC2626',
    bg: '#FEF2F2',
  },
  {
    id: '3',
    title: 'Giải Nhì Cuộc thi Nghiên cứu Khoa học SV HUIT',
    semester: 'Năm học 2024 - 2025',
    decision: 'Đề tài: Ứng dụng AI trong quản lý điểm danh',
    amount: '3.000.000 đ',
    icon: 'ribbon',
    color: '#2563EB',
    bg: '#EFF6FF',
  },
  {
    id: '4',
    title: 'Học bổng khuyến khích học tập Loại Giỏi',
    semester: 'Học kỳ 2 (2024 - 2025)',
    decision: 'Quyết định số 89/QĐ-DCT ngày 20/09/2025',
    amount: '8.200.000 đ',
    icon: 'trophy',
    color: '#D97706',
    bg: '#FFFBEB',
  },
];
