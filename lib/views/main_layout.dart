import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_view.dart';
// เดี๋ยวเราจะ import หน้า Dashboard, Room, Tenant, Bill ของจริงมาใส่ทีหลัง

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  // รายชื่อหน้าจอทั้ง 4 หน้า (ตอนนี้สร้างเป็นข้อความจำลองไว้ตรงกลางจอก่อน)
  final List<Widget> _pages = [
    const Center(
        child:
            Text('หน้า: ภาพรวม (Dashboard)', style: TextStyle(fontSize: 20))),
    const Center(
        child: Text('หน้า: จัดการห้องพัก', style: TextStyle(fontSize: 20))),
    const Center(child: Text('หน้า: ผู้เช่า', style: TextStyle(fontSize: 20))),
    const Center(
        child: Text('หน้า: ค่าใช้จ่าย (บิล)', style: TextStyle(fontSize: 20))),
  ];

  // ฟังก์ชันเปลี่ยนหน้าเมื่อกดเมนูด้านล่าง
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
      backgroundColor: const Color(0xFFFDFBF7), // พื้นหลังขาวนวล

      // แถบด้านบน (App Bar)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // เอาเงาออกให้แบนราบ
        title: const Text(
          'DormManager',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFC48B71)),
            onPressed: _handleLogout,
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),

      // พื้นที่แสดงผลหลักตรงกลางจอ (เปลี่ยนไปตามเมนูที่กด)
      body: _pages[_selectedIndex],

      // แถบเมนูด้านล่าง
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // บังคับให้แสดงข้อความครบทุกปุ่ม
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFC48B71), // สีส้มอิฐตอนถูกเลือก
        unselectedItemColor: Colors.grey.shade400, // สีเทาตอนไม่ได้เลือก
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded), // ไอคอนทึบตอนถูกเลือก
            label: 'ภาพรวม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.door_front_door_outlined),
            activeIcon: Icon(Icons.door_front_door),
            label: 'ห้องพัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'ผู้เช่า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'ค่าใช้จ่าย',
          ),
        ],
      ),
    );
  }
}
