import 'package:flutter/material.dart';
import 'widgets/attendance/manual_attendance_tab.dart';
import 'widgets/attendance/qr_attendance_tab.dart';
import 'widgets/attendance/grades_tab.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

class LecturerAttendanceScreen extends StatefulWidget {
  final int initialTabIndex;
  const LecturerAttendanceScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LecturerAttendanceScreen> createState() =>
      _LecturerAttendanceScreenState();
}

class _LecturerAttendanceScreenState extends State<LecturerAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
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
            title: 'Quản lý điểm danh',
            icon: Icons.how_to_reg_rounded,
          ),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ManualAttendanceTab(),
                QrAttendanceTab(),
                GradesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF6B4FA0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4FA0).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Inter'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Inter'),
        tabs: const [
          Tab(text: 'Điểm danh'),
          Tab(text: 'QR Code'),
          Tab(text: 'Kết quả'),
        ],
      ),
    );
  }
}