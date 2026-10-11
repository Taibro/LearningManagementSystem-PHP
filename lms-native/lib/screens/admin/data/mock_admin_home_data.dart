import 'package:flutter/material.dart';

final List<Map<String, dynamic>> mockPendingRequests = [
  {'type': 'Đề xuất dạy bù',  'from': 'GV Nguyễn Văn A', 'class': '14DHTH04', 'date': '28/04/2026', 'icon': Icons.add_circle_outline_rounded,  'color': const Color(0xFF4CAF50)},
  {'type': 'Đề xuất tạm ngừng', 'from': 'GV Trần Thị B',   'class': '16DHTH10', 'date': '30/04/2026', 'icon': Icons.pause_circle_outline_rounded, 'color': const Color(0xFFE65100)},
  {'type': 'Đề xuất dạy thay', 'from': 'GV Lê Văn C',     'class': '14DHTH03', 'date': '02/05/2026', 'icon': Icons.swap_horiz_rounded,           'color': const Color(0xFF1565C0)},
];

final List<Map<String, dynamic>> mockAdminActivities = [
  {'icon': Icons.how_to_reg_outlined, 'color': const Color(0xFF4CAF50), 'msg': 'GV Nguyễn Văn A vừa lưu điểm danh lớp 14DHTH04', 'time': '5 phút trước'},
  {'icon': Icons.grade_rounded,       'color': const Color(0xFF1A237E), 'msg': 'Bảng điểm HK2 lớp 14DHTH03 đã được khóa',         'time': '1 giờ trước'},
  {'icon': Icons.person_add_outlined, 'color': const Color(0xFF00695C), 'msg': '12 sinh viên mới đăng ký học kỳ 2 2025-2026',      'time': '2 giờ trước'},
  {'icon': Icons.warning_amber_outlined,'color':const Color(0xFFE85D75),'msg': '5 sinh viên vắng quá 20% – 16DHTH10',              'time': '3 giờ trước'},
  {'icon': Icons.schedule_rounded,    'color': const Color(0xFFE65100), 'msg': 'Thời khóa biểu tuần 19 đã được cập nhật',          'time': 'Hôm qua'},
];
