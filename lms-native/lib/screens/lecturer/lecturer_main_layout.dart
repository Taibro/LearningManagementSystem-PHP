import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'lecturer_home_screen.dart';
import 'lecturer_schedule_screen.dart';
import 'lecturer_attendance_screen.dart';
import 'lecturer_profile_screen.dart';
import 'lecturer_chatbot_screen.dart';
import '../../core/widgets/draggable_chatbot_button.dart';
import '../../core/widgets/mascot_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/lecturer/profile/teacher_profile_bloc.dart';
import '../../blocs/lecturer/profile/teacher_profile_event.dart';
import '../../blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import '../../blocs/lecturer/statistic/teacher_statistic_event.dart';

class LecturerMainLayout extends StatefulWidget {
  const LecturerMainLayout({super.key});

  @override
  State<LecturerMainLayout> createState() => _LecturerMainLayoutState();
}

class _LecturerMainLayoutState extends State<LecturerMainLayout> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    context.read<TeacherProfileBloc>().add(TeacherProfileFetchRequested());
    context.read<TeacherStatisticBloc>().add(TeacherStatisticFetchRequested());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const LecturerHomeScreen(),
    const LecturerScheduleScreen(),
    const LecturerAttendanceScreen(initialTabIndex: 0),
    const LecturerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: _screens,
          ),
          DraggableChatbotButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LecturerChatbotScreen()),
              );
            },
            iconData: Icons.smart_toy_rounded,
            backgroundColor: const Color(0xFF2E7D32),
          ),
          const MascotWidget(
            lottieAsset: 'assets/lottie/lecturer.json',
            isMoving: false, // Giảng viên đứng im góc trái
          ),
        ],
      ),
      bottomNavigationBar: _buildFloatingBottomNavBar(),
    );
  }

  Widget _buildFloatingBottomNavBar() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Trang chủ'},
      {'icon': Icons.calendar_month_rounded, 'label': 'Lịch dạy'},
      {'icon': Icons.fact_check_rounded, 'label': 'Điểm danh'},
      {'icon': Icons.person_rounded, 'label': 'Cá nhân'},
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4FA0).withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isSelected = _selectedIndex == index;
                final primaryColor = const Color(0xFF6B4FA0);
                final inactiveColor = const Color(0xFF94A3B8);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedIndex != index) {
                        setState(() => _selectedIndex = index);
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutQuart,
                        );
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            padding: EdgeInsets.all(isSelected ? 6 : 0),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              items[index]['icon'] as IconData,
                              color: isSelected ? primaryColor : inactiveColor,
                              size: isSelected ? 24 : 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[index]['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? primaryColor : inactiveColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutExpo),
    );
  }
}