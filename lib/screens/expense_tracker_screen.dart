import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../constants.dart';
import 'expense_detail_screen.dart';
import 'budget_detail_screen.dart';
import 'balance_detail_screen.dart';
import 'charts_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import '../widgets/add_transaction_content.dart';
import 'package:intl/intl.dart';
import '../utils/data_aggregator.dart';
import '../models/TransactionData.dart';
import '../models/mock_budget_category.dart';
import '../models/monthly_expense_data.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  DateTime _selectedMonthYear = DateTime.now();
  DateTime _selectedSpecificDate = DateTime.now();
  double get _monthlyBudget{
    final monthlyEntry = _categoryBudgetsSetting.firstWhere((e) => e.name == 'Ngân sách hàng tháng',
      orElse: () => MockBudgetCategory(name: 'Ngân sách hàng tháng', budget: 0.0, icon: Icons.error),
    );
    return monthlyEntry.budget;
  }
  int _selectedIndex = 0;
  // danh sách lưu giao dịch tạm thời
  List<TransactionData> _transactions = [];

  late List<MockBudgetCategory> _categoryBudgetsSetting;

  final List<Map<String, dynamic>> categories = [
    {'label': 'Mua sắm', 'icon': Icons.shopping_cart_outlined},
    {'label': 'Đồ ăn', 'icon': Icons.fastfood_outlined},
    {'label': 'Quần áo', 'icon': Icons.checkroom_outlined},
    {'label': 'Nhà ở', 'icon': Icons.home_outlined},
    {'label': 'Sức khỏe', 'icon': Icons.favorite_border},
    {'label': 'Học tập', 'icon': Icons.book_outlined},
    {'label': 'Du lịch', 'icon': Icons.flight_outlined},
    {'label': 'Giải trí', 'icon': Icons.videogame_asset_outlined},
    {'label': 'Sửa chữa', 'icon': Icons.build_outlined},
    {'label': 'Sắc đẹp', 'icon': Icons.spa_outlined},
    {'label': 'Điện thoại', 'icon': Icons.phone_android_outlined},
    {'label': 'Cài đặt', 'icon': Icons.settings_outlined, 'isSetting': true},
  ];

  // Định nghĩa list _pages trong initState để truy cập context
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _categoryBudgetsSetting = [
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
    _pages = [
      _buildHomeBody(context),
      const ChartsScreen(),
      const ProfileScreen(),
    ];
    _transactions.add(TransactionData(id: 't1', title: 'Ăn tối nhà hàng X', amount: 250000.0, category: 'Đồ ăn', categoryIcon: Icons.fastfood, type: TransactionType.expense, date: DateTime(2025, 11, 4), note: 'Ăn tối nhà hàng X'));
    _transactions.add(TransactionData(id: 't2', title: 'Đi siêu thị', amount: 248000.0, category: 'Mua sắm', categoryIcon: Icons.shopping_cart, type: TransactionType.expense, date: DateTime(2025, 11, 2), note: 'Đi siêu thị'));
    _transactions.add(TransactionData(id: 't3', title: 'Tiền trọ', amount: 1834000.0, category: 'Nhà ở', categoryIcon: Icons.home, type: TransactionType.expense, date: DateTime(2025, 10, 31), note: 'Tiền trọ'));
    _transactions.add(TransactionData(id: 't4', title: 'Đi chợ', amount: 25000.0, category: 'Đồ ăn', categoryIcon: Icons.fastfood, type: TransactionType.expense, date: DateTime(2025, 10, 2), note: 'Đi chợ'));
    _transactions.add(TransactionData(id: 't5', title: 'Cafe với bạn', amount: 75000.0, category: 'Đồ ăn', categoryIcon: Icons.fastfood, type: TransactionType.expense, date: DateTime(2025, 9, 15), note: 'Cafe với bạn'));
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionData> get _filteredTransactions {
    return _transactions.where((tx) {
      return tx.date.year == _selectedMonthYear.year &&
          tx.date.month == _selectedMonthYear.month;
    }).toList();
  }
  // tổng Chi tiêu của tháng đã chọn
  String get _monthlyExpense {
    double total = 0.0;
    for (var tx in _filteredTransactions) {
      total += tx.amount;
    }

    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(total);
  }

  List<MonthlyExpenseData> _aggregateMonthlyData(){
    //tạo map nhóm theo 'YYYY-mm'
    final Map<String, List<TransactionData>> grouped = {};
    for(var tx in _transactions){
      final key = DateFormat('yyyy-MM').format(tx.date);
      if(!grouped.containsKey(key)){
        grouped[key] = [];
      }
      grouped[key]!.add(tx);
    }
    final double budgetToUse = _monthlyBudget;
    List<MonthlyExpenseData> aggregateData = [];
    grouped.forEach((key, transactions){
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      double totalExpense = 0.0;
      for(var tx in transactions){
        totalExpense += tx.amount;
      }

      aggregateData.add(MonthlyExpenseData(
        month: month,
        year: year,
        expense: totalExpense,
        balance: budgetToUse - totalExpense,
      ));
    });

    aggregateData.sort((a, b) => (b.year*12 + b.month).compareTo(a.year*12 + a.month));
    return aggregateData;
  }

  // Hàm xử lý khi chọn tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Hàm hiển thị lịch chọn tháng/năm
  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonthYear,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('vi'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryPink,
              onPrimary: Colors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 0.95, // Giảm kích thước văn bản xuống 85%
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _selectedMonthYear) {
      setState(() {
        _selectedMonthYear = picked;
      });
    }
  }

  // Hàm hiển thị lịch chọn ngày cụ thể (cho AppBar)
  Future<void> _selectSpecificDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedSpecificDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryPink,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedSpecificDate) {
      setState(() {
        _selectedSpecificDate = picked;
        print('Ngày cụ thể đã chọn để lọc: $_selectedSpecificDate');
      });
    }
  }

  // Helper để định dạng tháng
  String _formatMonth(int month) {
    switch (month) {
      case 1: return 'Thg 1'; case 2: return 'Thg 2'; case 3: return 'Thg 3';
      case 4: return 'Thg 4'; case 5: return 'Thg 5'; case 6: return 'Thg 6';
      case 7: return 'Thg 7'; case 8: return 'Thg 8'; case 9: return 'Thg 9';
      case 10: return 'Thg 10'; case 11: return 'Thg 11'; case 12: return 'Thg 12';
      default: return '';
    }
  }

  // hàm để thêm danh mục mới vào list categories và budget list
  void _addNewCategory(Map<String, dynamic> newCategory){
    setState(() {
      // thêm vào ds danh mục
      // chèn danh mục mới trước cài đặt
      int settingIndex = categories.indexWhere((cat) => cat['label'] == 'Cài đặt');
      if(settingIndex != -1){
        categories.insert(settingIndex, newCategory);
      } else{
        categories.add(newCategory);
      }

      // them vao danh sach ngan sach
      bool existsInBudget = _categoryBudgetsSetting.any((e) => e.name == newCategory['label']);
      if (!existsInBudget){
        _categoryBudgetsSetting.add(
          MockBudgetCategory(
            name: newCategory['label'] as String,
            budget: 0.0,
            icon: newCategory['icon'] as IconData,
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm danh mục: ${newCategory['label']}')),
      );
    });
  }

  // Hàm hiển thị giao diện thêm giao dịch
  void _showAddTransactionSheet() async{
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: AddTransactionContent(categories: categories),
          ),
        );
      },
    );

    if(result != null){
      if(result.containsKey('newCategory')){
        _addNewCategory(result['newCategory'] as Map<String, dynamic>);
      } else if(result.containsKey('newTransaction')) {
        final newTransaction = result['newTransaction'] as TransactionData;

        setState(() {
          _transactions.add(newTransaction);
          _transactions.sort((a, b) => b.date.compareTo(a.date));
          updateTransactionData(_transactions);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm giao dịch: ${newTransaction.category}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Xóa / sửa giao dịch
  void _showEditOption(TransactionData tx, int index){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Sửa giao dịch'),
                onTap: (){
                  Navigator.pop(context);
                  _showEditTransactionSheet(tx, index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa giao dịch'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTransaction(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTransactionSheet(TransactionData oldTx, int index) async {
    final editedTransaction = await showModalBottomSheet<TransactionData>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: AddTransactionContent(
              transaction: oldTx,
              isEditing: true,
              categories: categories,
            ),
          ),
        );
      },
    );

    if (editedTransaction != null) {
      setState(() {
        _transactions[index] = editedTransaction; // CẬP NHẬT GIAO DỊCH ĐÃ SỬA
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sửa giao dịch thành công.'), backgroundColor: Colors.blue),
      );
    }
  }

  void _deleteTransaction(int index) {
    final deletedTx = _transactions[index];
    setState(() {
      _transactions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${deletedTx.category}'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            setState(() {
              _transactions.insert(index, deletedTx);
              _transactions.sort((a, b) => b.date.compareTo(a.date));
            });
          },
        ),
      ),
    );
  }

  //Widget xây dựng thêm 1 item giao dịch
  Widget _buildTransactionItem(TransactionData tx, int index){
    final category = categories.firstWhere((cat) => cat['label'] == tx.category,
      orElse: () => {'label': 'Khác', 'icon': Icons.category});

    final day = tx.date.day;
    final month = tx.date.month;
    final weekdayIndex = tx.date.weekday;
    final weekdayName = weekdayIndex == 7 ? 'Chủ nhật' : 'Thứ ${weekdayIndex + 1}';
    final formattedDateLine = '$day thg $month, $weekdayName';

    final displayNote = tx.note.isNotEmpty ? tx.note : tx.category;

    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    final double amountValue = tx.amount;
    final formattedAmount = formatter.format(amountValue);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDateLine, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text('Chi tiêu: $formattedAmount', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),

        InkWell(
          onLongPress: () => _showEditOption(tx, index),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kPrimaryPink.withOpacity(0.1),
              child: Icon(category['icon'] as IconData, color: kPrimaryPink),
            ),
            title: Text(displayNote, style: const TextStyle(fontSize: 16)),
            trailing: Text(
              '-$formattedAmount',
              style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold,),
            ),
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, BuildContext context) {
    Widget destinationScreen;
    if (label == 'Chi tiêu') {
      destinationScreen = ExpenseDetailScreen(
        monthlyData: _aggregateMonthlyData(),
      );
    } else if (label == 'Ngân sách') {
      destinationScreen = BudgetDetailScreen(
        initialCategoryBudgets: _categoryBudgetsSetting,
      );
    } else if (label == 'Số dư') {
      destinationScreen = const BalanceDetailScreen();
    } else {
      destinationScreen = const Scaffold(body: Center(child: Text('Lỗi màn hình')));
    }

    return InkWell(
      onTap: () async {
        // Chuyển sang màn hình tương ứng đã chọn
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => destinationScreen,
          ),
        );
        if(result is List<MockBudgetCategory>){
          setState((){
            _categoryBudgetsSetting = result;
          });
        }
        else if(result is double && label == 'Ngân sách'){
          setState(() {
          });
        }
      },
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo item trong Bottom Navigation Bar
  Widget _buildNavItem(IconData icon, String label, int index) {
    final Color color = index == _selectedIndex ? kPrimaryPink : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color, size: 24),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    final transactionsToDisplay = _filteredTransactions;
    final double budget = _monthlyBudget;
    final double expenseValue = double.tryParse(_monthlyExpense.replaceAll('.', '')) ?? 0.0;
    final double balanceValue = budget - expenseValue;

    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    final formattedBudget = formatter.format(budget);
    final formattedBalance = formatter.format(balanceValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[

                  //chon thang-nam
                  InkWell(
                    onTap: () => _selectMonthYear(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedMonthYear.year}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _formatMonth(_selectedMonthYear.month),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 24),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      _buildStatColumn('Chi tiêu', _monthlyExpense, context),
                      const SizedBox(width: 18),
                      _buildStatColumn('Ngân sách', formattedBudget, context),
                      const SizedBox(width: 18),
                      _buildStatColumn('Số dư', formattedBalance, context),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1, color: Colors.grey),
            ],
          ),
        ),

        // Phần danh sách giao dịch
        Expanded(
          child: Container(
            color: kLightPinkBackground,
            child: transactionsToDisplay.isEmpty
                ? Center(
                    child: Text('Chưa có giao dịch trong ${DateUtils.dateOnly(_selectedMonthYear).month}!', style: TextStyle(color: Colors.grey)),
                )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: transactionsToDisplay.length,
                    itemBuilder: (context, index) {
                      final tx = transactionsToDisplay[index];
                      final originalIndex = _transactions.indexOf(tx);
                      return _buildTransactionItem(tx, originalIndex);
                    },
                ),

          ),
        ),
      ],
    );
  }

  // 4. Build Function
  @override
  Widget build(BuildContext context) {

    Widget currentBody;
    PreferredSizeWidget currentAppBar;

    if (_selectedIndex == 0) {
      currentBody = _buildHomeBody(context);
      currentAppBar = AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Sổ cái thu chi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () => _selectSpecificDate(context),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      currentBody = const ChartsScreen();
      currentAppBar = AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Chi tiêu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () {}),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.calendar_month, color: Colors.black), onPressed: () => _selectSpecificDate(context)),
        ],
      );
    } else if (_selectedIndex == 2) {
      currentBody = ReportsScreen(
        transactions: _transactions,
        budgetCategories: _categoryBudgetsSetting,
      );
      currentAppBar = AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Báo cáo', style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () {}),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.calendar_month, color: Colors.black), onPressed: () => _selectSpecificDate(context)),
        ],
      );
    } else {
      currentBody = const ProfileScreen();
      currentAppBar = AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: const [],
      );
    }

    return Scaffold(
      // 1. App Bar
      appBar: currentAppBar,

      // 5. Body - Hiển thị màn hình tương ứng với tab được chọn
      body: currentBody,

      // 6. Floating Action Button (Nút + tròn)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        backgroundColor: kPrimaryPink,
        shape: const CircleBorder(),
        elevation: 4.0,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),

      // 7. Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildNavItem(Icons.description_outlined, 'Trang chủ', 0),
              _buildNavItem(Icons.pie_chart_outline, 'Biểu đồ', 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.assignment_outlined, 'Báo cáo', 2),
              _buildNavItem(Icons.person_outline, 'Tôi', 3),
            ],
          ),
        ),
      ),
    );
  }
}