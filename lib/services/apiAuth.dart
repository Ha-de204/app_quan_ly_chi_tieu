import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiClient.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  // Gọi hàm registerUser trong Controller
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _dio.post("auth/register", data: {
        "name": name,
        "email": email,
        "password": password,
      });

      // Nếu thành công, trả về dữ liệu (gồm token, user_id...)
      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data['message'] ?? "Lỗi đăng ký"
      };
    }
  }

  // Gọi hàm loginUser trong Controller
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post("auth/login", data: {
        "email": email,
        "password": password,
      });

      // Lưu Token vào máy để dùng cho các API sau này (như lấy Profile)
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['token']);
        await prefs.setString('user_id', response.data['user_id'].toString());
      }

      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data['message'] ?? "Sai email hoặc mật khẩu"
      };
    }
  }
}