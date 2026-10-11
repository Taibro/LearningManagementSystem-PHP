import 'package:flutter/material.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      appBar: AppBar(
        title: const Text('QR Code Điểm danh', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B4FA0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Môn: Lập trình Java', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6B4FA0))),
              const SizedBox(height: 8),
              const Text('Phòng C501 • 13:00 - 15:30', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 150, color: Color(0xFF212121)),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Mã xác nhận: 849201', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              const Text('Sinh viên quét mã hoặc nhập mã số trên để điểm danh.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
