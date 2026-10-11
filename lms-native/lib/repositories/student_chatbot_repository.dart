import '../models/student/student_profile.dart';
import '../models/student/student_schedule.dart';
import '../models/student/student_grade.dart';
import '../models/student/student_attendance.dart';
import '../models/student/student_debt.dart';
import '../models/student/student_conduct.dart';
import '../models/student/student_notification.dart';
import '../models/student/student_survey.dart';
import 'core_chatbot_repository.dart';

class StudentChatbotRepository extends CoreChatbotRepository {
  StudentChatbotRepository(
      StudentProfile profile,
      List<StudentSchedule> schedules,
      List<StudentGrade> grades,
      List<StudentAttendance> attendances,
      List<StudentDebt> debts,
      List<StudentConduct> conducts,
      List<StudentNotification> notifications,
      List<StudentSurvey> surveys) : super(roleKey: 'student') {
    
    // Format Lịch học
    String scheduleStr = schedules.isEmpty 
        ? "Không có lịch học tuần này." 
        : schedules.map((s) => "- ${s.courseName} (${s.classCode}), Phòng: ${s.roomName}, Thứ: ${s.dayOfWeek}, Tiết: ${s.startPeriod}-${s.endPeriod}, GV: ${s.teacherName ?? 'Chưa cập nhật'}").join("\n          ");

    // Format Điểm số
    String gradeStr = grades.isEmpty 
        ? "Chưa có thông biến điểm số." 
        : grades.map((g) => "- ${g.courseName}: Tổng kết ${g.gradeTotal ?? '?'} (${g.gradeLetter ?? '?'})").join("\n          ");

    // Format Điểm danh
    String attendanceStr = attendances.isEmpty 
        ? "Chưa có thông tin điểm danh." 
        : attendances.map((a) => "- ${a.courseName}: Vắng phép ${a.absentWithPermission ?? 0}, Không phép ${a.absentWithoutPermission ?? 0}, Trễ ${a.late ?? 0}").join("\n          ");

    // Format Học phí
    String debtStr = debts.isEmpty
        ? "Không có khoản nợ học phí nào."
        : debts.where((d) => d.isPaid == 0).map((d) => "- Môn ${d.courseName}: Còn nợ ${d.mucNop ?? 0} VND").join("\n          ");

    // Format Rèn luyện
    String conductStr = conducts.isEmpty
        ? "Chưa có điểm rèn luyện."
        : conducts.map((c) => "- Học kỳ ${c.semesterName}: Điểm rèn luyện ${c.conductScore ?? '?'} (${c.conductGrade ?? '?'}), Học bổng: ${c.scholarshipName ?? 'Không'}").join("\n          ");

    // Format Tin tức
    String notiStr = notifications.isEmpty
        ? "Không có thông báo mới."
        : notifications.take(5).map((n) => "- [${n.createdAt?.day ?? '?'}/${n.createdAt?.month ?? '?'}] ${n.title}: ${n.body}").join("\n          ");

    // Format Khảo sát
    String surveyStr = surveys.isEmpty
        ? "Không có bài khảo sát nào."
        : surveys.where((s) => s.isCompleted == 0).map((s) => "- Khảo sát môn ${s.courseName} (Chưa làm)").join("\n          ");

    String systemInstruction = '''
          Bạn là Trợ lý ảo AI của Hệ thống Quản lý Đào tạo (EduSpace). 
          Nhiệm vụ DUY NHẤT của bạn là hỗ trợ sinh viên các vấn đề liên quan đến: học tập, lịch học, điểm số, học phí, rèn luyện, khảo sát, tin tức và các quy chế nhà trường.
          
          [THÔNG TIN NGỮ CẢNH CỦA SINH VIÊN ĐANG TRÒ CHUYỆN]
          * Thông tin hệ thống:
          - Thời gian hiện tại: ${DateTime.now().toString()}

          * Thông tin cá nhân:
          - Tên sinh viên: ${profile.fullName ?? 'Không rõ'}
          - Mã sinh viên: ${profile.studentCode ?? 'Không rõ'}
          - Lớp: ${profile.className ?? 'Không rõ'}
          - Ngành: ${profile.major ?? 'Không rõ'}
          - Khoa: ${profile.departmentName ?? 'Không rõ'}
          
          * Lịch học tuần này:
          $scheduleStr

          * Điểm số:
          $gradeStr

          * Tình hình điểm danh:
          $attendanceStr
          
          * Học phí (Các khoản chưa đóng):
          ${debtStr.isEmpty ? "Đã đóng đủ học phí." : debtStr}
          
          * Điểm rèn luyện & Học bổng:
          $conductStr
          
          * Khảo sát chưa làm:
          ${surveyStr.isEmpty ? "Đã hoàn thành tất cả khảo sát." : surveyStr}
          
          * Tin tức nổi bật gần đây:
          $notiStr
          
          QUY TẮC NGHIÊM NGẶT:
          1. TUYỆT ĐỐI KHÔNG trả lời các câu hỏi ngoài lề như: giải trí, phim ảnh, âm nhạc, chính trị, thời tiết.
          2. Nếu sinh viên hỏi ngoài lề, bạn PHẢI từ chối lịch sự và nhắc nhở họ quay lại chủ đề học tập.
          3. Giọng điệu chuyên nghiệp, thân thiện, xưng "mình" và gọi "bạn" hoặc "sinh viên" hoặc tên của sinh viên.
          4. Nếu có khảo sát chưa làm hoặc nợ học phí, thỉnh thoảng nhắc nhở nhẹ nhàng.
        ''';

    initChatbot(systemInstruction);
  }
}
