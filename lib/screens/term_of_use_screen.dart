import 'package:flutter/material.dart';
import '../constants.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  static const String termsContent = """
 1. Chấp nhận Điều khoản
Bằng việc truy cập và sử dụng ứng dụng Sổ Cái Thu Chi, bạn đồng ý chịu ràng buộc bởi các điều khoản và điều kiện sau đây. Nếu bạn không đồng ý với bất kỳ điều khoản nào, vui lòng không sử dụng ứng dụng.

 2. Giới hạn Sử dụng
Ứng dụng chỉ được phép sử dụng cho mục đích quản lý tài chính cá nhân. Nghiêm cấm mọi hành vi sử dụng cho mục đích thương mại hoặc bất hợp pháp.

 3. Quyền sở hữu Trí tuệ
Tất cả nội dung, thiết kế, logo và phần mềm trong ứng dụng là tài sản của chúng tôi và được bảo vệ bởi luật sở hữu trí tuệ.

 4. Trách nhiệm Dữ liệu
Bạn hoàn toàn chịu trách nhiệm về tính chính xác của dữ liệu giao dịch bạn nhập. Chúng tôi không đảm bảo dữ liệu sẽ không bị mất do lỗi kỹ thuật hoặc sự cố ngoài tầm kiểm soát.

 5. Giới hạn Trách nhiệm
Ứng dụng được cung cấp "nguyên trạng". Chúng tôi không chịu trách nhiệm đối với bất kỳ tổn thất trực tiếp, gián tiếp hoặc ngẫu nhiên nào phát sinh từ việc sử dụng hoặc không thể sử dụng ứng dụng.

 6. Thay đổi Điều khoản
Chúng tôi có quyền sửa đổi các điều khoản này bất cứ lúc nào. Bằng việc tiếp tục sử dụng ứng dụng sau khi các thay đổi được đăng tải, bạn đồng ý chịu ràng buộc bởi các điều khoản đã sửa đổi.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Điều khoản sử dụng',
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
              termsContent,
              style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}