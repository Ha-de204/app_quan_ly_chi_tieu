import 'package:dio/dio.dart';
import 'apiClient.dart';

class BudgetService {
  final Dio _dio = ApiClient.instance;

  // 1. Thiết lập hoặc Cập nhật ngân sách (upsertBudget)
  Future<Map<String, dynamic>> upsertBudget({
    required String categoryId,
    required double amount,
    required String period,
  }) async {
    try {
      final response = await _dio.post("budgets/upsert", data: {
        "category_id": categoryId,
        "budget_amount": amount,
        "period": period,
      });
      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data['message'] ?? "Lỗi thiết lập ngân sách"
      };
    }
  }

  // 2. Lấy danh sách ngân sách theo tháng (getBudgets)
  Future<List<dynamic>> getBudgets(String period) async {
    try {
      final response = await _dio.get(
        "budgets/details",
        queryParameters: {"period": period},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      print("Lỗi lấy ngân sách: ${e.message}");
      return [];
    }
  }

  // 3. Xóa ngân sách (deleteBudget)
  Future<Map<String, dynamic>> deleteBudget(String budgetId) async {
    try {
      final response = await _dio.delete("budgets/delete/$budgetId");
      return {"success": true, "message": response.data['message']};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data['message'] ?? "Lỗi khi xóa ngân sách"
      };
    }
  }
}