class TenantModel {
  final String? id;
  final String name;
  final String? phone;
  final String? roomId;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String status;
  final DateTime? createdAt;

  TenantModel({
    this.id,
    required this.name,
    this.phone,
    this.roomId,
    required this.moveInDate,
    this.moveOutDate,
    required this.status,
    this.createdAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      roomId: json['room_id'],
      moveInDate: json['move_in_date'] != null
          ? DateTime.parse(json['move_in_date'])
          : DateTime.now(),
      moveOutDate: json['move_out_date'] != null
          ? DateTime.parse(json['move_out_date'])
          : null,
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'room_id': roomId,
      'move_in_date':
          moveInDate.toIso8601String().split('T')[0], // เก็บเฉพาะวันที่
      if (moveOutDate != null)
        'move_out_date': moveOutDate!.toIso8601String().split('T')[0],
      'status': status,
    };
  }
}
