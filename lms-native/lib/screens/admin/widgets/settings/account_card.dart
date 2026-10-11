import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_helpers.dart';
import 'bottom_sheets/change_password_sheet.dart';
import 'bottom_sheets/activity_log_sheet.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/auth/auth_event.dart';
import '../../../auth/school_code_screen.dart';

class AccountCard extends StatelessWidget {
  final Function(String) onAction;
  const AccountCard({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return buildSettingsCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildSectionTitle('Tài khoản', Icons.manage_accounts_outlined),
        const SizedBox(height: 14),
        buildMenuRow(
            'Đổi mật khẩu quản trị',
            '',
            Icons.lock_outline_rounded,
            const Color(0xFF2E7D32),
            () => _showChangePassword(context)),
        buildDivider(),
        buildMenuRow(
            'Phân quyền quản trị',
            '2 tài khoản admin',
            Icons.admin_panel_settings_outlined,
            const Color(0xFF5C6BC0),
            () => onAction('Quản lý phân quyền')),
        buildDivider(),
        buildMenuRow(
            'Nhật ký hoạt động',
            'Xem log hệ thống',
            Icons.history_rounded,
            const Color(0xFF9E9E9E),
            () => _showActivityLog(context)),
        buildDivider(),
        buildMenuRow(
            'Đăng xuất',
            '',
            Icons.logout_rounded,
            const Color(0xFFC62828),
            () => _showLogoutDialog(context)),
      ]),
    );
  }

  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  void _showActivityLog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ActivityLogSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: const Text(
                  'Bạn có chắc muốn đăng xuất khỏi trang quản trị?',
                  style: TextStyle(fontSize: 14, color: Color(0xFF616161))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Huỷ',
                        style: TextStyle(color: Color(0xFF616161)))),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SchoolCodeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ));
  }
}
