class BillModel {
  final String id;
  final String roomId;
  final String tenantId;
  final int month;
  final int year;
  final double roomPrice;
  final double waterMeterPrev;
  final double waterMeterCur;
  final double waterUnit;
  final double waterCost;
  final double electricMeterPrev;
  final double electricMeterCur;
  final double electricUnit;
  final double electricCost;
  final double totalAmount;
  final String status;
  final String? slipUrl;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final String? remark;
  final String? paymentMethod;

  // 💡 ตัวแปรพิเศษสำหรับดึงมาโชว์บนหน้าจอ
  final String? roomNumber;
  final String? tenantName;

  BillModel({
    required this.id,
    required this.roomId,
    required this.tenantId,
    required this.month,
    required this.year,
    required this.roomPrice,
    required this.waterMeterPrev,
    required this.waterMeterCur,
    required this.waterUnit,
    required this.waterCost,
    required this.electricMeterPrev,
    required this.electricMeterCur,
    required this.electricUnit,
    required this.electricCost,
    required this.totalAmount,
    required this.status,
    this.slipUrl,
    this.paidAt,
    this.createdAt,
    this.remark,
    this.paymentMethod,
    this.roomNumber,
    this.tenantName,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      roomId: json['room_id'],
      tenantId: json['tenant_id'],
      month: json['month'],
      year: json['year'],
      roomPrice: (json['room_price'] as num).toDouble(),
      waterMeterPrev: (json['water_meter_prev'] as num).toDouble(),
      waterMeterCur: (json['water_meter_cur'] as num).toDouble(),
      waterUnit: (json['water_unit'] as num).toDouble(),
      waterCost: (json['water_cost'] as num).toDouble(),
      electricMeterPrev: (json['electric_meter_prev'] as num).toDouble(),
      electricMeterCur: (json['electric_meter_cur'] as num).toDouble(),
      electricUnit: (json['electric_unit'] as num).toDouble(),
      electricCost: (json['electric_cost'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      slipUrl: json['slip_url'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      remark: json['remark'],
      paymentMethod: json['payment_method'],
      // 💡 ดึงข้อมูลจากการ Join ตาราง
      roomNumber:
          json['rooms_tb'] != null ? json['rooms_tb']['room_number'] : null,
      tenantName:
          json['tenants_tb'] != null ? json['tenants_tb']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'tenant_id': tenantId,
      'month': month,
      'year': year,
      'room_price': roomPrice,
      'water_meter_prev': waterMeterPrev,
      'water_meter_cur': waterMeterCur,
      'water_unit': waterUnit,
      'water_cost': waterCost,
      'electric_meter_prev': electricMeterPrev,
      'electric_meter_cur': electricMeterCur,
      'electric_unit': electricUnit,
      'electric_cost': electricCost,
      'total_amount': totalAmount,
      'status': status,
      'slip_url': slipUrl,
      'paid_at': paidAt?.toIso8601String(),
      'remark': remark,
      'payment_method': paymentMethod,
    };
  }
}
