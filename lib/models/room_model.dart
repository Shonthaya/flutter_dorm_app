class RoomModel {
  final String id;
  final String roomNumber;
  final double price;
  final double waterRate;
  final double electricRate;
  final String status; // 'available', 'occupied', 'maintenance'
  final DateTime? createdAt;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.price,
    required this.waterRate,
    required this.electricRate,
    required this.status,
    this.createdAt,
  });

  // แปลงข้อมูลจาก Supabase มาใช้ในแอป
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      roomNumber: json['room_number'],
      price: (json['price'] as num).toDouble(),
      waterRate: (json['water_rate'] as num).toDouble(),
      electricRate: (json['electric_rate'] as num).toDouble(),
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // แปลงข้อมูลจากแอปส่งกลับไปบันทึกใน Supabase
  Map<String, dynamic> toJson() {
    return {
      'room_number': roomNumber,
      'price': price,
      'water_rate': waterRate,
      'electric_rate': electricRate,
      'status': status,
      // ไม่ต้องส่ง id และ created_at ไปตอนสร้างใหม่ เพราะ Supabase จะจัดการให้
    };
  }
}
