import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants';
import { storageService } from '../services/storage';
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
  AchievementItem,
} from '../types/student.types';

export const studentApi = {
  login: async (
    studentCode: string,
    password: string,
    school: string = 'HUIT'
  ): Promise<{ token: string; profile: StudentProfile }> => {
    const response = await apiClient.post<any>(API_ENDPOINTS.AUTH.LOGIN, {
      loginCode: studentCode,
      password,
      userType: 'STUDENT',
      school,
    });
    const token = response.accessToken || response.token;
    const resolvedSchoolCode = response.schoolCode || school;
    const isHcmut = resolvedSchoolCode === 'HCMUT' || studentCode.startsWith('200122') || response.email?.includes('hcmut');

    let className = '14DHTH01';
    let majorName = 'Công nghệ thông tin';
    let facultyName = 'Khoa Công nghệ thông tin';
    let fullName = response.fullName || 'Sinh viên LMS';
    let birthDate = '15/08/2003';
    let idCard = '079203001234';
    let birthPlace = 'TP. Hồ Chí Minh';
    let phone = response.phone || '0987654321';
    let gender: 'MALE' | 'FEMALE' = 'MALE';

    if (isHcmut) {
      className = 'CC01';
      majorName = 'Khoa học Máy tính';
      facultyName = 'Khoa Khoa học và Kỹ thuật Máy tính';
      fullName = response.fullName || 'Trần Bách Khoa';
      birthDate = '20/10/2003';
      idCard = '079203009988';
      birthPlace = 'TP. Hồ Chí Minh';
      phone = response.phone || '0912345678';
    } else if (studentCode === '2001216304') {
      className = '12DHKT01';
      majorName = 'Kế toán';
      facultyName = 'Khoa Kế toán - Tài chính';
      fullName = response.fullName || 'Phạm Thị Cúc';
      birthDate = '08/09/2003';
      idCard = '079303005678';
      birthPlace = 'Đồng Nai';
      phone = response.phone || '0909876543';
      gender = 'FEMALE';
    } else if (studentCode === '2001216302') {
      className = '14DHTH02';
      majorName = 'Công nghệ thông tin';
      facultyName = 'Khoa Công nghệ thông tin';
      fullName = response.fullName || 'Nguyễn Minh Dũng';
      birthDate = '12/04/2003';
      idCard = '079203004567';
      birthPlace = 'Bình Định';
      phone = response.phone || '0938123456';
    } else if (studentCode === '2001230773') {
      className = '14DHTH01';
      majorName = 'Công nghệ thông tin';
      facultyName = 'Khoa Công nghệ thông tin';
      fullName = response.fullName || 'Nguyễn Thành Tài';
      birthDate = '15/08/2003';
      idCard = '079203001234';
      birthPlace = 'TP. Hồ Chí Minh';
      phone = response.phone || '0987654321';
    }

    const profile: StudentProfile = {
      studentCode: response.studentCode || response.userCode || studentCode,
      fullName,
      email: response.email || `${studentCode.toLowerCase()}@${resolvedSchoolCode.toLowerCase()}.edu.vn`,
      phone,
      gender,
      birthDate,
      idCard,
      birthPlace,
      className: response.className || className,
      majorName: response.majorName || majorName,
      facultyName: response.facultyName || facultyName,
      enrollmentYear: '2023 - 2027',
      trainingDuration: 4.0,
      yearLevel: response.yearLevel || 3,
      schoolCode: resolvedSchoolCode,
      schoolName: response.schoolName || (isHcmut ? 'Trường ĐH Bách Khoa TP.HCM (HCMUT)' : 'Trường ĐH Công Thương TP.HCM (HUIT)'),
    };
    return { token, profile };
  },

  changePassword: async (payload: {
    currentPassword: string;
    newPassword: string;
    confirmPassword: string;
  }): Promise<{ success: boolean; message: string }> => {
    return await apiClient.put<{ success: boolean; message: string }>(
      API_ENDPOINTS.AUTH.CHANGE_PASSWORD,
      payload
    );
  },

  getProfile: async (): Promise<StudentProfile> => {
    try {
      const me = await apiClient.get<any>('/auth/me');
      if (me && (me.studentCode || me.fullName)) {
        const schoolCode = me.schoolCode || 'HUIT';
        const isHcmut = schoolCode === 'HCMUT' || me.studentCode?.startsWith('200122');
        return {
          studentCode: me.studentCode || me.userCode || (isHcmut ? '2001220001' : '2001230773'),
          fullName: me.fullName || (isHcmut ? 'Trần Bách Khoa' : 'Nguyễn Thành Tài'),
          email: me.email || (isHcmut ? 'sv_hcmut@hcmut.edu.vn' : 'student@huit.edu.vn'),
          phone: me.phone || (isHcmut ? '0912345678' : '0987654321'),
          gender: me.studentCode === '2001216304' ? 'FEMALE' : 'MALE',
          birthDate: isHcmut ? '20/10/2003' : (me.studentCode === '2001216304' ? '08/09/2003' : '15/08/2003'),
          idCard: isHcmut ? '079203009988' : '079203001234',
          birthPlace: isHcmut ? 'TP. Hồ Chí Minh' : (me.studentCode === '2001216302' ? 'Bình Định' : 'TP. Hồ Chí Minh'),
          className: isHcmut ? 'CC01' : (me.studentCode === '2001216304' ? '12DHKT01' : (me.studentCode === '2001216302' ? '14DHTH02' : '14DHTH01')),
          majorName: isHcmut ? 'Khoa học Máy tính' : (me.studentCode === '2001216304' ? 'Kế toán' : 'Công nghệ thông tin'),
          facultyName: isHcmut ? 'Khoa Khoa học và Kỹ thuật Máy tính' : (me.studentCode === '2001216304' ? 'Khoa Kế toán - Tài chính' : 'Khoa Công nghệ thông tin'),
          enrollmentYear: '2023 - 2027',
          trainingDuration: 4.0,
          yearLevel: 3,
          schoolCode,
          schoolName: me.schoolName || (isHcmut ? 'Trường ĐH Bách Khoa TP.HCM (HCMUT)' : 'Trường ĐH Công Thương TP.HCM (HUIT)'),
        };
      }
    } catch {
      // Fallback to local stored user
    }
    const stored = await storageService.getUser<StudentProfile>();
    if (stored) return stored;

    return {
      studentCode: '2001230773',
      fullName: 'Nguyễn Thành Tài',
      email: 'tai.sv@huit.edu.vn',
      phone: '0987654321',
      gender: 'MALE',
      birthDate: '15/08/2003',
      idCard: '079203001234',
      birthPlace: 'TP. Hồ Chí Minh',
      className: '14DHTH01',
      majorName: 'Công nghệ thông tin',
      facultyName: 'Khoa Công nghệ thông tin',
      enrollmentYear: '2023 - 2027',
      trainingDuration: 4.0,
      yearLevel: 3,
      schoolCode: 'HUIT',
      schoolName: 'Trường ĐH Công Thương TP.HCM (HUIT)',
    };
  },

  getOverview: async (): Promise<StudentOverview> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    
    if (isHcmut) {
      return {
        fullName: prof.fullName || 'Trần Bách Khoa',
        yearLevel: 3,
        academicYear: '2023 - 2027',
        trainingDuration: 4.0,
        gpa4: 3.82,
        gpa10: 8.95,
        classification: 'Xuất sắc',
        creditsRegistered: 96,
        creditsAccumulated: 94,
        creditsDebt: 0,
        percentDebt: 0.0,
        creditsRequired: 142.0,
      };
    }
    if (prof.studentCode === '2001216302') {
      return {
        fullName: prof.fullName || 'Nguyễn Minh Dũng',
        yearLevel: 3,
        academicYear: '2023 - 2027',
        trainingDuration: 4.0,
        gpa4: 3.65,
        gpa10: 8.42,
        classification: 'Giỏi',
        creditsRegistered: 90,
        creditsAccumulated: 88,
        creditsDebt: 0,
        percentDebt: 0.0,
        creditsRequired: 151.0,
      };
    }
    if (prof.studentCode === '2001216304') {
      return {
        fullName: prof.fullName || 'Phạm Thị Cúc',
        yearLevel: 3,
        academicYear: '2023 - 2027',
        trainingDuration: 4.0,
        gpa4: 3.70,
        gpa10: 8.50,
        classification: 'Giỏi',
        creditsRegistered: 86,
        creditsAccumulated: 86,
        creditsDebt: 0,
        percentDebt: 0.0,
        creditsRequired: 145.0,
      };
    }
    return {
      fullName: prof.fullName || 'Nguyễn Thành Tài',
      yearLevel: 3,
      academicYear: '2023 - 2027',
      trainingDuration: 4.0,
      gpa4: 3.54,
      gpa10: 8.29,
      classification: 'Khá',
      creditsRegistered: 88,
      creditsAccumulated: 85,
      creditsDebt: 0,
      percentDebt: 0.0,
      creditsRequired: 151.0,
    };
  },

  getNextClass: async (): Promise<ScheduleItem | null> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return {
        id: 'hcmut-next-1',
        subjectName: 'Kiến trúc Máy tính',
        classCode: 'CO2007_L01',
        period: 'Tiết 1 - 3 (07:00 - 09:15)',
        room: 'C6-102 - CS1 ĐH Bách Khoa TP.HCM (268 Lý Thường Kiệt)',
        lecturer: 'TS. Trần Văn Nam',
        date: '2026-04-20',
        type: 'theory',
      };
    }
    if (prof.studentCode === '2001216302') {
      return {
        id: 'huit-dung-next',
        subjectName: 'Lập trình Web nâng cao',
        classCode: 'INT102_01',
        period: 'Tiết 7 - 9 (13:00 - 15:15)',
        room: 'B302 - CS1 HUIT (140 Lê Trọng Tấn)',
        lecturer: 'ThS. Nguyễn Văn A',
        date: '2026-04-20',
        type: 'practice',
      };
    }
    if (prof.studentCode === '2001216304') {
      return {
        id: 'huit-acc-1',
        subjectName: 'Nguyên lý kế toán',
        classCode: 'ACC101_01',
        period: 'Tiết 1 - 3 (07:00 - 09:15)',
        room: 'F201 - CS1 HUIT (140 Lê Trọng Tấn)',
        lecturer: 'ThS. Nguyễn Văn A',
        date: '2026-04-20',
        type: 'theory',
      };
    }
    return {
      id: 'huit-current-1',
      subjectName: 'Phát triển & Thiết kế HTTT',
      classCode: 'INT106_01',
      period: 'Tiết 1 - 3 (07:00 - 09:15)',
      room: 'C101 - CS1 HUIT (140 Lê Trọng Tấn)',
      lecturer: 'ThS. Lê Hoàng Long',
      date: '2026-04-20',
      type: 'theory',
    };
  },

  getSchedule: async (): Promise<ScheduleItem[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          id: 'sch-bk-1',
          subjectName: 'Kiến trúc Máy tính',
          classCode: 'CO2007_L01',
          period: 'Tiết 1 - 3 (07:00 - 09:15)',
          room: 'C6-102 - CS1 Lý Thường Kiệt',
          lecturer: 'TS. Trần Văn Nam',
          date: '2026-04-20',
          type: 'theory',
        },
        {
          id: 'sch-bk-2',
          subjectName: 'Cấu trúc Dữ liệu & Giải thuật',
          classCode: 'CO2003_L01',
          period: 'Tiết 4 - 6 (09:30 - 11:45)',
          room: 'B1-204 - CS1 Lý Thường Kiệt',
          lecturer: 'ThS. Lê Bách Khoa',
          date: '2026-04-21',
          type: 'practice',
        },
        {
          id: 'sch-bk-3',
          subjectName: 'Hệ điều hành',
          classCode: 'CO2011_L01',
          period: 'Tiết 7 - 9 (13:00 - 15:15)',
          room: 'H1-101 - CS2 Dĩ An',
          lecturer: 'TS. Trần Văn Nam',
          date: '2026-04-22',
          type: 'theory',
        },
        {
          id: 'sch-bk-4',
          subjectName: 'Mạng Máy tính',
          classCode: 'CO2013_L01',
          period: 'Tiết 1 - 3 (07:00 - 09:15)',
          room: 'B1-305 - CS1 Lý Thường Kiệt',
          lecturer: 'ThS. Lê Bách Khoa',
          date: '2026-04-23',
          type: 'practice',
        },
        {
          id: 'sch-bk-5',
          subjectName: 'Nhập môn Điện toán',
          classCode: 'CO1001_L01',
          period: 'Tiết 4 - 6 (09:30 - 11:45)',
          room: 'A4-301 - CS1 Lý Thường Kiệt',
          lecturer: 'TS. Trần Văn Nam',
          date: '2026-04-24',
          type: 'theory',
        },
        {
          id: 'sch-bk-6',
          subjectName: 'Giải tích 1',
          classCode: 'MT1003_L01',
          period: 'Tiết 1 - 3 (07:00 - 09:15)',
          room: 'A4-301 - CS1 Lý Thường Kiệt',
          lecturer: 'ThS. Lê Bách Khoa',
          date: '2026-04-25',
          type: 'theory',
        },
      ];
    }
    if (prof.studentCode === '2001216302') {
      return [
        {
          id: 'sch-dung-1',
          subjectName: 'Lập trình Web nâng cao',
          classCode: 'INT102_01',
          period: 'Tiết 7 - 9 (13:00 - 15:15)',
          room: 'B302 - CS1 HUIT',
          lecturer: 'ThS. Nguyễn Văn A',
          date: '2026-04-20',
          type: 'practice',
        },
        {
          id: 'sch-dung-2',
          subjectName: 'An toàn Thông tin',
          classCode: 'INT104_01',
          period: 'Tiết 1 - 3 (07:00 - 09:15)',
          room: 'C101 - CS1 HUIT',
          lecturer: 'ThS. Nguyễn Văn A',
          date: '2026-04-21',
          type: 'theory',
        },
        {
          id: 'sch-dung-3',
          subjectName: 'Trí tuệ Nhân tạo',
          classCode: 'INT105_01',
          period: 'Tiết 4 - 6 (09:30 - 11:45)',
          room: 'C102 - CS1 HUIT',
          lecturer: 'ThS. Lê Hoàng Long',
          date: '2026-04-22',
          type: 'theory',
        },
        {
          id: 'sch-dung-4',
          subjectName: 'Lập trình ứng dụng Java',
          classCode: 'INT101_01',
          period: 'Tiết 1 - 3 (07:00 - 09:15)',
          room: 'C101 - CS1 HUIT',
          lecturer: 'ThS. Nguyễn Văn A',
          date: '2026-04-23',
          type: 'practice',
        },
        {
          id: 'sch-dung-5',
          subjectName: 'Hệ quản trị CSDL',
          classCode: 'INT103_01',
          period: 'Tiết 7 - 9 (13:00 - 15:15)',
          room: 'B302 - CS1 HUIT',
          lecturer: 'ThS. Nguyễn Văn A',
          date: '2026-04-24',
          type: 'theory',
        },
      ];
    }
    if (prof.studentCode === '2001216304') {
      return [
        {
          id: 'sch-cuc-1',
          subjectName: 'Nguyên lý kế toán',
          classCode: 'ACC101_01',
          period: 'Tiết 1 - 3 (07:00 - 09:15)',
          room: 'F201 - CS1 HUIT',
          lecturer: 'ThS. Nguyễn Văn A',
          date: '2026-04-20',
          type: 'theory',
        },
        {
          id: 'sch-cuc-2',
          subjectName: 'Kế toán Tài chính 1',
          classCode: 'ACC102_01',
          period: 'Tiết 4 - 6 (09:30 - 11:45)',
          room: 'F202 - CS1 HUIT',
          lecturer: 'ThS. Nguyễn Văn A',
          date: '2026-04-21',
          type: 'theory',
        },
        {
          id: 'sch-cuc-3',
          subjectName: 'Thuế Doanh nghiệp',
          classCode: 'ACC103_01',
          period: 'Tiết 1 - 3 (07:00 - 09:15)',
          room: 'F202 - CS1 HUIT',
          lecturer: 'ThS. Nguyễn Văn A',
          date: '2026-04-22',
          type: 'theory',
        },
        {
          id: 'sch-cuc-4',
          subjectName: 'Tin học ứng dụng Kế toán',
          classCode: 'INT101_01',
          period: 'Tiết 7 - 9 (13:00 - 15:15)',
          room: 'F201 - CS1 HUIT',
          lecturer: 'ThS. Lê Hoàng Long',
          date: '2026-04-23',
          type: 'practice',
        },
      ];
    }
    return [
      {
        id: 'sch-tai-1',
        subjectName: 'Lập trình ứng dụng Java',
        classCode: 'INT101_01',
        period: 'Tiết 1 - 3 (07:00 - 09:15)',
        room: 'C101 - CS1 HUIT',
        lecturer: 'ThS. Nguyễn Văn A',
        date: '2026-04-20',
        type: 'practice',
      },
      {
        id: 'sch-tai-2',
        subjectName: 'Lập trình Web nâng cao',
        classCode: 'INT102_01',
        period: 'Tiết 7 - 9 (13:00 - 15:15)',
        room: 'B302 - CS1 HUIT',
        lecturer: 'ThS. Nguyễn Văn A',
        date: '2026-04-21',
        type: 'practice',
      },
      {
        id: 'sch-tai-3',
        subjectName: 'Hệ quản trị CSDL',
        classCode: 'INT103_01',
        period: 'Tiết 4 - 6 (09:30 - 11:45)',
        room: 'C102 - CS1 HUIT',
        lecturer: 'ThS. Nguyễn Văn A',
        date: '2026-04-22',
        type: 'theory',
      },
      {
        id: 'sch-tai-4',
        subjectName: 'Phát triển & Thiết kế HTTT',
        classCode: 'INT106_01',
        period: 'Tiết 1 - 3 (07:00 - 09:15)',
        room: 'C101 - CS1 HUIT',
        lecturer: 'ThS. Lê Hoàng Long',
        date: '2026-04-23',
        type: 'theory',
      },
    ];
  },

  getAttendanceCourses: async (): Promise<AttendanceCourseStat[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        { code: 'CO2007', name: 'Kiến trúc Máy tính', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
        { code: 'CO2003', name: 'Cấu trúc Dữ liệu & Giải thuật', total: 15, attended: 14, excused: 1, absent: 0, percent: 93.3 },
        { code: 'CO2011', name: 'Hệ điều hành', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
        { code: 'CO2013', name: 'Mạng Máy tính', total: 15, attended: 14, excused: 0, absent: 1, percent: 93.3 },
        { code: 'CO1001', name: 'Nhập môn Điện toán', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
        { code: 'MT1003', name: 'Giải tích 1', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
      ];
    }
    if (prof.studentCode === '2001216302') {
      return [
        { code: 'INT102', name: 'Lập trình Web nâng cao', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
        { code: 'INT104', name: 'An toàn Thông tin', total: 15, attended: 14, excused: 1, absent: 0, percent: 93.3 },
        { code: 'INT105', name: 'Trí tuệ Nhân tạo', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
        { code: 'INT101', name: 'Lập trình ứng dụng Java', total: 15, attended: 14, excused: 0, absent: 1, percent: 93.3 },
        { code: 'INT103', name: 'Hệ quản trị CSDL', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
      ];
    }
    if (prof.studentCode === '2001216304') {
      return [
        { code: 'ACC101', name: 'Nguyên lý kế toán', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
        { code: 'ACC102', name: 'Kế toán Tài chính 1', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
        { code: 'ACC103', name: 'Thuế Doanh nghiệp', total: 15, attended: 14, excused: 1, absent: 0, percent: 93.3 },
        { code: 'INT101', name: 'Tin học ứng dụng Kế toán', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
      ];
    }
    return [
      { code: 'INT106', name: 'Phát triển & Thiết kế HTTT', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
      { code: 'INT101', name: 'Lập trình ứng dụng Java', total: 15, attended: 14, excused: 1, absent: 0, percent: 93.3 },
      { code: 'INT102', name: 'Lập trình Web nâng cao', total: 15, attended: 14, excused: 0, absent: 1, percent: 93.3 },
      { code: 'INT103', name: 'Hệ quản trị CSDL', total: 15, attended: 15, excused: 0, absent: 0, percent: 100 },
    ];
  },

  getGrades: async (): Promise<SemesterSummary[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          semesterLabel: 'HK2 (2024 - 2025) - ĐH Bách Khoa TP.HCM (HCMUT)',
          gpa: 3.82,
          conductScore: 92,
          classification: 'Xuất sắc',
          status: 'Đạt',
          subjects: [
            { subjectCode: 'CO2007', subjectName: 'Kiến trúc Máy tính', credits: 3, midterm: 9.0, final: 9.5, average: 9.3, letterGrade: 'A+' },
            { subjectCode: 'CO2003', subjectName: 'Cấu trúc Dữ liệu & Giải thuật', credits: 4, midterm: 8.5, final: 9.0, average: 8.8, letterGrade: 'A' },
            { subjectCode: 'CO2011', subjectName: 'Hệ điều hành', credits: 3, midterm: 8.0, final: 8.5, average: 8.3, letterGrade: 'B+' },
            { subjectCode: 'CO2013', subjectName: 'Mạng Máy tính', credits: 3, midterm: 8.5, final: 9.0, average: 8.8, letterGrade: 'A' },
            { subjectCode: 'MT1003', subjectName: 'Giải tích 1', credits: 4, midterm: 9.0, final: 9.0, average: 9.0, letterGrade: 'A' },
            { subjectCode: 'CO1001', subjectName: 'Nhập môn Điện toán', credits: 3, midterm: 9.0, final: 8.5, average: 8.7, letterGrade: 'A' },
          ],
        },
        {
          semesterLabel: 'HK1 (2024 - 2025) - ĐH Bách Khoa TP.HCM (HCMUT)',
          gpa: 3.78,
          conductScore: 90,
          classification: 'Xuất sắc',
          status: 'Đạt',
          subjects: [
            { subjectCode: 'MT1001', subjectName: 'Đại số Tuyến tính', credits: 3, midterm: 8.5, final: 9.0, average: 8.8, letterGrade: 'A' },
            { subjectCode: 'PH1003', subjectName: 'Vật lý đại cương 1', credits: 3, midterm: 8.0, final: 8.5, average: 8.3, letterGrade: 'B+' },
            { subjectCode: 'CO1005', subjectName: 'Cấu trúc Rời rạc cho MT', credits: 4, midterm: 9.0, final: 9.5, average: 9.3, letterGrade: 'A+' },
            { subjectCode: 'EN1001', subjectName: 'Tiếng Anh học thuật 1', credits: 2, midterm: 8.5, final: 8.5, average: 8.5, letterGrade: 'A' },
          ],
        },
      ];
    }
    if (prof.studentCode === '2001216302') {
      return [
        {
          semesterLabel: 'HK2 (2024 - 2025) - Khoa CNTT HUIT',
          gpa: 3.65,
          conductScore: 88,
          classification: 'Giỏi',
          status: 'Đạt',
          subjects: [
            { subjectCode: 'INT102', subjectName: 'Lập trình Web nâng cao', credits: 3, midterm: 9.0, final: 9.0, average: 9.1, letterGrade: 'A' },
            { subjectCode: 'INT105', subjectName: 'Trí tuệ Nhân tạo', credits: 3, midterm: 9.0, final: 9.5, average: 9.2, letterGrade: 'A+' },
            { subjectCode: 'INT101', subjectName: 'Lập trình ứng dụng Java', credits: 3, midterm: 8.5, final: 8.5, average: 8.4, letterGrade: 'B+' },
            { subjectCode: 'INT103', subjectName: 'Hệ quản trị CSDL', credits: 3, midterm: 8.5, final: 8.5, average: 8.4, letterGrade: 'B+' },
            { subjectCode: 'INT104', subjectName: 'An toàn Thông tin', credits: 3, midterm: 8.0, final: 8.5, average: 8.3, letterGrade: 'B+' },
          ],
        },
      ];
    }
    if (prof.studentCode === '2001216304') {
      return [
        {
          semesterLabel: 'HK2 (2024 - 2025) - Khoa Kế toán HUIT',
          gpa: 3.70,
          conductScore: 90,
          classification: 'Giỏi',
          status: 'Đạt',
          subjects: [
            { subjectCode: 'ACC102', subjectName: 'Kế toán Tài chính 1', credits: 3, midterm: 9.0, final: 9.0, average: 8.9, letterGrade: 'A' },
            { subjectCode: 'ACC101', subjectName: 'Nguyên lý kế toán', credits: 3, midterm: 8.5, final: 9.0, average: 8.8, letterGrade: 'A' },
            { subjectCode: 'ACC103', subjectName: 'Thuế Doanh nghiệp', credits: 3, midterm: 8.5, final: 8.5, average: 8.4, letterGrade: 'B+' },
            { subjectCode: 'INT101', subjectName: 'Tin học ứng dụng Kế toán', credits: 3, midterm: 8.0, final: 8.0, average: 8.1, letterGrade: 'B' },
          ],
        },
      ];
    }
    return [
      {
        semesterLabel: 'HK2 (2024 - 2025) - Khoa CNTT HUIT',
        gpa: 3.54,
        conductScore: 85,
        classification: 'Khá',
        status: 'Đạt',
        subjects: [
          { subjectCode: 'INT106', subjectName: 'Phát triển & Thiết kế HTTT', credits: 3, midterm: 9.0, final: 9.0, average: 8.9, letterGrade: 'A' },
          { subjectCode: 'INT102', subjectName: 'Lập trình Web nâng cao', credits: 3, midterm: 8.5, final: 9.0, average: 8.8, letterGrade: 'A' },
          { subjectCode: 'INT101', subjectName: 'Lập trình ứng dụng Java', credits: 3, midterm: 8.5, final: 8.5, average: 8.4, letterGrade: 'B+' },
          { subjectCode: 'INT103', subjectName: 'Hệ quản trị CSDL', credits: 3, midterm: 8.0, final: 8.5, average: 8.2, letterGrade: 'B+' },
        ],
      },
    ];
  },

  getConductScores: async (): Promise<ConductScore[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          semester: 'Học kỳ 1 (2024 - 2025)',
          totalScore: 92,
          classification: 'Xuất sắc',
          details: [
            { title: 'Ý thức học tập và nghiên cứu khoa học', achievedScore: 20, maxScore: 20 },
            { title: 'Ý thức chấp hành nội quy, quy chế ĐHQG-HCM', achievedScore: 25, maxScore: 25 },
            { title: 'Hoạt động chính trị - xã hội, văn hóa, thể thao', achievedScore: 20, maxScore: 20 },
            { title: 'Phẩm chất công dân và quan hệ cộng đồng', achievedScore: 15, maxScore: 15 },
            { title: 'Thành tích đặc biệt trong học tập và rèn luyện BK', achievedScore: 12, maxScore: 20 },
          ],
        },
        {
          semester: 'Học kỳ 2 (2023 - 2024)',
          totalScore: 90,
          classification: 'Xuất sắc',
          details: [
            { title: 'Ý thức học tập và nghiên cứu khoa học', achievedScore: 19, maxScore: 20 },
            { title: 'Ý thức chấp hành nội quy, quy chế ĐHQG-HCM', achievedScore: 25, maxScore: 25 },
            { title: 'Hoạt động chính trị - xã hội, văn hóa, thể thao', achievedScore: 19, maxScore: 20 },
            { title: 'Phẩm chất công dân và quan hệ cộng đồng', achievedScore: 15, maxScore: 15 },
            { title: 'Thành tích đặc biệt trong học tập và rèn luyện BK', achievedScore: 12, maxScore: 20 },
          ],
        },
      ];
    }
    return [
      {
        semester: 'Học kỳ 1 (2024 - 2025)',
        totalScore: prof.studentCode === '2001216304' ? 90 : 88,
        classification: prof.studentCode === '2001216304' ? 'Xuất sắc' : 'Tốt',
        details: [
          { title: 'Ý thức học tập', achievedScore: 18, maxScore: 20 },
          { title: 'Chấp hành nội quy, quy chế nhà trường HUIT', achievedScore: 25, maxScore: 25 },
          { title: 'Tham gia hoạt động Đoàn - Hội và phong trào', achievedScore: 18, maxScore: 20 },
          { title: 'Ý thức công dân và quan hệ cộng đồng', achievedScore: 15, maxScore: 15 },
          { title: 'Khen thưởng, thành tích phong trào', achievedScore: 12, maxScore: 20 },
        ],
      },
    ];
  },

  getTransactions: async (): Promise<Transaction[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          id: '1',
          type: 'Học phí HK2 (2024 - 2025) - VNPAY QR',
          dateTime: '15/02/2025 09:30',
          amount: 18500000,
          status: 'SUCCESS',
        },
        {
          id: '2',
          type: 'Học phí HK1 (2024 - 2025) - Chuyển khoản',
          dateTime: '12/09/2024 14:15',
          amount: 16200000,
          status: 'SUCCESS',
        },
      ];
    }
    if (prof.studentCode === '2001216302') {
      return [
        {
          id: '1',
          type: 'Học phí HK2 (2024 - 2025) - Chuyển khoản OCB',
          dateTime: '10/02/2025 14:15',
          amount: 12500000,
          status: 'SUCCESS',
        },
      ];
    }
    if (prof.studentCode === '2001216304') {
      return [
        {
          id: '1',
          type: 'Học phí HK2 (2024 - 2025) - Ví điện tử MoMo',
          dateTime: '10/02/2025 10:20',
          amount: 11200000,
          status: 'SUCCESS',
        },
      ];
    }
    return [
      {
        id: '1',
        type: 'Học phí HK2 (2024 - 2025) - Chuyển khoản OCB',
        dateTime: '10/02/2025 08:30',
        amount: 15000000,
        status: 'SUCCESS',
      },
    ];
  },

  getReceipts: async (): Promise<Receipt[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          receiptNumber: 'INV-HCMUT-2025-01',
          dateTime: '15/02/2025 09:30',
          collector: 'Phòng Kế hoạch Tài chính - ĐH Bách Khoa TP.HCM',
          amount: 18500000,
          hasInvoice: true,
        },
        {
          receiptNumber: 'INV-HCMUT-2024-02',
          dateTime: '12/09/2024 14:15',
          collector: 'Phòng Kế hoạch Tài chính - ĐH Bách Khoa TP.HCM',
          amount: 16200000,
          hasInvoice: true,
        },
      ];
    }
    if (prof.studentCode === '2001216302') {
      return [
        {
          receiptNumber: 'INV-HUIT-2025-02',
          dateTime: '10/02/2025 14:15',
          collector: 'Phòng Tài chính - ĐH Công Thương TP.HCM',
          amount: 12500000,
          hasInvoice: true,
        },
      ];
    }
    if (prof.studentCode === '2001216304') {
      return [
        {
          receiptNumber: 'INV-HUIT-2025-03',
          dateTime: '10/02/2025 10:20',
          collector: 'Phòng Tài chính - ĐH Công Thương TP.HCM',
          amount: 11200000,
          hasInvoice: true,
        },
      ];
    }
    return [
      {
        receiptNumber: 'INV-HUIT-2025-01',
        dateTime: '10/02/2025 08:30',
        collector: 'Phòng Tài chính - ĐH Công Thương TP.HCM',
        amount: 15000000,
        hasInvoice: true,
      },
    ];
  },

  getNews: async (): Promise<NewsItem[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          id: '1',
          title: 'ĐHQG-HCM: Trường ĐH Bách Khoa công bố chương trình trao đổi sinh viên quốc tế OISP 2026',
          category: 'Hợp tác quốc tế',
          date: '05/05/2026',
          summary: 'Trường Đại học Bách Khoa - ĐHQG-HCM chính thức mở cổng đăng ký chương trình chuyển tiếp và trao đổi sinh viên sang các trường đối tác tại Úc, Nhật Bản và Singapore.',
          content: 'Chương trình liên kết quốc tế OISP dành cho sinh viên xuất sắc năm 2 và năm 3 ngành Khoa học Máy tính, Kỹ thuật Điện - Điện tử và Quản lý Công nghiệp. Sinh viên tham gia sẽ nhận được hỗ trợ học bổng từ 30% đến 50% học phí từ quỹ phát triển ĐHQG-HCM.',
          imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&auto=format&fit=crop&q=80',
        },
        {
          id: '2',
          title: 'Sinh viên Khoa KH&KT Máy tính Bách Khoa xuất sắc giành Giải Nhất Cuộc thi Lập trình ICPC 2026',
          category: 'Thành tích học thuật',
          date: '02/05/2026',
          summary: 'Đội tuyển BK.Coder của sinh viên Bách Khoa đã vượt qua hơn 120 đội tuyển toàn quốc để giành giải Vô địch vòng loại Quốc gia kỳ thi ICPC.',
          content: 'Trải qua 5 giờ thi đấu căng thẳng, đội tuyển trường ĐH Bách Khoa đã hoàn thành trọn vẹn 11/12 bài toán thuật toán phức tạp, qua đó giành quyền đại diện Việt Nam tham dự Vòng Chung kết ICPC Châu Á - Thái Bình Dương.',
          imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&auto=format&fit=crop&q=80',
        },
        {
          id: '3',
          title: 'Hội nghị Khoa học & Công nghệ Bách Khoa lần thứ 19: Chuyên đề Bán dẫn & Trí tuệ Nhân tạo',
          category: 'Khoa học công nghệ',
          date: '28/04/2026',
          summary: 'Hội nghị quy tụ hơn 500 nhà khoa học, chuyên gia hàng đầu từ các tập đoàn công nghệ Intel, Synopsys, NVIDIA và các trường đại học quốc tế.',
          content: 'Hội nghị tập trung thảo luận các giải pháp thiết kế vi mạch tiên tiến, ứng dụng mô hình ngôn ngữ lớn (LLM) trong hệ thống nhúng và chiến lược phát triển nguồn nhân lực bán dẫn chất lượng cao của Việt Nam giai đoạn 2026 - 2030.',
          imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800&auto=format&fit=crop&q=80',
        },
        {
          id: '4',
          title: 'Thông báo đăng ký Khóa luận tốt nghiệp và thực tập doanh nghiệp Học kỳ 1 (2025 - 2026)',
          category: 'Đào tạo',
          date: '25/04/2026',
          summary: 'Phòng Đào tạo thông báo kế hoạch xét điều kiện làm Khóa luận tốt nghiệp kỹ sư và tiếp nhận đăng ký thực tập doanh nghiệp.',
          content: 'Sinh viên khóa 2022 trở về trước đạt tối thiểu 110 tín chỉ tích lũy và điểm trung bình tích lũy từ 2.5/4.0 trở lên tiến hành đăng ký nguyện vọng đề tài trên cổng thông tin MyBK trước ngày 20/05/2026.',
          imageUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&auto=format&fit=crop&q=80',
        },
      ];
    }
    return [
      {
        id: '1',
        title: 'HUIT tổ chức Hội thảo Quốc tế về Trí tuệ Nhân tạo và Ứng dụng thực tiễn',
        category: 'Khoa học công nghệ',
        date: '15/04/2026',
        summary: 'Trường Đại học Công Thương TP.HCM tổ chức Hội thảo khoa học quốc tế về Trí tuệ Nhân tạo và Chuyển đổi số trong giáo dục đại học.',
        content: 'Sáng ngày 15/04/2026, Trường Đại học Công Thương TP.HCM (HUIT) đã long trọng tổ chức Hội thảo khoa học quốc tế về Trí tuệ Nhân tạo và Công nghệ chuyển đổi số trong giáo dục đại học với sự tham gia của các chuyên gia trong nước và quốc tế.',
        imageUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800&auto=format&fit=crop&q=80',
      },
      {
        id: '2',
        title: 'Cuộc thi sáng tạo Robot & IoT sinh viên HUIT chính thức khởi tranh',
        category: 'Đoàn - Hội',
        date: '10/04/2026',
        summary: 'Đoàn Thanh niên phối hợp Khoa CNTT phát động cuộc thi Sáng tạo Robot và IoT năm 2026 dành cho toàn thể sinh viên.',
        content: 'Nhằm thúc đẩy phong trào nghiên cứu khoa học và sáng tạo kỹ thuật, Đoàn Thanh niên - Hội Sinh viên trường phối hợp cùng Khoa CNTT phát động cuộc thi IoT & Robotics HUIT 2026 dành cho tất cả sinh viên đam mê công nghệ.',
        imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&auto=format&fit=crop&q=80',
      },
    ];
  },

  getSurveys: async (): Promise<SurveyItem[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        { id: '1', title: 'Khảo sát chất lượng đào tạo và dịch vụ sinh viên Cơ sở 2 Dĩ An - ĐH Bách Khoa', deadline: '30/05/2026', isCompleted: false },
        { id: '2', title: 'Khảo sát nhu cầu sử dụng hệ thống máy chủ tính toán hiệu năng cao (HPC BK)', deadline: '15/06/2026', isCompleted: true },
        { id: '3', title: 'Đánh giá hoạt động cố vấn học tập và nghiên cứu khoa học sinh viên BK 2025 - 2026', deadline: '20/06/2026', isCompleted: false },
      ];
    }
    return [
      { id: '1', title: 'Khảo sát chất lượng giảng dạy học kỳ 2 năm học 2024 - 2025', deadline: '30/05/2026', isCompleted: false },
      { id: '2', title: 'Khảo sát nhu cầu sử dụng thư viện số và cơ sở vật chất HUIT', deadline: '15/05/2026', isCompleted: true },
    ];
  },

  getCurriculum: async (): Promise<CurriculumSemester[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          semester: 1,
          totalCredits: 17,
          subjects: [
            { code: 'MT1001', name: 'Đại số Tuyến tính', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'MT1003', name: 'Giải tích 1', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO1001', name: 'Nhập môn Điện toán', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'PH1003', name: 'Vật lý đại cương 1', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'LA1001', name: 'Pháp luật đại cương', credits: 4, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 2,
          totalCredits: 18,
          subjects: [
            { code: 'MT1005', name: 'Giải tích 2', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'MT2001', name: 'Xác suất Thống kê', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO1003', name: 'Lập trình C/C++ nâng cao', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO1005', name: 'Cấu trúc Rời rạc cho MT', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'EN1001', name: 'Tiếng Anh học thuật 1', credits: 4, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 3,
          totalCredits: 18,
          subjects: [
            { code: 'CO2003', name: 'Cấu trúc Dữ liệu & Giải thuật', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO2007', name: 'Kiến trúc Máy tính', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'EE2001', name: 'Kỹ thuật số & Mạch số', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'PH1005', name: 'Vật lý đại cương 2', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'EN1003', name: 'Tiếng Anh học thuật 2', credits: 4, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 4,
          totalCredits: 18,
          subjects: [
            { code: 'CO2011', name: 'Hệ điều hành', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO2013', name: 'Mạng Máy tính', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO2015', name: 'Hệ quản trị Cơ sở Dữ liệu', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO2017', name: 'Nguyên lý Ngôn ngữ Lập trình', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'EN2001', name: 'Tiếng Anh chuyên ngành KHMT', credits: 4, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 5,
          totalCredits: 18,
          subjects: [
            { code: 'CO3001', name: 'Lập trình Hướng đối tượng', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO3003', name: 'Trí tuệ Nhân tạo', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO3005', name: 'Phân tích & Thiết kế Giải thuật', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'CO3007', name: 'Kiến trúc Phần mềm', credits: 3, type: 'Tự chọn', isCompleted: true },
            { code: 'ML3001', name: 'Nhập môn Học máy (Machine Learning)', credits: 3, type: 'Tự chọn', isCompleted: true },
          ],
        },
        {
          semester: 6,
          totalCredits: 18,
          subjects: [
            { code: 'CO3011', name: 'Công nghệ Phần mềm', credits: 4, type: 'Bắt buộc' },
            { code: 'CO3013', name: 'An toàn & Bảo mật Hệ thống', credits: 4, type: 'Bắt buộc' },
            { code: 'CO3015', name: 'Xử lý Dữ liệu Lớn (Big Data)', credits: 4, type: 'Tự chọn' },
            { code: 'CO3017', name: 'Điện toán Đám mây', credits: 3, type: 'Tự chọn' },
            { code: 'PR3001', name: 'Đồ án Chuyên ngành KHMT', credits: 3, type: 'Bắt buộc' },
          ],
        },
        {
          semester: 7,
          totalCredits: 17,
          subjects: [
            { code: 'CO4001', name: 'Chuyên đề Trí tuệ Nhân tạo nâng cao', credits: 4, type: 'Tự chọn' },
            { code: 'CO4003', name: 'Thị giác Máy tính & Xử lý Ảnh', credits: 4, type: 'Tự chọn' },
            { code: 'CO4005', name: 'Học sâu (Deep Learning)', credits: 4, type: 'Tự chọn' },
            { code: 'IN4001', name: 'Thực tập Tốt nghiệp Doanh nghiệp', credits: 5, type: 'Bắt buộc' },
          ],
        },
        {
          semester: 8,
          totalCredits: 18,
          subjects: [
            { code: 'CO4099', name: 'Khóa luận Tốt nghiệp Kỹ sư', credits: 14, type: 'Bắt buộc' },
            { code: 'CO4091', name: 'Chuyên đề Đạo đức Nghề nghiệp CNTT', credits: 4, type: 'Bắt buộc' },
          ],
        },
      ];
    }
    if (prof.studentCode === '2001216304') {
      return [
        {
          semester: 1,
          totalCredits: 18,
          subjects: [
            { code: 'ACC101', name: 'Nguyên lý kế toán', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'ECO101', name: 'Kinh tế vi mô', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'MAT101', name: 'Toán cao cấp cho kinh tế', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'ENG101', name: 'Tiếng Anh tổng quát 1', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'LAW101', name: 'Pháp luật đại cương', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'POL101', name: 'Triết học Mác - Lênin', credits: 3, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 2,
          totalCredits: 19,
          subjects: [
            { code: 'ACC102', name: 'Kế toán Tài chính 1', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'ACC103', name: 'Thuế và Kế toán Thuế', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'ECO102', name: 'Kinh tế vĩ mô', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'INT101', name: 'Tin học ứng dụng Kế toán', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'ENG102', name: 'Tiếng Anh chuyên ngành Kế toán 1', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'POL102', name: 'Kinh tế chính trị Mác - Lênin', credits: 2, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 3,
          totalCredits: 19,
          subjects: [
            { code: 'ACC201', name: 'Kế toán Tài chính 2', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'ACC202', name: 'Kế toán Chi phí', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'STA201', name: 'Thống kê kinh doanh & kinh tế', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'LAW201', name: 'Luật kinh tế và Doanh nghiệp', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'ENG201', name: 'Tiếng Anh chuyên ngành Kế toán 2', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'POL201', name: 'Chủ nghĩa xã hội khoa học', credits: 2, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 4,
          totalCredits: 18,
          subjects: [
            { code: 'ACC203', name: 'Kế toán Quản trị 1', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'FIN201', name: 'Tài chính doanh nghiệp căn bản', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'ACC204', name: 'Hệ thống thông tin kế toán', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'FIN202', name: 'Phân tích Báo cáo Tài chính', credits: 3, type: 'Bắt buộc', isCompleted: true },
            { code: 'POL202', name: 'Tư tưởng Hồ Chí Minh', credits: 2, type: 'Bắt buộc', isCompleted: true },
            { code: 'HIS201', name: 'Lịch sử Đảng Cộng sản Việt Nam', credits: 3, type: 'Bắt buộc', isCompleted: true },
          ],
        },
        {
          semester: 5,
          totalCredits: 18,
          subjects: [
            { code: 'ACC301', name: 'Kế toán Tài chính 3 (Tập đoàn)', credits: 4, type: 'Bắt buộc', isCompleted: true },
            { code: 'ACC302', name: 'Kế toán Quản trị 2 (Chiến lược)', credits: 3, type: 'Bắt buộc' },
            { code: 'AUD301', name: 'Kiểm toán căn bản', credits: 4, type: 'Bắt buộc' },
            { code: 'FIN301', name: 'Thị trường tài chính & Các định chế', credits: 4, type: 'Tự chọn' },
            { code: 'SKL301', name: 'Kỹ năng giao tiếp & Nghề nghiệp Kế toán', credits: 3, type: 'Tự chọn' },
          ],
        },
        {
          semester: 6,
          totalCredits: 18,
          subjects: [
            { code: 'AUD302', name: 'Kiểm toán Báo cáo Tài chính', credits: 4, type: 'Bắt buộc' },
            { code: 'ACC303', name: 'Kế toán Công & Hành chính sự nghiệp', credits: 4, type: 'Bắt buộc' },
            { code: 'ACC304', name: 'Thực hành mô phỏng ERP Kế toán', credits: 3, type: 'Bắt buộc' },
            { code: 'PRJ301', name: 'Đồ án Chuyên ngành Kế toán - Kiểm toán', credits: 4, type: 'Bắt buộc' },
            { code: 'RSK301', name: 'Quản trị rủi ro và Kiểm soát nội bộ', credits: 3, type: 'Tự chọn' },
          ],
        },
        {
          semester: 7,
          totalCredits: 18,
          subjects: [
            { code: 'INT301', name: 'Thực tập Tốt nghiệp tại Doanh nghiệp', credits: 6, type: 'Bắt buộc' },
            { code: 'ACC401', name: 'Kế toán Quốc tế (Chuẩn mực IFRS)', credits: 4, type: 'Tự chọn' },
            { code: 'VAL401', name: 'Thẩm định giá và Định giá Doanh nghiệp', credits: 4, type: 'Tự chọn' },
            { code: 'ACC402', name: 'Kế toán Môi trường & Báo cáo ESG', credits: 4, type: 'Tự chọn' },
          ],
        },
        {
          semester: 8,
          totalCredits: 17,
          subjects: [
            { code: 'THE401', name: 'Khóa luận Tốt nghiệp Cử nhân Kế toán', credits: 10, type: 'Bắt buộc' },
            { code: 'ETH401', name: 'Đạo đức nghề nghiệp Kế toán viên', credits: 4, type: 'Bắt buộc' },
            { code: 'DAT401', name: 'Kế toán số & Phân tích Dữ liệu Tài chính', credits: 3, type: 'Bắt buộc' },
          ],
        },
      ];
    }
    return [
      {
        semester: 1,
        totalCredits: 18,
        subjects: [
          { code: 'INT101', name: 'Lập trình ứng dụng Java', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT102', name: 'Lập trình Web nâng cao', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT103', name: 'Hệ quản trị CSDL', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'MAT101', name: 'Toán rời rạc', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'ENG101', name: 'Tiếng Anh chuyên ngành', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'POL101', name: 'Triết học Mác - Lênin', credits: 3, type: 'Bắt buộc', isCompleted: true },
        ],
      },
      {
        semester: 2,
        totalCredits: 19,
        subjects: [
          { code: 'INT104', name: 'An toàn Thông tin', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT105', name: 'Trí tuệ Nhân tạo', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT106', name: 'Phát triển & Thiết kế HTTT', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT107', name: 'Quản trị dự án CNTT', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'POL102', name: 'Kinh tế chính trị Mác - Lênin', credits: 2, type: 'Bắt buộc', isCompleted: true },
          { code: 'PE102', name: 'Giáo dục thể chất 2', credits: 2, type: 'Bắt buộc', isCompleted: true },
          { code: 'MAT102', name: 'Xác suất thống kê ứng dụng', credits: 3, type: 'Bắt buộc', isCompleted: true },
        ],
      },
      {
        semester: 3,
        totalCredits: 20,
        subjects: [
          { code: 'INT201', name: 'Cấu trúc Dữ liệu & Giải thuật nâng cao', credits: 4, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT202', name: 'Kiến trúc Máy tính và Hệ điều hành Linux', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT203', name: 'Lập trình Web Frontend Hiện đại (React)', credits: 4, type: 'Bắt buộc', isCompleted: true },
          { code: 'ENG201', name: 'Tiếng Anh giao tiếp Quốc tế TOEIC 1', credits: 4, type: 'Bắt buộc', isCompleted: true },
          { code: 'POL201', name: 'Chủ nghĩa xã hội khoa học', credits: 2, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT204', name: 'Mạng máy tính và Truyền thông dữ liệu', credits: 3, type: 'Bắt buộc', isCompleted: true },
        ],
      },
      {
        semester: 4,
        totalCredits: 20,
        subjects: [
          { code: 'INT205', name: 'Lập trình Backend chuyên sâu (NodeJS/Spring)', credits: 4, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT206', name: 'Phân tích & Thiết kế Giải thuật', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT207', name: 'Thiết kế Giao diện UI/UX', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'POL202', name: 'Tư tưởng Hồ Chí Minh', credits: 2, type: 'Bắt buộc', isCompleted: true },
          { code: 'HIS201', name: 'Lịch sử Đảng Cộng sản Việt Nam', credits: 3, type: 'Bắt buộc', isCompleted: true },
          { code: 'ENG202', name: 'Tiếng Anh giao tiếp Quốc tế TOEIC 2', credits: 5, type: 'Bắt buộc', isCompleted: true },
        ],
      },
      {
        semester: 5,
        totalCredits: 20,
        subjects: [
          { code: 'INT301', name: 'Công nghệ Phần mềm & Agile/Scrum', credits: 4, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT302', name: 'Lập trình ứng dụng Di động (Mobile App)', credits: 4, type: 'Bắt buộc', isCompleted: true },
          { code: 'INT303', name: 'Kiểm thử & Đảm bảo Chất lượng Phần mềm (QA/QC)', credits: 4, type: 'Bắt buộc' },
          { code: 'INT304', name: 'Nhập môn Học máy (Machine Learning)', credits: 4, type: 'Tự chọn' },
          { code: 'SKL301', name: 'Kỹ năng làm việc nhóm & Thuyết trình chuyên nghiệp', credits: 4, type: 'Tự chọn' },
        ],
      },
      {
        semester: 6,
        totalCredits: 19,
        subjects: [
          { code: 'INT305', name: 'Điện toán Đám mây & Thực hành DevOps (AWS/Docker)', credits: 4, type: 'Bắt buộc' },
          { code: 'INT306', name: 'An toàn và Bảo mật Hệ thống Web/App', credits: 4, type: 'Bắt buộc' },
          { code: 'INT307', name: 'Xử lý Dữ liệu Lớn (Big Data)', credits: 4, type: 'Tự chọn' },
          { code: 'PRJ301', name: 'Đồ án Chuyên ngành Công nghệ Thông tin', credits: 4, type: 'Bắt buộc' },
          { code: 'INT308', name: 'Phát triển Hệ thống Microservices', credits: 3, type: 'Tự chọn' },
        ],
      },
      {
        semester: 7,
        totalCredits: 18,
        subjects: [
          { code: 'INT401', name: 'Thực tập Tốt nghiệp Doanh nghiệp CNTT', credits: 6, type: 'Bắt buộc' },
          { code: 'INT402', name: 'Chuyên đề Trí tuệ Nhân tạo & Xử lý ngôn ngữ tự nhiên', credits: 4, type: 'Tự chọn' },
          { code: 'INT403', name: 'Thị giác Máy tính và Xử lý ảnh số', credits: 4, type: 'Tự chọn' },
          { code: 'INT404', name: 'Internet vạn vật (IoT) và Hệ thống nhúng', credits: 4, type: 'Tự chọn' },
        ],
      },
      {
        semester: 8,
        totalCredits: 17,
        subjects: [
          { code: 'THE401', name: 'Khóa luận Tốt nghiệp Kỹ sư/Cử nhân CNTT', credits: 10, type: 'Bắt buộc' },
          { code: 'ETH401', name: 'Đạo đức Nghề nghiệp và Pháp luật CNTT', credits: 3, type: 'Bắt buộc' },
          { code: 'ENT401', name: 'Khởi nghiệp Đổi mới Sáng tạo trong Kỷ nguyên Số', credits: 4, type: 'Bắt buộc' },
        ],
      },
    ];
  },

  getAchievements: async (): Promise<AchievementItem[]> => {
    const prof = await studentApi.getProfile();
    const isHcmut = prof.schoolCode === 'HCMUT' || prof.studentCode?.startsWith('200122') || prof.email?.includes('hcmut');
    if (isHcmut) {
      return [
        {
          id: '1',
          title: 'Huy chương Vàng Olympic Tin học Sinh viên Toàn quốc',
          semester: 'Học kỳ 1 (2024 - 2025)',
          decision: 'QĐ số 892/QĐ-BGDĐT của Bộ GD&ĐT & Hội Tin học VN',
          amount: 'Bằng khen & 10.000.000 VNĐ',
          icon: 'medal',
          color: '#F59E0B',
          bg: '#FEF3C7',
        },
        {
          id: '2',
          title: 'Danh hiệu Sinh viên 5 Tốt cấp Đại học Quốc gia TP.HCM',
          semester: 'Học kỳ 2 (2023 - 2024)',
          decision: 'QĐ số 115/QĐ-ĐHQG của Ban Thường vụ Đoàn ĐHQG-HCM',
          amount: 'Bằng khen & Biểu trưng danh dự',
          icon: 'ribbon',
          color: '#2563EB',
          bg: '#EFF6FF',
        },
        {
          id: '3',
          title: 'Học bổng Khuyến khích Học tập Bách Khoa loại Xuất sắc',
          semester: 'Học kỳ 1 (2024 - 2025)',
          decision: 'QĐ số 450/QĐ-ĐHBK của Hiệu trưởng Trường ĐH Bách Khoa',
          amount: 'Học bổng 100% học phí (18.500.000 VNĐ)',
          icon: 'school',
          color: '#059669',
          bg: '#ECFDF5',
        },
      ];
    }
    return [
      {
        id: '1',
        title: 'Giải Nhì Cuộc thi Nghiên cứu Khoa học SV HUIT',
        semester: 'Học kỳ 1 (2024 - 2025)',
        decision: 'QĐ số 412/QĐ-DCT của Hiệu trưởng Trường ĐH Công Thương TP.HCM',
        amount: 'Giấy khen & 5.000.000 VNĐ',
        icon: 'trophy',
        color: '#D97706',
        bg: '#FEF3C7',
      },
      {
        id: '2',
        title: 'Danh hiệu Sinh viên 5 Tốt cấp Trường',
        semester: 'Học kỳ 2 (2023 - 2024)',
        decision: 'QĐ số 45/QĐ-ĐTN của Đoàn trường ĐH Công Thương TP.HCM',
        amount: 'Giấy chứng nhận & 2.000.000 VNĐ',
        icon: 'ribbon',
        color: '#2563EB',
        bg: '#EFF6FF',
      },
    ];
  },
};
