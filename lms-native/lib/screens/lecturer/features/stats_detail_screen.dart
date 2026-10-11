import 'package:flutter/material.dart';

class StatsDetailScreen extends StatelessWidget {
  final int initialTabIndex;
  const StatsDetailScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F1F8),
        appBar: AppBar(
          title: const Text('Chi tiết thống kê', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF6B4FA0),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: '2 Lớp (Hôm nay)'),
              Tab(text: '8 Buổi (Tuần)'),
              Tab(text: '1 Đề xuất'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildClassesTab(),
            _buildSessionsTab(),
            _buildProposalsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Lập trình Java', 'C501 • 13:00 - 15:30', Icons.class_outlined, const Color(0xFF6B4FA0)),
        _buildDetailCard('Mạng máy tính', 'A102 • 15:45 - 18:00', Icons.class_outlined, const Color(0xFF6B4FA0)),
      ],
    );
  }

  Widget _buildSessionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Thứ 2 - Lập trình Java', 'C501 • 13:00 - 15:30', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
        _buildDetailCard('Thứ 2 - Mạng máy tính', 'A102 • 15:45 - 18:00', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
        _buildDetailCard('Thứ 3 - Cơ sở dữ liệu', 'B204 • 07:00 - 09:30', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
        _buildDetailCard('Thứ 4 - Lập trình Java', 'C501 • 13:00 - 15:30', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
        _buildDetailCard('Thứ 5 - Kiến trúc máy tính', 'D105 • 09:45 - 12:00', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
        _buildDetailCard('Thứ 5 - Mạng máy tính', 'A102 • 13:00 - 15:30', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
        _buildDetailCard('Thứ 6 - Cơ sở dữ liệu', 'B204 • 07:00 - 09:30', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
        _buildDetailCard('Thứ 7 - Thực hành Java', 'PM1 • 13:00 - 16:00', Icons.calendar_today_outlined, const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildProposalsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Đề xuất dạy thay', 'Lập trình Java - Ngày 15/06/2026', Icons.pending_actions_outlined, const Color(0xFFE65100)),
      ],
    );
  }

  Widget _buildDetailCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
