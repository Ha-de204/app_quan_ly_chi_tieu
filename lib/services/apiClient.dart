import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _baseUrl = "https://api-quan-ly-chi-tieu.onrender.com/api/";

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));

    // Thêm Interceptor ngay khi tạo object Dio
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('token');
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
    return dio;
  }

  static Dio get instance => _dio;
}