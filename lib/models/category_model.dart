class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Không tên').toString(),
      iconCodePoint: json['iconCodePoint'] ?? json['icon_code_point'] ?? 58248,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCodePoint': iconCodePoint,
    };
  }
}