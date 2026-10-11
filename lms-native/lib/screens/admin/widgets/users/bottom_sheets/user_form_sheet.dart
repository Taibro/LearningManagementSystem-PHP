import 'package:flutter/material.dart';

class UserFormSheet extends StatelessWidget {
  final Map<String, dynamic>? user;
  final String type;

  const UserFormSheet({super.key, this.user, required this.type});

  static const _kPrimary = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final isStudent = type == 'student';
    final isEdit    = user != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        // Handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40, height: 4,
          decoration: BoxDecoration(color: const Color(0xFFE0D8F0), borderRadius: BorderRadius.circular(2)),
        )),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _kPrimary.withOpacity(0.10), shape: BoxShape.circle),
              child: const Icon(Icons.person_outlined, color: _kPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              isEdit ? 'Chỉnh sửa ${isStudent ? 'sinh viên' : 'giảng viên'}'
                     : 'Thêm ${isStudent ? 'sinh viên' : 'giảng viên'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF212121)),
            ),
          ]),
        ),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
          _formFieldBox('Họ và tên', user?['name'] ?? ''),
          const SizedBox(height: 12),
          if (isStudent) ...[
            _formFieldBox('MSSV', user?['mssv'] ?? ''),
            const SizedBox(height: 12),
            _formFieldBox('Lớp học', user?['class'] ?? ''),
            const SizedBox(height: 12),
            _formFieldBox('Chuyên ngành', user?['major'] ?? ''),
          ] else ...[
            _formFieldBox('Mã giảng viên', user?['code'] ?? ''),
            const SizedBox(height: 12),
            _formFieldBox('Khoa / Bộ môn', user?['department'] ?? ''),
            const SizedBox(height: 12),
            _formFieldBox('Học vị', user?['degree'] ?? ''),
            const SizedBox(height: 12),
            _formFieldBox('Chức danh', user?['rank'] ?? ''),
          ],
          const SizedBox(height: 12),
          _formFieldBox('Email', user?['email'] ?? ''),
          const SizedBox(height: 12),
          _formFieldBox('Số điện thoại', user?['phone'] ?? ''),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D1B6E), _kPrimary]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(
                isEdit ? 'Lưu thay đổi' : 'Tạo tài khoản',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              )),
            ),
          ),
        ]))),
      ]),
    );
  }

  Widget _formFieldBox(String label, String hint) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF616161))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: hint.isEmpty ? Colors.white : const Color(0xFFF9F9FF),
          border: Border.all(color: const Color(0xFFE0D8F0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          hint.isEmpty ? 'Nhập $label...' : hint,
          style: TextStyle(fontSize: 13, color: hint.isEmpty ? const Color(0xFFBDBDBD) : const Color(0xFF212121)),
        ),
      ),
    ],
  );
}
