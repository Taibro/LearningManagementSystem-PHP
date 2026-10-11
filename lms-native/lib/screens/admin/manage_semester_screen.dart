import 'package:flutter/material.dart';

class ManageSemesterScreen extends StatelessWidget {
  const ManageSemesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý học kỳ'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: const Center(
        child: Text('Giao diện quản lý học kỳ sẽ được triển khai ở đây.'),
      ),
    );
  }
}
