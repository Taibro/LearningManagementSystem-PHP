import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart';
import 'add_class_screen.dart';
import 'announcement_screen.dart';
import 'update_schedule_screen.dart';
import 'backup_screen.dart';
import 'widgets/home/home_header.dart';
import 'widgets/home/system_stats_grid.dart';
import 'widgets/home/semester_progress_card.dart';
import 'widgets/home/pending_requests_card.dart';
import 'widgets/home/quick_actions_card.dart';
import 'widgets/home/activity_feed_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import '../../blocs/admin/dashboard/admin_dashboard_bloc.dart';
import '../../blocs/admin/dashboard/admin_dashboard_event.dart';
import '../../blocs/admin/dashboard/admin_dashboard_state.dart';
import '../../blocs/admin/request/admin_request_bloc.dart';
import '../../blocs/admin/request/admin_request_event.dart';
import '../../blocs/admin/request/admin_request_state.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static const _kBg = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardBloc>().add(const AdminDashboardFetchRequested());
    context.read<AdminRequestBloc>().add(const AdminRequestFetchPending());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AdminDashboardBloc>().add(const AdminDashboardFetchRequested());
                context.read<AdminRequestBloc>().add(const AdminRequestFetchPending());
                await Future.delayed(const Duration(seconds: 1));
              },
              color: const Color(0xFF1A237E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
                      builder: (context, state) {
                        if (state is AdminDashboardLoadSuccess) {
                          return SystemStatsGrid(stats: state.stats);
                        } else if (state is AdminDashboardLoadFailure) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                Text('Chưa thể tải dữ liệu thống kê\n${state.message}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
                              ]
                            ),
                          );
                        }
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CustomLoadingIndicator()));
                      },
                    ),
                    const SizedBox(height: 20),
                    const SemesterProgressCard(),
                    const SizedBox(height: 20),
                    BlocBuilder<AdminRequestBloc, AdminRequestState>(
                      builder: (context, state) {
                        if (state is AdminRequestLoadSuccess) {
                          return PendingRequestsCard(
                            requests: state.pendingRequests,
                            onAction: (action, id) {
                              if (action == 'Phê duyệt') {
                                context.read<AdminRequestBloc>().add(AdminRequestApprove(id));
                              } else {
                                context.read<AdminRequestBloc>().add(AdminRequestReject(id, 'Từ chối'));
                              }
                            },
                          );
                        } else if (state is AdminRequestLoadFailure) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                Text('Chưa thể tải danh sách yêu cầu\n${state.message}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
                              ]
                            ),
                          );
                        }
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CustomLoadingIndicator()));
                      },
                    ),
                    const SizedBox(height: 20),
                    QuickActionsCard(
                      onAction: _handleQuickAction,
                    ),
                    const SizedBox(height: 20),
                    const ActivityFeedCard(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'Thêm\nsinh viên':
        _navigate(const AddStudentScreen());
        break;
      case 'Thêm\ngiảng viên':
        _navigate(const AddTeacherScreen());
        break;
      case 'Thêm\nlớp học':
        _navigate(const AddClassScreen());
        break;
      case 'Thông\nbáo':
        _navigate(const AnnouncementScreen());
        break;
      case 'Cập nhật\nlịch':
        _navigate(const UpdateScheduleScreen());
        break;
      case 'Sao lưu\nDL':
        _navigate(const BackupScreen());
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chưa có màn hình cho: $action'),
          backgroundColor: const Color(0xFF1A237E),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
    }
  }
}