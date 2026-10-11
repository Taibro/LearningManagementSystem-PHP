import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      appBar: AppBar(
        title: const Text('Kết quả học tập', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.class_outlined, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chọn lớp học phần', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Lập trình Java (010110)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Danh sách sinh viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildStudentGradeRow('1', '200121001', 'Nguyễn Văn A', '8.5', '9.0'),
            _buildStudentGradeRow('2', '200121002', 'Trần Thị B', '7.0', '8.5'),
            _buildStudentGradeRow('3', '200121003', 'Lê Văn C', '9.0', '9.5'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.save_outlined, color: Colors.white),
        label: const Text('Lưu bảng điểm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStudentGradeRow(String stt, String id, String name, String gk, String ck) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(stt, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(id, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              const Text('GK', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(gk, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              const Text('CK', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(ck, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
            ],
          ),
        ],
      ),
    );
  }
}
