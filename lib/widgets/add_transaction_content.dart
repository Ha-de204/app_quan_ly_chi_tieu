import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:math_expressions/math_expressions.dart';
import '../screens/setting_category_screen.dart';
import '../models/TransactionData.dart';

class AddTransactionContent extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final TransactionData? transaction;
  final bool isEditing;
  const AddTransactionContent({
    super.key,
    this.transaction,
    this.isEditing = false,
    required this.categories,
  });


  @override
  State<AddTransactionContent> createState() => _AddTransactionContentState();
}

class _AddTransactionContentState extends State<AddTransactionContent> {
  int _selectedIndex = -1;
  String _displayValue = '0';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _noteController = TextEditingController();
  final Map<int, GlobalKey> _categoryKeys = {};

  String get formattedDateShort {
    final day = _selectedDate.day;
    final month = _selectedDate.month;
    final year = _selectedDate.year;
    return '$day thg $month, $year';
  }

  @override
  void initState(){
    super.initState();
    // tải dl khi ở chế độ sửa
    if(widget.isEditing && widget.transaction != null){
      final tx = widget.transaction!;
      _displayValue = tx.amount.toString();
      _selectedDate = tx.date;
      _noteController.text = tx.note;
      // tìm index danh mục cũ
      final oldIndex = widget.categories.indexWhere((cat) => cat['label'] == tx.category);
      if(oldIndex != -1){
        _selectedIndex = oldIndex;
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // HÀM HIỂN THỊ DATE PICKER
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  //Logic tính toán
  bool _needsCalculation() {
    return _displayValue.contains('+') ||
        (_displayValue.contains('-') && _displayValue.indexOf('-') > 0) ||
        _displayValue.contains('/');
  }
  bool _isOperator(String char) {
    return char == '+' || char == '-' || char == '/';
  }

  void _handleCategoryTap(Map<String, dynamic> category, int index) async {
    final bool isSetting = category['isSetting'] ?? false;
    final String label = category['label'] as String;

    if (isSetting) {
      final newCategory = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingCategoryScreen(),
        ),
      );

      if (newCategory != null) {
        Navigator.pop(context, {'newCategory': newCategory});
      }

    } else {
      setState(() {
        _selectedIndex = index;
        _displayValue = '0';
      });

      final targetKey = _categoryKeys[index];
      if (targetKey != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            alignment: 0.0,
          );
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chọn: $label')),
      );
    }
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'D') {
        if (_displayValue.length > 1) {
          _displayValue = _displayValue.substring(0, _displayValue.length - 1);
        } else {
          _displayValue = '0';
        }
      } else if (key == 'check') {
        if (_needsCalculation()) {
          try {
            String finalExpression = _displayValue;
            Parser p = Parser();
            Expression exp = p.parse(finalExpression);

            ContextModel cm = ContextModel();
            double eval = exp.evaluate(EvaluationType.REAL, cm);
            String result = eval.toStringAsFixed(2);
            if (result.endsWith('.00')) {
              _displayValue = result.substring(0, result.length - 3);
            } else {
              _displayValue = result;
            }
          } catch (e) {
            _displayValue = 'Lỗi';
          }
        }
      } else if (_isOperator(key)) {
          if (_displayValue.isNotEmpty &&
              !_isOperator(_displayValue.substring(_displayValue.length - 1))) {
            _displayValue += key;
          } else if (_displayValue == '0' && key == '-') {
            _displayValue = key;
          }
      } else {
        if (_displayValue == '0' || _displayValue == 'Lỗi') {
            _displayValue = key;
        } else {
            if (key == '.' && _displayValue.contains('.')) {
              return;
            }
            _displayValue += key;
        }
      }
    });
  }

  Widget _buildCategoryItem(BuildContext context, int index, String label, IconData icon, {bool isSetting = false}){
    final bool isSelected = _selectedIndex == index && !isSetting;

    return InkWell(
      onTap: (){
        _handleCategoryTap(widget.categories[index], index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: isSelected ? kPrimaryPink : Colors.grey[700]
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 15, color: isSelected ? kPrimaryPink : Colors.black)),
        ],
      ),
    );
  }

  // Helper Widget xây dựng nút bàn phím
  Widget _buildKeyboardButton(String label, {IconData? icon, Color? color, bool isOperation = false, VoidCallback? onTap, bool isCalendarButton = false}) {
    final Color textColor = isOperation ? kPrimaryPink : Colors.black;
    final Color backgroundColor = isOperation && icon == Icons.check ? kPrimaryPink : Colors.white;

    String key = label;
    if (icon == Icons.check) key = 'check';
    if (icon == Icons.backspace_outlined) key = 'D';

    if(isCalendarButton) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),

            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined, color: Colors.black, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    formattedDateShort,
                    style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: onTap ?? () => _onKeyPressed(key),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: icon != null
                ? Icon(icon, color: icon == Icons.check ? Colors.white : Colors.black, size:24)
                : Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: isOperation ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget riêng chứa Ghi chú và bàn phím
  Widget _buildInputAndKeyboard(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                    _displayValue,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.grey[800])
                ),
              ),
              const SizedBox(height: 5),

              //ghi chú
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Ghi chú: Nhập ghi chú...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    hintStyle: TextStyle(color: Colors.grey, fontSize:16),
                  ),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),

        //Bàn phím
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildKeyboardButton('7'), _buildKeyboardButton('8'), _buildKeyboardButton('9'), _buildKeyboardButton('+', isOperation: true),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        _buildKeyboardButton('4'), _buildKeyboardButton('5'), _buildKeyboardButton('6'), _buildKeyboardButton('-', isOperation: true),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        _buildKeyboardButton('1'), _buildKeyboardButton('2'), _buildKeyboardButton('3'), _buildKeyboardButton('/', isOperation: true),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        _buildKeyboardButton('', icon: Icons.calendar_month_outlined, onTap: _selectDate, isCalendarButton: true),
                        _buildKeyboardButton('0'),
                        _buildKeyboardButton('', icon: Icons.backspace_outlined, onTap: () => _onKeyPressed('D')),
                        _buildKeyboardButton('', icon: Icons.check, color:kPrimaryPink, isOperation: true, onTap: () async {
                          if (_selectedIndex == -1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng chọn danh mục trước khi lưu.',), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          if (_needsCalculation()) {
                            _onKeyPressed('check');
                            await Future.delayed(const Duration(milliseconds: 100));
                          }

                          if (_displayValue != 'Lỗi') {
                            final double parsedAmount = double.tryParse(_displayValue) ?? 0.0;
                            final selectedCategory = widget.categories[_selectedIndex];

                            final transaction = TransactionData(
                              id: widget.isEditing ? widget.transaction!.id : UniqueKey().toString(),
                              title: selectedCategory['label'] as String,
                              amount: parsedAmount,
                              category: selectedCategory['label'] as String,
                              categoryIcon: selectedCategory['icon'] as IconData,
                              type: TransactionType.expense,
                              date: _selectedDate,
                              note: _noteController.text.isEmpty ? '' : _noteController.text,
                            );

                            Navigator.pop(context, {'newTransaction': transaction});
                          } else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lỗi cú pháp tính toán! Vui lòng sửa lại.'), backgroundColor: Colors.red),
                            );
                          }
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    final bool showInputSection = _selectedIndex != -1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy', style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
              Text(
                widget.isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1),

        // Body cuộn
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: GridView.builder(physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: widget.categories.length,
                      itemBuilder: (context, index){
                        //Gán GlobalKey cho item để có thể focus
                        if (!_categoryKeys.containsKey(index)) {
                          _categoryKeys[index] = GlobalKey();
                        }
                        final category = widget.categories[index];
                        return KeyedSubtree(
                          key: _categoryKeys[index],
                          child: _buildCategoryItem(
                            context,
                            index,
                            category['label'] as String,
                            category['icon'] as IconData,
                            isSetting: category['isSetting'] ?? false,
                          ),
                        );
                      },
                  ),
                ),

                if (showInputSection)
                  const SizedBox(height: 300),
              ],
            ),
          ),
        ),
        if (showInputSection)
          _buildInputAndKeyboard(),
      ],
    );
  }
}