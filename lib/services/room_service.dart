import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. ดึงข้อมูลห้องทั้งหมด เรียงตามเลขห้อง
  Future<List<RoomModel>> getRooms() async {
    try {
      final response = await _supabase
          .from('rooms_tb')
          .select()
          .order('room_number', ascending: true);

      return (response as List)
          .map((room) => RoomModel.fromJson(room))
          .toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลห้องพัก: $e');
    }
  }

  // 2. เพิ่มห้องใหม่ (เดี๋ยวเราจะใช้ในหน้าเพิ่มข้อมูล)
  Future<void> addRoom(RoomModel room) async {
    try {
      await _supabase.from('rooms_tb').insert(room.toJson());
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการเพิ่มห้องพัก: $e');
    }
  }
}
