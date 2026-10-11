import 'package:dio/dio.dart';
import '../models/admin/dashboard_stats.dart';
import '../models/admin/schedule_exception_response.dart';
import '../models/admin/notification_response.dart';
import '../models/admin/semester.dart';
import '../models/admin/academic_year.dart';
import '../models/admin/room.dart';

class SchoolAdminRepository {
  final Dio _dio;

  SchoolAdminRepository(this._dio);

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('/school-admin/dashboard/stats');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải thống kê: $e');
    }
  }

  Future<List<ScheduleExceptionResponse>> getPendingExceptions() async {
    try {
      final response = await _dio.get('/school-admin/schedule-exceptions/pending');
      final data = response.data as List;
      return data.map((e) => ScheduleExceptionResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách yêu cầu: $e');
    }
  }

  Future<ScheduleExceptionResponse> approveException(int id) async {
    try {
      final response = await _dio.put('/school-admin/schedule-exceptions/$id/approve');
      return ScheduleExceptionResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi duyệt yêu cầu: $e');
    }
  }

  Future<ScheduleExceptionResponse> rejectException(int id, String adminNote) async {
    try {
      final response = await _dio.put('/school-admin/schedule-exceptions/$id/reject', data: {'adminNote': adminNote});
      return ScheduleExceptionResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi từ chối yêu cầu: $e');
    }
  }

  Future<List<NotificationResponse>> getAllNotifications() async {
    try {
      final response = await _dio.get('/school-admin/notifications');
      final data = response.data as List;
      return data.map((e) => NotificationResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách thông báo: $e');
    }
  }

  Future<NotificationResponse> createNotification(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post('/school-admin/notifications', data: request);
      return NotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo thông báo: $e');
    }
  }

  Future<void> broadcastNotification(Map<String, dynamic> request) async {
    try {
      await _dio.post('/school-admin/notifications/broadcast', data: request);
    } catch (e) {
      throw Exception('Lỗi khi gửi thông báo hàng loạt: $e');
    }
  }

  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> request) async {
    try {
      // 1. Create User first
      final userResp = await _dio.post('/school-admin/users', data: {
        'fullName': request['fullName'],
        'email': request['email'],
        'phone': request['phoneNumber'],
        'citizenIdNumber': request['studentCode'] ?? 'SV${DateTime.now().millisecondsSinceEpoch}', // Dummy CCCD if missing
        'isActive': true
      });
      final userId = userResp.data['id'];

      // 2. Map faculty to departmentId
      int deptId = 1;
      if (request['faculty'] == 'Kế toán') deptId = 2;
      else if (request['faculty'] == 'Quản trị kinh doanh') deptId = 3;
      else if (request['faculty'] == 'Cơ khí') deptId = 4;
      else if (request['faculty'] == 'Ngoại ngữ') deptId = 5;

      int enrollmentYear = DateTime.now().year;
      if (request['academicYear'] != null) {
         final yearStr = request['academicYear'].toString().split('-').first;
         enrollmentYear = int.tryParse(yearStr) ?? enrollmentYear;
      }

      // 3. Create Student
      final studentResp = await _dio.post('/school-admin/students', data: {
        'userId': userId,
        'studentCode': request['studentCode'],
        'className': request['className'],
        'departmentId': deptId,
        'enrollmentYear': enrollmentYear,
        'major': request['faculty'],
      });
      
      return studentResp.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception('Lỗi khi tạo sinh viên: ${e.response?.data}');
      }
      throw Exception('Lỗi khi tạo sinh viên: $e');
    }
  }

  Future<Map<String, dynamic>> createTeacher(Map<String, dynamic> request) async {
    try {
      int deptId = 1;
      if (request['faculty'] == 'Kế toán') deptId = 2;
      else if (request['faculty'] == 'Quản trị kinh doanh') deptId = 3;
      else if (request['faculty'] == 'Cơ khí') deptId = 4;
      else if (request['faculty'] == 'Ngoại ngữ') deptId = 5;

      final mappedRequest = {
        'fullName': request['fullName'],
        'email': request['email'],
        'phone': request['phoneNumber'],
        'citizenIdNumber': request['teacherCode'] ?? 'GV${DateTime.now().millisecondsSinceEpoch}',
        'teacherCode': request['teacherCode'],
        'degree': request['degree'],
        'specialization': request['position'] ?? request['faculty'],
        'departmentId': deptId,
      };

      final response = await _dio.post('/school-admin/teachers', data: mappedRequest);
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception('Lỗi khi tạo giảng viên: ${e.response?.data}');
      }
      throw Exception('Lỗi khi tạo giảng viên: $e');
    }
  }

  Future<Map<String, dynamic>> createClass(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post('/school-admin/classes', data: request);
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception('Lỗi khi tạo lớp học: ${e.response?.data}');
      }
      throw Exception('Lỗi khi tạo lớp học: $e');
    }
  }

  Future<List<Room>> getAllRooms() async {
    try {
      final response = await _dio.get('/school-admin/rooms/get-all');
      final data = response.data as List;
      return data.map((e) => Room.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách phòng học: $e');
    }
  }

  Future<Room> createRoom(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post('/school-admin/rooms', data: request);
      return Room.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo phòng học: $e');
    }
  }

  Future<List<Semester>> getAllSemesters() async {
    try {
      final response = await _dio.get('/school-admin/semesters/get-all');
      final data = response.data as List;
      return data.map((e) => Semester.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách học kỳ: $e');
    }
  }

  Future<Semester> createSemester(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post('/school-admin/semesters', data: request);
      return Semester.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo học kỳ: $e');
    }
  }

  Future<Semester> updateSemester(int id, Map<String, dynamic> request) async {
    try {
      final response = await _dio.put('/school-admin/semesters/$id', data: request);
      return Semester.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật học kỳ: $e');
    }
  }

  Future<List<AcademicYear>> getAllAcademicYears(int schoolId) async {
    try {
      final response = await _dio.get('/school-admin/academic-years/school/$schoolId');
      final data = response.data as List;
      return data.map((e) => AcademicYear.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách năm học: $e');
    }
  }

  Future<AcademicYear> createAcademicYear(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post('/school-admin/academic-years', data: request);
      return AcademicYear.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo năm học: $e');
    }
  }
}
