import 'package:flutter/material.dart';
import '../../../../models/admin/schedule_exception_response.dart';
import 'home_helpers.dart';

class PendingRequestsCard extends StatelessWidget {
  final List<ScheduleExceptionResponse> requests;
  final Function(String, int) onAction;
  const PendingRequestsCard({super.key, required this.requests, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return buildHomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            buildSectionTitle('Đề xuất chờ duyệt', Icons.pending_actions_rounded),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFE85D75), borderRadius: BorderRadius.circular(20)),
              child: Text('${requests.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 12),
          ...requests.map((r) {
            final col = const Color(0xFFE65100);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: col.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: col.withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: col.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(Icons.event_busy_outlined, color: col, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.exceptionType ?? 'Đề xuất', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('${r.teacherName} · ${r.classCode} · ${r.exceptionDate}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                ])),
                const SizedBox(width: 8),
                _approveBtn('Phê duyệt', const Color(0xFF4CAF50), r.id ?? 0),
                const SizedBox(width: 6),
                _approveBtn('Từ chối', const Color(0xFFC62828), r.id ?? 0),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _approveBtn(String label, Color color, int id) {
    return GestureDetector(
      onTap: () => onAction(label, id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
