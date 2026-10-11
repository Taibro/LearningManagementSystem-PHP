import 'package:flutter/material.dart';

// ATTENDANCE DATA
final List<Map<String, dynamic>> mockClassStats = [
  {'class': '14DHTH04', 'subject': 'QTHTMM', 'lecturer': 'Nguyễn Văn A', 'present': 58, 'total': 60, 'absent': 2, 'excused': 0},
  {'class': '16DHTH10', 'subject': 'KTMT',   'lecturer': 'Nguyễn Văn A', 'present': 40, 'total': 42, 'absent': 1, 'excused': 1},
  {'class': '14DHTH40', 'subject': 'TH QTHTMM','lecturer':'Nguyễn Văn A','present': 26, 'total': 28, 'absent': 2, 'excused': 0},
  {'class': '14DHTH01', 'subject': 'KPD',    'lecturer': 'Trần Thị B',   'present': 44, 'total': 48, 'absent': 3, 'excused': 1},
  {'class': '14DHTH05', 'subject': 'LTDĐ',   'lecturer': 'Lê Văn C',     'present': 35, 'total': 38, 'absent': 2, 'excused': 1},
];

final List<Map<String, dynamic>> mockWarningStudents = [
  {'name': 'Cao Đức Mạnh', 'mssv': '14DHTH12007', 'absent': 6, 'total': 15, 'pct': 40},
  {'name': 'Phan Trọng Nghiêm', 'mssv': '12DHBM05001', 'absent': 5, 'total': 15, 'pct': 33},
];

// GRADES DATA
final List<Map<String, dynamic>> mockDistribution = [
  {'label': 'Xuất sắc (≥9.0)', 'count': 215, 'pct': 0.18, 'color': const Color(0xFF1A237E)},
  {'label': 'Giỏi (8.0–8.9)',   'count': 380, 'pct': 0.32, 'color': const Color(0xFF4CAF50)},
  {'label': 'Khá (7.0–7.9)',    'count': 290, 'pct': 0.24, 'color': const Color(0xFF2196F3)},
  {'label': 'TB (5.0–6.9)',     'count': 215, 'pct': 0.18, 'color': const Color(0xFFE65100)},
  {'label': 'Không đạt (<5)',   'count': 95,  'pct': 0.08, 'color': const Color(0xFFC62828)},
];

final List<Map<String, dynamic>> mockTopClasses = [
  {'class': '14DHTH04', 'subject': 'QTHTMM', 'avg': 8.2, 'passed': 98},
  {'class': '16DHTH10', 'subject': 'KTMT',   'avg': 7.6, 'passed': 95},
  {'class': '14DHTH01', 'subject': 'KPD',    'avg': 7.1, 'passed': 91},
];

// TEACHING DATA
final List<Map<String, dynamic>> mockLecturerStats = [
  {'name': 'Nguyễn Văn A', 'code': 'GV001', 'planned': 120, 'done': 87,  'extra': 12, 'exam': 3},
  {'name': 'Trần Thị B',   'code': 'GV002', 'planned': 90,  'done': 90,  'extra': 0,  'exam': 2},
  {'name': 'Lê Văn C',     'code': 'GV003', 'planned': 75,  'done': 60,  'extra': 0,  'exam': 1},
  {'name': 'Phạm Thị D',   'code': 'GV004', 'planned': 105, 'done': 105, 'extra': 15, 'exam': 4},
];

// REQUESTS DATA
final List<Map<String, dynamic>> mockRequestsByStatus = [
  {'label': 'Đã duyệt',   'count': 18, 'color': const Color(0xFF4CAF50)},
  {'label': 'Chờ duyệt',  'count': 3,  'color': const Color(0xFFE65100)},
  {'label': 'Từ chối',    'count': 5,  'color': const Color(0xFFC62828)},
];

final List<Map<String, dynamic>> mockRequestsByType = [
  {'label': 'Tạm ngừng lịch dạy', 'count': 12, 'approved': 8,  'color': const Color(0xFFF5A623)},
  {'label': 'Dạy bù',             'count': 9,  'approved': 8,  'color': const Color(0xFF4CAF50)},
  {'label': 'Dạy thay',           'count': 5,  'approved': 2,  'color': const Color(0xFF1565C0)},
];

final List<Map<String, dynamic>> mockRecentDecisions = [
  {'type': 'Đề xuất dạy bù',  'from': 'GV Nguyễn Văn A', 'status': 'approved', 'date': '25/04/2026'},
  {'type': 'Tạm ngừng',       'from': 'GV Trần Thị B',   'status': 'rejected', 'date': '24/04/2026'},
  {'type': 'Đề xuất dạy bù',  'from': 'GV Lê Văn C',     'status': 'approved', 'date': '22/04/2026'},
  {'type': 'Tạm ngừng',       'from': 'GV Phạm Thị D',   'status': 'pending',  'date': '28/04/2026'},
];
