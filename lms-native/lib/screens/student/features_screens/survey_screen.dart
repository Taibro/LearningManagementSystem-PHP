import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../widgets/shared/custom_app_bar.dart';
import '../widgets/shared/mesh_background.dart';
import '../data/mock_features_data.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Khảo sát', isGradient: true),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                itemCount: kSurveyList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  return _SurveyCard(survey: kSurveyList[i])
                      .animate()
                      .fade(duration: 400.ms, delay: (100 * i).ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  final SurveyItem survey;

  const _SurveyCard({required this.survey});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: Navigate to survey detail
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            survey.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: survey.isCompleted 
                                ? const Color(0xFF10B981).withOpacity(0.15) 
                                : const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            survey.isCompleted ? 'Đã tham gia' : 'Chờ thực hiện',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: survey.isCompleted ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.event_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Hạn chót: ${survey.deadline}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        if (!survey.isCompleted)
                          Icon(Icons.arrow_forward_rounded, size: 20, color: const Color(0xFF4F46E5).withOpacity(0.8))
                              .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
                              .slideX(begin: -0.2, end: 0.2, duration: 800.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
