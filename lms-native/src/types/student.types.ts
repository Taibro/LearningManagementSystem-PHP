export interface StudentProfile {
  studentCode: string;
  fullName: string;
  email: string;
  phone: string;
  gender: 'MALE' | 'FEMALE';
  birthDate: string;
  idCard: string;
  birthPlace: string;
  className: string;
  majorName: string;
  facultyName: string;
  enrollmentYear: string;
  trainingDuration: number;
  yearLevel: number;
}

export interface StudentOverview {
  fullName: string;
  yearLevel: number;
  academicYear: string;
  trainingDuration: number;
  gpa4: number;
  gpa10: number;
  classification: string;
  creditsRegistered: number;
  creditsAccumulated: number;
  creditsDebt: number;
  percentDebt: number;
  creditsRequired: number;
}

export interface ScheduleItem {
  id: string;
  subjectName: string;
  classCode: string;
  period: string;        // e.g. "Tiết 7 - 11"
  room: string;          // e.g. "A110 - Phòng máy tính"
  lecturer: string;      // e.g. "Đặng Đức Trung"
  date: string;          // YYYY-MM-DD
  type?: 'online' | 'practice' | 'theory';
}

export interface SubjectGrade {
  subjectCode: string;
  subjectName: string;
  credits: number;
  midterm?: number;
  final?: number;
  average?: number;
  letterGrade?: string;
}

export interface SemesterSummary {
  semesterLabel: string; // e.g. "HK2 (2025 - 2026)"
  gpa: number;
  conductScore: number;
  classification: string;
  status: string;
  subjects: SubjectGrade[];
}

export interface ConductDetail {
  title: string;
  maxScore: number;
  achievedScore: number;
}

export interface ConductScore {
  semester: string;
  totalScore: number;
  classification: string;
  details: ConductDetail[];
}

export interface AttendanceCourseStat {
  code: string;
  name: string;
  total: number;
  attended: number;
  excused: number;
  absent: number;
  percent: number;
}

export interface Transaction {
  id: string;
  type: string;
  dateTime: string;
  amount: number;
  status: 'SUCCESS' | 'CANCELLED';
}

export interface Receipt {
  receiptNumber: string;
  dateTime: string;
  collector: string;
  amount: number;
  hasInvoice: boolean;
}

export interface NewsItem {
  id: string;
  title: string;
  date: string;
  category: string;
  imageUrl: string;
  summary?: string;
  content?: string;
}

export interface SurveyItem {
  id: string;
  title: string;
  deadline: string;
  isCompleted: boolean;
}

export interface CurriculumSubject {
  code: string;
  name: string;
  credits: number;
  type: 'Bắt buộc' | 'Tự chọn';
  prerequisite?: string;
  isCompleted?: boolean;
}

export interface CurriculumSemester {
  semester: number;
  totalCredits: number;
  subjects: CurriculumSubject[];
}

export interface AchievementItem {
  id: string;
  title: string;
  semester: string;
  decision: string;
  amount: string;
  icon: string;
  color: string;
  bg: string;
}

export interface ChatMessage {
  id: string;
  text: string;
  sender: 'user' | 'bot';
  timestamp: string;
}
