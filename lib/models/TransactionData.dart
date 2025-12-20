import 'package:flutter/material.dart';
enum TransactionType { expense, income, transfer }

class TransactionData {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final IconData categoryIcon;
  final TransactionType type;
  final String note;

  TransactionData({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.categoryIcon,
    required this.type,
    required this.note,
  });
}

// dl tĩnh
final List<TransactionData> DUMMY_TRANSACTIONS = [
  TransactionData(
    id: 't1',
    title: 'Cafe với bạn',
    amount: 75000,
    date: DateTime(2025, 9, 15),
    category: 'Đồ ăn',
    categoryIcon: Icons.fastfood,
    type: TransactionType.expense,
    note: 'Cafe với bạn',
  ),

  TransactionData(
    id:'t2',
    title: 'Tiền trọ',
    amount: 1834000,
    date: DateTime(2025, 10, 31),
    category: 'Nhà ở',
    categoryIcon: Icons.home,
    type: TransactionType.expense,
    note: 'Tiền trọ',
  ),

  TransactionData(
    id: 't3',
    title: 'Đi chợ',
    amount: 25000,
    date: DateTime(2025, 10, 2),
    category: 'Đồ ăn',
    categoryIcon: Icons.fastfood,
    type: TransactionType.expense,
    note: 'Đi chợ',
  ),

  TransactionData(
    id: 't4',
    title: 'Đi siêu thị',
    amount: 248000,
    date: DateTime(2025, 11, 2),
    category: 'Mua sắm',
    categoryIcon: Icons.shopping_cart,
    type: TransactionType.expense,
    note: 'Đi siêu thị',
  ),

  TransactionData(
    id: 't4',
    title: 'Ăn tối nhà hàng X',
    amount: 250000,
    date: DateTime(2025, 11, 4),
    category: 'Đồ ăn',
    categoryIcon: Icons.fastfood,
    type: TransactionType.expense,
    note: 'Ăn tối nhà hàng X',
  ),
];