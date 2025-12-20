import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/add_reminder_screen.dart';
import '../constants.dart';
import '../models/ReminderData.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<Reminder> _reminders = [];

  void _addReminder() async {
    final newReminder = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReminderScreen()),
    );

    if (newReminder != null && newReminder is Reminder) {
      setState(() {
        _reminders.add(newReminder);
        _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm lời nhắc thành công!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  Widget _buildReminderCard(Reminder reminder) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reminder.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryPink,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.alarm, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${timeFormatter.format(reminder.dateTime)} - ${dateFormatter.format(reminder.dateTime)}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  reminder.frequency,
                  style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            if (reminder.message != null && reminder.message!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Lời nhắc: ${reminder.message!}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),

            if (reminder.note != null && reminder.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Ghi chú: ${reminder.note!}',
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
            'Lời nhắc nhở',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _reminders.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có lời nhắc nào.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const Text(
                  'Hãy thêm một lời nhắc mới!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                return _buildReminderCard(_reminders[index]);
              },
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        backgroundColor: kPrimaryPink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm lời nhắc',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}