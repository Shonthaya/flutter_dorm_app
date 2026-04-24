import 'package:flutter/material.dart';
import 'login_view.dart'; // Import หน้า Login เพื่อเตรียมเปลี่ยนหน้า

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  // ฟังก์ชันหน่วงเวลา 2.5 วินาที แล้วเปลี่ยนไปหน้า Login อัตโนมัติ
  Future<void> _navigateToLogin() async {
    // ในอนาคตเราจะเอาหน้านี้ไว้เช็คว่าเคยล็อกอินค้างไว้หรือเปล่า
    await Future.delayed(const Duration(milliseconds: 2500));

    // ตรวจสอบว่าหน้าจอยังเปิดอยู่หรือไม่ก่อนทำการเปลี่ยนหน้า
    if (!mounted) return;

    // ใช้ pushReplacement เพื่อไม่ให้กดย้อนกลับมาหน้า Splash Screen ได้อีก
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // scaffoldBackgroundColor จะถูกดึงมาจากธีม (สีเทาอ่อน F6F8FA) อัตโนมัติครับ
    return Scaffold(
      body: Stack(
        children: [
          // พื้นที่แสดงโลโก้และชื่อแอปตรงกลาง
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. LOGO (เรียกใช้รูปภาพโลโก้ DM)
                Container(
                  width: 150, // ปรับขนาดความกว้างตามความเหมาะสม
                  height: 150, // ปรับขนาดความสูง
                  decoration: BoxDecoration(
                    color: Colors.white, // ใส่พื้นหลังสีขาวให้โลโก้ดูเด่นขึ้น
                    shape: BoxShape.circle, // ทำเป็นทรงกลม
                    // ใส่เงา Soft UI บางๆ รอบโลโก้ตามแบบที่คุณชอบ
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        75), // ตัดรูปภาพให้โค้งตาม Container
                    child: Image.asset(
                      'assets/image/LOGODM.png', // ระบุชื่อไฟล์โลโก้ของคุณให้ถูกต้อง
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32), // เว้นระยะห่าง
              ],
            ),
          ),
          // 4. ตัวโหลดหมุนๆ (Loading Indicator) แสดงด้านล่างสุดของจอ
          const Positioned(
            bottom: 60, // อยู่ห่างจากขอบล่าง 60 pixels
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3, // ความหนาของเส้นโหลด
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFF28C38)), // สีส้มตามธีม DM
              ),
            ),
          ),
        ],
      ),
    );
  }
}
