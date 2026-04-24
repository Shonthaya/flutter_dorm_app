import 'package:flutter/material.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';

class BillDetailView extends StatelessWidget {
  final BillModel bill;
  const BillDetailView({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ห้อง ${bill.roomNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. การ์ดสรุปยอดที่ต้องจ่าย
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03), blurRadius: 20)
                ],
              ),
              child: Column(
                children: [
                  const Text('ยอดที่ต้องชำระ',
                      style: TextStyle(color: Colors.black54, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('฿${bill.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF28C38))),
                  const Divider(height: 40),
                  _buildDetailRow('ค่าห้อง', bill.roomPrice),
                  _buildDetailRow(
                      'ค่าน้ำ (${bill.waterUnit} หน่วย)', bill.waterCost),
                  _buildDetailRow(
                      'ค่าไฟ (${bill.electricUnit} หน่วย)', bill.electricCost),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. ถ้า "ยังไม่จ่าย" โชว์ QR Code
            if (bill.status == 'unpaid') ...[
              const Text('สแกนเพื่อชำระเงิน',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: QRCodeGenerate(
                  promptPayId: "0983543900", //
                  amount: bill.totalAmount,
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              const Text('ชื่อบัญชี: สนธยา สายวรรณะ',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 40),

              // ปุ่มยืนยันการรับเงิน
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    // โชว์โหลดหมุนๆ รอแปบนึง
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFF28C38))),
                    );

                    try {
                      final billService = BillService();
                      await billService.updateBillStatusToPaid(
                          bill.id); // ยิงคำสั่งไป Supabase

                      if (context.mounted) {
                        Navigator.pop(context); // ปิดหน้าโหลด
                        Navigator.pop(context,
                            true); // ปิดหน้านี้แล้วเด้งกลับไปหน้าหลัก (เพื่อรีเฟรชข้อมูล)
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('ยืนยันรับชำระเงินสำเร็จ!')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // ปิดหน้าโหลด
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: const Text('ยืนยันได้รับเงินแล้ว'),
                ),
              ),
            ]
            // 3. ถ้า "จ่ายแล้ว" โชว์ UI ติ๊กถูกสวยๆ
            else ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 64),
              ),
              const SizedBox(height: 16),
              const Text('ชำระเงินเรียบร้อยแล้ว',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text('฿${amount.toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
