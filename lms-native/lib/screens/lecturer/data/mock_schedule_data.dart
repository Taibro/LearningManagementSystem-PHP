final List<String> kWeekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
final List<String> kWeekDates = [
  '20/04', '21/04', '22/04', '23/04', '24/04', '25/04', '26/04'
];

final Map<int, List<Map<String, dynamic>>> kWeekSchedule = {
  0: [
    {
      'subject': 'Kiến trúc máy tính (LT)',
      'code': '16DHTH10',
      'room': 'A401 - 140 LTT',
      'session': 'Tiết 1–3',
      'type': 'theory',
    },
    {
      'subject': 'TH Quản trị HTMM (TH)',
      'code': '14DHTH40',
      'room': 'A107 - Phòng máy',
      'session': 'Tiết 13–15',
      'type': 'practice',
    },
  ],
  1: [
    {
      'subject': 'Kiến trúc máy tính (LT)',
      'code': '16DHTH08',
      'room': 'B407 - 140 LTT',
      'session': 'Tiết 7–9',
      'type': 'theory',
    },
    {
      'subject': 'TH Quản trị HTMM (TH)',
      'code': '14DHTH41',
      'room': 'A107 - Phòng máy',
      'session': 'Tiết 13–15',
      'type': 'practice',
    },
  ],
  3: [
    {
      'subject': 'Quản trị HTMM (LT)',
      'code': '14DHTH04',
      'room': 'A202 - 140 LTT',
      'session': 'Tiết 7–9',
      'type': 'theory',
    },
    {
      'subject': 'Quản trị HTMM (LT)',
      'code': '14DHTH03',
      'room': 'A301 - 140 LTT',
      'session': 'Tiết 10–12',
      'type': 'theory',
    },
    {
      'subject': 'TH Quản trị HTMM (TH)',
      'code': '14DHTH42',
      'room': 'A108 - Phòng máy',
      'session': 'Tiết 13–15',
      'type': 'practice',
    },
  ],
  4: [
    {
      'subject': 'Các vấn đề ATTT (LT)',
      'code': '09CUICMITUE02',
      'room': 'DP01 - Công ty CP Tin học Đại Phát',
      'session': 'Tiết 2–6',
      'type': 'online',
    },
    {
      'subject': 'TH Quản trị HTMM (TH)',
      'code': '14DHTH43',
      'room': 'A108 - Phòng máy',
      'session': 'Tiết 13–15',
      'type': 'practice',
    },
  ],
};

final List<Map<String, dynamic>> kProgressList = [
  {
    'subject': 'Kiến trúc máy tính (LT)',
    'code': '010100228915 - 16DHTH10',
    'total': 45,
    'done': 29,
    'status': 'Đang dạy',
    'statusColor': 0xFF4CAF50,
    'chapters': [
      {'label': 'Chương 1', 'done': true, 'pct': 1.0},
      {'label': 'Chương 2', 'done': true, 'pct': 1.0},
      {'label': 'Chương 3', 'done': true, 'pct': 1.0},
      {'label': 'Chương 4', 'done': false, 'pct': 0.6},
      {'label': 'Chương 5', 'done': false, 'pct': 0.0},
    ],
  },
  {
    'subject': 'Quản trị hệ thống mạng (LT)',
    'code': '010110197304 - 14DHTH04',
    'total': 60,
    'done': 24,
    'status': 'Đang dạy',
    'statusColor': 0xFF2196F3,
    'chapters': [],
  },
  {
    'subject': 'TH Quản trị hệ thống mạng (TH)',
    'code': '010110192400 - 14DHTH40',
    'total': 30,
    'done': 24,
    'status': 'Gần hoàn thành',
    'statusColor': 0xFFE65100,
    'chapters': [],
  },
  {
    'subject': 'Các vấn đề biên đại ATTT (LT)',
    'code': '932210293002 - 09CUICMITUE02',
    'total': 30,
    'done': 30,
    'status': 'Hoàn thành',
    'statusColor': 0xFF6B4FA0,
    'chapters': [],
  },
];
