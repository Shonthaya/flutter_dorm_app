import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ฟังก์ชันเหมาจ่าย: ดึงสถิติทั้ง 3 อย่างกลับมาพร้อมกัน
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // หาเดือนและปีปัจจุบัน เพื่อดึงรายได้ให้ตรงเดือน
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // 1. คำนวณยอดรายรับเดือนนี้ (เอาเฉพาะบิลที่ status = 'paid' ของเดือนนี้)
      final billsResponse = await _supabase
          .from('bills_tb')
          .select('total_amount')
          .eq('status', 'paid')
          .eq('month', currentMonth)
          .eq('year', currentYear);

      double totalRevenue = 0;
      for (var bill in billsResponse) {
        totalRevenue += (bill['total_amount'] as num).toDouble();
      }

      // 2. นับจำนวนบิลค้างชำระ (status = 'unpaid')
      final unpaidResponse = await _supabase
          .from('bills_tb')
          .select('id')
          .eq('status', 'unpaid')
          .count(CountOption.exact); // คำสั่งให้นับจำนวนแถว

      final unpaidCount = unpaidResponse.count ?? 0;

      // 3. นับจำนวนห้องว่าง (status = 'available')
      final roomsResponse = await _supabase
          .from('rooms_tb')
          .select('id')
          .eq('status', 'available')
          .count(CountOption.exact);

      final availableRoomsCount = roomsResponse.count ?? 0;

      // ส่งข้อมูลทั้ง 3 ก้อนกลับไปให้หน้า UI
      return {
        'revenue': totalRevenue,
        'unpaid_bills': unpaidCount,
        'available_rooms': availableRoomsCount,
      };
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูล Dashboard: $e');
    }
  }
}
