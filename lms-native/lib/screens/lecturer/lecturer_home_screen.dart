import 'package:flutter/material.dart';
import 'widgets/home/home_header.dart';
import 'widgets/home/stats_row.dart';
import 'widgets/home/today_classes.dart';
import 'widgets/home/function_grid.dart';
import 'widgets/home/recent_notifications.dart';

class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({super.key});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) {
                  setState(() {});
                }
              },
              color: const Color(0xFF6A1B9A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    StatsRow(),
                    SizedBox(height: 20),
                    TodayClasses(),
                    SizedBox(height: 20),
                    FunctionGrid(),
                    SizedBox(height: 20),
                    RecentNotifications(),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}