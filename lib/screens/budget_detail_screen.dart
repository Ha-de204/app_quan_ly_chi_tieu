import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/budget_setting_screen.dart';
import 'package:intl/intl.dart';
import '../utils/data_aggregator.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../models/mock_budget_category.dart';

class BudgetCategory {
  final String name;
  double budget;
  final double expense;
  final IconData icon;

  BudgetCategory({
    required this.name,
    required this.budget,
    required this.expense,
    required this.icon,
  });

  double get remaining => budget - expense;
}

class BudgetDetailScreen extends StatefulWidget {
  final List<MockBudgetCategory> initialCategoryBudgets;
  const BudgetDetailScreen({super.key, required this.initialCategoryBudgets});

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  late double _totalBudgetSetting;
  DateTime _selectedMonthYear = DateTime.now();
  List<MockBudgetCategory> _budgetCategoriesFromSetting = [];

  String? _editingCategoryName;
  String _inputString = '';
  double _currentInput = 0.0;

  @override
  void initState(){
    super.initState();
    _budgetCategoriesFromSetting = List.from(widget.initialCategoryBudgets);
    _totalBudgetSetting = _budgetCategoriesFromSetting
        .firstWhere((e) => e.name == 'Ngân sách hàng tháng')
        .budget;
    _inputString = _totalBudgetSetting.toInt().toString();
    _currentInput = _totalBudgetSetting;
    _editingCategoryName = null;
  }

  List<BudgetCategory> get _categoryBudgetsDynamic {
    final actualExpenses = getMonthlyExpenseByCategory(_selectedMonthYear);
    final Map<String, dynamic> expenseMap = {
      for(var expense in actualExpenses) expense.categoryName: expense
    };
    final List<BudgetCategory> result = [];

    // Duyệt qua TẤT CẢ các danh mục ĐÃ CÀI ĐẶT NGÂN SÁCH (trừ 'Ngân sách hàng tháng')
    for (var setting in _budgetCategoriesFromSetting) {
      if (setting.name == 'Ngân sách hàng tháng') continue;

      final expenseData = expenseMap[setting.name];
      final double expenseAmount = expenseData?.totalAmount ?? 0.0;

      if (setting.budget > 0 || expenseAmount > 0) {
        result.add(
            BudgetCategory(
              name: setting.name,
              budget: setting.budget,
              expense: expenseAmount,
              icon: setting.icon,
            )
        );
      }
      if (expenseData != null) {
        expenseMap.remove(setting.name);
      }
    }
    expenseMap.forEach((categoryName, expense) {
      if (expense.totalAmount > 0) {
        result.add(
            BudgetCategory(
              name: categoryName,
              budget: 0.0,
              expense: expense.totalAmount,
              icon: expense.icon,
            )
        );
      }
    });

    return result;
  }

  double _getBudgetSettingForCategory(String categoryName){
    MockBudgetCategory? budgetEntry = _budgetCategoriesFromSetting.firstWhere(
          (e) => e.name == categoryName,
      orElse: () => MockBudgetCategory(name: '', budget: 0.0, icon: Icons.error),
    );
    return budgetEntry.budget;
  }

  List<BudgetCategory> get _categoryBudgets => _categoryBudgetsDynamic;
  double get _totalExpense => getTotalMonthlyExpense(_selectedMonthYear);
  double get _totalRemaining => _totalBudgetSetting - _totalExpense;

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  double _getBudgetByName(String name) {
    if(name == 'Monthly') return _totalBudgetSetting;
    return _categoryBudgets.firstWhere((e) => e.name == name).budget;
  }

  // logic chế độ sửa trực tiếp
  void _startEditing(String categoryName) {
    setState(() {
      _editingCategoryName = categoryName;
      double initialBudget = _getBudgetByName(categoryName);
      _inputString = initialBudget.toInt().toString();
      _currentInput = initialBudget;
    });
  }

  void _onKeyTap(String key) {
    if(_editingCategoryName == null) return;

    setState(() {
      if(key == '✓'){
        double newValue = double.tryParse(_inputString) ?? 0.0;
        String categoryToSave = _editingCategoryName == 'Monthly' ? 'Ngân sách hàng tháng' : _editingCategoryName!;
        _saveCategoryBudget(categoryToSave, newValue);
        if(_editingCategoryName == 'Monthly'){
          _totalBudgetSetting = newValue;
        } else{
          _saveCategoryBudget(_editingCategoryName!, newValue);
        }
        _editingCategoryName = null;
        _inputString = '';
        _currentInput = 0.0;
        return;
      }

      if(key == 'x'){
        if(_inputString.isNotEmpty){
          _inputString = _inputString.substring(0, _inputString.length-1);
        }
        if(_inputString.isEmpty){
          _inputString = '0';
        }
      } else if (key == '🗑️'){
        _inputString = '0';
        _currentInput = 0.0;
      } else if(key == '▼'){
        _editingCategoryName = null;
        _inputString = '';
        _currentInput = 0.0;
        return;
      } else if(int.tryParse(key) != null){
        if(_inputString.length < 10){
          if(_inputString == '0'){
            _inputString = key;
          } else {
            _inputString += key;
          }
        }
      }
      String cleanInput = _inputString.replaceAll('.', '');
      _currentInput = double.tryParse(_inputString) ?? 0.0;
    });
  }

  void _saveCategoryBudget(String categoryName, double newBudget){
    final index = _budgetCategoriesFromSetting.indexWhere((e) => e.name == categoryName);
    if (index != -1) {
      final updatedEntry = MockBudgetCategory(
        name: categoryName,
        budget: newBudget,
        icon: _budgetCategoriesFromSetting[index].icon,
      );
      _budgetCategoriesFromSetting[index] = updatedEntry;
    }
  }

