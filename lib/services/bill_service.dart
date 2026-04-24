import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bill_model.dart';

class BillService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. ดึงข้อมูลบิลทั้งหมด พร้อมชื่อห้องและชื่อคนเช่า
  Future<List<BillModel>> getBills() async {
    try {
      final response = await _supabase
          .from('bills_tb')
          .select('*, rooms_tb(room_number), tenants_tb(name)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((bill) => BillModel.fromJson(bill))
          .toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลบิล: $e');
    }
  }

  // 2. ดึงรายชื่อผู้เช่าที่ยังอยู่ (active) พร้อมข้อมูลเรทน้ำไฟของห้องนั้น
  Future<List<Map<String, dynamic>>> getActiveTenantsForBilling() async {
    try {
      final response = await _supabase
          .from('tenants_tb')
          .select(
              'id, name, room_id, rooms_tb(room_number, price, water_rate, electric_rate)')
          .eq('status', 'active');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลผู้เช่า: $e');
    }
  }

  // 3. บันทึกบิลใหม่ลงฐานข้อมูล
  Future<void> createBill(BillModel bill) async {
    try {
      await _supabase.from('bills_tb').insert(bill.toJson());
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการสร้างบิล: $e');
    }
  }

  // 4. ดึงเลขมิเตอร์ล่าสุดของห้องนั้นๆ เพื่อเอาไปเป็นค่าเริ่มต้นของบิลเดือนถัดไป
  Future<Map<String, double>> getLastMeterReading(String roomId) async {
    try {
      final response = await _supabase
          .from('bills_tb')
          .select('water_meter_cur, electric_meter_cur')
          .eq('room_id', roomId)
          .order('created_at', ascending: false) // เรียงจากบิลล่าสุด
          .limit(1); // เอามาแค่ใบเดียว

      if (response.isNotEmpty) {
        // ถ้าเคยมีบิลแล้ว ให้เอามิเตอร์ "เดือนนี้" ของบิลใบเก่า ส่งกลับไปเป็นมิเตอร์ตั้งต้น
        return {
          'water': (response[0]['water_meter_cur'] as num).toDouble(),
          'electric': (response[0]['electric_meter_cur'] as num).toDouble(),
        };
      }
      // ถ้าเป็นบิลใบแรกของห้องนี้ (ยังไม่เคยมีประวัติ) ให้เริ่มที่ 0
      return {'water': 0.0, 'electric': 0.0};
    } catch (e) {
      return {'water': 0.0, 'electric': 0.0};
    }
  }

  // 5. ตรวจสอบว่าในเดือน/ปีนี้ ห้องนี้ได้ออกบิลไปแล้วหรือยัง
  Future<bool> isBillAlreadyCreated(String roomId, int month, int year) async {
    try {
      final response = await _supabase
          .from('bills_tb')
          .select('id')
          .eq('room_id', roomId)
          .eq('month', month)
          .eq('year', year)
          .maybeSingle(); // ถ้าเจอมากกว่า 1 หรือไม่เจอเลยจะไม่ error แต่คืนค่า null

      return response != null; // ถ้าไม่เป็น null แปลว่ามีบิลอยู่แล้ว
    } catch (e) {
      return false;
    }
  }
}
