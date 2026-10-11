import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../../blocs/student/profile/profile_bloc.dart';
import '../../../../blocs/student/profile/profile_state.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          String name = 'Đang tải...';
          String mssv = 'Đang tải...';
          String? avatarUrl;

          if (state is ProfileLoadSuccess) {
            name = state.profile.fullName ?? 'Chưa cập nhật';
            mssv = 'MSSV: ${state.profile.studentCode ?? 'N/A'}';
            avatarUrl = state.profile.avatarUrl;
          } else if (state is ProfileLoadFailure) {
            name = 'Lỗi tải dữ liệu';
            mssv = '';
          }

          return Column(
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl, 
                              fit: BoxFit.cover, 
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_rounded, size: 50, color: Color(0xFFCBD5E1))
                            )
                          : const Icon(Icons.person_rounded, size: 50, color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 16),
              // Name + MSSV
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuart),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  mssv,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B), 
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuart),
            ],
          );
        },
      ),
    );
  }
}
