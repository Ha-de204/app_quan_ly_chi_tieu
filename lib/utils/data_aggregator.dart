import 'package:flutter/material.dart';
import '../models/TransactionData.dart';
import '../models/mock_budget_category.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class CategoryExpense {
  final String categoryName;
  final double totalAmount;
  final IconData icon;
  final double percentage;

  CategoryExpense({
    required this.categoryName,
    required this.totalAmount,
    required this.icon,
    required this.percentage,
  });
}

List<TransactionData> _currentTransactions = DUMMY_TRANSACTIONS;

void updateTransactionData(List<TransactionData> transactions) {
  _currentTransactions = transactions;
}

List<CategoryExpense> getMonthlyExpenseByCategory(DateTime monthYear) {
  final filteredTransactions = _currentTransactions.where((tx) {
    return tx.date.year == monthYear.year &&
           tx.date.month == monthYear.month &&
           tx.type == TransactionType.expense;
  }).toList();

  final Map<String, double> categoryTotals ={};
  final Map<String, IconData> categoryIcons = {};

  for(var tx in filteredTransactions) {
    categoryTotals.update(
      tx.category,
          (existingAmount) => existingAmount + tx.amount,
      ifAbsent: () => tx.amount,
    );
    categoryIcons[tx.category] = tx.categoryIcon;
  }

  final totalExpense = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
  if (totalExpense == 0.0) return [];

  return categoryTotals.entries.map((entry) {
    return CategoryExpense(
      categoryName: entry.key,
      totalAmount: entry.value,
      icon: categoryIcons[entry.key]!,
      percentage: entry.value / totalExpense,
    );
  }).toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
}

double getTotalMonthlyExpense(DateTime monthYear) {
  final categoryExpenses = getMonthlyExpenseByCategory(monthYear);
  return categoryExpenses.fold(0.0, (sum, item) => sum + item.totalAmount);
}

class DataAggregator {
  static const Color defaultPrimaryColor = Color(0xFFE91E63);

  static DateTime getStartOfWeek(DateTime date){
    int diff = date.weekday - 1;
    if(diff<0) diff += 7;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
  }

  static DateTime getEndOfWeek(DateTime date){
    return getStartOfWeek(date).add(const Duration(days: 6));
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }

  // tìm giao dịch sớm nhất
  static DateTime _getFirstTransactionDate() {
    if (_currentTransactions.isEmpty) {
      return DateTime.now().subtract(const Duration(days: 365));
    }
    return _currentTransactions.fold(_currentTransactions.first.date,
            (minDate, tx) => tx.date.isBefore(minDate) ? tx.date : minDate);
  }

  // tính percentage
  static List<CategoryExpense> _processExpenses(List<TransactionData> expenses) {
    final Map<String, double> categoryTotals ={};
    final Map<String, IconData> categoryIcons = {};

    for(var tx in expenses) {
      categoryTotals.update(
        tx.category,
            (existingAmount) => existingAmount + tx.amount,
        ifAbsent: () => tx.amount,
      );
      categoryIcons[tx.category] = tx.categoryIcon;
    }

    final totalExpense = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    if (totalExpense == 0.0) {
      return [];
    }

    return categoryTotals.entries.map((entry) {
      final amount = entry.value;
      final percentage = amount / totalExpense;

      return CategoryExpense(
        categoryName: entry.key,
        totalAmount: amount,
        icon: categoryIcons[entry.key]!,
        percentage: percentage,
      );
    }).toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  }

  static List<CategoryExpense> aggregateCategoryExpenses(
      DateTime date,
      int filterIndex, // 0: Tuần, 1: Tháng, 2: Năm
      List<MockBudgetCategory> allCategories,
      ) {
    DateTime startDate;
    DateTime endDate;

    if (filterIndex == 0) {
      startDate = getStartOfWeek(date);
      endDate = getEndOfWeek(date);
    } else if (filterIndex == 1) {
      startDate = getStartOfMonth(date);
      endDate = getEndOfMonth(date);
    } else {
      startDate = getStartOfYear(date);
      endDate = getEndOfYear(date);
    }

    final filteredExpenses = _currentTransactions.where((tx) {
      final txDate = tx.date;
      return tx.type == TransactionType.expense &&
          (txDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              txDate.isBefore(endDate.add(const Duration(days: 1))));
    }).toList();

    return _processExpenses(filteredExpenses);
  }

  // tổng chi tiêu
  static double getTotalExpense(DateTime date, int filterIndex) {
    final aggregatedData = aggregateCategoryExpenses(date, filterIndex, mockBudgetCategories);
    return aggregatedData.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  // lấy dl cho các chu kỳ trước
  static List<DateTime> getPastPeriods(int selectedFilterIndex, DateTime currentDate) {
    List<DateTime> periods = [];
    DateTime firstTransactionDate = _getFirstTransactionDate();

    // 1. xac dinh ngay bat dau cua chu ky dau tien (chua gd som nhat)
    DateTime startIteratingDate;
    if (selectedFilterIndex == 0) {
      startIteratingDate = getStartOfWeek(firstTransactionDate);
    } else if (selectedFilterIndex == 1) {
      startIteratingDate = getStartOfMonth(firstTransactionDate);
    } else {
      startIteratingDate = getStartOfYear(firstTransactionDate);
    }

    DateTime currentPeriodDate = startIteratingDate;

    // 2. lap den chu ky chua ngay hien tai
    while (true) {
      periods.add(currentPeriodDate);
      DateTime endOfCurrentPeriod;
      if (selectedFilterIndex == 0) {
        endOfCurrentPeriod = getEndOfWeek(currentPeriodDate);
      } else if (selectedFilterIndex == 1) {
        endOfCurrentPeriod = getEndOfMonth(currentPeriodDate);
      } else {
        endOfCurrentPeriod = getEndOfYear(currentPeriodDate);
      }

      if (endOfCurrentPeriod.year == currentDate.year &&
          endOfCurrentPeriod.month == currentDate.month &&
          (selectedFilterIndex == 1 || selectedFilterIndex == 2 || (selectedFilterIndex == 0 && endOfCurrentPeriod.isAfter(currentDate)) )
      ) {
        if (selectedFilterIndex == 1 || selectedFilterIndex == 2) {
          break;
        }
        if (endOfCurrentPeriod.isAfter(currentDate) && currentPeriodDate.isBefore(currentDate)) {
          break;
        }
      }

      // 3. sang chu ky tiep theo
      if (selectedFilterIndex == 0) {
        currentPeriodDate = currentPeriodDate.add(const Duration(days: 7));
      } else if (selectedFilterIndex == 1) {
        currentPeriodDate = DateTime(currentPeriodDate.year, currentPeriodDate.month + 1, 1);
      } else {
        currentPeriodDate = DateTime(currentPeriodDate.year + 1, 1, 1);
      }

      if (periods.length > 500) break;

      if (currentPeriodDate.isAfter(currentDate.add(const Duration(days: 31)))) break;
    }
    return periods;
  }


}
