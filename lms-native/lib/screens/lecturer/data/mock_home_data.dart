import 'package:flutter/material.dart';

final List<Map<String, dynamic>> kTodayClasses = [
  {
    'subject': 'Kiến trúc máy tính (LT)',
    'classCode': '010100228915 - 16DHTH10',
    'room': 'A401 - 140 Lê Trọng Tấn',
    'session': 'Tiết 1 – 3',
    'time': '07:00 – 09:30',
    'type': 'theory',
  },
  {
    'subject': 'TH Quản trị hệ thống mạng (TH)',
    'classCode': '010110192400 - 14DHTH40',
    'room': 'A107 - Phòng máy BM',
    'session': 'Tiết 13 – 15',
    'time': '18:00 – 20:30',
    'type': 'practice',
  },
];

final List<Map<String, dynamic>> kNotifications = [
  {
    'icon': Icons.check_circle_outline,
    'color': const Color(0xFF4CAF50),
    'title': 'Đề xuất dạy bù đã được duyệt',
    'time': '30 phút trước',
  },
  {
    'icon': Icons.info_outline,
    'color': const Color(0xFF6B4FA0),
    'title': 'Nhắc nhở: Nộp bảng điểm HK2 trước 20/05',
    'time': '2 giờ trước',
  },
  {
    'icon': Icons.warning_amber_outlined,
    'color': const Color(0xFFE85D75),
    'title': '3 sinh viên vắng trên 20% - 14DHTH04',
    'time': 'Hôm qua',
  },
];
