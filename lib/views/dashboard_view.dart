import 'package:flutter/material.dart';
import '../services/dashboard_service.dart'; // 1. Import Service เข้ามา

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = true; // ตอนเริ่มให้เป็น true เพื่อโชว์ตัวโหลด
  double _monthlyRevenue = 0.0;
  int _unpaidBillsCount = 0;
  int _availableRoomsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData(); // 2. สั่งโหลดข้อมูลทันทีที่เปิดหน้านี้
  }

  // ฟังก์ชันดึงข้อมูลจาก Service
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _dashboardService.getDashboardStats();

      if (mounted) {
        setState(() {
          _monthlyRevenue = stats['revenue'] as double;
          _unpaidBillsCount = stats['unpaid_bills'] as int;
          _availableRoomsCount = stats['available_rooms'] as int;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              // ถ้ากำลังโหลด ให้โชว์วงกลมหมุนๆ สีส้ม
              child: CircularProgressIndicator(color: Color(0xFFF28C38)),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData, // สไลด์จอลงเพื่อรีเฟรชข้อมูลใหม่
              color: const Color(0xFFF28C38),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'สวัสดีครับแอดมิน 👋',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3338)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'นี่คือภาพรวมหอพักของคุณในเดือนนี้',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),

                    // 3. เอาตัวแปรจริงมาใส่ใน UI
                    _buildMainStatCard(
                      title: 'ยอดรับเดือนนี้',
                      value:
                          '฿${_monthlyRevenue.toStringAsFixed(0)}', // ตัดทศนิยมออกให้ดูคลีน
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFFF28C38),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSubStatCard(
                            title: 'บิลค้างชำระ',
                            value: '$_unpaidBillsCount ห้อง',
                            icon: Icons.receipt_long_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSubStatCard(
                            title: 'ห้องว่าง',
                            value: '$_availableRoomsCount ห้อง',
                            icon: Icons.door_front_door_rounded,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'เมนูด่วน',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3338)),
                    ),
                    const SizedBox(height: 16),
                    // เดี๋ยวเรามาเพิ่มปุ่มเมนูด่วนตรงนี้
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMainStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF2C3338),
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
