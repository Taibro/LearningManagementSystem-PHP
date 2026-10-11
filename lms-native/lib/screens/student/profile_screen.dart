import 'package:flutter/material.dart';
import 'widgets/profile/profile_header.dart';
import 'widgets/profile/profile_menu_card.dart';
import 'widgets/shared/mesh_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/profile/profile_bloc.dart';
import '../../blocs/student/profile/profile_event.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
            const ProfileHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120), // Padding to account for floating nav bar
                child: Column(
                  children: const [
                    SizedBox(height: 16),
                    ProfileMenuCard(),
                    SizedBox(height: 32),
                    Text(
                      'Phiên bản 1.4.8',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
