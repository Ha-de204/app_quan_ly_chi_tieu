import 'package:flutter/material.dart';

class MockBudgetCategory {
  final String name;
  double budget;
  final IconData icon;

  MockBudgetCategory({
    required this.name,
    required this.budget,
    required this.icon,
  });
}

final List<MockBudgetCategory> mockBudgetCategories = [
  MockBudgetCategory(name: 'Ngân sách hàng tháng', budget: 2000000.0, icon: Icons.remove_circle),
  MockBudgetCategory(name: 'Mua sắm', budget: 500000.0, icon: Icons.shopping_cart),
  MockBudgetCategory(name: 'Đồ ăn', budget: 800000.0, icon: Icons.fastfood),
  MockBudgetCategory(name: 'Quần áo', budget: 200000.0, icon: Icons.checkroom),
  MockBudgetCategory(name: 'Nhà ở', budget: 1500000.0, icon: Icons.home),
  MockBudgetCategory(name: 'Sức khỏe', budget: 300000.0, icon: Icons.favorite),
  MockBudgetCategory(name: 'Học tập', budget: 0.0, icon: Icons.book_online),
  MockBudgetCategory(name: 'Du lịch', budget: 0.0, icon: Icons.flight),
  MockBudgetCategory(name: 'Giải trí', budget: 0.0, icon: Icons.videogame_asset),
  MockBudgetCategory(name: 'Sửa chữa', budget: 0.0, icon: Icons.build),
  MockBudgetCategory(name: 'Sắc đẹp', budget: 0.0, icon: Icons.spa),
  MockBudgetCategory(name: 'Điện thoại', budget: 0.0, icon: Icons.phone_android),
];