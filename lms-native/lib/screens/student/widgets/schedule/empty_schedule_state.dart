import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/mock_schedule_data.dart';
import '../../utils/schedule_utils.dart';

class EmptyScheduleState extends StatelessWidget {
  final DateTime date;

  const EmptyScheduleState({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 160,
            child: CustomPaint(painter: _FolderPainter()),
          ).animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
           .slideY(begin: -0.05, end: 0.05, duration: 2000.ms, curve: Curves.easeInOut),
          const SizedBox(height: 20),
          Text(
            'Không có dữ liệu vào ${dayDateLong(date)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: kTextGrey),
          ),
        ],
      ),
    );
  }
}

class _FolderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const grey = Color(0xFFCFD8DC);
    const lightGrey = Color(0xFFECEFF1);

    // ── Folder back ─────────────────────────────────────────────
    p.color = grey;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, cy * 0.55, size.width - 36, size.height * 0.58),
        const Radius.circular(12),
      ),
      p,
    );

    // ── Folder tab ───────────────────────────────────────────────
    final tab = Path()
      ..moveTo(18, cy * 0.55)
      ..lineTo(18, cy * 0.3)
      ..quadraticBezierTo(18, cy * 0.22, 24, cy * 0.22)
      ..lineTo(cx * 0.85, cy * 0.22)
      ..quadraticBezierTo(cx * 0.94, cy * 0.22, cx * 0.97, cy * 0.36)
      ..lineTo(cx * 1.02, cy * 0.55)
      ..close();
    canvas.drawPath(tab, p);

    // ── Folder front ─────────────────────────────────────────────
    p.color = lightGrey;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, cy * 0.72, size.width - 36, size.height * 0.52),
        const Radius.circular(12),
      ),
      p,
    );

    // ── Lines inside folder ──────────────────────────────────────
    p
      ..color = grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final y = cy * 0.92 + i * 13.0;
      canvas.drawLine(Offset(cx - 45, y), Offset(cx + 45, y), p);
    }

    // ── Sad face ─────────────────────────────────────────────────
    // Eyes
    p
      ..style = PaintingStyle.fill
      ..color = grey;
    canvas.drawCircle(Offset(cx - 12, cy * 0.88), 4.5, p);
    canvas.drawCircle(Offset(cx + 12, cy * 0.88), 4.5, p);

    // Mouth
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = grey;
    final mouth = Path()
      ..moveTo(cx - 14, cy * 1.05)
      ..quadraticBezierTo(cx, cy * 0.98, cx + 14, cy * 1.05);
    canvas.drawPath(mouth, p);

    // ── Decorative dots ──────────────────────────────────────────
    p
      ..style = PaintingStyle.fill
      ..color = grey.withOpacity(0.45);
    for (final pos in [
      Offset(18.0, cy * 0.42),
      Offset(size.width - 18, cy * 0.5),
      Offset(12.0, cy * 0.85),
      Offset(size.width - 12, cy * 0.9),
      Offset(cx + 50, cy * 0.32),
    ]) {
      canvas.drawCircle(pos, 4, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
