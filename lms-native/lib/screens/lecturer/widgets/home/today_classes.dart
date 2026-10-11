import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/teacher_repository.dart';
import '../../../../models/lecturer/teacher_schedule.dart';

class TodayClasses extends StatefulWidget {
  const TodayClasses({super.key});

  @override
  State<TodayClasses> createState() => _TodayClassesState();
}

class _TodayClassesState extends State<TodayClasses> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  List<TeacherSchedule> _todayClasses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodayClasses();
  }

  Future<void> _fetchTodayClasses() async {
    try {
      final repo = context.read<TeacherRepository>();
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final schedules = await repo.getWeeklySchedule(date: todayStr);
      
      final currentJavaDay = now.weekday; // 1 = Monday, 7 = Sunday
      final targetDay = currentJavaDay == 7 ? 8 : currentJavaDay + 1;

      final filtered = schedules.where((s) => s.dayOfWeek == targetDay).toList();
      
      if (mounted) {
        setState(() {
          _todayClasses = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 146,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))),
      );
    }
    
    if (_todayClasses.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final dateStr = "Thứ ${now.weekday == 7 ? 'CN' : now.weekday + 1}, ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: const Text(
                'Lịch dạy hôm nay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
            ),
            const SizedBox(width: 8),
            Text(
              dateStr,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 146,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _todayClasses.length,
            itemBuilder: (context, index) {
              final cls = _todayClasses[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildClassCard(cls, index),
              );
            },
          ),
        ),
        if (_todayClasses.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _todayClasses.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildClassCard(TeacherSchedule cls, int index) {
    Color accentColor;
    Color bgColor;
    Color iconBgColor;
    IconData typeIcon;
    String typeLabel;

    switch (cls.sessionType) {
      case 'TH':
        accentColor = const Color(0xFF0EA5E9);
        bgColor = const Color(0xFFF0F9FF);
        iconBgColor = const Color(0xFFE0F2FE);
        typeIcon = Icons.computer_outlined;
        typeLabel = 'Thực hành';
        break;
      case 'ONL':
        accentColor = const Color(0xFFE85D75);
        bgColor = const Color(0xFFFFF1F2);
        iconBgColor = const Color(0xFFFFE4E6);
        typeIcon = Icons.video_call_outlined;
        typeLabel = 'Trực tuyến';
        break;
      default:
        accentColor = const Color(0xFF4F46E5);
        bgColor = const Color(0xFFEEF2FF);
        iconBgColor = const Color(0xFFE0E7FF);
        typeIcon = Icons.school_rounded;
        typeLabel = 'Lý thuyết';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          // Subtle background gradient element
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [accentColor.withOpacity(0.08), Colors.transparent],
                  center: Alignment.bottomRight,
                  radius: 1.0,
                ),
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    typeIcon,
                    size: 28,
                    color: accentColor,
                  ),
                ).animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
                 .moveY(begin: -2, end: 2, duration: 2.seconds, curve: Curves.easeInOut),
                 
                const SizedBox(width: 14),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$typeLabel • ${cls.roomName ?? ''}',
                          style: GoogleFonts.inter(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cls.courseName ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Ca ${cls.startPeriod} - ${cls.endPeriod} (${cls.startTime} - ${cls.endTime})',
                              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                // Go Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _todayClasses.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 14,
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
}
