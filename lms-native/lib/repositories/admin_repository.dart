import 'package:dio/dio.dart';
import '../models/admin/admin_dashboard_stats.dart';
import '../models/admin/admin_tuition_invoice.dart';
import '../models/admin/admin_student.dart';
import '../models/admin/admin_teacher.dart';
import '../models/admin/admin_class.dart';
import '../models/admin/admin_course.dart';

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('/school-admin/dashboard/stats');
      return AdminDashboardStats.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return AdminDashboardStats(
          totalStudents: 0,
          totalTeachers: 0,
          totalClasses: 0,
          todayAbsences: 0,
          totalTuitionDebt: 0,
          schoolName: 'Hệ thống Quản lý Đào tạo',
        );
      }
      throw Exception('Lỗi khi tải thống kê tổng quan: $e');
    }
  }

  Future<List<AdminTuitionInvoice>> getUnpaidInvoices() async {
    try {
      final response = await _dio.get('/school-admin/tuition-invoices');
      final List<dynamic> data = response.data;
      final invoices = data.map((json) => AdminTuitionInvoice.fromJson(json)).toList();
      
      // Filter out unpaid invoices (where status is not PAID, or paidAmount < totalAmount)
      return invoices.where((inv) => 
        inv.status != 'PAID' && inv.status != 'COMPLETED'
      ).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Lỗi khi tải danh sách hóa đơn: $e');
    }
  }

  Future<List<AdminStudent>> getAllStudents() async {
    try {
      final response = await _dio.get('/school-admin/students');
      return (response.data as List).map((json) => AdminStudent.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) return [];
      throw Exception('Lỗi khi tải danh sách sinh viên: $e');
    }
  }

  Future<List<AdminTeacher>> getAllTeachers() async {
    try {
      final response = await _dio.get('/school-admin/teachers/get-all');
      return (response.data as List).map((json) => AdminTeacher.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) return [];
      throw Exception('Lỗi khi tải danh sách giảng viên: $e');
    }
  }

  Future<List<AdminClass>> getAllClasses() async {
    try {
      final response = await _dio.get('/school-admin/classes');
      return (response.data as List).map((json) => AdminClass.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) return [];
      throw Exception('Lỗi khi tải danh sách lớp học: $e');
    }
  }

  Future<List<AdminCourse>> getAllCourses() async {
    try {
      final response = await _dio.get('/school-admin/courses/get-all');
      return (response.data as List).map((json) => AdminCourse.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) return [];
      throw Exception('Lỗi khi tải danh sách môn học: $e');
    }
  }
}
