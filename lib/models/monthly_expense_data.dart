import 'package:flutter/material.dart';

class MonthlyExpenseData {
  final int month;
  final int year;
  final double expense;
  final double balance;

  MonthlyExpenseData({
    required this.month,
    required this.year,
    required this.expense,
    required this.balance,
  });
  String get monthLabel => 'Thg $month, $year';
  String get key => '$year-$month';
}