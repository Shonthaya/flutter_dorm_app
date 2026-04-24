import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart'; // ดึงตัวแปร supabase ที่เราสร้างไว้มาใช้งาน

class AuthService {
  // ฟังก์ชันสำหรับเข้าสู่ระบบ
  Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    try {
      // ส่งคำสั่งไปตรวจสอบกับระบบ Auth ของ Supabase
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      // ดักจับ Error ที่มาจาก Supabase โดยตรง (เช่น รหัสผิด, ไม่มีอีเมลนี้)
      throw Exception(e.message);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการเชื่อมต่อ');
    }
  }

  // ฟังก์ชันสำหรับออกจากระบบ
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // เช็คว่าปัจจุบันมีแอดมินล็อกอินค้างไว้หรือไม่ (ใช้เช็คตอนหน้า Splash Screen)
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
