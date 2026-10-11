import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/reports/admin_reports_bloc.dart';
import '../../blocs/admin/reports/admin_reports_event.dart';
import 'widgets/reports/reports_header_and_filter.dart';
import 'widgets/reports/attendance_tab.dart';
import 'widgets/reports/grades_tab.dart';
import 'widgets/reports/teaching_tab.dart';
import 'widgets/reports/requests_tab.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  static const _kPrimary = Color(0xFF3F51B5);
  static const _kBg = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    context.read<AdminReportsBloc>().add(const AdminReportsFetchRequested());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        ReportsHeaderAndFilter(
          onExport: () => _snack('Xuất báo cáo tổng hợp'),
        ),
        _buildTabBar(),
        Expanded(
            child: TabBarView(controller: _tab, children: const [
          AttendanceTab(),
          GradesTab(),
          TeachingTab(),
          RequestsTab(),
        ])),
      ]),
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
            color: _kPrimary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tab,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(24),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Inter'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Inter'),
        tabs: const [
          Tab(text: 'Điểm danh'),
          Tab(text: 'Kết quả HT'),
          Tab(text: 'Giảng dạy'),
          Tab(text: 'Đề xuất')
        ],
      ),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: _kPrimary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2)),
      );
}
