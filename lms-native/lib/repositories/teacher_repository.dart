import 'package:dio/dio.dart';
import '../models/lecturer/teacher_profile.dart';
import '../models/lecturer/monthly_salary.dart';
import '../models/lecturer/teaching_statistic.dart';
import '../models/lecturer/teacher_attendance.dart';
import '../models/lecturer/teacher_material.dart';
import '../models/lecturer/teacher_schedule.dart';
import '../models/admin/notification_response.dart';
import '../models/lecturer/active_class_schedule.dart';
import '../models/lecturer/teacher_request.dart';

class TeacherRepository {
  final Dio _dio;

  TeacherRepository(this._dio);

  Future<TeacherProfile> getProfile() async {
    try {
      final response = await _dio.get('/lecturer/profile');
      return TeacherProfile.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin giảng viên: $e');
    }
  }

  Future<MonthlySalary> getMonthlySalary(int year, int month) async {
    try {
      final response = await _dio.get(
        '/lecturer/salaries/monthly',
        queryParameters: {'year': year, 'month': month},
      );
      return MonthlySalary.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return MonthlySalary(
          periodMonth: month,
          periodYear: year,
          baseAmount: 0,
          sessionAmount: 0,
          bonusAmount: 0,
          deductionAmount: 0,
          netAmount: 0,
        );
      }
      throw Exception('Lỗi khi tải bảng lương: $e');
    }
  }

  Future<TeachingStatistic> getDashboardStatistics() async {
    try {
      final response = await _dio.get('/lecturer/statistics/dashboard');
      return TeachingStatistic.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải thống kê giảng dạy: $e');
    }
  }

  Future<List<TeacherMaterial>> getMaterials(int teacherId) async {
    try {
      final response = await _dio.get(
        '/lecturer/materials',
        queryParameters: {'teacherId': teacherId},
      );
      
      final List<dynamic> data = response.data;
      return data.map((m) => TeacherMaterial.fromJson(m)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải tài liệu bài giảng: $e');
    }
  }

  Future<TeacherAttendanceList> getAttendanceList(
      int classId, int scheduleId, String date) async {
    try {
      final response = await _dio.get(
        '/lecturer/attendance',
        queryParameters: {
          'classId': classId,
          'scheduleId': scheduleId,
          'date': date,
        },
      );
      return TeacherAttendanceList.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách sinh viên: $e');
    }
  }

  Future<void> saveAttendance(Map<String, dynamic> request) async {
    try {
      await _dio.post('/lecturer/attendance/save', data: request);
    } catch (e) {
      throw Exception('Lỗi khi lưu điểm danh: $e');
    }
  }

  Future<List<TeacherSchedule>> getWeeklySchedule({String? date}) async {
    try {
      final response = await _dio.get(
        '/lecturer/schedules/weekly-schedule',
        queryParameters: date != null ? {'date': date} : null,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => TeacherSchedule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch dạy: $e');
    }
  }

  Future<List<NotificationResponse>> getMyNotifications() async {
    try {
      final response = await _dio.get('/notifications/my-notifications');
      final List<dynamic> data = response.data;
      return data.map((json) => NotificationResponse.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải thông báo: $e');
    }
  }

  Future<List<ActiveClassSchedule>> getActiveClasses() async {
    try {
      final response = await _dio.get('/lecturer/schedules/active-classes');
      final List<dynamic> data = response.data;
      return data.map((json) => ActiveClassSchedule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách lớp đang dạy: $e');
    }
  }

  Future<Map<String, dynamic>> generateQr(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post('/lecturer/attendance/qr/generate', data: request);
      return response.data;
    } catch (e) {
      throw Exception('Lỗi khi tạo mã QR: $e');
    }
  }

  Future<void> uploadMaterial(dynamic request) async {
    try {
      await _dio.post('/lecturer/materials/upload', data: request);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception('Lỗi khi tải lên tài liệu (Mã lỗi: ${e.response?.statusCode}): ${e.response?.data}');
      }
      throw Exception('Lỗi khi tải lên tài liệu: $e');
    }
  }

  Future<List<TeacherRequest>> getTeachingRequests() async {
    try {
      final response = await _dio.get('/lecturer/requests');
      return (response.data['data'] as List)
          .map((e) => TeacherRequest.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đề xuất: $e');
    }
  }

  Future<void> createTeachingRequest(Map<String, dynamic> data) async {
    try {
      await _dio.post('/lecturer/requests/create', data: data);
    } catch (e) {
      throw Exception('Lỗi khi tạo đề xuất: $e');
    }
  }
}
