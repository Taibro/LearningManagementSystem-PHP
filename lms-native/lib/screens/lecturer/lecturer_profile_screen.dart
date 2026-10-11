import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/profile/profile_header.dart';
import 'widgets/profile/semester_card.dart';
import 'widgets/profile/main_menu_card.dart';
import 'widgets/profile/request_menu_card.dart';
import 'widgets/profile/settings_card.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/lecturer/profile/teacher_profile_bloc.dart';
import '../../blocs/lecturer/profile/teacher_profile_event.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherProfileBloc>().add(TeacherProfileFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const SemesterCard().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  const MainMenuCard().animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  const RequestMenuCard().animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  const SettingsCard().animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  const Text(
                    'HUIT E-Office · Phiên bản 2.1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}