import 'package:flutter/material.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      appBar: AppBar(
        title: const Text('Khảo sát', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE85D75),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSurveyCard('Đánh giá chất lượng giảng dạy HK2', 'Hạn chót: 30/06/2026', 'Mới', Colors.red),
          _buildSurveyCard('Khảo sát cơ sở vật chất', 'Hạn chót: 15/05/2026', 'Đã hoàn thành', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSurveyCard(String title, String deadline, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
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
          const SizedBox(height: 12),
          Text(deadline, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'Mới' ? const Color(0xFFE85D75) : Colors.grey.shade300,
                foregroundColor: status == 'Mới' ? Colors.white : Colors.black54,
              ),
              child: const Text('Thực hiện khảo sát'),
            ),
          ),
        ],
      ),
    );
  }
}
