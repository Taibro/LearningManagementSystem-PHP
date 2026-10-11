import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/student_repository.dart';
import '../../../models/student/student_schedule.dart';

class CurrentClassCard extends StatefulWidget {
  const CurrentClassCard({super.key});

  @override
  State<CurrentClassCard> createState() => _CurrentClassCardState();
}

class _CurrentClassCardState extends State<CurrentClassCard> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  List<StudentSchedule> _todayClasses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTodayClasses();
  }

  Future<void> _fetchTodayClasses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final repo = context.read<StudentRepository>();
      final schedules = await repo.getWeeklySchedule();
      
      final today = DateTime.now();
      // Lọc các môn học của ngày hôm nay
      final todaySchedules = schedules.where((s) {
        // Kiểm tra lịch học bù/nghỉ
        if (s.exceptionType == 'CANCEL' && 
            s.exceptionDate != null && 
            s.exceptionDate!.year == today.year && 
            s.exceptionDate!.month == today.month && 
            s.exceptionDate!.day == today.day) {
          return false; // Bị hủy hôm nay
        }
        
        // Học bù hôm nay
        if (s.replacementDate != null && 
            s.replacementDate!.year == today.year && 
            s.replacementDate!.month == today.month && 
            s.replacementDate!.day == today.day) {
          return true;
        }

        // Lịch học chính thức hôm nay
        int javaDay = today.weekday; // 1 = Mon, 7 = Sun
        int dbDayOfWeek = javaDay == 7 ? 8 : javaDay + 1;
        return s.dayOfWeek == dbDayOfWeek;
      }).toList();

      // Sắp xếp theo tiết bắt đầu
      todaySchedules.sort((a, b) => (a.startPeriod ?? 0).compareTo(b.startPeriod ?? 0));

      setState(() {
        _todayClasses = todaySchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getStatus(StudentSchedule cls) {
    final now = DateTime.now();
    if (cls.startTime == null || cls.endTime == null) return 'Hôm nay';
    
    try {
      final startTimeParts = cls.startTime!.split(':');
      final endTimeParts = cls.endTime!.split(':');
      final start = DateTime(now.year, now.month, now.day, int.parse(startTimeParts[0]), int.parse(startTimeParts[1]));
      final end = DateTime(now.year, now.month, now.day, int.parse(endTimeParts[0]), int.parse(endTimeParts[1]));

      if (now.isAfter(start) && now.isBefore(end)) return 'Đang diễn ra';
      if (now.isBefore(start)) return 'Sắp diễn ra';
      return 'Đã kết thúc';
    } catch (e) {
      return 'Hôm nay';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 145,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SizedBox(
        height: 145,
        child: Center(
          child: Text('Lỗi: $_errorMessage', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_todayClasses.isEmpty) {
      return Container(
        height: 145,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
              const SizedBox(height: 8),
              Text(
                'Hôm nay bạn không có lịch học',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 145, // Fixed height for the card
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _todayClasses.length,
            itemBuilder: (context, index) {
              return _buildCard(_todayClasses[index]);
            },
          ),
        ),
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
    );
  }

  Widget _buildCard(StudentSchedule cls) {
    final status = _getStatus(cls);
    final isOnline = (cls.roomName?.toLowerCase().contains('meet') ?? false) || 
                     (cls.roomName?.toLowerCase().contains('zoom') ?? false);
    final roomDisplay = cls.roomName ?? 'Chưa xếp phòng';
    final subjectDisplay = cls.courseName ?? 'Môn học';
    
    // Format time
    String timeDisplay = '';
    if (cls.startPeriod != null && cls.endPeriod != null) {
      timeDisplay = 'Tiết ${cls.startPeriod} - ${cls.endPeriod}';
      if (cls.startTime != null && cls.endTime != null) {
        // cắt giây nếu có (07:00:00 -> 07:00)
        final st = cls.startTime!.length > 5 ? cls.startTime!.substring(0, 5) : cls.startTime;
        final et = cls.endTime!.length > 5 ? cls.endTime!.substring(0, 5) : cls.endTime;
        timeDisplay += ' ($st - $et)';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2), // Small gap between pages
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.06),
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
                  colors: [const Color(0xFF0EA5E9).withOpacity(0.1), Colors.transparent],
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
                    gradient: LinearGradient(
                      colors: isOnline 
                        ? [const Color(0xFFFFE4E6), const Color(0xFFFFF1F2)]
                        : [const Color(0xFFE0E7FF), const Color(0xFFF1F5F9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isOnline ? const Color(0xFFE85D75) : const Color(0xFF4F46E5)).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isOnline ? Icons.video_call_rounded : Icons.school_rounded,
                    size: 28,
                    color: isOnline ? const Color(0xFFE85D75) : const Color(0xFF4F46E5),
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
                          color: status == 'Đang diễn ra' ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$status • $roomDisplay',
                          style: GoogleFonts.inter(
                            color: status == 'Đang diễn ra' ? const Color(0xFFEF4444) : const Color(0xFF475569),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subjectDisplay,
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
                              timeDisplay,
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
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