  // nut appbar
  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonthYear,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('vi'),
      builder: (context, child){
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryPink,
              onPrimary: Colors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
            textScaleFactor: 0.95,
            ),
            child: child!,
          ),
        );
      },
    );
    if(picked != null && (picked.year != _selectedMonthYear.year || picked.month != _selectedMonthYear.month)){
      setState(() {
        _selectedMonthYear = picked;
      });
    }
  }

  void _openSettingsScreen() async {
    final dynamic updatedBudgets = await showModalBottomSheet(
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
            child: BudgetSettingScreen(
              initialBudgets: _budgetCategoriesFromSetting,
            ),
          ),
        );
      },
    );

    if(updatedBudgets != null && updatedBudgets is List) {
      List<MockBudgetCategory> newBudgets = updatedBudgets.cast<MockBudgetCategory>();
      MockBudgetCategory? monthlyBudgetEntry = newBudgets.firstWhere(
            (e) => e.name == 'Ngân sách hàng tháng',
        orElse: () => MockBudgetCategory(name: '', budget: 0.0, icon: Icons.error), // Tránh lỗi nếu không tìm thấy
      );
      setState(() {
        _totalBudgetSetting = monthlyBudgetEntry?.budget ?? _totalBudgetSetting;
        _budgetCategoriesFromSetting = newBudgets;
      });
    }
  }
  Widget _buildKey(String label, {Color color = Colors.black, bool isAction = false}) {
    bool isCheck = label == '✓';
    bool isDelete = label == '🗑️';
    bool isBackspace = label == 'x';
    bool isDownArrow = label == '▼';
    bool isComma = label == ',';

    IconData? icon;
    if (isCheck) icon = Icons.check;
    else if (isDelete) icon = Icons.delete_outline;
    else if (isBackspace) icon = Icons.backspace_outlined;
    else if (isDownArrow) icon = Icons.keyboard_arrow_down;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => _onKeyTap(label),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAction ? Colors.pink.shade400 : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: isAction || isCheck ? null : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: icon != null
              ? Icon(
                  icon,
                  color: isCheck ? Colors.white : Colors.black,
                  size: 24,
                )
              : Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isAction ? Colors.white : color,
                ),
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatDetail(String title, String value, {Color color = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildBudgetRow(String label, double budget, double expense, {IconData? icon, bool isMonthlyTotal = false}) {
    String categoryKey = isMonthlyTotal ? 'Monthly' : label;
    bool isEditing = _editingCategoryName == categoryKey;

    double displayBudget = isEditing ? _currentInput : budget;
    double remaining = displayBudget - expense;
    double progress = displayBudget > 0 ? expense / displayBudget : 0.0;

    Color progressColor;
    if (expense > displayBudget) {
      progressColor = Colors.red;
    }
    else if (displayBudget == 0.0 && expense == 0.0) {
      progressColor = Colors.lightGreen.shade200;
    }
    else {
      if (progress <= 0.8) {
        progressColor = Colors.lightGreen;
      } else {
        progressColor = Colors.green.shade200;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 5.0,
                        backgroundColor: Colors.lightGreen.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                    if (icon != null)
                      Icon(icon, color: Colors.pink.shade400, size: 30),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isMonthlyTotal ? 'Ngân sách hàng tháng' : label,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            if (isEditing) {
                              setState(() {
                                _editingCategoryName = null;
                              });
                            } else {
                              _startEditing(categoryKey);
                            }
                          },
                          child: Text(
                              isEditing ? 'Huỷ' : 'Sửa',
                              style: TextStyle(color: isEditing ? Colors.grey : Colors.pink.shade400)
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatDetail('Ngân sách:', _formatAmount(displayBudget)),
                        _buildStatDetail('Chi tiêu:', _formatAmount(expense), color: Colors.black),
                        _buildStatDetail('Còn lại:', _formatAmount(remaining), color: remaining >= 0 ? Colors.black : Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          if(!isEditing)
            const Divider(
              color: Colors.grey,
              height: 1.0,
              thickness: 0.5,
            ),
        ],
      ),
    );
  }

  Widget _buildInputDisplay() {
    String title = _editingCategoryName == 'Monthly' ? 'Ngân sách hàng tháng' : _editingCategoryName!;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            alignment: Alignment.centerRight,
            child: Text(
              _formatAmount(_currentInput),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorKeypad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: 16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        const List<String> keys = [
          '7', '8', '9', '▼',
          '4', '5', '6', '🗑️',
          '1', '2', '3', '',
          ',', '0', 'x', '✓',
        ];

        String label = keys[index];
        bool isAction = label == '✓';
        return _buildKey(label, isAction: isAction);
      },
    );
  }

  // BUILD chính
  @override
  Widget build(BuildContext context) {
    bool isEditing = _editingCategoryName != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân Sách', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _budgetCategoriesFromSetting),
        ),
        actions: [
          TextButton(
            onPressed: () => _selectMonthYear(context),
            child: Row(
              children: [
                Text(
                  'Thg ${DateFormat('MM yyyy').format(_selectedMonthYear)}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.only(bottom: isEditing ? 300.0 : 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBudgetRow(
                      'Ngân sách hàng tháng',
                      _totalBudgetSetting,
                      _totalExpense,
                      isMonthlyTotal: true
                  ),

                  const SizedBox(height: 20),

                  ..._categoryBudgets.map((budget) {
                    return _buildBudgetRow(
                      budget.name,
                      budget.budget,
                      budget.expense,
                      icon: budget.icon,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEditing)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInputDisplay(),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              height: 220,
                              child: _buildCalculatorKeypad(),
                            )
                        )
                      ]
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _openSettingsScreen,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.pink.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '+ Cài đặt ngân sách',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
