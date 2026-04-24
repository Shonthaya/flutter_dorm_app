import 'package:flutter/material.dart';
import '../models/tenant_model.dart';
import '../models/room_model.dart';
import '../services/tenant_service.dart';

class TenantView extends StatefulWidget {
  const TenantView({super.key});

  @override
  State<TenantView> createState() => _TenantViewState();
}

class _TenantViewState extends State<TenantView> {
  final TenantService _tenantService = TenantService();
  bool _isLoading = true;
  List<TenantModel> _tenants = [];

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    setState(() => _isLoading = true);
    try {
      final tenants = await _tenantService.getTenants();
      if (mounted) setState(() => _tenants = tenants);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 💡 ฟังก์ชันใหม่: แสดงกล่องยืนยันการย้ายออก
  void _showCheckOutConfirmDialog(TenantModel tenant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Text('แจ้งย้ายออก', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'คุณต้องการแจ้งย้ายออกให้คุณ ${tenant.name}\n(ห้อง ${tenant.roomNumber}) ใช่หรือไม่?\n\nระบบจะบันทึกประวัติการย้ายออก และเปลี่ยนสถานะห้องให้กลับมา "ว่าง" พร้อมรับผู้เช่าใหม่ทันที',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.redAccent, // ปุ่มสีแดงให้รู้ว่าเป็น Action สำคัญ
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context); // ปิดกล่องยืนยัน
              setState(() => _isLoading = true); // โชว์โหลดหมุนๆ รอ
              try {
                // เรียกใช้ Service ที่เราเพิ่งสร้าง
                await _tenantService.checkOutTenant(tenant.id, tenant.roomId);
                _fetchTenants(); // โหลดข้อมูลใหม่
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('บันทึกการย้ายออกเรียบร้อยแล้ว')));
                }
              } catch (e) {
                setState(() => _isLoading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('ยืนยันย้ายออก',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddTenantDialog() async {
    List<RoomModel> availableRooms = [];
    try {
      availableRooms = await _tenantService.getAvailableRooms();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }

    if (availableRooms.isEmpty) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('ไม่มีห้องว่างในขณะนี้ กรุณาเพิ่มห้องก่อน')));
      return;
    }

    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String? selectedRoomId = availableRooms.first.id;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ลงทะเบียนผู้เช่าใหม่',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3338))),
                const SizedBox(height: 24),
                _buildInputLabel('เลือกห้องพัก (เฉพาะห้องว่าง)'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedRoomId,
                      items: availableRooms.map((room) {
                        return DropdownMenuItem(
                          value: room.id,
                          child: Text(
                              'ห้อง ${room.roomNumber} (฿${room.price.toStringAsFixed(0)})'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setModalState(() => selectedRoomId = value),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputLabel('ชื่อ-นามสกุล'),
                _buildSimpleTextField(
                    nameController, 'ชื่อผู้เช่า', Icons.person_outline),
                const SizedBox(height: 16),
                _buildInputLabel('เบอร์โทรศัพท์'),
                _buildSimpleTextField(
                    phoneController, '08X-XXX-XXXX', Icons.phone_outlined,
                    isNumber: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || selectedRoomId == null)
                        return;

                      final newTenant = TenantModel(
                        id: '',
                        name: nameController.text,
                        phone: phoneController.text,
                        roomId: selectedRoomId!,
                        moveInDate: DateTime.now(),
                        status: 'active',
                      );

                      try {
                        await _tenantService.addTenant(newTenant);
                        if (mounted) {
                          Navigator.pop(context);
                          _fetchTenants();
                        }
                      } catch (e) {
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: const Text('บันทึกข้อมูลผู้เช่า'),
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSimpleTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF6F8FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ผู้เช่าทั้งหมด'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _fetchTenants),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF28C38)))
          : _tenants.isEmpty
              ? _buildEmptyState()
              : _buildTenantList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTenantDialog,
        backgroundColor: const Color(0xFFF28C38),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('เพิ่มผู้เช่า',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('ยังไม่มีข้อมูลผู้เช่า',
              style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('กดปุ่ม "เพิ่มผู้เช่า" เพื่อลงทะเบียนคนแรก',
              style: TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildTenantList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _tenants.length,
      itemBuilder: (context, index) {
        final tenant = _tenants[index];
        final isActive = tenant.status == 'active';

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
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF28C38).withOpacity(0.1),
                    radius: 24,
                    child: const Icon(Icons.person_rounded,
                        color: Color(0xFFF28C38)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tenant.name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3338))),
                        const SizedBox(height: 4),
                        Text(
                            'ห้อง ${tenant.roomNumber ?? '-'} | โทร: ${tenant.phone ?? '-'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isActive ? 'กำลังพักอาศัย' : 'ย้ายออกแล้ว',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // 💡 เพิ่มปุ่ม "แจ้งย้ายออก" เข้ามาใต้ข้อมูล (โชว์เฉพาะคนที่ยังพักอยู่)
              if (isActive) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFFF6F8FA), thickness: 1.5),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showCheckOutConfirmDialog(tenant),
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 18),
                    label: const Text('แจ้งย้ายออก',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
