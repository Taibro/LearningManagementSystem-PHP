import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<UserProfile> mobileLogin({
    required String loginCode,
    required String password,
    required String userType,
    String? schoolCode,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/mobile/login',
        data: {
          'loginCode': loginCode,
          'password': password,
          'userType': userType,
          if (schoolCode != null) 'school': schoolCode,
        },
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
