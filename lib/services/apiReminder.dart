import 'package:dio/dio.dart';
import 'apiClient.dart';

class ReminderService {
  final Dio _dio = ApiClient.instance;

  // 1. Tạo lời nhắc mới
  Future<Map<String, dynamic>> createReminder({
    required String title,
    String? message,
    required String dueDate,
    required String frequency,
  }) async {
    try {
      final response = await _dio.post("reminders", data: {
        "title": title,
        "message": message ?? "",
        "due_date": dueDate,
        "frequency": frequency,
      });
      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data['message'] ?? "Lỗi tạo lời nhắc"
      };
    }
  }

  // 2. Lấy danh sách tất cả lời nhắc
  Future<List<dynamic>> getReminders() async {
    try {
      final response = await _dio.get("reminders");
      return response.data;
    } on DioException catch (e) {
      print("Lỗi lấy lời nhắc: ${e.message}");
      return [];
    }
  }

  Future<bool> toggleReminder(String id, bool isEnabled) async {
    try {
      await _dio.patch("reminders/$id", data: {"isEnabled": isEnabled});
      return true;
    } catch (e) {
      print("Lỗi bật/tắt lời nhắc: $e");
      return false;
    }
  }

  // 3. Cập nhật lời nhắc (Bao gồm cả việc bật/tắt isEnabled)
  Future<Map<String, dynamic>> updateReminder(
      String id, {
        required String title,
        String? message,
        required String dueDate,
        required String frequency,
        required bool isEnabled,
      }) async {
    try {
      final response = await _dio.put("reminders/$id", data: {
        "title": title,
        "message": message ?? "",
        "due_date": dueDate,
        "frequency": frequency,
        "is_enabled": isEnabled,
      });
      return {"success": true, "message": response.data['message']};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data['message'] ?? "Lỗi cập nhật lời nhắc"
      };
    }
  }

  // 4. Xóa lời nhắc
  Future<Map<String, dynamic>> deleteReminder(String id) async {
    try {
      final response = await _dio.delete("reminders/$id");
      return {"success": true, "message": response.data['message']};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data['message'] ?? "Lỗi xóa lời nhắc"
      };
    }
  }
}