import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/settings/admin_semester_bloc.dart';
import '../../blocs/admin/settings/admin_semester_event.dart';
import 'backup_screen.dart';
import 'manage_semester_screen.dart';
import 'widgets/settings/admin_profile_card.dart';
import 'widgets/settings/semester_card.dart';
import 'widgets/settings/system_card.dart';
import 'widgets/settings/notification_card.dart';
import 'widgets/settings/announcement_card.dart';
import 'widgets/settings/account_card.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  static const _kPrimary = Color(0xFF3F51B5);

  @override
  void initState() {
    super.initState();
    context.read<AdminSemesterBloc>().add(const AdminSemesterFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        _buildHeader(),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(children: [
            const AdminProfileCard(),
            const SizedBox(height: 14),
            const SemesterCard(),
            const SizedBox(height: 14),
            SystemCard(onAction: (msg) {
              if (msg == 'Đang sao lưu...') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
              } else if (msg == 'Mở quản lý học kỳ') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageSemesterScreen()));
              } else {
                _snack(msg);
              }
            }),
            const SizedBox(height: 14),
            const NotificationCard(),
            const SizedBox(height: 14),
            const AnnouncementCard(),
            const SizedBox(height: 14),
            AccountCard(onAction: (msg) => _snack(msg)),
            const SizedBox(height: 24),
            const Text('HUIT E-Office Admin · v2.1.0',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 24),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPrimary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_rounded, color: _kPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cài đặt hệ thống',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5)),
                Text('Quản lý thông tin & Hệ thống',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: _kPrimary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2)),
      );
}
