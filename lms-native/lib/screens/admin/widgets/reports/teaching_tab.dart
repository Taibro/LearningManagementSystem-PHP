import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/mock_admin_reports_data.dart';
import 'reports_helpers.dart';

class TeachingTab extends StatelessWidget {
  const TeachingTab({super.key});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF3F51B5);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(children: [
        Row(children: [
          buildSummaryCard('342/450', 'Tiết đã dạy / KH', kPrimary),
          const SizedBox(width: 8),
          buildSummaryCard('27', 'Tiết vượt KH', const Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          buildSummaryCard('10', 'Buổi coi thi', const Color(0xFFE65100)),
        ]).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 20),
        buildSectionCard(
          'Thống kê giảng viên',
          Icons.person_rounded,
          Column(children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Expanded(flex: 3, child: Text('Giảng viên', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimary))),
                SizedBox(width: 50, child: Text('KH', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimary))),
                SizedBox(width: 50, child: Text('Thực', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimary))),
                SizedBox(width: 50, child: Text('Vượt', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimary))),
              ]),
            ),
            const SizedBox(height: 12),
            ...mockLecturerStats.asMap().entries.map((e) {
              final idx = e.key;
              final l = e.value;
              final pct = (l['done'] as int) / (l['planned'] as int);
              final col = pct >= 1.0
                  ? const Color(0xFF4CAF50)
                  : pct >= 0.7
                      ? kPrimary
                      : const Color(0xFFE65100);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: idx.isEven ? const Color(0xFFF8FAFC) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: idx.isEven ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                        flex: 3,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(l['code'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ])),
                    SizedBox(width: 50, child: Text('${l['planned']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
                    SizedBox(
                        width: 50,
                        child: Text('${l['done']}', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: col))),
                    SizedBox(
                        width: 50,
                        child: Text(
                          (l['extra'] as int) > 0 ? '+${l['extra']}' : '0',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: (l['extra'] as int) > 0 ? const Color(0xFF4CAF50) : const Color(0xFF94A3B8)),
                        )),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      backgroundColor: col.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(col),
                      minHeight: 6,
                    ),
                  ),
                ]),
              ).animate().fade(delay: (200 + idx * 100).ms).slideX(begin: 0.1, end: 0);
            }).toList(),
          ]),
        ),
      ]),
    );
  }
}
