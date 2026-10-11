import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/shared/custom_app_bar.dart';
import '../widgets/shared/mesh_background.dart';
import 'package:learning_management_app/models/student/student_conduct.dart';
import 'package:learning_management_app/repositories/student_repository.dart';
import 'package:learning_management_app/core/widgets/custom_loading_indicator.dart';

class ConductScreen extends StatefulWidget {
  const ConductScreen({super.key});

  @override
  State<ConductScreen> createState() => _ConductScreenState();
}

class _ConductScreenState extends State<ConductScreen> {
  int _selectedIndex = 0;
  Future<List<StudentConduct>>? _conductFuture;

  @override
  void initState() {
    super.initState();
    _conductFuture = context.read<StudentRepository>().getConduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Điểm Rèn luyện', isGradient: true),
            
            Expanded(
              child: FutureBuilder<List<StudentConduct>>(
                future: _conductFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  
                  final conductList = snapshot.data ?? [];
                  if (conductList.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu điểm rèn luyện'));
                  }
                  
                  final currentConduct = conductList[_selectedIndex];

                  return Column(
                    children: [
                      // Semester Selector
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: conductList.length,
                          itemBuilder: (context, i) {
                            final isSelected = i == _selectedIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF4F46E5) : Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ] : [],
                                ),
                                child: Center(
                                  child: Text(
                                    conductList[i].semesterName ?? 'Không xác định',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate().fade(duration: 400.ms).slideX(begin: 0.1, end: 0),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Score Circle
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: (currentConduct.conductScore ?? 0) / 100,
                              strokeWidth: 16,
                              backgroundColor: const Color(0xFFE2E8F0),
                              color: const Color(0xFF10B981),
                              strokeCap: StrokeCap.round,
                            ),
                          ).animate(key: ValueKey(_selectedIndex)).scale(duration: 800.ms, curve: Curves.easeOutBack),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${currentConduct.conductScore ?? 0}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ).animate(key: ValueKey(_selectedIndex)).fade(duration: 600.ms).slideY(begin: 0.2, end: 0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentConduct.conductGrade ?? 'Chưa xét',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ).animate(key: ValueKey('c_$_selectedIndex')).fade(delay: 200.ms),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade().slideY(begin: -0.1, end: 0),

                    const SizedBox(height: 32),

                    // Details List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: [
                              _buildDetailRow('Điểm trung bình (GPA)', currentConduct.gpa ?? 0.0, 4.0),
                              Divider(color: Colors.grey.shade200, height: 24),
                              _buildDetailRow('Tín chỉ tích lũy', (currentConduct.creditsEarned ?? 0).toDouble(), 150.0),
                              if (currentConduct.scholarshipName != null && currentConduct.scholarshipName!.isNotEmpty) ...[
                                Divider(color: Colors.grey.shade200, height: 24),
                                _buildDetailText('Học bổng', currentConduct.scholarshipName!),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, double achieved, double maxScore) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4F46E5), size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (achieved / maxScore).clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: const Color(0xFF4F46E5),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        RichText(
          text: TextSpan(
            text: achieved.toStringAsFixed(achieved.truncateToDouble() == achieved ? 0 : 2),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
            children: [
              TextSpan(
                text: '/${maxScore.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailText(String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.stars_rounded, color: Color(0xFF10B981), size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
