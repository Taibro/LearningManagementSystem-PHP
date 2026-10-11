import 'package:flutter/material.dart';
import '../../../shared/shared_notifications_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../blocs/admin/dashboard/admin_dashboard_bloc.dart';
import '../../../../blocs/admin/dashboard/admin_dashboard_state.dart';
import '../../../../blocs/admin/request/admin_request_bloc.dart';
import '../../../../blocs/admin/request/admin_request_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  static const _kPrimary = Color(0xFF3F51B5);
  static const _kAccent  = Color(0xFF283593);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B6E), _kPrimary, _kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                  ),
                ),
                child: const Center(
                  child: Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Xin chào, Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
                      builder: (context, state) {
                        String schoolName = 'Trường chưa cập nhật';
                        if (state is AdminDashboardLoadSuccess) {
                          schoolName = state.stats.schoolName ?? 'HUIT';
                        }
                        return Text('Quản trị hệ thống · $schoolName', style: const TextStyle(color: Colors.white60, fontSize: 12));
                      },
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SharedNotificationsScreen()),
                  );
                },
                child: Stack(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                  ),
                  Positioned(right: 6, top: 6,
                    child: Container(width: 9, height: 9,
                      decoration: const BoxDecoration(color: Color(0xFFE85D75), shape: BoxShape.circle)),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _hStat('HK2 2025-2026', 'Học kỳ'),
                _hDiv(),
                BlocBuilder<AdminRequestBloc, AdminRequestState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is AdminRequestLoadSuccess) {
                      count = state.pendingRequests.length;
                    }
                    return _hStat('$count chờ duyệt', 'Đề xuất');
                  },
                ),
                _hDiv(),
                _hStat(
                  DateFormat('EEEE, dd/MM', 'vi_VN').format(DateTime.now()),
                  'Hôm nay'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hStat(String v, String l) => Column(children: [
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]);
  
  Widget _hDiv() => Container(width: 1, height: 28, color: Colors.white24);
}
