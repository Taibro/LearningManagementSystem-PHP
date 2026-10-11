import 'package:flutter/material.dart';

class ScheduleProposalScreen extends StatelessWidget {
  const ScheduleProposalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      appBar: AppBar(
        title: const Text('Đề xuất lịch dạy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE85D75),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProposalCard('Dạy bù', 'Lập trình Java - C501', 'Đang chờ duyệt', Colors.orange),
          _buildProposalCard('Dạy thay', 'Cơ sở dữ liệu - A204', 'Đã duyệt', Colors.green),
          _buildProposalCard('Ngừng dạy', 'Mạng máy tính - B101', 'Đã từ chối', Colors.red),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFFE85D75),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tạo đề xuất', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildProposalCard(String type, String desc, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 12),
          const Text('Ngày gửi: 01/06/2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
