import 'package:flutter/material.dart';
import 'login_view.dart'; // import หน้า Login เข้ามาเพื่อเตรียมเปลี่ยนหน้า

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // หน่วงเวลา 2.5 วินาที เพื่อให้โชว์หน้า Splash Screen
    // (ในอนาคตเราจะใส่คำสั่งเช็คสถานะการล็อกอินที่นี่)
    await Future.delayed(const Duration(milliseconds: 2500));

    // ตรวจสอบว่าหน้าจอยังเปิดอยู่หรือไม่ก่อนทำการเปลี่ยนหน้า
    if (!mounted) return;

    // ใช้ pushReplacement เพื่อไม่ให้ผู้ใช้กดย้อนกลับมาหน้า Splash Screen ได้อีก
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // สีพื้นหลังขาวนวล
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้
            const Icon(
              Icons.domain_rounded,
              size: 100,
              color: Color(0xFFC48B71), // สีหลักโทนอบอุ่น
            ),
            const SizedBox(height: 24),

            // ชื่อแอป
            const Text(
              'DormManager',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // ตัวโหลดหมุนๆ
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC48B71)),
            ),
          ],
        ),
      ),
    );
  }
}
