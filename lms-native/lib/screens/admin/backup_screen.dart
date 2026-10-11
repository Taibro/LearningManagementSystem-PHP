import 'package:flutter/material.dart';
import '../../core/widgets/custom_loading_indicator.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  bool _autoBackup = true;
  String _backupFrequency = 'Hàng ngày';
  bool _isBackingUp = false;

  final _backupHistory = [
    {'date': '14/05/2026 22:00', 'size': '1.2 GB', 'status': 'success', 'type': 'Tự động'},
    {'date': '13/05/2026 22:00', 'size': '1.2 GB', 'status': 'success', 'type': 'Tự động'},
    {'date': '12/05/2026 15:30', 'size': '1.1 GB', 'status': 'success', 'type': 'Thủ công'},
    {'date': '11/05/2026 22:00', 'size': '1.1 GB', 'status': 'failed', 'type': 'Tự động'},
    {'date': '10/05/2026 22:00', 'size': '1.1 GB', 'status': 'success', 'type': 'Tự động'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildSettingsCard(),
              const SizedBox(height: 16),
              _buildHistoryCard(),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B6E), _kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16, right: 16, bottom: 16,
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.backup_outlined, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        const Text('Sao lưu dữ liệu',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D1B6E), _kPrimary]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_done_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sao lưu gần nhất', style: TextStyle(color: Colors.white60, fontSize: 12)),
              SizedBox(height: 4),
              Text('14/05/2026 22:00', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('Kích thước: 1.2 GB · Thành công', style: TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _startBackup,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (_isBackingUp)
                SizedBox(width: 18, height: 18, child: CustomLoadingIndicator())
              else
                const Icon(Icons.backup_rounded, color: _kPrimary, size: 20),
              const SizedBox(width: 8),
              Text(_isBackingUp ? 'Đang sao lưu...' : 'Sao lưu ngay',
                  style: const TextStyle(color: _kPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.settings_outlined, color: _kPrimary, size: 18),
          const SizedBox(width: 8),
          const Text('Cài đặt sao lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        ]),
        const SizedBox(height: 14),
        _toggleRow('Sao lưu tự động', 'Tự động sao lưu theo lịch', Icons.schedule_outlined, const Color(0xFF4CAF50), _autoBackup, (v) => setState(() => _autoBackup = v)),
        const Divider(height: 1, indent: 52, color: Color(0xFFF0F0F0)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: const Color(0xFF5C6BC0).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.repeat_rounded, color: Color(0xFF5C6BC0), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tần suất', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))),
              Text(_backupFrequency, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0D8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _backupFrequency,
                  items: ['Hàng ngày', 'Hàng tuần', 'Hàng tháng'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => _backupFrequency = v!),
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1, indent: 52, color: Color(0xFFF0F0F0)),
        _menuRow('Khôi phục dữ liệu', 'Phục hồi từ bản sao lưu', Icons.restore_rounded, const Color(0xFFE65100), () => _snack('Mở trang khôi phục')),
      ]),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.history_rounded, color: _kPrimary, size: 18),
          const SizedBox(width: 8),
          const Text('Lịch sử sao lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        ]),
        const SizedBox(height: 14),
        ..._backupHistory.map((b) {
          final success = b['status'] == 'success';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (success ? const Color(0xFF4CAF50) : const Color(0xFFC62828)).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: (success ? const Color(0xFF4CAF50) : const Color(0xFFC62828)).withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(success ? Icons.check_circle_outline : Icons.error_outline,
                  color: success ? const Color(0xFF4CAF50) : const Color(0xFFC62828), size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b['date']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${b['size']} · ${b['type']} · ${success ? 'Thành công' : 'Thất bại'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ])),
              if (success)
                GestureDetector(
                  onTap: () => _snack('Tải xuống bản sao lưu ${b['date']}'),
                  child: const Icon(Icons.download_outlined, color: Color(0xFF9E9E9E), size: 20),
                ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _toggleRow(String label, String subtitle, IconData icon, Color col, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: col, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        Switch(
          value: value, onChanged: onChanged,
          activeColor: Colors.white, activeTrackColor: _kPrimary,
          inactiveThumbColor: Colors.white, inactiveTrackColor: const Color(0xFFBDBDBD),
        ),
      ]),
    );
  }

  Widget _menuRow(String label, String subtitle, IconData icon, Color col, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: col, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ])),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
        ]),
      ),
    );
  }

  void _startBackup() {
    if (_isBackingUp) return;
    setState(() => _isBackingUp = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isBackingUp = false);
        _snack('Sao lưu hoàn tất!');
      }
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: _kPrimary, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );
}
