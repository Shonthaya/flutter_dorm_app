// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'main_layout.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  // สร้างตัวแปรเรียกใช้ Service
  final AuthService _authService = AuthService();

  void _handleLogin() async {
    // 1. ตรวจสอบว่ากรอกข้อมูลครบไหม
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
      );
      return;
    }

    setState(() => _isLoading = true); // เริ่มโหลด

    try {
      // 2. เรียกใช้ Service เพื่อตรวจสอบกับ Supabase
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. ถ้าสำเร็จ ให้เปลี่ยนหน้าไป MainLayout
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      // 4. ถ้าผิดพลาด (เช่น รหัสผิด) ให้แจ้งเตือนผู้ใช้
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // หยุดโหลด
    }
  }

  @override
  void dispose() {
    // คืนค่าหน่วยความจำเมื่อปิดหน้าจอ
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // สีพื้นหลังขาวนวล ตามธีม
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ส่วนของโลโก้ (ชั่วคราวใช้ Icon หากมีภาพสามารถเปลี่ยนเป็น Image.asset ได้)
                const Icon(
                  Icons.domain_rounded,
                  size: 80,
                  color: Color(0xFFC48B71), // สีหลักโทนอบอุ่น
                ),
                const SizedBox(height: 24),

                // ชื่อแอป
                const Text(
                  'DormManager',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333), // สีเทาเข้ม
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // ข้อความต้อนรับ
                const Text(
                  'ยินดีต้อนรับสู่การทำงาน',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),

                // ช่องกรอกอีเมล
                CustomTextField(
                  hintText: 'อีเมล',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // ช่องกรอกรหัสผ่าน
                CustomTextField(
                  hintText: 'รหัสผ่าน',
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 32),

                // ปุ่มล็อกอิน
                CustomButton(
                  text: 'เข้าสู่ระบบ',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
