import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'admin_home_screen.dart';
import 'admin_schedule_screen.dart';
import 'admin_users_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_chatbot_screen.dart';
import '../../core/widgets/draggable_chatbot_button.dart';
import 'widgets/shared/admin_animated_background.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const AdminScheduleScreen(),
    const AdminUsersScreen(),
    const AdminReportsScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AdminAnimatedBackground(),
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
                MaterialPageRoute(builder: (_) => const AdminChatbotScreen()),
              );
            },
            iconData: Icons.smart_toy_rounded,
            backgroundColor: const Color(0xFFC62828),
          ),
        ],
      ),
      bottomNavigationBar: _buildFloatingBottomNavBar(),
    );
  }

  Widget _buildFloatingBottomNavBar() {
    final items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.calendar_month_rounded, 'label': 'Lịch học'},
      {'icon': Icons.manage_accounts_rounded, 'label': 'Quản lý'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Báo cáo'},
      {'icon': Icons.settings_rounded, 'label': 'Cài đặt'},
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F51B5).withOpacity(0.15),
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
                final primaryColor = const Color(0xFF3F51B5);
                final inactiveColor = const Color(0xFF94A3B8);

                return GestureDetector(
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
                    width: 60,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
