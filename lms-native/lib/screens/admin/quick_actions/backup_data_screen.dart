import 'package:flutter/material.dart';

class BackupDataScreen extends StatefulWidget {
  const BackupDataScreen({super.key});

  @override
  State<BackupDataScreen> createState() => _BackupDataScreenState();
}

class _BackupDataScreenState extends State<BackupDataScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_done_outlined, color: Colors.green, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('Trạng thái Hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kPrimary)),
                        const SizedBox(height: 8),
                        Text('Bản sao lưu gần nhất: 04/06/2026', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Text('Dung lượng lưu trữ: 45MB', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang tiến hành sao lưu...')));
                            },
                            icon: const Icon(Icons.backup_outlined),
                            label: const Text('Tiến hành Sao lưu ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C6BC0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang khôi phục dữ liệu...')));
                            },
                            icon: const Icon(Icons.restore_outlined),
                            label: const Text('Khôi phục dữ liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE53935),
                              side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          const Text('Sao lưu Dữ liệu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
