class BudgetModel {
  final String id;
  final String categoryId;
  final double budgetAmount;
  final String period;
  final double totalSpent;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.budgetAmount,
    required this.period,
    this.totalSpent = 0.0,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: (json['_id'] ?? json['budget_id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? 'TOTAL').toString(),
      budgetAmount: (json['budget_amount'] as num? ?? 0.0).toDouble(),
      period: (json['period'] ?? '').toString(),
      totalSpent: (json['TotalSpent'] as num? ?? 0.0).toDouble(),
    );
  }
}