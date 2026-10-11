import 'package:flutter/material.dart';

class UpdateScheduleScreen extends StatefulWidget {
  const UpdateScheduleScreen({super.key});

  @override
  State<UpdateScheduleScreen> createState() => _UpdateScheduleScreenState();
}

class _UpdateScheduleScreenState extends State<UpdateScheduleScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  int _selectedWeek = 12;
  final _weeks = List.generate(20, (i) => i + 1);

  final _scheduleData = [
    {'day': 'Thứ 2', 'classes': [
      {'time': 'Tiết 1-3', 'subject': 'Lập trình Java', 'room': 'A1-301', 'teacher': 'TS. Nguyễn Văn A', 'class': 'DHKTPM17A'},
      {'time': 'Tiết 7-9', 'subject': 'Cơ sở dữ liệu', 'room': 'A2-201', 'teacher': 'ThS. Trần Thị B', 'class': 'DHKTPM17B'},
    ]},
    {'day': 'Thứ 3', 'classes': [
      {'time': 'Tiết 4-6', 'subject': 'Mạng máy tính', 'room': 'B1-101', 'teacher': 'PGS.TS Lê Văn C', 'class': 'DHKTPM16A'},
    ]},
    {'day': 'Thứ 4', 'classes': [
      {'time': 'Tiết 1-3', 'subject': 'Trí tuệ nhân tạo', 'room': 'A1-302', 'teacher': 'TS. Nguyễn Văn A', 'class': 'DHKTPM17A'},
      {'time': 'Tiết 4-6', 'subject': 'Lập trình Web', 'room': 'A2-202', 'teacher': 'ThS. Phạm Thị D', 'class': 'DHKTPM17C'},
      {'time': 'Tiết 10-12', 'subject': 'An toàn thông tin', 'room': 'B2-201', 'teacher': 'ThS. Trần Thị B', 'class': 'DHKTPM16B'},
    ]},
    {'day': 'Thứ 5', 'classes': [
      {'time': 'Tiết 1-3', 'subject': 'Lập trình Java', 'room': 'A1-301', 'teacher': 'TS. Nguyễn Văn A', 'class': 'DHKTPM17B'},
    ]},
    {'day': 'Thứ 6', 'classes': [
      {'time': 'Tiết 4-6', 'subject': 'Cơ sở dữ liệu', 'room': 'A2-201', 'teacher': 'ThS. Trần Thị B', 'class': 'DHKTPM17A'},
      {'time': 'Tiết 7-9', 'subject': 'Mạng máy tính', 'room': 'B1-101', 'teacher': 'PGS.TS Lê Văn C', 'class': 'DHKTPM16A'},
    ]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(children: [
        _buildHeader(),
        _buildWeekSelector(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              ..._scheduleData.map((day) => _buildDayCard(day)),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B6E), _kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16, right: 16, bottom: 16,
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        const Text('Cập nhật lịch',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        GestureDetector(
          onTap: () => _snack('Đã đồng bộ lịch'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(children: [
              Icon(Icons.sync_rounded, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Text('Đồng bộ', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      color: _kPrimary.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        GestureDetector(
          onTap: () => setState(() { if (_selectedWeek > 1) _selectedWeek--; }),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.chevron_left, color: _kPrimary, size: 20),
          ),
        ),
        Expanded(
          child: Center(
            child: Text('Tuần $_selectedWeek · HK2 2025-2026',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kPrimary)),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() { if (_selectedWeek < 20) _selectedWeek++; }),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.chevron_right, color: _kPrimary, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> dayData) {
    final day = dayData['day'] as String;
    final classes = dayData['classes'] as List;
    final colors = [const Color(0xFF1A237E), const Color(0xFF2E7D32), const Color(0xFFE65100), const Color(0xFF00695C), const Color(0xFF5C6BC0)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _kPrimary.withOpacity(0.06),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(children: [
            Icon(Icons.today, color: _kPrimary, size: 16),
            const SizedBox(width: 8),
            Text(day, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kPrimary)),
            const Spacer(),
            Text('${classes.length} lớp', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          ]),
        ),
        ...classes.asMap().entries.map((entry) {
          final c = entry.value as Map<String, String>;
          final col = colors[entry.key % colors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Container(
                width: 4, height: 50,
                decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['subject']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text('${c['time']} · ${c['room']} · ${c['class']}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                  Text(c['teacher']!, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                ]),
              ),
              GestureDetector(
                onTap: () => _snack('Chỉnh sửa: ${c['subject']}'),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit_outlined, color: col, size: 16),
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 4),
      ]),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: _kPrimary, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );
}
