import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';
import 'bill_detail_view.dart'; // 💡 เพิ่ม Import หน้ารายละเอียดบิลตรงนี้

class BillView extends StatefulWidget {
  const BillView({super.key});

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {
  final BillService _billService = BillService();
  bool _isLoading = true;
  List<BillModel> _bills = [];

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    setState(() => _isLoading = true);
    try {
      final bills = await _billService.getBills();
      if (mounted) setState(() => _bills = bills);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateBillDialog() async {
    List<Map<String, dynamic>> tenants = [];
    try {
      tenants = await _billService.getActiveTenantsForBilling();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    }

    if (tenants.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('ไม่มีผู้เช่าในระบบ')));
      }
      return;
    }

    Map<String, dynamic>? selectedTenant = tenants.first;

    // โหลดมิเตอร์ล่าสุดมารอไว้
    Map<String, double> lastMeters =
        await _billService.getLastMeterReading(selectedTenant!['room_id']);

    final waterPreCtrl =
        TextEditingController(text: lastMeters['water']!.toStringAsFixed(0));
    final elecPreCtrl =
        TextEditingController(text: lastMeters['electric']!.toStringAsFixed(0));
    final waterCurCtrl = TextEditingController();
    final elecCurCtrl = TextEditingController();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        void calculateTotal() {
          setModalState(() {});
        }

        double roomPrice =
            (selectedTenant!['rooms_tb']['price'] as num).toDouble();
        double wRate =
            (selectedTenant!['rooms_tb']['water_rate'] as num).toDouble();
        double eRate =
            (selectedTenant!['rooms_tb']['electric_rate'] as num).toDouble();

        double wPre = double.tryParse(waterPreCtrl.text) ?? 0;
        double wCur = double.tryParse(waterCurCtrl.text) ?? 0;
        double ePre = double.tryParse(elecPreCtrl.text) ?? 0;
        double eCur = double.tryParse(elecCurCtrl.text) ?? 0;

        double wUnit = (wCur > wPre) ? (wCur - wPre) : 0;
        double eUnit = (eCur > ePre) ? (eCur - ePre) : 0;
        double wCost = wUnit * wRate;
        double eCost = eUnit * eRate;
        double totalAmount = roomPrice + wCost + eCost;

        return Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ออกบิลค่าเช่าใหม่',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3338))),
                const SizedBox(height: 24),
                _buildInputLabel('เลือกผู้เช่า'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      isExpanded: true,
                      value: selectedTenant,
                      items: tenants.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(
                              'ห้อง ${t['rooms_tb']['room_number']} - ${t['name']}'),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          Map<String, double> newMeters = await _billService
                              .getLastMeterReading(value['room_id']);
                          setModalState(() {
                            selectedTenant = value;
                            waterPreCtrl.text =
                                newMeters['water']!.toStringAsFixed(0);
                            elecPreCtrl.text =
                                newMeters['electric']!.toStringAsFixed(0);
                            waterCurCtrl.clear();
                            elecCurCtrl.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputLabel('มิเตอร์น้ำ (หน่วยละ ฿$wRate)'),
                Row(
                  children: [
                    Expanded(
                        child: _buildReadOnlyField(waterPreCtrl, 'เดือนก่อน')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildCalculateField(
                            waterCurCtrl, 'จดเลขใหม่', calculateTotal)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputLabel('มิเตอร์ไฟ (หน่วยละ ฿$eRate)'),
                Row(
                  children: [
                    Expanded(
                        child: _buildReadOnlyField(elecPreCtrl, 'เดือนก่อน')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildCalculateField(
                            elecCurCtrl, 'จดเลขใหม่', calculateTotal)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF28C38).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      _buildSummaryRow('ค่าห้อง', roomPrice),
                      _buildSummaryRow('ค่าน้ำ ($wUnit หน่วย)', wCost),
                      _buildSummaryRow('ค่าไฟ ($eUnit หน่วย)', eCost),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ยอดรวมทั้งสิ้น',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('฿${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF28C38))),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (waterCurCtrl.text.isEmpty ||
                          elecCurCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'กรุณากรอกเลขมิเตอร์เดือนนี้ให้ครบถ้วน')));
                        return;
                      }

                      final int currentMonth = DateTime.now().month;
                      final int currentYear = DateTime.now().year;

                      bool isDuplicate =
                          await _billService.isBillAlreadyCreated(
                              selectedTenant!['room_id'],
                              currentMonth,
                              currentYear);

                      if (isDuplicate) {
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.redAccent, size: 28),
                                    SizedBox(width: 8),
                                    Text('แจ้งเตือนบิลซ้ำ',
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                content: Text(
                                  'ห้อง ${selectedTenant!['rooms_tb']['room_number']} ได้ออกบิลเดือน $currentMonth/$currentYear ไปแล้ว!\n\nกรุณาตรวจสอบอีกครั้ง',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('เข้าใจแล้ว',
                                        style: TextStyle(
                                            color: Color(0xFFF28C38),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return;
                      }

                      final newBill = BillModel(
                        id: '',
                        roomId: selectedTenant!['room_id'],
                        tenantId: selectedTenant!['id'],
                        month: currentMonth,
                        year: currentYear,
                        roomPrice: roomPrice,
                        waterMeterPrev: wPre,
                        waterMeterCur: wCur,
                        waterUnit: wUnit,
                        waterCost: wCost,
                        electricMeterPrev: ePre,
                        electricMeterCur: eCur,
                        electricUnit: eUnit,
                        electricCost: eCost,
                        totalAmount: totalAmount,
                        status: 'unpaid',
                      );

                      try {
                        await _billService.createBill(newBill);
                        if (mounted) {
                          Navigator.pop(context);
                          _fetchBills();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('บันทึกบิลสำเร็จ')));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                    child: const Text('บันทึกบิล'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalculateField(
      TextEditingController controller, String hint, VoidCallback onChanged) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (val) => onChanged(),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF6F8FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: Colors.black54),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black87)),
          Text('฿${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการบิลค่าเช่า'), actions: [
        IconButton(
            icon: const Icon(Icons.refresh_rounded), onPressed: _fetchBills)
      ]),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF28C38)))
          : _bills.isEmpty
              ? const Center(
                  child: Text('ยังไม่มีบิลในระบบ',
                      style: TextStyle(fontSize: 18, color: Colors.black54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    final bill = _bills[index];
                    final isPaid = bill.status == 'paid';

                    // 💡 เปลี่ยนจาก Container ธรรมดามาใช้ InkWell เพื่อให้กดได้
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillDetailView(bill: bill),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
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
                                Text(
                                    'ห้อง ${bill.roomNumber} (${bill.tenantName})',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3338))),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: isPaid
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.redAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Text(isPaid ? 'ชำระแล้ว' : 'ค้างชำระ',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: isPaid
                                              ? Colors.green.shade700
                                              : Colors.redAccent.shade700,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                                color: Color(0xFFF6F8FA), thickness: 1.5),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('บิลประจำเดือน ${bill.month}/${bill.year}',
                                    style:
                                        const TextStyle(color: Colors.black54)),
                                Text('฿${bill.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF28C38))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBillDialog,
        backgroundColor: const Color(0xFFF28C38),
        icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
        label: const Text('ออกบิลใหม่',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
