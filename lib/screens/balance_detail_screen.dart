import 'package:flutter/material.dart';
import '../constants.dart';

class BalanceDetailScreen extends StatelessWidget {
  const BalanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Số dư', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 40, color: kPrimaryPink),
            const SizedBox(height: 10),
            const Text(
              'Giao diện Lịch sử số dư và dòng tiền sẽ nằm ở đây.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}