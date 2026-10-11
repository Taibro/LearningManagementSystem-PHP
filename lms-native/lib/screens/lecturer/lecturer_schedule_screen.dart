import 'package:flutter/material.dart';
import 'widgets/schedule/weekly_tab.dart';
import 'widgets/schedule/progress_tab.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

class LecturerScheduleScreen extends StatefulWidget {
  const LecturerScheduleScreen({super.key});

  @override
  State<LecturerScheduleScreen> createState() => _LecturerScheduleScreenState();
}

class _LecturerScheduleScreenState extends State<LecturerScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const LecturerCustomAppBar(
            title: 'Lịch giảng dạy',
            icon: Icons.calendar_today_rounded,
          ),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                WeeklyTab(),
                ProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6B4FA0),
          indicatorWeight: 3,
          labelColor: const Color(0xFF6B4FA0),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'Lịch theo tuần'),
            Tab(text: 'Tiến độ giảng dạy'),
          ],
        ),
      ),
    );
  }
}