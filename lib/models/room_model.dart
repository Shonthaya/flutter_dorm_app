class RoomModel {
  final String? id; // ใช้ String เพื่อรองรับ UUID
  final String roomNumber;
  final double price;
  final double waterRate;
  final double electricRate;
  final String status;
  final DateTime? createdAt;

  RoomModel({
    this.id,
    required this.roomNumber,
    required this.price,
    required this.waterRate,
    required this.electricRate,
    required this.status,
    this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      roomNumber: json['room_number'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      waterRate: (json['water_rate'] ?? 0).toDouble(),
      electricRate: (json['electric_rate'] ?? 0).toDouble(),
      status: json['status'] ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'room_number': roomNumber,
      'price': price,
      'water_rate': waterRate,
      'electric_rate': electricRate,
      'status': status,
    };
  }
}
