import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_view.dart';
import 'dashboard_view.dart';
import 'room_view.dart';
import 'tenant_view.dart';
import 'bill_view.dart';
// เดี๋ยวเราจะทำการ import ไฟล์หน้าจอของจริง (Dashboard, Room, ฯลฯ) มาใส่ในขั้นต่อไป

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  // สร้าง List ของหน้าจอทั้ง 4 หน้า (ตอนนี้ใส่ข้อความจำลองไว้ตรงกลางจอก่อน)
  final List<Widget> _pages = [
    const DashboardView(),
    const RoomView(),
    const TenantView(),
    const BillView(),
    const Center(child: Text('หน้า: จัดการห้องพัก')),
    const Center(child: Text('หน้า: ผู้เช่า')),
    const Center(child: Text('หน้า: ค่าใช้จ่าย (บิล)')),
  ];

  // ฟังก์ชันสลับหน้าจอเมื่อกดเมนูด้านล่าง
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ฟังก์ชันออกจากระบบ
  void _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แถบด้านบน (App Bar) จะดึงสไตล์ความคลีนมาจาก app_theme.dart อัตโนมัติ
      appBar: AppBar(
        title: const Text('Dorm Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),

      // พื้นที่แสดงผลหลักตรงกลางจอ (เปลี่ยนไปตามเมนูที่กด)
      body: _pages[_selectedIndex],

      // แถบเมนูด้านล่าง (Bottom Navigation Bar) สไตล์ Soft UI
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, -5), // เงาฟุ้งขึ้นด้านบนเล็กน้อย
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0, // ปิดเงาเดิมของ Flutter ทิ้งไปใช้เงาของ Container แทน
          type: BottomNavigationBarType
              .fixed, // บังคับให้แสดงข้อความและไอคอนครบทุกปุ่ม
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          // สีของไอคอนที่ถูกเลือกจะถูกดึงมาจาก Theme หลัก (สีส้ม) อัตโนมัติ
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'ภาพรวม',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.door_front_door_outlined),
              activeIcon: Icon(Icons.door_front_door_rounded),
              label: 'ห้องพัก',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'ผู้เช่า',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'ค่าใช้จ่าย',
            ),
          ],
        ),
      ),
    );
  }
}
