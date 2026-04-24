import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        // 💡 ลบ style: ElevatedButton.styleFrom(...) ออกทั้งหมด
        // เพื่อให้ปุ่มดึงสีส้ม DM โลโก้ และเงาโค้งมนจาก AppTheme มาใช้อัตโนมัติ
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3),
              )
            : Text(text),
        // 💡 ลบ TextStyle ออกด้วย เพื่อให้ดึงฟอนต์ Kanit จาก Theme มาใช้
      ),
    );
  }
}
