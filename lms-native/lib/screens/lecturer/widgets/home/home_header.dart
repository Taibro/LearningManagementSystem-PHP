import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../blocs/lecturer/profile/teacher_profile_bloc.dart';
import '../../../../../blocs/lecturer/profile/teacher_profile_state.dart';
import '../../../../../blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import '../../../../../blocs/lecturer/statistic/teacher_statistic_state.dart';
import '../../../shared/shared_notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng,';
    if (hour < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6B4FA0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Icon(Icons.person, size: 36, color: Color(0xFF6B4FA0)),
                    ),
                  ),
                ],
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
                        builder: (context, state) {
                          String name = 'Đang tải...';
                          if (state is TeacherProfileLoadSuccess) {
                            name = '${state.profile.degree ?? ''} ${state.profile.fullName ?? ''}'.trim();
                          }
                          return Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildNotificationButton(context).animate().scale(duration: 400.ms, delay: 200.ms),
            ],
          ),
          const SizedBox(height: 24),
          _buildGlassStatsCard().animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SharedNotificationsScreen()),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444), // Red alert
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6B4FA0), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatsCard() {
    return BlocBuilder<TeacherStatisticBloc, TeacherStatisticState>(
      builder: (context, state) {
        String currentSemester = '...';
        String totalClasses = '...';
        String totalPeriods = '...';

        if (state is TeacherStatisticLoadSuccess) {
          final stats = state.statistic;
          currentSemester = stats.currentSemesterLabel ?? '...';
          totalClasses = '${stats.classDetails?.length ?? 0} Lớp';
          totalPeriods = '${stats.totalPeriods ?? 0} Tiết';
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildStatItem(currentSemester, 'Học kỳ', Icons.school_rounded)),
                  _buildDivider(),
                  Expanded(child: _buildStatItem(totalClasses, 'Phụ trách', Icons.groups_rounded)),
                  _buildDivider(),
                  Expanded(child: _buildStatItem(totalPeriods, 'Tổng số', Icons.timer_rounded)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
