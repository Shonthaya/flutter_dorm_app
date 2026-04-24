class TenantModel {
  final String id;
  final String name;
  final String? phone;
  final String roomId;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String status;
  final DateTime? createdAt;

  // ตัวแปรพิเศษที่ดึงมาจากการ Join ตาราง rooms_tb เพื่อเอาเลขห้องมาโชว์บนแอป
  final String? roomNumber;

  TenantModel({
    required this.id,
    required this.name,
    this.phone,
    required this.roomId,
    required this.moveInDate,
    this.moveOutDate,
    required this.status,
    this.createdAt,
    this.roomNumber,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      roomId: json['room_id'],
      moveInDate: DateTime.parse(json['move_in_date']),
      moveOutDate: json['move_out_date'] != null
          ? DateTime.parse(json['move_out_date'])
          : null,
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      // ดึงเลขห้องมาจากข้อมูลก้อน rooms_tb ที่ Supabase ส่งพ่วงมาให้
      roomNumber:
          json['rooms_tb'] != null ? json['rooms_tb']['room_number'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'room_id': roomId,
      'move_in_date':
          moveInDate.toIso8601String().split('T')[0], // แปลงเป็น YYYY-MM-DD
      'status': status,
      // move_out_date ปล่อยว่างไว้ก่อนตอนย้ายเข้าใหม่ๆ
    };
  }
}
