import 'package:flutter/material.dart';
import '../constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String policyContent = """
 1. Loại Thông tin Thu thập
Chúng tôi chỉ thu thập thông tin cá nhân cần thiết để cung cấp dịch vụ, bao gồm:
- Thông tin Tài khoản: Tên người dùng và địa chỉ email (khi đăng nhập qua Google).
- Dữ liệu Giao dịch: Chi tiêu, thu nhập, ngân sách được bạn nhập vào ứng dụng.

 2. Mục đích Thu thập
Dữ liệu chỉ được sử dụng để:
- Cung cấp, duy trì và cải thiện các chức năng của ứng dụng.
- Cá nhân hóa trải nghiệm của bạn (ví dụ: báo cáo chi tiêu).
- Gửi thông báo cần thiết (nếu bạn bật Lời nhắc nhở).

 3. Lưu trữ và Bảo mật Dữ liệu
- Dữ liệu giao dịch được lưu trữ bảo mật trên nền tảng đám mây (Firestore).
- Chúng tôi áp dụng các biện pháp bảo mật tiêu chuẩn để bảo vệ dữ liệu khỏi truy cập trái phép.
- Chỉ người dùng đã đăng nhập mới có thể truy cập dữ liệu của chính mình.

 4. Chia sẻ Thông tin
Chúng tôi cam kết không bán, trao đổi hoặc chuyển giao thông tin cá nhân hoặc dữ liệu giao dịch của bạn cho bên thứ ba, trừ khi có yêu cầu pháp lý hoặc theo sự đồng ý rõ ràng của bạn.

 5. Quyền của Người dùng
Bạn có quyền:
- Truy cập và xem xét dữ liệu cá nhân của mình.
- Yêu cầu xóa tất cả dữ liệu (xem mục "Xóa tất cả dữ liệu" trên màn hình Tài khoản).

 6. Liên hệ
Nếu có bất kỳ câu hỏi nào về Chính sách bảo mật này, vui lòng liên hệ với chúng tôi qua email hỗ trợ: abc@gmail.com.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chính sách bảo mật',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              policyContent,
              style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}