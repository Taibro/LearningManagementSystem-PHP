import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../blocs/auth/auth_bloc.dart';
import '../../../../../blocs/auth/auth_state.dart';
import '../../../../../blocs/admin/settings/admin_semester_bloc.dart';
import '../../../../../blocs/admin/settings/admin_semester_event.dart';
import 'settings_sheet_helpers.dart';

class NewSemesterSheet extends StatefulWidget {
  const NewSemesterSheet({super.key});

  @override
  State<NewSemesterSheet> createState() => _NewSemesterSheetState();
}

class _NewSemesterSheetState extends State<NewSemesterSheet> {
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _academicYearController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader('Tạo học kỳ mới', Icons.add_circle_outline),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTextField('Tên học kỳ', 'VD: HK1', _nameController)),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTextField('Ngày bắt đầu', 'YYYY-MM-DD', _startDateController)),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTextField('Ngày kết thúc', 'YYYY-MM-DD', _endDateController)),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTextField('Năm học', '2026-2027', _academicYearController)),
                  const SizedBox(height: 8),
                  buildSheetSubmitButton(
                      'Tạo học kỳ', _submit),
                ]))),
      ]),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF616161))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user.schoolId != null) {
      context.read<AdminSemesterBloc>().add(AdminSemesterCreated(
        name: _nameController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        academicYearName: _academicYearController.text.trim(),
        schoolId: authState.user.schoolId!,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi xác thực School ID')));
    }
  }
}
