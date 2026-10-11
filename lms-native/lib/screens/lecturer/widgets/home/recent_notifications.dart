import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/teacher_repository.dart';
import '../../../../models/admin/notification_response.dart';
import 'package:intl/intl.dart';

class RecentNotifications extends StatefulWidget {
  const RecentNotifications({super.key});

  @override
  State<RecentNotifications> createState() => _RecentNotificationsState();
}

class _RecentNotificationsState extends State<RecentNotifications> {
  List<NotificationResponse> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final repo = context.read<TeacherRepository>();
      final notifs = await repo.getMyNotifications();
      if (mounted) {
        setState(() {
          // Take top 3 most recent
          _notifications = notifs.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thông báo gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B4FA0),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4FA0).withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF6B4FA0))),
                  )
                : _notifications.isEmpty 
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Không có thông báo nào', style: TextStyle(color: Colors.grey))),
                      )
                    : Column(
              children: _notifications.asMap().entries.map((entry) {
                final i = entry.key;
                final n = entry.value;

                IconData iconData = Icons.notifications;
                Color color = const Color(0xFF6B4FA0);
                if (n.type == 'SYSTEM') {
                  iconData = Icons.info_outline_rounded;
                  color = const Color(0xFF0EA5E9);
                } else if (n.type == 'REQUEST_APPROVED') {
                  iconData = Icons.check_circle_outline_rounded;
                  color = const Color(0xFF22C55E);
                }

                String timeStr = '';
                if (n.createdAt != null) {
                  final dt = DateTime.parse(n.createdAt!).toLocal();
                  timeStr = DateFormat('dd/MM/yyyy HH:mm').format(dt);
                }
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        highlightColor: color.withOpacity(0.05),
                        splashColor: color.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: color.withOpacity(0.1), width: 1),
                                ),
                                child: Icon(iconData,
                                    color: color, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Color(0xFFCBD5E1), size: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (i < _notifications.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 76,
                        endIndent: 16,
                        color: Color(0xFFF1F5F9),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }
}
