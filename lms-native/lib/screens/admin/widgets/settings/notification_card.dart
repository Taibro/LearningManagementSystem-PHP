import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_helpers.dart';
import 'bottom_sheets/broadcast_sheet.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({super.key});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _notifNewRequest = true;
  bool _notifAttendance = true;
  bool _notifGrade = false;
  static const _kPrimary = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifNewRequest = prefs.getBool('notifNewRequest') ?? true;
      _notifAttendance = prefs.getBool('notifAttendance') ?? true;
      _notifGrade = prefs.getBool('notifGrade') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return buildSettingsCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildSectionTitle('Cài đặt thông báo', Icons.notifications_outlined),
        const SizedBox(height: 14),
        buildToggleRow(
            'Đề xuất lịch dạy mới',
            'Nhận TB khi GV gửi đề xuất',
            Icons.pending_actions_outlined,
            const Color(0xFFE65100),
            _notifNewRequest,
            (v) {
              setState(() => _notifNewRequest = v);
              _saveSetting('notifNewRequest', v);
            }),
        buildDivider(),
        buildToggleRow(
            'Cảnh báo điểm danh',
            'SV vắng quá 20%',
            Icons.warning_amber_outlined,
            const Color(0xFFE85D75),
            _notifAttendance,
            (v) {
              setState(() => _notifAttendance = v);
              _saveSetting('notifAttendance', v);
            }),
        buildDivider(),
        buildToggleRow(
            'Bảng điểm chưa nộp',
            'GV chưa nộp điểm đúng hạn',
            Icons.grade_outlined,
            const Color(0xFF4CAF50),
            _notifGrade,
            (v) {
              setState(() => _notifGrade = v);
              _saveSetting('notifGrade', v);
            }),
        buildDivider(),
        buildMenuRow(
            'Gửi thông báo hàng loạt',
            'Gửi cho sinh viên / giảng viên',
            Icons.campaign_outlined,
            _kPrimary,
            () => _showBroadcastSheet()),
      ]),
    );
  }

  void _showBroadcastSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BroadcastSheet(),
    );
  }
}
