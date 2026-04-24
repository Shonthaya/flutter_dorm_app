import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // อย่าลืมแพ็กเกจนี้สำหรับจัด format วันที่
import '../models/bill_model.dart';
import '../services/bill_service.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final BillService _billService = BillService();
  bool _isLoading = true;
  List<BillModel> _paidBills = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final bills = await _billService.getPaidBillsHistory();
      if (mounted) setState(() => _paidBills = bills);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันช่วยแปลงวันที่ให้ดูอ่านง่าย (เช่น 25 เม.ย. 2026 เวลา 14:30 น.)
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    // แปลงให้เป็นเวลาไทยคร่าวๆ และจัด format
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติรายรับ'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _fetchHistory),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF28C38)))
          : _paidBills.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _paidBills.length,
                  itemBuilder: (context, index) {
                    final bill = _paidBills[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ห้อง ${bill.roomNumber}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3338))),
                                  const SizedBox(height: 4),
                                  Text(bill.tenantName ?? 'ไม่ระบุชื่อ',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54)),
                                ],
                              ),
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.green, size: 32),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(
                              color: Color(0xFFF6F8FA), thickness: 1.5),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ยอดรับชำระ',
                                  style: TextStyle(color: Colors.black54)),
                              Text('฿${bill.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('วันที่รับเงิน',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12)),
                              Text(_formatDateTime(bill.paidAt),
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('ยังไม่มีประวัติการรับชำระเงิน',
              style: TextStyle(fontSize: 18, color: Colors.black54)),
        ],
      ),
    );
  }
}
