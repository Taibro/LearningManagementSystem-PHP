import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_attendance_data.dart';

const Color _kPrimary = Color(0xFF6B4FA0);

class GradesTab extends StatelessWidget {
  const GradesTab({super.key});

  double _computeTotal(Map<String, dynamic> g) =>
      g['cc'] * 0.1 + g['gk'] * 0.3 + g['ck'] * 0.6;

  String _gradeLabel(double total) {
    if (total >= 9.0) return 'Xuất sắc';
    if (total >= 8.0) return 'Giỏi';
    if (total >= 7.0) return 'Khá';
    if (total >= 5.0) return 'Trung bình';
    return 'Không đạt';
  }

  Color _gradeLabelColor(double total) {
    if (total >= 9.0) return const Color(0xFF10B981);
    if (total >= 7.0) return const Color(0xFF3B82F6);
    if (total >= 5.0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final avg = kGrades.fold<double>(
            0, (sum, g) => sum + _computeTotal(g)) /
        kGrades.length;
    final passed = kGrades.where((g) => _computeTotal(g) >= 5.0).length;
    final failed = kGrades.where((g) => _computeTotal(g) < 5.0).length;
    final excellent = kGrades.where((g) => _computeTotal(g) >= 9.0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
      child: Column(
        children: [
          // Filter
          _buildGradesFilter(context).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          // Summary stats
          Row(
            children: [
              _buildGradeStat(avg.toStringAsFixed(1), 'Điểm TB', const Color(0xFF6B4FA0), 0),
              const SizedBox(width: 12),
              _buildGradeStat('$passed', 'Đạt (≥5)', const Color(0xFF10B981), 1),
              const SizedBox(width: 12),
              _buildGradeStat('$failed', 'Không đạt', const Color(0xFFEF4444), 2),
              const SizedBox(width: 12),
              _buildGradeStat('$excellent', 'Xuất sắc', const Color(0xFFF59E0B), 3),
            ],
          ),
          const SizedBox(height: 24),
          // Grade table
          _buildGradeTable(context).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGradesFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lớp học phần',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('010110195604 - 14DHTH04',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B4FA0), Color(0xFF8B6BBF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text('Tìm kiếm',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showSnack(context, 'Xuất Excel'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: _kPrimary, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.table_chart_rounded, color: _kPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeStat(String value, String label, Color color, int index) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10, color: color.withOpacity(0.9), fontWeight: FontWeight.w700, height: 1.2)),
          ],
        ),
      ).animate().scale(delay: (50 * index).ms, curve: Curves.easeOutBack, duration: 400.ms),
    );
  }

  Widget _buildGradeTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bảng điểm chi tiết',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${kGrades.length} SV',
                    style: GoogleFonts.inter(
                      color: _kPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1.5, color: Color(0xFFF1F5F9)),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 24,
                    child: Text('#',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11, color: const Color(0xFF64748B)))),
                const SizedBox(width: 8),
                Expanded(
                    flex: 3,
                    child: Text('Họ tên',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFF475569)))),
                const SizedBox(width: 4),
                SizedBox(
                    width: 40,
                    child: Text('CC\n10%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11, color: const Color(0xFF475569), height: 1.2))),
                const SizedBox(width: 4),
                SizedBox(
                    width: 40,
                    child: Text('GK\n30%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11, color: const Color(0xFF475569), height: 1.2))),
                const SizedBox(width: 4),
                SizedBox(
                    width: 40,
                    child: Text('CK\n60%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11, color: const Color(0xFF475569), height: 1.2))),
                const SizedBox(width: 4),
                SizedBox(
                    width: 48,
                    child: Text('Tổng',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: _kPrimary))),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          ...kGrades.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            final total = _computeTotal(g);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text('${i + 1}',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g['name'],
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(g['mssv'],
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '${g['cc']}',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text('${g['gk']}',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text('${g['ck']}',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 48,
                        child: Column(
                          children: [
                            Text(
                              total.toStringAsFixed(1),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _gradeLabelColor(total),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: _gradeLabelColor(total).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _gradeLabel(total),
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  color: _gradeLabelColor(total),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < kGrades.length - 1)
                  const Divider(height: 1, indent: 24, thickness: 1, color: Color(0xFFF1F5F9)),
              ],
            );
          }),
          // Actions
          const Divider(height: 1, thickness: 1.5, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(context, 'Lưu điểm', const Color(0xFF6B4FA0), Icons.save_rounded),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionBtn(context, 'Khóa điểm', const Color(0xFF10B981), Icons.lock_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, Color color, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSnack(context, label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6B4FA0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
