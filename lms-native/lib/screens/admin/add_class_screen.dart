import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/user_management/admin_user_management_bloc.dart';
import '../../blocs/admin/user_management/admin_user_management_event.dart';
import '../../blocs/admin/user_management/admin_user_management_state.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _maxCtrl = TextEditingController(text: '40');

  String _selectedSubject = 'Lập trình Java';
  String _selectedTeacher = 'TS. Nguyễn Văn A';
  String _selectedRoom = 'A1-301';
  String _selectedDay = 'Thứ 2';
  String _selectedPeriod = 'Tiết 1-3';
  String _selectedSemester = 'HK2 - 2025-2026';

  final _subjects = ['Lập trình Java', 'Cơ sở dữ liệu', 'Mạng máy tính', 'Trí tuệ nhân tạo', 'Lập trình Web'];
  final _teachers = ['TS. Nguyễn Văn A', 'ThS. Trần Thị B', 'PGS.TS Lê Văn C', 'ThS. Phạm Thị D'];
  final _rooms = ['A1-301', 'A1-302', 'A2-201', 'A2-202', 'B1-101', 'B2-201'];
  final _days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
  final _periods = ['Tiết 1-3', 'Tiết 4-6', 'Tiết 7-9', 'Tiết 10-12'];
  final _semesters = ['HK2 - 2025-2026', 'HK1 - 2025-2026'];

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminUserManagementBloc, AdminUserManagementState>(
      listener: (context, state) {
        if (state is AdminUserManagementSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: _kPrimary,
          ));
          Navigator.pop(context);
        } else if (state is AdminUserManagementFailure) {
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
              child: Form(
                key: _formKey,
                child: Column(children: [
                  _buildBasicInfoCard(),
                  const SizedBox(height: 16),
                  _buildScheduleCard(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                ]),
              ),
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
        const Icon(Icons.add_box_outlined, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        const Text('Thêm lớp học',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildBasicInfoCard() {
    return _card(
      title: 'Thông tin lớp học',
      icon: Icons.class_outlined,
      children: [
        _buildField('Mã lớp', _codeCtrl, 'Nhập mã lớp...', Icons.tag),
        const SizedBox(height: 12),
        _buildField('Tên lớp', _nameCtrl, 'Nhập tên lớp...', Icons.class_outlined),
        const SizedBox(height: 12),
        _buildDropdown('Môn học', _selectedSubject, _subjects, (v) => setState(() => _selectedSubject = v!)),
        const SizedBox(height: 12),
        _buildDropdown('Giảng viên', _selectedTeacher, _teachers, (v) => setState(() => _selectedTeacher = v!)),
        const SizedBox(height: 12),
        _buildDropdown('Học kỳ', _selectedSemester, _semesters, (v) => setState(() => _selectedSemester = v!)),
        const SizedBox(height: 12),
        _buildField('Sĩ số tối đa', _maxCtrl, '40', Icons.groups_outlined, inputType: TextInputType.number),
      ],
    );
  }

  Widget _buildScheduleCard() {
    return _card(
      title: 'Lịch học',
      icon: Icons.calendar_today_outlined,
      children: [
        _buildDropdown('Phòng', _selectedRoom, _rooms, (v) => setState(() => _selectedRoom = v!)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildDropdown('Thứ', _selectedDay, _days, (v) => setState(() => _selectedDay = v!))),
          const SizedBox(width: 12),
          Expanded(child: _buildDropdown('Tiết', _selectedPeriod, _periods, (v) => setState(() => _selectedPeriod = v!))),
        ]),
      ],
    );
  }

  Widget _card({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: _kPrimary, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        ]),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, IconData icon, {TextInputType? inputType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF616161), fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
          prefixIcon: Icon(icon, size: 20, color: _kPrimary.withOpacity(0.6)),
          filled: true,
          fillColor: const Color(0xFFF9F9FF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0D8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0D8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null,
      ),
    ]);
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF616161), fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FF),
          border: Border.all(color: const Color(0xFFE0D8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0D1B6E), _kPrimary]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_box, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Thêm lớp học', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminUserManagementBloc>().add(AdminUserManagementCreateClass({
        'classCode': _codeCtrl.text,
        'className': _nameCtrl.text,
        'subject': _selectedSubject,
        'teacher': _selectedTeacher,
        'semester': _selectedSemester,
        'maxStudents': int.tryParse(_maxCtrl.text) ?? 40,
        'room': _selectedRoom,
        'dayOfWeek': _selectedDay,
        'period': _selectedPeriod,
      }));
    }
  }
}
