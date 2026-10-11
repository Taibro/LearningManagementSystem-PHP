import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/shared/lecturer_custom_app_bar.dart';

class SalaryInfoScreen extends StatelessWidget {
  const SalaryInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Thông tin lương', icon: Icons.monetization_on_rounded),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Kỳ lương Tháng 5/2026',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('TỔNG THU NHẬP', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                        const SizedBox(height: 8),
                        const Text(
                          '15,450,000 đ',
                          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lương cơ bản', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 4),
                                  Text('8,000,000 đ', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Container(height: 30, width: 1, color: Colors.white24),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Phụ cấp', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 4),
                                  Text('2,000,000 đ', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Lương giờ chuẩn (40h)', '4,000,000 đ', Icons.access_time_rounded, false),
                        const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFF1F5F9)),
                        _buildDetailRow('Lương vượt giờ (12h)', '1,800,000 đ', Icons.speed_rounded, false),
                        const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFF1F5F9)),
                        _buildDetailRow('Khấu trừ thuế TNCN', '- 350,000 đ', Icons.receipt_long_rounded, true),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, bool isDeduction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDeduction ? const Color(0xFFEF4444) : const Color(0xFF6B4FA0)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDeduction ? const Color(0xFFEF4444) : const Color(0xFF6B4FA0), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDeduction ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
