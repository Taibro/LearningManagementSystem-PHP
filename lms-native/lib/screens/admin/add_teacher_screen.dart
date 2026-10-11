import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/user_management/admin_user_management_bloc.dart';
import '../../blocs/admin/user_management/admin_user_management_event.dart';
import '../../blocs/admin/user_management/admin_user_management_state.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();

  String _selectedFaculty = 'Công nghệ thông tin';
  String _selectedPosition = 'Giảng viên';

  final _faculties = ['Công nghệ thông tin', 'Kế toán', 'Quản trị kinh doanh', 'Cơ khí', 'Ngoại ngữ'];
  final _positions = ['Giảng viên', 'Phó trưởng khoa', 'Trưởng khoa', 'Trợ giảng'];

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _degreeCtrl.dispose();
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
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildPositionCard(),
                  const SizedBox(height: 16),
                  _buildSubjectsCard(),
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
        const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        const Text('Thêm giảng viên',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildInfoCard() {
    return _card(
      title: 'Thông tin cá nhân',
      icon: Icons.person_outline,
      children: [
        _buildField('Mã giảng viên', _idCtrl, 'Nhập mã GV...', Icons.badge_outlined),
        const SizedBox(height: 12),
        _buildField('Họ và tên', _nameCtrl, 'Nhập họ và tên...', Icons.person_outline),
        const SizedBox(height: 12),
        _buildField('Email', _emailCtrl, 'Nhập email...', Icons.email_outlined, inputType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildField('Số điện thoại', _phoneCtrl, 'Nhập SĐT...', Icons.phone_outlined, inputType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildField('Học vị', _degreeCtrl, 'Ví dụ: Thạc sĩ, Tiến sĩ...', Icons.workspace_premium_outlined),
      ],
    );
  }

  Widget _buildPositionCard() {
    return _card(
      title: 'Chức vụ & Khoa',
      icon: Icons.work_outline,
      children: [
        _buildDropdown('Khoa', _selectedFaculty, _faculties, (v) => setState(() => _selectedFaculty = v!)),
        const SizedBox(height: 12),
        _buildDropdown('Chức vụ', _selectedPosition, _positions, (v) => setState(() => _selectedPosition = v!)),
      ],
    );
  }

  Widget _buildSubjectsCard() {
    final subjects = ['Lập trình Java', 'Cơ sở dữ liệu', 'Mạng máy tính', 'Trí tuệ nhân tạo'];
    final selected = <String>{'Lập trình Java', 'Cơ sở dữ liệu'};
    return _card(
      title: 'Môn học phụ trách',
      icon: Icons.menu_book_outlined,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: subjects.map((s) {
            final isSel = selected.contains(s);
            return GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? _kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSel ? _kPrimary : const Color(0xFFE0D8F0)),
                ),
                child: Text(s,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSel ? Colors.white : const Color(0xFF424242),
                      fontWeight: FontWeight.w500,
                    )),
              ),
            );
          }).toList(),
        ),
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
          Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Thêm giảng viên', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminUserManagementBloc>().add(AdminUserManagementCreateTeacher({
        'teacherCode': _idCtrl.text,
        'fullName': _nameCtrl.text,
        'email': _emailCtrl.text,
        'phoneNumber': _phoneCtrl.text,
        'faculty': _selectedFaculty,
        'position': _selectedPosition,
        'degree': _degreeCtrl.text,
      }));
    }
  }
}
