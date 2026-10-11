import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/dio_client.dart';
import '../../core/widgets/custom_loading_indicator.dart';

class SharedNotificationsScreen extends StatefulWidget {
  const SharedNotificationsScreen({super.key});

  @override
  State<SharedNotificationsScreen> createState() => _SharedNotificationsScreenState();
}

class _SharedNotificationsScreenState extends State<SharedNotificationsScreen> {
  static const _kPrimary = Color(0xFF4F46E5);
  static const _kBg = Color(0xFFF8FAFC);
  
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final dio = context.read<DioClient>().dio;
      final response = await dio.get('/notifications/my-notifications');
      setState(() {
        _notifications = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải thông báo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      final dio = context.read<DioClient>().dio;
      await dio.put('/notifications/$id/mark-read');
      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
        }
      });
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông báo',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CustomLoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.inter(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchNotifications();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa có thông báo nào',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ).animate().fade().scale(),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      color: _kPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return _buildNotificationCard(notif, index);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, int index) {
    final bool isRead = notif['isRead'] ?? false;
    final int id = notif['id'];
    
    // Determine icon and color based on type
    final type = notif['type'] ?? 'Chung';
    Color iconColor = const Color(0xFF475569);
    IconData iconData = Icons.notifications_active_outlined;
    
    if (type.toString().toLowerCase().contains('khẩn') || type.toString().toLowerCase().contains('cảnh báo')) {
      iconColor = const Color(0xFFEF4444); // Red
      iconData = Icons.warning_amber_rounded;
    } else if (type.toString().toLowerCase().contains('hệ thống') || type.toString().toLowerCase().contains('thành công')) {
      iconColor = const Color(0xFF3B82F6); // Blue
      iconData = Icons.info_outline_rounded;
    } else if (type.toString().toLowerCase().contains('điểm') || type.toString().toLowerCase().contains('học tập')) {
      iconColor = const Color(0xFF10B981); // Green
      iconData = Icons.school_outlined;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          _markAsRead(id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.transparent : _kPrimary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead ? Colors.grey.shade100 : iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: isRead ? Colors.grey.shade400 : iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.grey.shade200 : iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type,
                          style: GoogleFonts.inter(
                            color: isRead ? Colors.grey.shade600 : iconColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (notif['createdAt'] != null)
                        Text(
                          _formatDate(notif['createdAt']),
                          style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notif['title'] ?? '',
                    style: GoogleFonts.inter(
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                      fontSize: 15,
                      color: isRead ? const Color(0xFF475569) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif['body'] ?? '',
                    style: GoogleFonts.inter(
                      color: isRead ? Colors.grey.shade500 : Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _kPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
