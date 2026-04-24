class BillModel {
  final String? id;
  final String? roomId;
  final String? tenantId;
  final int month;
  final int year;
  final double roomPrice;

  // น้ำ
  final double waterMeterPrev;
  final double waterMeterCurr;
  final double waterUnit;
  final double waterCost;

  // ไฟ
  final double electricMeterPrev;
  final double electricMeterCurr;
  final double electricUnit;
  final double electricCost;

  final double totalAmount;
  final String status;
  final String? slipUrl;
  final DateTime? paidAt;
  final DateTime? createdAt;

  BillModel({
    this.id,
    this.roomId,
    this.tenantId,
    required this.month,
    required this.year,
    required this.roomPrice,
    required this.waterMeterPrev,
    required this.waterMeterCurr,
    required this.waterUnit,
    required this.waterCost,
    required this.electricMeterPrev,
    required this.electricMeterCurr,
    required this.electricUnit,
    required this.electricCost,
    required this.totalAmount,
    required this.status,
    this.slipUrl,
    this.paidAt,
    this.createdAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      roomId: json['room_id'],
      tenantId: json['tenant_id'],
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      roomPrice: (json['room_price'] ?? 0).toDouble(),
      waterMeterPrev: (json['water_meter_prev'] ?? 0).toDouble(),
      waterMeterCurr: (json['water_meter_curr'] ?? 0).toDouble(),
      waterUnit: (json['water_unit'] ?? 0).toDouble(),
      waterCost: (json['water_cost'] ?? 0).toDouble(),
      electricMeterPrev: (json['electric_meter_prev'] ?? 0).toDouble(),
      electricMeterCurr: (json['electric_meter_curr'] ?? 0).toDouble(),
      electricUnit: (json['electric_unit'] ?? 0).toDouble(),
      electricCost: (json['electric_cost'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'unpaid',
      slipUrl: json['slip_url'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'room_id': roomId,
      'tenant_id': tenantId,
      'month': month,
      'year': year,
      'room_price': roomPrice,
      'water_meter_prev': waterMeterPrev,
      'water_meter_curr': waterMeterCurr,
      'water_unit': waterUnit,
      'water_cost': waterCost,
      'electric_meter_prev': electricMeterPrev,
      'electric_meter_curr': electricMeterCurr,
      'electric_unit': electricUnit,
      'electric_cost': electricCost,
      'total_amount': totalAmount,
      'status': status,
      'slip_url': slipUrl,
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
    };
  }
}
