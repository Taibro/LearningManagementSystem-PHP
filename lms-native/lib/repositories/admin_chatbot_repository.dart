import '../models/admin/admin_dashboard_stats.dart';
import '../models/admin/admin_tuition_invoice.dart';
import '../models/admin/admin_student.dart';
import '../models/admin/admin_teacher.dart';
import '../models/admin/admin_class.dart';
import '../models/admin/admin_course.dart';
import 'core_chatbot_repository.dart';
import '../screens/admin/data/mock_admin_schedule_data.dart' show mockClasses;

class AdminChatbotRepository extends CoreChatbotRepository {
  AdminChatbotRepository({
    required AdminDashboardStats stats,
    required List<AdminTuitionInvoice> unpaidInvoices,
    required List<AdminStudent> students,
    required List<AdminTeacher> teachers,
    required List<AdminClass> classes,
    required List<AdminCourse> courses,
  }) : super(roleKey: 'admin') {
    String statsStr = "Thông tin tổng quan:\n"
        "          - Tên trường: ${stats.schoolName ?? 'Không rõ'}\n"
        "          - Tổng số sinh viên: ${stats.totalStudents ?? 0}\n"
        "          - Tổng số giảng viên: ${stats.totalTeachers ?? 0}\n"
        "          - Tổng số lớp học: ${stats.totalClasses ?? 0}\n"
        "          - Số sinh viên vắng mặt hôm nay: ${stats.todayAbsences ?? 0}\n"
        "          - Tổng nợ học phí: ${stats.totalTuitionDebt ?? 0} đ";

    String unpaidStr = "Danh sách sinh viên đang nợ học phí:\n";
    if (unpaidInvoices.isEmpty) {
      unpaidStr += "Hiện tại không có sinh viên nào nợ học phí.\n";
    } else {
      final displayInvoices = unpaidInvoices.take(50).toList();
      for (var inv in displayInvoices) {
        final debt = (inv.totalAmount ?? 0) - (inv.paidAmount ?? 0);
        unpaidStr += " - Sinh viên: ${inv.studentName} (Mã: ${inv.studentCode}) nợ: $debt đ\n";
      }
      if (unpaidInvoices.length > 50) {
        unpaidStr += " - ... và ${unpaidInvoices.length - 50} sinh viên khác.\n";
      }
    }

    String studentsStr = "Danh sách Sinh viên:\n";
    final displayStudents = students.take(50).toList();
    for (var s in displayStudents) {
      studentsStr += " - [${s.studentCode}] ${s.fullName} | Lớp: ${s.className ?? 'N/A'} | Ngành: ${s.major ?? 'N/A'}\n";
    }
    if (students.length > 50) studentsStr += " - ... và ${students.length - 50} sinh viên khác.\n";

    String teachersStr = "Danh sách Giảng viên:\n";
    final displayTeachers = teachers.take(50).toList();
    for (var t in displayTeachers) {
      teachersStr += " - [${t.teacherCode}] ${t.fullName} | Chuyên ngành: ${t.specialization ?? 'N/A'} | Khoa: ${t.departmentName ?? 'N/A'}\n";
    }
    if (teachers.length > 50) teachersStr += " - ... và ${teachers.length - 50} giảng viên khác.\n";

    String classesStr = "Danh sách Lớp học:\n";
    final displayClasses = classes.take(50).toList();
    for (var c in displayClasses) {
      classesStr += " - [${c.code}] Môn: ${c.courseName ?? 'N/A'} | Kỳ: ${c.semesterName ?? 'N/A'} | Sĩ số: ${c.enrolledStudents ?? 0}/${c.maxStudents ?? 0}\n";
    }
    if (classes.length > 50) classesStr += " - ... và ${classes.length - 50} lớp học khác.\n";

    String coursesStr = "Danh sách Môn học:\n";
    final displayCourses = courses.take(50).toList();
    for (var c in displayCourses) {
      coursesStr += " - [${c.code}] ${c.name} | Tín chỉ: ${c.credits ?? 0} | Khoa quản lý: ${c.departmentName ?? 'N/A'}\n";
    }
    if (courses.length > 50) coursesStr += " - ... và ${courses.length - 50} môn học khác.\n";

    String scheduleStr = "Lịch học tuần này (Dữ liệu Lịch Công tác/Lịch học):\n";
    for (var c in mockClasses) {
      scheduleStr += " - Môn: ${c['subject']} | Giảng viên: ${c['lecturer']} | ${c['day']} ${c['session']} | Phòng: ${c['room']}\n";
    }

    String systemInstruction = '''
          Bạn là Trợ lý ảo AI của Hệ thống Quản lý Đào tạo (EduSpace). 
          Bạn có ĐẶC QUYỀN TRUY CẬP VÀO TOÀN BỘ DỮ LIỆU trong cơ sở dữ liệu của trường học đang quản trị. 
          Nhiệm vụ của bạn là hỗ trợ QUẢN TRỊ VIÊN (Ban Giám Hiệu/Admin) giải đáp MỌI THÔNG TIN liên quan đến hoạt động của trường (như sinh viên, giảng viên, lớp học, môn học, tài chính, lịch công tác, điểm số, điểm danh, v.v.).
          
          [THÔNG TIN NGỮ CẢNH CỦA TRƯỜNG HỌC]
          * Thời gian hiện tại: ${DateTime.now().toString()}
          
          * Thống kê tổng quan:
          $statsStr
          
          * Dữ liệu Tài chính chi tiết:
          $unpaidStr
          
          * Dữ liệu Danh mục:
          $studentsStr
          $teachersStr
          $classesStr
          $coursesStr
          
          * Dữ liệu Lịch học toàn trường:
          $scheduleStr
          
          QUY TẮC NGHIÊM NGẶT:
          1. TUYỆT ĐỐI KHÔNG trả lời các câu hỏi ngoài lề như: giải trí, phim ảnh, âm nhạc, chính trị, thời tiết.
          2. Nếu người dùng hỏi ngoài lề, bạn PHẢI từ chối lịch sự và nhắc nhở họ quay lại chủ đề quản trị trường học.
          3. Giọng điệu chuyên nghiệp, xưng "mình" và gọi "Thầy/Cô Ban Giám Hiệu" hoặc "Quản trị viên".
          4. Hỗ trợ cung cấp thông tin ngắn gọn, súc tích và có số liệu rõ ràng dựa vào dữ liệu được cung cấp.
        ''';

    initChatbot(systemInstruction);
  }
}
