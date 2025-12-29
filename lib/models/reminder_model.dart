class ReminderModel {
  final String id;
  final String title;
  final String? message;
  final DateTime dueDate;
  final String frequency;
  bool isEnabled;

  ReminderModel({
    required this.id,
    required this.title,
    this.message,
    required this.dueDate,
    required this.frequency,
    required this.isEnabled,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    String cleanId(dynamic rawId) {
      if (rawId == null) return "";
      String idStr = rawId.toString();
      if (idStr.contains("ObjectId(")) {
        return idStr.split("'")[1];
      }
      return idStr;
    }

    return ReminderModel(
      id: cleanId(json['_id'] ?? json['id']),
      title: (json['title'] ?? 'Nhắc nhở').toString(),
      message:json['message']?.toString(),
      dueDate: DateTime.parse(json['due_date'] ?? json['dueDate'] ?? DateTime.now().toIso8601String()),
      frequency: json['frequency']?.toString() ?? 'once',
      isEnabled: json['is_enabled'] ?? json['isEnabled'] ?? true,
    );
  }
}