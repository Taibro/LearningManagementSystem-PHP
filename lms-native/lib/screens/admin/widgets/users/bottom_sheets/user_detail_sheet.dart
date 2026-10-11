import 'package:flutter/material.dart';

class UserDetailSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  final String type;

  const UserDetailSheet({super.key, required this.user, required this.type});

  static const _kPrimary = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final isStudent = type == 'student';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        // Handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40, height: 4,
          decoration: BoxDecoration(color: const Color(0xFFE0D8F0), borderRadius: BorderRadius.circular(2)),
        )),
        // Profile header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0D1B6E), _kPrimary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), color: Colors.white.withOpacity(0.2)),
              child: Center(child: Text(
                (user['name'] as String).split(' ').last.substring(0, 1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              )),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 3),
              Text(
                isStudent ? 'MSSV: ${user['mssv']}  ·  ${user['class']}' : '${user['code']}  ·  ${user['department']}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ])),
          ]),
        ),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
          // Info section 1
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF9F9FF), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isStudent ? 'Thông tin sinh viên' : 'Thông tin giảng viên',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _kPrimary)),
              const SizedBox(height: 10),
              if (isStudent) ...[
                _detailInfoRow('MSSV',         user['mssv']),
                _detailInfoRow('Lớp',          user['class']),
                _detailInfoRow('Chuyên ngành', user['major']),
                _detailInfoRow('GPA',          '${user['gpa']}'),
                _detailInfoRow('Trạng thái',   user['status']),
              ] else ...[
                _detailInfoRow('Mã GV',        user['code']),
                _detailInfoRow('Khoa',         user['department']),
                _detailInfoRow('Học vị',       user['degree']),
                _detailInfoRow('Chức danh',    user['rank']),
                _detailInfoRow('Số lớp',       '${user['classes']} lớp'),
              ],
            ]),
          ),
          const SizedBox(height: 12),
          // Info section 2
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF9F9FF), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Liên hệ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _kPrimary)),
              const SizedBox(height: 10),
              _detailInfoRow('Email',      user['email']),
              _detailInfoRow('Điện thoại', user['phone']),
            ]),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(color: _kPrimary, borderRadius: BorderRadius.circular(9)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Chỉnh sửa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(9)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_reset, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Đặt lại MK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ),
            )),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(9)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.block, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Khoá tài khoản', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            ),
          ),
        ]))),
      ]),
    );
  }

  Widget _detailInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF212121)))),
    ]),
  );
}
