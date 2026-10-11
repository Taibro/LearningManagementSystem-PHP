import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFF5C6BC0), child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Nguyễn Văn A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Giảng viên - Khoa CNTT', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Column(
                children: [
                  _ProfileItem(icon: Icons.badge, title: 'Mã số', value: 'GV00123'),
                  Divider(height: 30),
                  _ProfileItem(icon: Icons.email, title: 'Email', value: 'nguyenvana@huit.edu.vn'),
                  Divider(height: 30),
                  _ProfileItem(icon: Icons.phone, title: 'Điện thoại', value: '0901234567'),
                  Divider(height: 30),
                  _ProfileItem(icon: Icons.cake, title: 'Ngày sinh', value: '01/01/1980'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ProfileItem({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5C6BC0), size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
