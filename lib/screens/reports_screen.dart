import 'package:flutter/material.dart';
import 'expense_detail_screen.dart';
import 'budget_detail_screen.dart';
import '../models/TransactionData.dart';
import '../models/mock_budget_category.dart';
import '../constants.dart';
import '../models/monthly_expense_data.dart';
import 'package:intl/intl.dart';
import '../utils/data_aggregator.dart';

class ReportData {
  final String monthLabel;
  final double totalExpense;
  final double balance;
  final double monthlyBudget;
  final double budgetSpent;
  final List<TransactionData> monthTransactions;
  final List<MonthlyExpenseData> monthlyReports;

  ReportData({
    required this.monthLabel,
    required this.totalExpense,
    required this.balance,
    required this.monthlyBudget,
    required this.budgetSpent,
    required this.monthTransactions,
    required this.monthlyReports,
  });
}

class ReportsScreen extends StatefulWidget {
  final List<TransactionData> transactions;
  final List<MockBudgetCategory> budgetCategories;
  const ReportsScreen({
    super.key,
    required this.transactions,
    required this.budgetCategories,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late ReportData _currentMonthReport;
  late List<MockBudgetCategory> _budgetCategoriesState;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _budgetCategoriesState = List.from(widget.budgetCategories);
    _currentMonthReport = _getReportDataForCurrentMonth(widget.transactions, _budgetCategoriesState);
  }

  // dinh dang tien
  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // ham tong hop toan bo giao dich
  List<MonthlyExpenseData> _getMonthlyExpenseData(List<TransactionData> transactions, List<MockBudgetCategory> budgetCategorie) {
    final Map<String, List<TransactionData>> grouped = {};
    for(var tx in transactions){
      final key = DateFormat('yyyy-MM').format(tx.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tx);
    }
    final List<MonthlyExpenseData> monthlyData = [];

    // thong tin ngan sach hang thang
    final monthlyBudgetCat = widget.budgetCategories.firstWhere(
        (cat) => cat.name == 'Ngân sách hàng tháng',
        orElse: () => MockBudgetCategory(name: 'Ngân sách hàng tháng', budget: 0.0, icon: Icons.error)
    );
    final monthlyBudget = monthlyBudgetCat.budget;

    grouped.forEach((key, txList) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final expense = txList.where((tx) => tx.type == TransactionType.expense)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      final balance = monthlyBudget - expense;

      monthlyData.add(MonthlyExpenseData(
        month: month,
        year: year,
        expense: expense,
        balance: balance,
      ));
    });

    monthlyData.sort((a, b) {
      final aDate = a.year * 100 + a.month;
      final bDate = b.year * 100 + b.month;
      return bDate.compareTo(aDate);
    });

    return monthlyData;
  }

  // ham tong hop dl bao cao
  ReportData _getReportDataForCurrentMonth(List<TransactionData> transactions, List<MockBudgetCategory> budgetCategories){
    final targetMonth = now.month;
    final targetYear = now.year;

    // loc giao dich thang hien tai
    final monthTransactions = widget.transactions.where((tx) =>
    tx.date.month == targetMonth && tx.date.year == targetYear
    ).toList();

    // tinh tong chi tieu
    final totalExpense = monthTransactions.where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // lay thong tin ngan sach hang thang
    final monthlyBudgetCat = widget.budgetCategories.firstWhere(
            (cat) => cat.name == 'Ngân sách hàng tháng',
        orElse: () => MockBudgetCategory(name: 'Ngân sách hàng tháng', budget: 0.0, icon: Icons.error)
    );
    final monthlyBudget = monthlyBudgetCat.budget;

    final balance = monthlyBudget - totalExpense;
    final allMonthlyReports = _getMonthlyExpenseData(transactions,  budgetCategories);

    return ReportData(
      monthLabel: 'Thg ${targetMonth}, ${targetYear}',
      totalExpense: totalExpense,
      balance: balance,
      monthlyBudget: monthlyBudget,
      budgetSpent: totalExpense,
      monthTransactions: monthTransactions,
      monthlyReports: allMonthlyReports,
    );

  }

  // link den tran chi tiet chi tieu
  void _openMonthlyExpenseDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          monthlyData: _currentMonthReport.monthlyReports,
        ),
      ),
    );
  }

  void _openMonthlyBudgetDetail() async {
    final dynamic updatedBudgets = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailScreen(
          initialCategoryBudgets: _budgetCategoriesState,
        ),
      ),
    );

    if(updatedBudgets != null && updatedBudgets is List<MockBudgetCategory>){
      setState(() {
        _budgetCategoriesState = updatedBudgets;
        _currentMonthReport = _getReportDataForCurrentMonth(widget.transactions, _budgetCategoriesState);
      });
    }
  }

  Widget _buildReportRow(String label, double value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black)),
          Text(
            _formatAmount(value),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({required String title, required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentMonthReport;
    double budgetRemaining = data.monthlyBudget - data.budgetSpent;
    double budgetPercentage = data.monthlyBudget > 0 ? (data.budgetSpent / data.monthlyBudget) : 0;

    double progressValue = budgetPercentage.clamp(0.0, 1.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 8.0),
          ),
          //  thong ke hang thang
          _buildReportCard(
            title: 'Thống kê hàng tháng',
            onTap: _openMonthlyExpenseDetail,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.monthLabel,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 4),

                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Chi tiêu',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAmount(data.totalExpense),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black), // Màu đen
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Số dư',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAmount(data.balance),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: data.balance >= 0 ? Colors.green.shade700 : Colors.red.shade700, // Giữ màu trạng thái
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),

          // ngan sach hang thang
          _buildReportCard(
            title: 'Ngân sách hàng tháng',
            onTap: _openMonthlyBudgetDetail,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 20),
                  child: CircularProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(budgetRemaining >= 0 ? Colors.green.shade700 : Colors.red.shade700),
                    strokeWidth: 5,
                  ),
                ),

                // chi tiet ngan sach
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ngân sách:', style: TextStyle(color: Colors.black)),
                          Text('Chi tiêu:', style: TextStyle(color: Colors.black)),
                          Text('Còn lại:', style: TextStyle(color: Colors.green[700])),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_formatAmount(data.monthlyBudget), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(_formatAmount(data.budgetSpent), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(_formatAmount(budgetRemaining), style: TextStyle(fontWeight: FontWeight.bold, color: budgetRemaining >= 0 ? Colors.green[700] : Colors.red[700])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}