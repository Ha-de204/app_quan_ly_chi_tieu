class TransactionModel {
  final String id;
  final String categoryId;
  final double amount;
  final String type;
  final DateTime date;
  final String title;
  final String? note;

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    required this.title,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? json['categoryId'] ?? '').toString(),
      amount: (json['amount'] as num).toDouble(),
      type: (json['type'] ?? 'expense').toString(),
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      title: (json['title'] ?? 'Giao dịch').toString(),
      note: json['note']?.toString(),
    );
  }
}