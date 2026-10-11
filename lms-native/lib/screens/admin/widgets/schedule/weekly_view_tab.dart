import 'package:flutter/material.dart';
import '../../data/mock_admin_schedule_data.dart';

class WeeklyViewTab extends StatefulWidget {
  const WeeklyViewTab({super.key});

  @override
  State<WeeklyViewTab> createState() => _WeeklyViewTabState();
}

class _WeeklyViewTabState extends State<WeeklyViewTab> {
  int _weekOffset = 0;
  static const _kPrimary = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final days = ['T2\n28/04', 'T3\n29/04', 'T4\n30/04', 'T5\n01/05', 'T6\n02/05', 'T7\n03/05'];
    final classMap = {0: ['C01','C02'], 1: ['C04'], 2: ['C05'], 3: ['C03'], 4: ['C06'], 5: []};

    return Column(children: [
      // Week navigator
      Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          IconButton(onPressed: () => setState(() => _weekOffset--),
              icon: const Icon(Icons.chevron_left, color: _kPrimary), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          Expanded(child: Text('Tuần ${20 + _weekOffset}/04 – ${26 + _weekOffset}/04/2026',
              textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          IconButton(onPressed: () => setState(() => _weekOffset++),
              icon: const Icon(Icons.chevron_right, color: _kPrimary), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          GestureDetector(
            onTap: () => setState(() => _weekOffset = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _kPrimary, borderRadius: BorderRadius.circular(7)),
              child: const Text('Hôm nay', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            children: List.generate(6, (dayIdx) {
              final dayClasses = (classMap[dayIdx] ?? [])
                  .map((id) => mockClasses.firstWhere((c) => c['id'] == id))
                  .toList();
              final isToday = dayIdx == 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: isToday ? Border.all(color: _kPrimary, width: 1.5) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isToday ? _kPrimary.withOpacity(0.07) : const Color(0xFFF9F9FF),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(children: [
                      Text(days[dayIdx].replaceAll('\n', '  '), style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13,
                          color: isToday ? _kPrimary : const Color(0xFF424242))),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: _kPrimary, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Hôm nay', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
                      ],
                      const Spacer(),
                      Text('${dayClasses.length} lớp', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    ]),
                  ),
                  if (dayClasses.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text('Không có lịch', style: TextStyle(fontSize: 13, color: Colors.grey[400], fontStyle: FontStyle.italic)))
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: dayClasses.map((c) {
                        Color col = c['type'] == 'practice' ? const Color(0xFF5C6BC0)
                            : c['type'] == 'online' ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
                        Color bg  = c['type'] == 'practice' ? const Color(0xFFE8EAF6)
                            : c['type'] == 'online' ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: bg, borderRadius: BorderRadius.circular(8),
                            border: Border(left: BorderSide(color: col, width: 3)),
                          ),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c['subject'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: col)),
                              Text('${c['lecturer']} · ${c['group']} · ${c['room']}',
                                  style: TextStyle(fontSize: 11, color: col.withOpacity(0.75))),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                              child: Text(c['session'] as String, style: TextStyle(fontSize: 10, color: col, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        );
                      }).toList()),
                    ),
                ]),
              );
            }),
          ),
        ),
      ),
    ]);
  }
}
