import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../blocs/admin/notification/admin_notification_bloc.dart';
import '../../../../../blocs/admin/notification/admin_notification_event.dart';
import '../../../../../blocs/admin/notification/admin_notification_state.dart';
import 'settings_sheet_helpers.dart';

class BroadcastSheet extends StatefulWidget {
  const BroadcastSheet({super.key});

  @override
  State<BroadcastSheet> createState() => _BroadcastSheetState();
}

class _BroadcastSheetState extends State<BroadcastSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedAudience = 'Tất cả';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1A237E);
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader('Gửi thông báo hàng loạt', Icons.campaign_outlined),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _buildTextField('Tiêu đề', 'Nhập tiêu đề thông báo...', _titleController, false),
                  const SizedBox(height: 12),
                  const Text('Đối tượng nhận',
                      style: TextStyle(fontSize: 12, color: Color(0xFF616161))),
                  const SizedBox(height: 6),
                  Row(children: [
                    _audienceChip('Tất cả', _selectedAudience == 'Tất cả', kPrimary),
                    const SizedBox(width: 8),
                    _audienceChip('Sinh viên', _selectedAudience == 'Sinh viên', kPrimary),
                    const SizedBox(width: 8),
                    _audienceChip('Giảng viên', _selectedAudience == 'Giảng viên', kPrimary),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Nội dung',
                      style: TextStyle(fontSize: 12, color: Color(0xFF616161))),
                  const SizedBox(height: 4),
                  _buildTextField('Nội dung', 'Nhập nội dung thông báo...', _bodyController, true),
                  const SizedBox(height: 20),
                  BlocConsumer<AdminNotificationBloc, AdminNotificationState>(
                    listener: (context, state) {
                      if (state is AdminNotificationActionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                        Navigator.pop(context);
                      } else if (state is AdminNotificationActionFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminNotificationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return buildSheetSubmitButton(
                          '📣  Gửi thông báo', () {
                            if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ tiêu đề và nội dung'), backgroundColor: Colors.red));
                              return;
                            }
                            context.read<AdminNotificationBloc>().add(AdminNotificationBroadcast({
                              'title': _titleController.text.trim(),
                              'body': _bodyController.text.trim(),
                              'type': 'SYSTEM',
                            }));
                          });
                    },
                  ),
                ]))),
      ]),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isMultiline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMultiline) ...[
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF616161))),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0D8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0D8F0)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _audienceChip(String label, bool selected, Color kPrimary) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAudience = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? kPrimary : const Color(0xFFE0D8F0)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : const Color(0xFF424242),
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}
