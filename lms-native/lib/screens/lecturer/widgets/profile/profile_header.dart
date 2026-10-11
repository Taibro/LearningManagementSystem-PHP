import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'bottom_sheets/edit_profile_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/lecturer/teacher_profile.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../blocs/lecturer/profile/teacher_profile_state.dart';
import '../../../../blocs/lecturer/profile/teacher_profile_bloc.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditProfileSheet(),
    );
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
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Icon(Icons.person, size: 48, color: Color(0xFF6B4FA0)),
                ),
              ),
            ],
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 20),
          Expanded(
            child: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
              builder: (context, state) {
                if (state is TeacherProfileLoading) {
                  return Center(child: CustomLoadingIndicator());
                } else if (state is TeacherProfileLoadSuccess) {
                  final profile = state.profile;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName ?? 'Chưa cập nhật',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 6),
                      Text(
                        'Mã GV: ${profile.teacherCode ?? ''}  ·  Khoa ${profile.departmentName ?? ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.degree ?? ''} · ${profile.specialization ?? ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),
                    ],
                  );
                }
                return const Text('Không thể tải dữ liệu', style: TextStyle(color: Colors.white));
              },
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEditProfile(context),
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ).animate().scale(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }
}
