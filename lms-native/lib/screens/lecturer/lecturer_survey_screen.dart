import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

const Color _kPrimary = Color(0xFF6B4FA0);
const Color _kBg = Color(0xFFF4F1F8);

class LecturerSurveyScreen extends StatelessWidget {
  const LecturerSurveyScreen({super.key});

  final List<Map<String, dynamic>> _surveys = const [
    {
      'subject': 'Kiến trúc máy tính',
      'class': '16DHTH10',
      'semester': 'HK2 2025-2026',
      'responses': 42,
      'total': 50,
      'rating': 4.5,
      'status': 'completed',
    },
    {
      'subject': 'TH Quản trị HT Mạng',
      'class': '14DHTH40',
      'semester': 'HK2 2025-2026',
      'responses': 28,
      'total': 45,
      'rating': 4.2,
      'status': 'active',
    },
    {
      'subject': 'Lập trình mạng',
      'class': '14DHTH04',
      'semester': 'HK2 2025-2026',
      'responses': 0,
      'total': 48,
      'rating': 0.0,
      'status': 'pending',
    },
    {
      'subject': 'An ninh mạng',
      'class': '16DHTH07',
      'semester': 'HK1 2025-2026',
      'responses': 38,
      'total': 40,
      'rating': 4.7,
      'status': 'completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Khảo sát', icon: Icons.poll_rounded),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCards().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  const Text(
                    'Khảo sát theo môn học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 16),
                  ..._surveys.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSurveyCard(entry.value)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (150 + 50 * entry.key).ms)
                            .slideY(begin: 0.1, end: 0),
                      )),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final completedCount = _surveys.where((s) => s['status'] == 'completed').length;
    final activeCount = _surveys.where((s) => s['status'] == 'active').length;
    final avgRating = _surveys
        .where((s) => (s['rating'] as double) > 0)
        .map((s) => s['rating'] as double)
        .fold<double>(0, (a, b) => a + b);
    final ratedCount = _surveys.where((s) => (s['rating'] as double) > 0).length;
    final avg = ratedCount > 0 ? (avgRating / ratedCount) : 0.0;

    final cards = [
      {'value': '$completedCount', 'label': 'Hoàn thành', 'color': const Color(0xFF10B981)},
      {'value': '$activeCount', 'label': 'Đang diễn ra', 'color': const Color(0xFFF59E0B)},
      {'value': avg.toStringAsFixed(1), 'label': 'Điểm TB', 'color': _kPrimary},
    ];

    return Row(
      children: cards.map((c) {
        final color = c['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  c['value'] as String,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c['label'] as String,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSurveyCard(Map<String, dynamic> survey) {
    Color statusColor;
    String statusLabel;
    switch (survey['status']) {
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Hoàn thành';
        break;
      case 'active':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Đang diễn ra';
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusLabel = 'Chưa bắt đầu';
    }

    final responses = survey['responses'] as int;
    final total = survey['total'] as int;
    final ratio = total > 0 ? responses / total : 0.0;
    final rating = survey['rating'] as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey['subject'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${survey['class']}  ·  ${survey['semester']}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              const Text('Phản hồi:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$responses/$total',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          if (rating > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (i) {
                    if (i < rating.floor()) {
                      return const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22);
                    } else if (i < rating.ceil() && rating % 1 > 0) {
                      return const Icon(Icons.star_half_rounded, color: Color(0xFFF59E0B), size: 22);
                    } else {
                      return Icon(Icons.star_outline_rounded, color: Colors.grey.shade300, size: 22);
                    }
                  }),
                  const SizedBox(width: 12),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
