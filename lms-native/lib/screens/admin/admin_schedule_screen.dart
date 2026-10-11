import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/class/admin_class_bloc.dart';
import '../../blocs/admin/class/admin_class_event.dart';
import '../../blocs/admin/class/admin_class_state.dart';
import 'data/mock_admin_schedule_data.dart';
import 'widgets/schedule/class_list_tab.dart';
import 'widgets/schedule/weekly_view_tab.dart';
import 'widgets/schedule/rooms_tab.dart';
import 'widgets/schedule/bottom_sheets/class_form_sheet.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});
  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  static const _kPrimary = Color(0xFF3F51B5);
  static const _kBg = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    context.read<AdminClassBloc>().add(const AdminClassFetchRequested());
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
        _buildHeader(),
        _buildTabBar(),
        Expanded(
            child: TabBarView(
                controller: _tab,
                children: const [
              ClassListTab(),
              WeeklyViewTab(),
              RoomsTab(),
            ])),
      ]),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddClassSheet(),
          backgroundColor: _kPrimary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Thêm lịch',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_rounded, color: _kPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quản lý lịch học',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5)),
                Text('Học kỳ 2 · 2025-2026',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
          BlocBuilder<AdminClassBloc, AdminClassState>(
            builder: (context, state) {
              int count = 0;
              if (state is AdminClassLoadSuccess) {
                count = state.classes.length;
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('$count lớp',
                    style: const TextStyle(
                        color: _kPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
          Tab(text: 'Lớp học'),
          Tab(text: 'Lịch tuần'),
          Tab(text: 'Phòng học')
        ],
      ),
    );
  }

  void _showAddClassSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ClassFormSheet(existing: null),
    );
  }
}
