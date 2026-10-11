import 'package:flutter/material.dart';

final List<Map<String, dynamic>> mockClasses = [
  {'id': 'C01', 'subject': 'Kiến trúc máy tính (LT)',            'code': '010100228915', 'group': '16DHTH10', 'lecturer': 'Nguyễn Văn A', 'room': 'A401', 'day': 'Thứ 2', 'session': 'Tiết 1–3',   'type': 'theory',   'enrolled': 42, 'capacity': 50},
  {'id': 'C02', 'subject': 'TH Quản trị HTMM (TH)',              'code': '010110192400', 'group': '14DHTH40', 'lecturer': 'Nguyễn Văn A', 'room': 'A107', 'day': 'Thứ 2', 'session': 'Tiết 13–15', 'type': 'practice', 'enrolled': 28, 'capacity': 30},
  {'id': 'C03', 'subject': 'Quản trị hệ thống mạng (LT)',        'code': '010110197304', 'group': '14DHTH04', 'lecturer': 'Nguyễn Văn A', 'room': 'A202', 'day': 'Thứ 5', 'session': 'Tiết 7–9',   'type': 'theory',   'enrolled': 55, 'capacity': 60},
  {'id': 'C04', 'subject': 'Khai phá dữ liệu (LT)',              'code': '010110218801', 'group': '14DHTH01', 'lecturer': 'Trần Thị B',   'room': 'B305', 'day': 'Thứ 3', 'session': 'Tiết 1–3',   'type': 'theory',   'enrolled': 48, 'capacity': 50},
  {'id': 'C05', 'subject': 'Lập trình di động (LT)',             'code': '010110220501', 'group': '14DHTH05', 'lecturer': 'Lê Văn C',     'room': 'A301', 'day': 'Thứ 4', 'session': 'Tiết 7–9',   'type': 'theory',   'enrolled': 38, 'capacity': 40},
  {'id': 'C06', 'subject': 'Các vấn đề biên đại ATTT (LT)',     'code': '932210293002', 'group': '09CUIC02', 'lecturer': 'Nguyễn Văn A', 'room': 'DP01', 'day': 'Thứ 6', 'session': 'Tiết 2–6',   'type': 'online',   'enrolled': 22, 'capacity': 30},
];

final List<Map<String, dynamic>> mockRooms = [
  {'id': 'A101', 'name': 'A101 - Phòng lý thuyết', 'capacity': 60, 'status': 'available', 'facility': 'Máy chiếu, Điều hòa'},
  {'id': 'A107', 'name': 'A107 - Phòng máy BM',    'capacity': 30, 'status': 'occupied',  'facility': 'Máy tính, Điều hòa'},
  {'id': 'A202', 'name': 'A202 - Phòng lý thuyết', 'capacity': 60, 'status': 'occupied',  'facility': 'Máy chiếu, Điều hòa'},
  {'id': 'A301', 'name': 'A301 - Phòng lý thuyết', 'capacity': 50, 'status': 'available', 'facility': 'Máy chiếu'},
  {'id': 'A401', 'name': 'A401 - Phòng lý thuyết', 'capacity': 50, 'status': 'occupied',  'facility': 'Máy chiếu, Điều hòa'},
  {'id': 'B305', 'name': 'B305 - Hội trường',      'capacity': 100,'status': 'available', 'facility': 'Máy chiếu, Mic'},
  {'id': 'B407', 'name': 'B407 - Phòng lý thuyết', 'capacity': 50, 'status': 'maintenance','facility': 'Đang bảo trì'},
];
