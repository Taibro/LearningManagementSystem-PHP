import '../models/lecturer/teacher_profile.dart';
import '../models/lecturer/monthly_salary.dart';
import '../models/lecturer/teaching_statistic.dart';
import '../models/lecturer/teacher_material.dart';
import 'core_chatbot_repository.dart';

class LecturerChatbotRepository extends CoreChatbotRepository {
  LecturerChatbotRepository(
      TeacherProfile profile,
      MonthlySalary salary,
      TeachingStatistic stats,
      List<TeacherMaterial> materials) : super(roleKey: 'lecturer') {
    
    // Format Bảng lương
    String salaryStr = "Tháng ${salary.periodMonth}/${salary.periodYear}: "
        "Lương cơ bản ${salary.baseAmount ?? 0} đ, "
        "Giảng dạy ${salary.sessionAmount ?? 0} đ, "
        "Thưởng ${salary.bonusAmount ?? 0} đ, "
        "Trừ ${salary.deductionAmount ?? 0} đ => Thực nhận: ${salary.netAmount ?? 0} đ.";

    // Format Thống kê giảng dạy
    String statsStr = "Học kỳ: ${stats.currentSemesterLabel ?? '?'}\n"
        "          - Tổng số tiết: ${stats.totalPeriods ?? 0} (Lý thuyết: ${stats.theoryPeriods ?? 0}, Thực hành: ${stats.labPeriods ?? 0})\n"
        "          - Ca thi: ${stats.examShifts ?? 0} (Sắp tới: ${stats.upcomingExamShifts ?? 0})\n"
        "          - Tiến độ hoàn thành: ${stats.overallProgress ?? 0}%\n"
        "          - Nhắc nhở: ${(stats.reminders == null || stats.reminders!.isEmpty) ? 'Không có' : stats.reminders!.join(', ')}";

    // Format Tài liệu bài giảng
    String materialStr = materials.isEmpty
        ? "Chưa có tài liệu nào."
        : materials.map((m) => "- [${m.classInfo ?? '?'}] ${m.title ?? '?'} (${m.fileSize ?? '?'}, ${m.uploadDate ?? '?'})").join("\n          ");

    String systemInstruction = '''
          Bạn là Trợ lý ảo AI của Hệ thống Quản lý Đào tạo (EduSpace). 
          Nhiệm vụ DUY NHẤT của bạn là hỗ trợ GIẢNG VIÊN các vấn đề liên quan đến: giảng dạy, lịch trình, bảng lương, thống kê tiến độ, tài liệu học tập, và các quy chế nhà trường.
          
          [THÔNG TIN NGỮ CẢNH CỦA GIẢNG VIÊN ĐANG TRÒ CHUYỆN]
          * Thông tin hệ thống:
          - Thời gian hiện tại: ${DateTime.now().toString()}

          * Thông tin cá nhân:
          - Tên giảng viên: ${profile.fullName ?? 'Không rõ'}
          - Khoa: ${profile.departmentName ?? 'Không rõ'}
          - Chuyên ngành: ${profile.specialization ?? 'Không rõ'}
          - Học vị: ${profile.degree ?? 'Không rõ'}
          
          * Thống kê giảng dạy:
          $statsStr

          * Bảng lương tháng hiện tại:
          $salaryStr

          * Tài liệu bài giảng đã tải lên:
          $materialStr
          
          QUY TẮC NGHIÊM NGẶT:
          1. TUYỆT ĐỐI KHÔNG trả lời các câu hỏi ngoài lề như: giải trí, phim ảnh, âm nhạc, chính trị, thời tiết.
          2. Nếu giảng viên hỏi ngoài lề, bạn PHẢI từ chối lịch sự và nhắc nhở họ quay lại chủ đề công việc.
          3. Giọng điệu chuyên nghiệp, thân thiện, xưng "mình" và gọi "thầy/cô" hoặc tên của giảng viên.
          4. Hỗ trợ cung cấp thông tin ngắn gọn, súc tích dựa vào dữ liệu được cung cấp.
        ''';

    initChatbot(systemInstruction);
  }
}
