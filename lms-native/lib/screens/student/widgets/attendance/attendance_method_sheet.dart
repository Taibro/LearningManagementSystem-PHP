import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_app/models/Attendance.dart';
import 'package:learning_management_app/repositories/student_repository.dart';
import 'qr_scanner_screen.dart';

class AttendanceMethodSheet extends StatefulWidget {
  final Attendance item;
  final VoidCallback onSuccess;

  const AttendanceMethodSheet({
    super.key,
    required this.item,
    required this.onSuccess,
  });

  @override
  State<AttendanceMethodSheet> createState() => _AttendanceMethodSheetState();
}

class _AttendanceMethodSheetState extends State<AttendanceMethodSheet> {
  // 0 = QR, 1 = Nhập mã
  int _mode = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                const Expanded(
                  child: Text(
                    'Nhập mã',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _mode == 0 ? _buildQRView() : _buildCodeView(),
            ),
          ),
          const SizedBox(height: 16),

          // Quét QR / Nhập mã
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mode = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _mode == 0
                            ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: _mode == 0
                                ? const Color(0xFF1565C0)
                                : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Quét QR',
                            style: TextStyle(
                              color: _mode == 0
                                  ? const Color(0xFF1565C0)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mode = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _mode == 1
                            ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard_alt_outlined,
                            color: _mode == 1
                                ? const Color(0xFF1565C0)
                                : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Nhập mã',
                            style: TextStyle(
                              color: _mode == 1
                                  ? const Color(0xFF1565C0)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── QR ──────────────────────────────────────────────────
  Widget _buildQRView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // QR
        Container(
          width: 420,
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // QR corner
              CustomPaint(
                size: const Size(200, 200),
                painter: _QRCornerPainter(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 100,
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hướng camera vào mã QR',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Đưa mã QR vào khung hình để quét',
          style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _openScanner,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Mở Camera'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // ── Code Entry View ──────────────────────────────────────────
  Widget _buildCodeView() {
    return _CodeEntryForm(
      onSubmit: (code) {
        if (code.isNotEmpty) _submitAttendance(code);
      },
    );
  }

  void _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );
    if (result != null && result is String) {
      _submitAttendance(result);
    }
  }

  void _submitAttendance(String qrToken) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Assuming studentId is 1 for now or fetched from somewhere. 
      // In a real app we might get the user profile first or not need studentId if the token has it.
      // But based on QrScanRequest it needs studentId. Let's pass 1 for test or fetch from profileBloc.
      // Ideally backend extracts from JWT, but since it's required in body, we pass 1 as placeholder 
      // or we can catch any error.
      final repo = context.read<StudentRepository>();
      await repo.scanQrCode(qrToken);
      
      if (context.mounted) Navigator.pop(context); // Close loading
      _handleSuccess();
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleSuccess() {
    Navigator.pop(context);
    widget.onSuccess();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Điểm danh thành công!'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ── Code Entry Form─────────────────────

class _CodeEntryForm extends StatefulWidget {
  final void Function(String code) onSubmit;
  const _CodeEntryForm({required this.onSubmit});

  @override
  State<_CodeEntryForm> createState() => _CodeEntryFormState();
}

class _CodeEntryFormState extends State<_CodeEntryForm> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Illustration
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _SecurityIllustrationPainter(),
              size: const Size(200, 180),
            ),
          ),
          const SizedBox(height: 32),
          // Input field
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Nhập mã',
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              counterText: '',
              suffixIcon: const Icon(
                Icons.volume_up_outlined,
                color: Color(0xFF9E9E9E),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF1565C0),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _ctrl.text.isNotEmpty
                  ? () => widget.onSubmit(_ctrl.text)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                disabledBackgroundColor: const Color(0xFFBBDEFB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Gửi mã',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── góc QR ───────────────────────────
class _QRCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 20.0;
    const offset = 10.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(offset, offset + corner)
        ..lineTo(offset, offset)
        ..lineTo(offset + corner, offset),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - offset - corner, offset)
        ..lineTo(size.width - offset, offset)
        ..lineTo(size.width - offset, offset + corner),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(offset, size.height - offset - corner)
        ..lineTo(offset, size.height - offset)
        ..lineTo(offset + corner, size.height - offset),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - offset - corner, size.height - offset)
        ..lineTo(size.width - offset, size.height - offset)
        ..lineTo(size.width - offset, size.height - offset - corner),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SecurityIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;

    // Phone body
    paint.color = const Color(0xFFBBDEFB);
    final phone = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx - 20, size.height * 0.5),
        width: 90,
        height: 130,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(phone, paint);

    // Phone screen
    paint.color = const Color(0xFF90CAF9);
    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx - 20, size.height * 0.5),
        width: 74,
        height: 110,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(screen, paint);

    // Shield
    paint.color = const Color(0xFF1565C0);
    final shieldPath = Path();
    final sx = cx + 10.0;
    final sy = size.height * 0.12;
    shieldPath.moveTo(sx, sy);
    shieldPath.lineTo(sx + 22, sy + 8);
    shieldPath.lineTo(sx + 22, sy + 26);
    shieldPath.quadraticBezierTo(sx + 22, sy + 38, sx, sy + 44);
    shieldPath.quadraticBezierTo(sx - 22, sy + 38, sx - 22, sy + 26);
    shieldPath.lineTo(sx - 22, sy + 8);
    shieldPath.close();
    canvas.drawPath(shieldPath, paint);

    // Check on shield
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;
    final checkPath = Path();
    checkPath.moveTo(sx - 10, sy + 22);
    checkPath.lineTo(sx - 2, sy + 30);
    checkPath.lineTo(sx + 12, sy + 16);
    canvas.drawPath(checkPath, paint);

    // Stars (asterisks placeholder)
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF1565C0).withOpacity(0.7);
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(cx - 30 + i * 16.0, size.height * 0.42),
        5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
