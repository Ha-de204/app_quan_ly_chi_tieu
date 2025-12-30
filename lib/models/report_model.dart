class ReportSummaryModel {
  final double totalExpense;
  final double budgetAmount;
  final double netBalance;

  ReportSummaryModel({
    required this.totalExpense,
    required this.budgetAmount,
    required this.netBalance,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalExpense: (json['TotalExpense'] as num).toDouble(),
      budgetAmount: (json['BudgetAmount'] as num).toDouble(),
      netBalance: (json['NetBalance'] as num).toDouble(),
    );
  }
}

class CategoryBreakdownModel {
  final String categoryId;
  final String categoryName;
  final double totalAmount;

  CategoryBreakdownModel({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      categoryId: json['_id'],
      categoryName: json['categoryName'] ?? 'Không xác định',
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}