import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mock_budget_category.dart';

class BudgetSettingScreen extends StatefulWidget {
  final List<MockBudgetCategory> initialBudgets;
  const BudgetSettingScreen({
    super.key,
    required this.initialBudgets,
  });

  @override
  State<BudgetSettingScreen> createState() => _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends State<BudgetSettingScreen> {
  // Dữ liệu tĩnh
  late List<MockBudgetCategory> _budgetCategories;

  String? _editingCategoryName;
  double _currentBudgetInput = 0.0;
  String _inputString = '';

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  void initState(){
    super.initState();
    _budgetCategories = List.from(widget.initialBudgets);

    _editingCategoryName = null;
    _inputString = '';
    _currentBudgetInput = 0.0;
  }
  // -Logic Chỉnh sửa
  void _startEditing(String categoryName, double initialBudget) {
    setState(() {
      _editingCategoryName = categoryName;
      _inputString = initialBudget.toInt().toString();
      _currentBudgetInput = initialBudget;
    });
  }

  void _onKeyTap(String key) {
    if(_editingCategoryName == null) return;

    setState(() {
      if(key == '✓'){
        double newValue = double.tryParse(_inputString) ?? 0.0;
        String categoryToSave = _editingCategoryName!;
        _saveBudget(categoryToSave, newValue);

        _editingCategoryName = null;
        _inputString = '';
        _currentBudgetInput = 0.0;
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
      } else if(key == '▼'){
        _editingCategoryName = null;
        _inputString = '';
        _currentBudgetInput = 0.0;
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
      _currentBudgetInput = double.tryParse(_inputString) ?? 0.0;
    });
  }

  void _saveBudget(String categoryName, double newBudget) {
      int index = _budgetCategories.indexWhere((e) => e.name == categoryName);
      if (index != -1) {
          _budgetCategories[index] = MockBudgetCategory(
            name: categoryName,
            budget: newBudget,
            icon: _budgetCategories[index].icon,
          );
      }
  }

  Widget _buildKey(String label, {bool isAction = false}) {
    bool isCheck = label == '✓';
    bool isDelete = label == '🗑️';
    bool isBackspace = label == 'x';
    bool isDownArrow = label == '▼';

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
              boxShadow: isCheck ? null : [
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
                    color: isAction ? Colors.white : Colors.black,
                  ),
              ),
          ),
        ),
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

  Widget _buildBudgetSettingRow(MockBudgetCategory item) {
    bool isEditing = _editingCategoryName == item.name;
    double displayAmount = isEditing ? _currentBudgetInput : item.budget;
    Widget editWidget = InkWell(
      onTap: () => _startEditing(item.name, item.budget),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          item.budget == 0.0 ? 'Sửa' : _formatAmount(displayAmount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isEditing ? Colors.pink.shade400 : Colors.black,
          ),
        ),
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(item.icon, color: Colors.red, size: 24),
              const SizedBox(width: 15),
              Text(item.name, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              editWidget,
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  Widget _buildInputDisplay() {
    String title = _editingCategoryName ?? '';

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
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
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              _formatAmount(_currentBudgetInput),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  //  BUILD chính
  @override
  Widget build(BuildContext context) {
    bool isEditing = _editingCategoryName != null;

    return Container(
      height: MediaQuery.of(context).size.height * (isEditing ? 0.9 : 0.7),
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                ),
                const Text('Cài đặt ngân sách', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () => Navigator.pop(context, _budgetCategories),
                  child: const Text('Xong', style: TextStyle(color: Colors.pink)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // danh sách ngân sách
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ..._budgetCategories.map((item) => _buildBudgetSettingRow(item)).toList(),
                ],
              ),
            ),
          ),

          if (isEditing)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputDisplay(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: SizedBox(
                    height: 250,
                    child: _buildCalculatorKeypad(),
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}