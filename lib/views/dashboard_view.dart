import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
// 💡 Import หน้าจอต่างๆ เพื่อให้ Dashboard รู้จักและพาไปถูกที่
import 'room_view.dart';
import 'tenant_view.dart';
import 'bill_view.dart';
import 'history_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardService _dashboardService = DashboardService();
  bool _isLoading = true;

  double _monthlyRevenue = 0.0;
  int _unpaidBillsCount = 0;
  int _availableRoomsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
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
              child: CircularProgressIndicator(color: Color(0xFFF28C38)))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: const Color(0xFFF28C38),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('สวัสดีครับแอดมิน 👋',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3338))),
                    const SizedBox(height: 8),
                    const Text('นี่คือภาพรวมหอพักของคุณในเดือนนี้',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 32),

                    _buildMainStatCard(
                      title: 'รายรับเดือนนี้ (ชำระแล้ว)',
                      value: '฿${_monthlyRevenue.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFFF28C38),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSubStatCard(
                            title: 'ยังไม่จ่าย',
                            value: '$_unpaidBillsCount บิล',
                            icon: Icons.pending_actions_rounded,
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

                    const Text('เมนูด่วน',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3338))),
                    const SizedBox(height: 16),

                    // 💡 ส่วนที่อัปเดต: ใส่ Navigator.push ให้ปุ่มทำงาน
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildQuickMenu(
                            Icons.post_add_rounded, 'จัดการบิล', Colors.blue,
                            () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BillView())).then((_) =>
                              _loadDashboardData()); // กลับมาหน้าแรกให้โหลดข้อมูลใหม่
                        }),
                        _buildQuickMenu(Icons.person_add_alt_1_rounded,
                            'เพิ่มผู้เช่า', Colors.purple, () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const TenantView()))
                              .then((_) => _loadDashboardData());
                        }),
                        _buildQuickMenu(Icons.add_business_rounded,
                            'จัดการห้องพัก', Colors.orange, () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RoomView()))
                              .then((_) => _loadDashboardData());
                        }),
                        _buildQuickMenu(Icons.history_rounded, 'ประวัติบิล',
                            Colors.blueGrey, () {
                          // เปลี่ยนมาใช้คำสั่งนี้เพื่อไปหน้าประวัติ
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HistoryView()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickMenu(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
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
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
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
              offset: const Offset(0, 5))
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
