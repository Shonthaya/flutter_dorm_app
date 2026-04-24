import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tenant_model.dart';
import '../models/room_model.dart';

class TenantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. ดึงข้อมูลผู้เช่าทั้งหมด พร้อมเอาเลขห้องจาก rooms_tb มาด้วย
  Future<List<TenantModel>> getTenants() async {
    try {
      final response = await _supabase
          .from('tenants_tb')
          .select('*, rooms_tb(room_number)') // Join ดึงเลขห้องมาโชว์
          .order('created_at', ascending: false);

      return (response as List).map((t) => TenantModel.fromJson(t)).toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลผู้เช่า: $e');
    }
  }

  // 2. ดึงเฉพาะ "ห้องว่าง" เพื่อเอาไปโชว์ใน Dropdown ตอนเพิ่มผู้เช่า
  Future<List<RoomModel>> getAvailableRooms() async {
    try {
      final response = await _supabase
          .from('rooms_tb')
          .select()
          .eq('status', 'available')
          .order('room_number', ascending: true);

      return (response as List)
          .map((room) => RoomModel.fromJson(room))
          .toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลห้องว่าง: $e');
    }
  }

  // 3. เพิ่มผู้เช่าใหม่ + อัปเดตสถานะห้องเป็น "มีผู้เช่า"
  Future<void> addTenant(TenantModel tenant) async {
    try {
      // 3.1 บันทึกข้อมูลผู้เช่า
      await _supabase.from('tenants_tb').insert(tenant.toJson());

      // 3.2 เปลี่ยนสถานะห้องนั้นให้เป็น occupied
      await _supabase
          .from('rooms_tb')
          .update({'status': 'occupied'}).eq('id', tenant.roomId);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e');
    }
  }

  // 4. แจ้งย้ายออก (Check-out)
  Future<void> checkOutTenant(String tenantId, String roomId) async {
    try {
      // หาวันที่ปัจจุบัน (YYYY-MM-DD) เพื่อบันทึกเป็นวันย้ายออก
      final moveOutDate = DateTime.now().toIso8601String().split('T')[0];

      // Step 1: ปิดสถานะผู้เช่าคนนี้ และใส่วันที่ย้ายออก
      await _supabase.from('tenants_tb').update({
        'status': 'inactive',
        'move_out_date': moveOutDate,
      }).eq('id', tenantId);

      // Step 2: เปลี่ยนสถานะห้องนั้นให้กลับมา 'ว่าง' อีกครั้ง
      await _supabase
          .from('rooms_tb')
          .update({'status': 'available'}).eq('id', roomId);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการแจ้งย้ายออก: $e');
    }
  }
}
