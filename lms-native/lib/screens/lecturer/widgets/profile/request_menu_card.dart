import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../lecturer_request_screen.dart';

class RequestMenuCard extends StatelessWidget {
  const RequestMenuCard({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Text(
                    'ĐỀ XUẤT LỊCH DẠY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B4FA0),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D75).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE85D75),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '1 chờ duyệt',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE85D75),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            _buildMenuItem(
              icon: Icons.pause_circle_outline_rounded,
              iconBgColor: const Color(0xFFF59E0B).withOpacity(0.08),
              iconColor: const Color(0xFFF59E0B),
              label: 'Đề xuất tạm ngừng lịch dạy',
              subtitle: '2 đề xuất gần đây',
              onTap: () => _navigateTo(context, const LecturerRequestScreen(initialTabIndex: 0)),
              badge: null,
              index: 0,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.add_circle_outline_rounded,
              iconBgColor: const Color(0xFF10B981).withOpacity(0.08),
              iconColor: const Color(0xFF10B981),
              label: 'Đề xuất dạy bù',
              subtitle: '1 chờ duyệt · 1 đã hoàn thành',
              onTap: () => _navigateTo(context, const LecturerRequestScreen(initialTabIndex: 1)),
              badge: '1',
              index: 1,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.swap_horiz_rounded,
              iconBgColor: const Color(0xFF3B82F6).withOpacity(0.08),
              iconColor: const Color(0xFF3B82F6),
              label: 'Đề xuất dạy thay',
              subtitle: 'Không có đề xuất mới',
              onTap: () => _navigateTo(context, const LecturerRequestScreen(initialTabIndex: 2)),
              index: 2,
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
    String? subtitle,
    required VoidCallback onTap,
    String? badge,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 24),
            ],
          ),
        ),
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
