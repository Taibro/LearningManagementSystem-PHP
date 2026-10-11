import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/student/student_profile.dart';
import '../models/student/student_schedule.dart';
import '../models/student/student_grade.dart';
import '../models/student/student_attendance.dart';
import '../models/student/student_debt.dart';
import '../models/student/student_conduct.dart';
import '../models/student/student_notification.dart';
import '../models/student/student_survey.dart';
import '../models/student/teacher_chat_response.dart';
import '../models/student/tuition_payment.dart';

class StudentRepository {
  final DioClient _dioClient;

  StudentRepository(this._dioClient);

  Future<StudentProfile> getProfile() async {
    try {
      final response = await _dioClient.dio.get('/student/profile');
      return StudentProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy thông tin cá nhân: ${e.message}');
    }
  }

  Future<List<StudentSchedule>> getWeeklySchedule({String? date}) async {
    try {
      final queryParams = date != null ? {'date': date} : null;
      final response = await _dioClient.dio.get('/student/weekly-schedule', queryParameters: queryParams);
      return (response.data as List).map((e) => StudentSchedule.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy lịch học: ${e.message}');
    }
  }

  Future<List<StudentSchedule>> getProgressSchedule({int semesterId = 0}) async {
    try {
      final response = await _dioClient.dio.get('/student/progress-schedule', queryParameters: {'semesterId': semesterId});
      return (response.data as List).map((e) => StudentSchedule.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy tiến độ lịch học: ${e.message}');
    }
  }

  Future<List<StudentGrade>> getGrades() async {
    try {
      final response = await _dioClient.dio.get('/student/grades');
      return (response.data as List).map((e) => StudentGrade.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy kết quả học tập: ${e.message}');
    }
  }

  Future<List<StudentAttendance>> getAttendance() async {
    try {
      final response = await _dioClient.dio.get('/student/attendance');
      return (response.data as List).map((e) => StudentAttendance.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy thông tin điểm danh: ${e.message}');
    }
  }

  Future<List<StudentConduct>> getConduct() async {
    try {
      final response = await _dioClient.dio.get('/student/conduct');
      return (response.data as List).map((e) => StudentConduct.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy điểm rèn luyện: ${e.message}');
    }
  }

  Future<List<StudentDebt>> getDebtDetail() async {
    try {
      final response = await _dioClient.dio.get('/student/debt-detail');
      return (response.data as List).map((e) => StudentDebt.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy công nợ học phí: ${e.message}');
    }
  }

  Future<List<StudentNotification>> getNotifications() async {
    try {
      final response = await _dioClient.dio.get('/student/notifications');
      return (response.data as List).map((e) => StudentNotification.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy tin tức: ${e.message}');
    }
  }

  Future<List<StudentSurvey>> getSurveys() async {
    try {
      final response = await _dioClient.dio.get('/student/surveys');
      return (response.data as List).map((e) => StudentSurvey.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy khảo sát: ${e.message}');
    }
  }

  Future<List<TeacherChatResponse>> getTeachersForChat({int semesterId = 0}) async {
    try {
      final response = await _dioClient.dio.get('/student/teachers', queryParameters: {'semesterId': semesterId});
      return (response.data as List).map((e) => TeacherChatResponse.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy danh sách giảng viên: ${e.message}');
    }
  }

  Future<List<TuitionPayment>> getPayments() async {
    try {
      final response = await _dioClient.dio.get('/student/payments');
      return (response.data as List).map((e) => TuitionPayment.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lấy lịch sử giao dịch: ${e.message}');
    }
  }

  Future<void> scanQrCode(String qrToken) async {
    try {
      await _dioClient.dio.post(
        '/student/attendance/qr/scan', 
        data: {
          'qrToken': qrToken,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi điểm danh: ${e.message}');
    }
  }
}
