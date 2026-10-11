import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'dart:io' show Platform;

class DioClient {
  late final Dio dio;

  static String get baseUrl {
    try {
      // Vì bạn đang dùng máy thật và đã cấu hình `adb reverse tcp:8080 tcp:8080`
      // nên URL phải trỏ về localhost (hoặc 127.0.0.1) thay vì 10.0.2.2 (chỉ dành cho máy ảo).
      return 'http://localhost:8080/api';
    } catch (e) {
      // Dành cho Web
      return 'http://localhost:8080/api';
    }
  }

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Thêm Token vào Header nếu có
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Xử lý token hết hạn (ví dụ: xoá token, đẩy ra màn hình login)
          await SecureStorage.deleteToken();
          // TODO: Gửi sự kiện đẩy về màn hình đăng nhập nếu cần
        }
        return handler.next(e);
      },
    ));
  }
}
