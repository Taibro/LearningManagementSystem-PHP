import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'widgets/shared/custom_app_bar.dart';
import 'widgets/shared/mesh_background.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/profile/profile_bloc.dart';
import '../../blocs/student/profile/profile_event.dart';
import '../../blocs/student/profile/profile_state.dart';
import 'package:learning_management_app/models/student/student_profile.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import 'package:intl/intl.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Thông tin sinh viên', paddingBottom: 10),
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return Center(child: CustomLoadingIndicator());
                  } else if (state is ProfileLoadFailure) {
                    return Center(child: Text('Lỗi: ${state.message}'));
                  } else if (state is ProfileLoadSuccess) {
                    final profile = state.profile;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          _buildAvatarSection(profile),
                          _buildInfoList(profile),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(StudentProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 110,
            height: 110,
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
                  blurRadius: 24,
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
                child: profile.avatarUrl != null
                    ? Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_rounded, size: 60, color: Color(0xFFCBD5E1))
                      )
                    : const Icon(Icons.person_rounded, size: 60, color: Color(0xFFCBD5E1)),
              ),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            profile.fullName ?? 'Chưa cập nhật',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuart),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              profile.studentCode ?? 'N/A',
              style: GoogleFonts.inter(
                color: const Color(0xFF4F46E5),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuart),
        ],
      ),
    );
  }

  Widget _buildInfoList(StudentProfile profile) {
    final dobFormat = profile.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(profile.dateOfBirth!) : 'Chưa cập nhật';
    final items = [
      _InfoItem('Trạng thái', 'Đang học', Icons.check_circle_rounded, const Color(0xFF22C55E)),
      _InfoItem('MSSV', profile.studentCode ?? 'N/A', Icons.badge_rounded, const Color(0xFF3B82F6)),
      _InfoItem('Khoa', profile.departmentName ?? 'N/A', Icons.account_balance_rounded, const Color(0xFF6366F1)),
      _InfoItem('Lớp', profile.className ?? 'N/A', Icons.class_rounded, const Color(0xFF8B5CF6)),
      _InfoItem('Bậc đào tạo', 'Đại học', Icons.school_rounded, const Color(0xFFEC4899)),
      _InfoItem('Loại hình', 'Chính quy', Icons.model_training_rounded, const Color(0xFFF43F5E)),
      _InfoItem('Khóa học', profile.enrollmentYear?.toString() ?? 'N/A', Icons.timeline_rounded, const Color(0xFFF97316)),
      _InfoItem('Ngành', profile.major ?? 'N/A', Icons.menu_book_rounded, const Color(0xFFEAB308)),
      _InfoItem('Ngày sinh', dobFormat, Icons.cake_rounded, const Color(0xFF14B8A6)),
      _InfoItem('Giới tính', profile.gender ?? 'N/A', Icons.person_search_rounded, const Color(0xFF06B6D4)),
      _InfoItem('Email', profile.email ?? 'N/A', Icons.email_rounded, const Color(0xFF3B82F6)),
      _InfoItem('Số điện thoại', profile.phone ?? 'N/A', Icons.phone_rounded, const Color(0xFF22C55E)),
      _InfoItem('Địa chỉ', profile.address ?? 'N/A', Icons.location_on_rounded, const Color(0xFFEF4444)),
      _InfoItem('CCCD', profile.citizenIdNumber ?? 'N/A', Icons.credit_card_rounded, const Color(0xFF64748B)),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 56,
              endIndent: 20,
              color: const Color(0xFFE2E8F0).withOpacity(0.5),
            ),
            itemBuilder: (_, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 20, color: item.iconColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  const _InfoItem(this.label, this.value, this.icon, this.iconColor);
}
