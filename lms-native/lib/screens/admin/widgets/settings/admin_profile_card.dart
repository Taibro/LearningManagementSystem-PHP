import 'package:flutter/material.dart';
import 'settings_helpers.dart';
import 'bottom_sheets/edit_profile_sheet.dart';

class AdminProfileCard extends StatelessWidget {
  const AdminProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1A237E);
    return buildSettingsCard(
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
          ),
          child: const Center(
              child: Text('AD',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
        ),
        const SizedBox(width: 14),
        const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Quản trị viên',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF212121))),
              SizedBox(height: 3),
              Text('admin@huit.edu.vn',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              SizedBox(height: 3),
              Text('Trường ĐH Công nghiệp TP.HCM',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            ])),
        GestureDetector(
          onTap: () => _showEditProfile(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: kPrimary, borderRadius: BorderRadius.circular(20)),
            child: const Text('Chỉnh sửa',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditProfileSheet(),
    );
  }
}
