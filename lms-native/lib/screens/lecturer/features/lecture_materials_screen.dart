import 'package:flutter/material.dart';

class LectureMaterialsScreen extends StatelessWidget {
  const LectureMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      appBar: AppBar(
        title: const Text('Tài liệu bài giảng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFolderCard('Lập trình Java', '12 files • 45 MB', Icons.folder_open),
          _buildFolderCard('Cơ sở dữ liệu', '8 files • 20 MB', Icons.folder_open),
          _buildFolderCard('Mạng máy tính', '15 files • 120 MB', Icons.folder_open),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF5C6BC0),
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }

  Widget _buildFolderCard(String title, String subtitle, IconData icon) {
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
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF5C6BC0), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}
