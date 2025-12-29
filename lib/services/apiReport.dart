import 'package:dio/dio.dart';
import 'apiClient.dart';

class ReportService {
  final Dio _dio = ApiClient.instance;

  // 1. Lấy tổng quan: Tổng chi, Ngân sách, Số dư (getSummary)
  // Gửi startDate và endDate dạng YYYY-MM-DD
  Future<Map<String, dynamic>> getSummary(String startDate, String endDate) async {
    try {
      final response = await _dio.get(
        "reports/summary",
        queryParameters: {
          "startDate": startDate,
          "endDate": endDate,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print("Lỗi lấy tổng quan báo cáo: ${e.message}");
      return {"TotalExpense": 0, "BudgetAmount": 0, "NetBalance": 0};
    }
  }

  // 2. Lấy dữ liệu biểu đồ tròn (getCategoryBreakdown)
  Future<List<dynamic>> getCategoryBreakdown(String startDate, String endDate) async {
    try {
      final response = await _dio.get(
        "reports/category-breakdown",
        queryParameters: {
          "startDate": startDate,
          "endDate": endDate,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print("Lỗi lấy phân tích danh mục: ${e.message}");
      return [];
    }
  }

  // 3. Lấy dữ liệu biểu đồ cột dòng tiền theo năm (getMonthlyFlow)
  Future<List<dynamic>> getMonthlyFlow(int year) async {
    try {
      final response = await _dio.get(
        "reports/monthly-flow",
        queryParameters: {"year": year},
      );
      return response.data;
    } on DioException catch (e) {
      print("Lỗi lấy dòng tiền tháng: ${e.message}");
      return [];
    }
  }
}