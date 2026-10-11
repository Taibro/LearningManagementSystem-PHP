import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'settings_helpers.dart';
import 'bottom_sheets/room_config_sheet.dart';

class SystemCard extends StatefulWidget {
  final Function(String) onAction;
  const SystemCard({super.key, required this.onAction});

  @override
  State<SystemCard> createState() => _SystemCardState();
}

class _SystemCardState extends State<SystemCard> {
  bool _maintenanceMode = false;
  bool _allowQr = true;
  String _lastBackupDate = 'Chưa sao lưu';
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maintenanceMode = prefs.getBool('maintenance_mode') ?? false;
      _allowQr = prefs.getBool('allow_qr_attendance') ?? true;
      _lastBackupDate = prefs.getString('last_backup_date') ?? 'Chưa sao lưu';
    });
  }

  Future<void> _saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _triggerBackup() async {
    if (_isBackingUp) return;
    setState(() => _isBackingUp = true);
    
    // Simulate backup delay
    await Future.delayed(const Duration(seconds: 2));
    
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_backup_date', now);
    
    if (mounted) {
      setState(() {
        _lastBackupDate = now;
        _isBackingUp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sao lưu dữ liệu thành công'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildSettingsCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildSectionTitle('Cài đặt hệ thống', Icons.tune_rounded),
        const SizedBox(height: 14),
        buildToggleRow(
            'Chế độ bảo trì',
            'Tắt tạm thời truy cập người dùng',
            Icons.build_outlined,
            const Color(0xFFE85D75),
            _maintenanceMode,
            (v) {
              setState(() => _maintenanceMode = v);
              _saveToggle('maintenance_mode', v);
            }),
        buildDivider(),
        buildToggleRow(
            'Cho phép điểm danh QR',
            'Sinh viên quét mã điểm danh',
            Icons.qr_code_2_rounded,
            const Color(0xFF4CAF50),
            _allowQr,
            (v) {
              setState(() => _allowQr = v);
              _saveToggle('allow_qr_attendance', v);
            }),
        buildDivider(),
        buildMenuRow(
            'Sao lưu dữ liệu',
            _isBackingUp ? 'Đang sao lưu...' : 'Lần cuối: $_lastBackupDate',
            Icons.backup_outlined,
            const Color(0xFF2E7D32),
            _triggerBackup),
        buildDivider(),
        buildMenuRow(
            'Cấu hình phòng học',
            'Quản lý danh sách phòng',
            Icons.meeting_room_outlined,
            const Color(0xFFE65100),
            () => _showRoomConfig()),
      ]),
    );
  }

  void _showRoomConfig() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RoomConfigSheet(),
    );
  }
}
