import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:learning_management_app/core/network/fcm_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learning_management_app/repositories/admin_repository.dart';

import 'package:learning_management_app/screens/auth/school_code_screen.dart';
import 'package:learning_management_app/screens/student/attendance_screen.dart';
import 'package:learning_management_app/screens/student/home_screen.dart';
import 'package:learning_management_app/screens/student/profile_screen.dart';
import 'package:learning_management_app/screens/student/schedule_screen.dart';
import 'package:learning_management_app/core/globals.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_app/core/network/dio_client.dart';
import 'package:learning_management_app/repositories/auth_repository.dart';
import 'package:learning_management_app/repositories/student_repository.dart';
import 'package:learning_management_app/blocs/auth/auth_bloc.dart';
import 'package:learning_management_app/blocs/student/profile/profile_bloc.dart';
import 'package:learning_management_app/blocs/student/schedule/schedule_bloc.dart';
import 'package:learning_management_app/blocs/student/grade/grade_bloc.dart';
import 'package:learning_management_app/blocs/student/attendance/attendance_bloc.dart';

import 'package:learning_management_app/repositories/teacher_repository.dart';
import 'package:learning_management_app/blocs/lecturer/profile/teacher_profile_bloc.dart';
import 'package:learning_management_app/blocs/lecturer/salary/teacher_salary_bloc.dart';
import 'package:learning_management_app/blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import 'package:learning_management_app/blocs/lecturer/material/teacher_material_bloc.dart';
import 'package:learning_management_app/blocs/lecturer/attendance/teacher_attendance_bloc.dart';
import 'package:learning_management_app/blocs/lecturer/request/teacher_request_bloc.dart';

import 'package:learning_management_app/repositories/school_admin_repository.dart';
import 'package:learning_management_app/blocs/admin/dashboard/admin_dashboard_bloc.dart';
import 'package:learning_management_app/blocs/admin/request/admin_request_bloc.dart';
import 'package:learning_management_app/blocs/admin/notification/admin_notification_bloc.dart';
import 'package:learning_management_app/blocs/admin/user_management/admin_user_management_bloc.dart';
import 'package:learning_management_app/blocs/admin/class/admin_class_bloc.dart';
import 'package:learning_management_app/blocs/admin/users/admin_users_bloc.dart';
import 'package:learning_management_app/blocs/admin/reports/admin_reports_bloc.dart';
import 'package:learning_management_app/blocs/admin/settings/admin_semester_bloc.dart';
import 'package:learning_management_app/blocs/admin/settings/room/admin_room_bloc.dart';

import 'package:learning_management_app/core/utils/feature_manager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await dotenv.load(fileName: ".env");
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DioClient()),
        RepositoryProvider(create: (context) => AuthRepository(context.read<DioClient>())),
        RepositoryProvider(create: (context) => StudentRepository(context.read<DioClient>())),
        RepositoryProvider(create: (context) => TeacherRepository(context.read<DioClient>().dio)),
        RepositoryProvider(create: (context) => SchoolAdminRepository(context.read<DioClient>().dio)),
        RepositoryProvider(create: (context) => AdminRepository(context.read<DioClient>().dio)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(context.read<AuthRepository>())),
          BlocProvider(create: (context) => ProfileBloc(context.read<StudentRepository>())),
          BlocProvider(create: (context) => ScheduleBloc(context.read<StudentRepository>())),
          BlocProvider(create: (context) => GradeBloc(context.read<StudentRepository>())),
          BlocProvider(create: (context) => AttendanceBloc(context.read<StudentRepository>())),
          // Lecturer Blocs
          BlocProvider(create: (context) => TeacherProfileBloc(context.read<TeacherRepository>())),
          BlocProvider(create: (context) => TeacherSalaryBloc(context.read<TeacherRepository>())),
          BlocProvider(create: (context) => TeacherStatisticBloc(context.read<TeacherRepository>())),
          BlocProvider(create: (context) => TeacherMaterialBloc(repository: context.read<TeacherRepository>())),
          BlocProvider(create: (context) => TeacherAttendanceBloc(context.read<TeacherRepository>())),
          BlocProvider(create: (context) => TeacherRequestBloc(repository: context.read<TeacherRepository>())),
          // Admin Blocs
          BlocProvider(create: (context) => AdminDashboardBloc(context.read<SchoolAdminRepository>())),
          BlocProvider(create: (context) => AdminRequestBloc(context.read<SchoolAdminRepository>())),
          BlocProvider(create: (context) => AdminNotificationBloc(context.read<SchoolAdminRepository>())),
          BlocProvider(create: (context) => AdminUserManagementBloc(context.read<SchoolAdminRepository>())),
          BlocProvider(create: (context) => AdminClassBloc(context.read<AdminRepository>())),
          BlocProvider(create: (context) => AdminUsersBloc(context.read<AdminRepository>())),
          BlocProvider(create: (context) => AdminReportsBloc(context.read<AdminRepository>())),
          BlocProvider(create: (context) => AdminSemesterBloc(context.read<SchoolAdminRepository>())),
          BlocProvider(create: (context) => AdminRoomBloc(context.read<SchoolAdminRepository>())),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Learning Management System',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
            useMaterial3: true,
          ),
          home: const SchoolCodeScreen(),
        ),
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Danh sách các màn hình sẽ được tráo đổi
  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const AttendanceScreen(), // Tạo tạm một màn hình rỗng nếu chưa có
    const ProfileScreen(),    // Tạo tạm một màn hình rỗng nếu chưa có
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Cho phép nội dung tràn xuống dưới thanh điều hướng
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Comment this out if you want swipe-to-change
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: _screens,
      ), 
      bottomNavigationBar: _buildFloatingBottomNavBar(),
    );
  }

  Widget _buildFloatingBottomNavBar() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Trang chủ'},
      {'icon': Icons.calendar_month_rounded, 'label': 'Lịch học'},
      {'icon': Icons.fact_check_rounded, 'label': 'Điểm danh'},
      {'icon': Icons.person_rounded, 'label': 'Cá nhân'},
    ];
 
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(216), // 0.85 * 255 = ~216
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withAlpha(38), // 0.15 * 255 = ~38
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isSelected = _selectedIndex == index;
                final primaryColor = const Color(0xFF4F46E5);
                final inactiveColor = const Color(0xFF94A3B8);

                return GestureDetector(
                  onTap: () {
                    if (_selectedIndex != index) {
                      setState(() => _selectedIndex = index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuart,
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 75,
                    color: Colors.transparent, // expanded touch area
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          padding: EdgeInsets.all(isSelected ? 6 : 2),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor.withAlpha(25) : Colors.transparent, // 0.1 * 255 = 25
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            items[index]['icon'] as IconData,
                            color: isSelected ? primaryColor : inactiveColor,
                            size: isSelected ? 24 : 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: GoogleFonts.inter(
                            fontSize: isSelected ? 11 : 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? primaryColor : inactiveColor,
                          ),
                          child: Text(
                            items[index]['label'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutExpo),
    );
  }
}