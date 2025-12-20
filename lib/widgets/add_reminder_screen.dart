import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/ReminderData.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  // controller cho input text
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedFrequency = 'Hàng ngày';
  final List<String> _frequencyOptions = ['Hàng ngày', 'Hàng tuần', 'Hàng tháng', 'Hàng năm'];

  //State cho Date va Time
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 5));

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute,
    ).add(const Duration(minutes: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ham hien thi lich
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDateTime,
        firstDate: DateTime.now().subtract(const Duration(days: 365*5)),
        lastDate: DateTime.now().add(const Duration(days: 365*5)),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: kPrimaryPink,
              colorScheme: const ColorScheme.light(primary: kPrimaryPink),
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
    );
    if(pickedDate != null){
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  // ham hien thi chon gio
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: kPrimaryPink,
              colorScheme: const ColorScheme.light(primary: kPrimaryPink),
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
    );
    if(pickedTime != null){
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // luu reminder
  void _saveReminder() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final note = _noteController.text.trim();

    if(title.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên mục nhắc nhở.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message.isNotEmpty ? message: null,
      dateTime: _selectedDateTime,
      frequency: _selectedFrequency!,
      note: note.isNotEmpty ? note : null,
      isEnabled: true,
    );
    Navigator.pop(context, newReminder);// tra doi tuong ReminderData ve man hinh truoc
  }

  Widget _buildCustomInput({
    required String title,
    String? hintText,
    bool isDropdown = false,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, color: kPrimaryPink, margin: const EdgeInsets.only(right: 8)),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: isDropdown ? 0 : 10,
              bottom: isDropdown ? 0 : 10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: isDropdown
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFrequency,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFrequency = newValue;
                        });
                      },
                      items: _frequencyOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            )
                : TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none, // Xóa border
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInput({required String title, required String value, required VoidCallback onTap, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, color: kPrimaryPink, margin: const EdgeInsets.only(right: 8)),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // format theo tieng Viet
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    String selectedDateString = dateFormatter.format(_selectedDateTime);
    String selectedTimeString = timeFormatter.format(_selectedDateTime);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: kPrimaryPink, fontSize: 16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: kPrimaryPink),
            onPressed: _saveReminder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomInput(
              title: 'Tên mục nhắc nhở',
              hintText: 'Nhập tên lời nhắc',
              controller: _titleController,
            ),
            _buildCustomInput(
              title: 'Lời nhắc nhở',
              hintText: 'Lời nhắc nhở (tùy chọn)',
              controller: _messageController,
            ),

            _buildCustomInput(
              title: 'Tần suất nhắc nhở',
              isDropdown: true,
            ),

            _buildDateTimeInput(
              title: 'Ngày bắt đầu nhắc nhở',
              value: selectedDateString,
              onTap: _selectDate,
              icon: Icons.calendar_today_outlined,
            ),

            _buildDateTimeInput(
              title: 'Thời gian',
              value: selectedTimeString,
              onTap: _selectTime,
              icon: Icons.access_time_outlined,
            ),

            _buildCustomInput(
              title: 'Ghi chú',
              hintText: 'Đừng quên ghi lại các khoản chi tiêu của bạn!',
              controller: _noteController,
              maxLines: 3,
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}