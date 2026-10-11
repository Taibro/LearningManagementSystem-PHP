import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../student_info_screen.dart';
import '../../profile_screens/change_password_screen.dart';
import '../../profile_screens/terms_screen.dart';
import '../../profile_screens/help_screen.dart';
import '../../../auth/role_selection_screen.dart';
import '../../../auth/school_code_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/auth/auth_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileMenuCard extends StatefulWidget {
  const ProfileMenuCard({super.key});

  @override
  State<ProfileMenuCard> createState() => _ProfileMenuCardState();
}

class _ProfileMenuCardState extends State<ProfileMenuCard> {
  bool _notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_rounded,
            iconBgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF3B82F6),
            label: 'Thông tin sinh viên',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentInfoScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.lock_rounded,
            iconBgColor: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF22C55E),
            label: 'Đổi mật khẩu',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.description_rounded,
            iconBgColor: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF8B5CF6),
            label: 'Điều khoản và chính sách',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.support_agent_rounded,
            iconBgColor: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFF97316),
            label: 'Trợ giúp & Góp ý',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            ),
          ),
          _buildDivider(),
          // Thông báo với Toggle
          _buildToggleItem(),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconBgColor: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFEF4444),
            label: 'Đăng xuất',
            onTap: _showLogoutDialog,
            showArrow: false,
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFCBD5E1),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Thông báo',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: _notificationEnabled,
            onChanged: _toggleNotification,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4F46E5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 78,
      endIndent: 20,
      color: Color(0xFFF1F5F9),
    );
  }

  // ── Logout Dialog with radio options ─────────────────────────────
  void _showLogoutDialog() {
    int selectedOption = 0; // 0 = Đăng nhập lại, 1 = Nhập mã trường

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 16),
                // Option 1: Đăng nhập lại
                GestureDetector(
                  onTap: () => setDialogState(() => selectedOption = 0),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        selectedOption == 0
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selectedOption == 0
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFBDBDBD),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Đăng nhập lại',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Option 2: Nhập mã trường
                GestureDetector(
                  onTap: () => setDialogState(() => selectedOption = 1),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        selectedOption == 1
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selectedOption == 1
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFBDBDBD),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Nhập mã trường',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              Row(
                children: [
                  // Huỷ
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF616161),
                        side: const BorderSide(color: Color(0xFFBDBDBD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Xác nhận
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        if (selectedOption == 0) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const RoleSelectionScreen(schoolName: 'EduSpace')),
                            (route) => false,
                          );
                        } else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const SchoolCodeScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
