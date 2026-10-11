import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import '../../blocs/lecturer/profile/teacher_profile_bloc.dart';
import '../../blocs/lecturer/profile/teacher_profile_event.dart';
import '../../blocs/lecturer/profile/teacher_profile_state.dart';

const Color _kPrimary = Color(0xFF6B4FA0);
const Color _kBg = Color(0xFFF4F1F8);

class LecturerPersonalProfileScreen extends StatefulWidget {
  const LecturerPersonalProfileScreen({super.key});

  @override
  State<LecturerPersonalProfileScreen> createState() => _LecturerPersonalProfileScreenState();
}

class _LecturerPersonalProfileScreenState extends State<LecturerPersonalProfileScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<TeacherProfileBloc>();
    if (bloc.state is TeacherProfileInitial || bloc.state is TeacherProfileLoadFailure) {
      bloc.add(TeacherProfileFetchRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Hồ sơ cá nhân', icon: Icons.person_rounded),
          Expanded(
            child: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
              builder: (context, state) {
                if (state is TeacherProfileLoading || state is TeacherProfileInitial) {
                  return Center(child: CustomLoadingIndicator());
                } else if (state is TeacherProfileLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${state.message}',
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                } else if (state is TeacherProfileLoadSuccess) {
                  final profile = state.profile;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      children: [
                        _buildAvatarSection(profile).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 24),
                        _buildInfoCard(
                          title: 'Thông tin cá nhân',
                          icon: Icons.badge_rounded,
                          color: const Color(0xFF4F46E5),
                          items: [
                            _InfoItem('Họ và tên', profile.fullName ?? 'Chưa cập nhật'),
                            _InfoItem('Giới tính', profile.gender ?? 'Chưa cập nhật'),
                            _InfoItem('Ngày sinh', profile.dateOfBirth ?? 'Chưa cập nhật'),
                            _InfoItem('CCCD', profile.citizenIdNumber ?? 'Chưa cập nhật'),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'Thông tin công tác',
                          icon: Icons.work_rounded,
                          color: const Color(0xFF10B981),
                          items: [
                            _InfoItem('Mã giảng viên', profile.teacherCode ?? 'Chưa cập nhật'),
                            _InfoItem('Khoa / Bộ môn', profile.departmentName ?? 'Chưa cập nhật'),
                            _InfoItem('Học vị', profile.degree ?? 'Chưa cập nhật'),
                            _InfoItem('Chuyên môn', profile.specialization ?? 'Chưa cập nhật'),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'Thông tin liên hệ',
                          icon: Icons.contact_mail_rounded,
                          color: const Color(0xFFF59E0B),
                          items: [
                            _InfoItem('Email', profile.email ?? 'Chưa cập nhật'),
                            _InfoItem('Điện thoại', profile.phone ?? 'Chưa cập nhật'),
                            _InfoItem('Địa chỉ', profile.address ?? 'Chưa cập nhật'),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
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
    );
  }

  Widget _buildAvatarSection(dynamic profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6B4FA0), Color(0xFF8B6BBF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B4FA0).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const Icon(Icons.person_rounded, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName ?? 'Chưa cập nhật',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kPrimary.withOpacity(0.15)),
            ),
            child: Text(
              '${profile.degree ?? ''} · ${profile.specialization ?? ''}',
              style: const TextStyle(
                fontSize: 13,
                color: _kPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.departmentName ?? 'Chưa cập nhật',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF8FAFC)),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}
