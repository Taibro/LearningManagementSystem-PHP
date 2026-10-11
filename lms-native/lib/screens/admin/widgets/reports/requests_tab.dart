import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/mock_admin_reports_data.dart';
import 'reports_helpers.dart';

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(children: [
        Row(
            children: mockRequestsByStatus.asMap().entries.map((entry) {
          final idx = entry.key;
          final s = entry.value;
          final col = s['color'] as Color;
          return Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [col, col.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: col.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Column(children: [
                      Text('${s['count']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(s['label'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
                    ]),
                  ).animate().fade(delay: (idx * 100).ms).slideY(begin: 0.2, end: 0)));
        }).toList()),
        const SizedBox(height: 20),
        buildSectionCard(
          'Theo loại đề xuất',
          Icons.category_rounded,
          Column(
            children: mockRequestsByType.asMap().entries.map((entry) {
              final idx = entry.key;
              final t = entry.value;
              final col = t['color'] as Color;
              final pct = (t['approved'] as int) / (t['count'] as int);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: col.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: col.withOpacity(0.1)),
                ),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.description_rounded, color: col, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(t['label'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                        Text('${t['approved']}/${t['count']} duyệt', style: TextStyle(fontSize: 13, color: col, fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: col.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(col),
                          minHeight: 8,
                        ),
                      ),
                    ]),
                  ),
                ]),
              ).animate().fade(delay: (200 + idx * 100).ms).slideX(begin: 0.1, end: 0);
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        buildSectionCard(
          'Lịch sử quyết định',
          Icons.history_rounded,
          Column(
            children: mockRecentDecisions.asMap().entries.map((entry) {
              final idx = entry.key;
              final d = entry.value;
              Color col;
              String label;
              IconData icon;
              switch (d['status']) {
                case 'approved':
                  col = const Color(0xFF4CAF50);
                  label = 'Đã duyệt';
                  icon = Icons.check_circle_rounded;
                  break;
                case 'rejected':
                  col = const Color(0xFFC62828);
                  label = 'Từ chối';
                  icon = Icons.cancel_rounded;
                  break;
                default:
                  col = const Color(0xFFE65100);
                  label = 'Chờ duyệt';
                  icon = Icons.pending_rounded;
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: col.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: col.withOpacity(0.15))),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: col.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: col, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d['type'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text('${d['from']}  ·  ${d['date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20), boxShadow: [
                      BoxShadow(color: col.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
                    ]),
                    child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ).animate().fade(delay: (400 + idx * 100).ms).slideY(begin: 0.1, end: 0);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}
