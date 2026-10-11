import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/school_code_screen.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/auth/auth_event.dart';
import '../../lecturer_change_password_screen.dart';
import '../../features/terms_screen.dart';
import '../../features/feedback_screen.dart';

class SettingsCard extends StatefulWidget {
  const SettingsCard({super.key});

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  bool _notificationEnabled = true;

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SchoolCodeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.lock_outline_rounded,
              iconBgColor: const Color(0xFF10B981).withOpacity(0.08),
              iconColor: const Color(0xFF10B981),
              label: 'Đổi mật khẩu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LecturerChangePasswordScreen(),
                  ),
                );
              },
              index: 0,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.description_outlined,
              iconBgColor: const Color(0xFF6B4FA0).withOpacity(0.08),
              iconColor: const Color(0xFF6B4FA0),
              label: 'Điều khoản & chính sách',
              onTap: () => _navigateTo(context, const TermsScreen()),
              index: 1,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.chat_bubble_outline_rounded,
              iconBgColor: const Color(0xFFF59E0B).withOpacity(0.08),
              iconColor: const Color(0xFFF59E0B),
              label: 'Góp ý ứng dụng',
              onTap: () => _navigateTo(context, const FeedbackScreen()),
              index: 2,
            ),
            _buildDivider(),
            // Notification toggle
            _buildToggleItem(index: 3),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.logout_rounded,
              iconBgColor: const Color(0xFFEF4444).withOpacity(0.08),
              iconColor: const Color(0xFFEF4444),
              label: 'Đăng xuất',
              onTap: () => _showLogoutDialog(context),
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    required int index,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: iconColor.withOpacity(0.05),
        splashColor: iconColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.1), width: 1),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 24),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildToggleItem({required int index}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Color(0xFF64748B), size: 22),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Switch(
            value: _notificationEnabled,
            onChanged: (val) => setState(() => _notificationEnabled = val),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF6B4FA0),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD5E1),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildDivider() => const Divider(
        height: 1,
        thickness: 1,
        indent: 80,
        endIndent: 20,
        color: Color(0xFFF1F5F9),
      );
}
