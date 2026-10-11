import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/notification/admin_notification_bloc.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import '../../blocs/admin/notification/admin_notification_event.dart';
import '../../blocs/admin/notification/admin_notification_state.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  String _selectedAudience = 'Tất cả';
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminNotificationBloc>().add(const AdminNotificationFetchAll());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminNotificationBloc, AdminNotificationState>(
      listener: (context, state) {
        if (state is AdminNotificationActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: _kPrimary,
          ));
          _titleCtrl.clear();
          _contentCtrl.clear();
        } else if (state is AdminNotificationActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: _kBg,
        body: Column(children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildComposeCard(),
                const SizedBox(height: 20),
                _buildHistoryCard(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B6E), _kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16, right: 16, bottom: 16,
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.campaign_outlined, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        const Text('Thông báo',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        BlocBuilder<AdminNotificationBloc, AdminNotificationState>(
          builder: (context, state) {
            int count = 0;
            if (state is AdminNotificationLoadSuccess) {
              count = state.notifications.length;
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count thông báo',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildComposeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.edit_note_rounded, color: _kPrimary, size: 18),
          const SizedBox(width: 8),
          const Text('Tạo thông báo mới', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        ]),
        const SizedBox(height: 14),
        // Title
        const Text('Tiêu đề', style: TextStyle(fontSize: 12, color: Color(0xFF616161), fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            hintText: 'Nhập tiêu đề thông báo...',
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9F9FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0D8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0D8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        // Audience
        const Text('Đối tượng nhận', style: TextStyle(fontSize: 12, color: Color(0xFF616161), fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Row(children: [
          _audienceChip('Tất cả'),
          const SizedBox(width: 8),
          _audienceChip('Sinh viên'),
          const SizedBox(width: 8),
          _audienceChip('Giảng viên'),
        ]),
        const SizedBox(height: 12),
        // Content
        const Text('Nội dung', style: TextStyle(fontSize: 12, color: Color(0xFF616161), fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _contentCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung thông báo...',
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9F9FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0D8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0D8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) return;
            
            String apiType = 'SYSTEM';
            if (_selectedAudience == 'Sinh viên') apiType = 'STUDENT';
            if (_selectedAudience == 'Giảng viên') apiType = 'TEACHER';

            context.read<AdminNotificationBloc>().add(AdminNotificationCreate({
              'title': _titleCtrl.text,
              'body': _contentCtrl.text,
              'type': apiType,
            }));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D1B6E), _kPrimary]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.send_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Gửi thông báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _audienceChip(String label) {
    final selected = _selectedAudience == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedAudience = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _kPrimary : const Color(0xFFE0D8F0)),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : const Color(0xFF424242),
              fontWeight: FontWeight.w500,
            )),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return BlocBuilder<AdminNotificationBloc, AdminNotificationState>(
      builder: (context, state) {
        if (state is AdminNotificationLoading) {
          return Center(child: CustomLoadingIndicator());
        }
        if (state is AdminNotificationLoadSuccess) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.history_rounded, color: _kPrimary, size: 18),
                const SizedBox(width: 8),
                const Text('Lịch sử thông báo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              ]),
              const SizedBox(height: 14),
              ...state.notifications.map((a) {
                Color col = _kPrimary;
                IconData icon = Icons.info_outline;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: col.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: col.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: col, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 3),
                        Text('Loại: ${a.type}  ·  ${a.createdAt}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                      ]),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
                  ]),
                );
              }),
            ]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
