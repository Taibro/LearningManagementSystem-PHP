import 'package:flutter/material.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Cảnh báo hệ thống: Lịch thi cuối kỳ',
      'body': 'Vui lòng kiểm tra lại phòng thi cho kỳ 2.',
      'type': 'Khẩn cấp',
      'date': '04/06/2026',
      'color': const Color(0xFFE53935)
    },
    {
      'title': 'Cập nhật tính năng đóng học phí',
      'body': 'Đã tích hợp thành công thanh toán VNPay.',
      'type': 'Hệ thống',
      'date': '03/06/2026',
      'color': const Color(0xFF1E88E5)
    },
    {
      'title': 'Thông báo nghỉ lễ',
      'body': 'Sinh viên và Giảng viên được nghỉ lễ 30/4 và 1/5.',
      'type': 'Chung',
      'date': '25/04/2026',
      'color': const Color(0xFF43A047)
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _buildNotificationCard(notif);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mở form soạn thông báo...')));
        },
        backgroundColor: _kPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Soạn thông báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B6E), _kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 8, right: 16, bottom: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.campaign_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          const Text('Quản lý thông báo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final color = notif['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_outlined, color: color, size: 22),
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
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(notif['type'], style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    Text(notif['date'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(notif['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF212121))),
                const SizedBox(height: 4),
                Text(notif['body'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
