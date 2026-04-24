// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomView extends StatefulWidget {
  const RoomView({super.key});

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  final RoomService _roomService = RoomService();
  bool _isLoading = true;
  List<RoomModel> _rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  // ฟังก์ชันแสดงหน้าต่างเพิ่มห้องพัก
  void _showAddRoomDialog() {
    final TextEditingController roomNumberController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController waterRateController = TextEditingController();
    final TextEditingController electricRateController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // เพื่อให้หน้าต่างขยายตามคีย์บอร์ด
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // ดันขึ้นเมื่อคีย์บอร์ดมา
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
              const Text(
                'เพิ่มห้องพักใหม่',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3338)),
              ),
              const SizedBox(height: 24),

              _buildInputLabel('หมายเลขห้อง'),
              _buildSimpleTextField(
                  roomNumberController, 'เช่น 101', Icons.numbers),

              const SizedBox(height: 16),
              _buildInputLabel('ราคาเช่าต่อเดือน'),
              _buildSimpleTextField(
                  priceController, '0.00', Icons.payments_outlined,
                  isNumber: true),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('เรทค่าน้ำ (หน่วยละ)'),
                        _buildSimpleTextField(
                            waterRateController, '0', Icons.water_drop_outlined,
                            isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('เรทค่าไฟ (หน่วยละ)'),
                        _buildSimpleTextField(electricRateController, '0',
                            Icons.flash_on_outlined,
                            isNumber: true),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              // ปุ่มยืนยันการเพิ่มห้อง
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (roomNumberController.text.isEmpty ||
                        priceController.text.isEmpty) return;

                    final newRoom = RoomModel(
                      id: '', // Supabase จะสร้างให้เอง
                      roomNumber: roomNumberController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      waterRate: double.tryParse(waterRateController.text) ?? 0,
                      electricRate:
                          double.tryParse(electricRateController.text) ?? 0,
                      status: 'available',
                    );

                    try {
                      await _roomService.addRoom(newRoom);
                      if (mounted) {
                        Navigator.pop(context); // ปิดหน้าต่าง
                        _fetchRooms(); // รีเฟรชรายการห้องใหม่
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: const Text('บันทึกข้อมูลห้อง'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้างป้ายชื่อช่องกรอก
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

  // Widget ช่วยสร้างช่องกรอกข้อมูลแบบคลีนๆ
  Widget _buildSimpleTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF6F8FA), // พื้นหลังเทาอ่อนมากๆ
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _roomService.getRooms();
      if (mounted) setState(() => _rooms = rooms);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการห้องพัก'),
        // ปุ่มรีเฟรชข้อมูลบน App Bar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchRooms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF28C38)))
          : _rooms.isEmpty
              ? _buildEmptyState()
              : _buildRoomList(),

      // ปุ่มลอย (FAB) สำหรับเพิ่มห้องใหม่ มุมขวาล่าง
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddRoomDialog();
        },
        backgroundColor: const Color(0xFFF28C38),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มห้อง',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // กรณีที่ยังไม่มีห้องในระบบ
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('ยังไม่มีข้อมูลห้องพัก',
              style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('กดปุ่ม "เพิ่มห้อง" ด้านล่างเพื่อเริ่มต้น',
              style: TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }

  // วาดรายการห้องพักเป็น List
  Widget _buildRoomList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        final isAvailable = room.status == 'available';

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
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ห้อง ${room.roomNumber}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3338))),
                  const SizedBox(height: 4),
                  Text('฿${room.price.toStringAsFixed(0)} / เดือน',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
              // ป้ายสถานะ (Badge)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isAvailable ? 'ว่าง' : 'มีผู้เช่า',
                  style: TextStyle(
                    color: isAvailable
                        ? Colors.green.shade700
                        : Colors.redAccent.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
