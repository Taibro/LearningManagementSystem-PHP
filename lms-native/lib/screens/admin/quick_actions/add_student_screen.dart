import 'package:flutter/material.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  static const _kPrimary = Color(0xFF1A237E);
  static const _kBg = Color(0xFFF0F2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thông tin cá nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kPrimary)),
                    const SizedBox(height: 20),
                    _buildTextField('Mã sinh viên', Icons.badge_outlined, 'Nhập mã SV (VD: 200121...)'),
                    const SizedBox(height: 16),
                    _buildTextField('Họ và Tên', Icons.person_outline, 'Nhập họ tên đầy đủ'),
                    const SizedBox(height: 16),
                    _buildTextField('Email', Icons.email_outlined, 'Nhập địa chỉ email'),
                    const SizedBox(height: 16),
                    _buildTextField('Số điện thoại', Icons.phone_outlined, 'Nhập số điện thoại'),
                    const SizedBox(height: 16),
                    _buildDropdown('Khoa trực thuộc', Icons.account_balance_outlined, ['Công nghệ thông tin', 'Quản trị kinh doanh', 'Tài chính ngân hàng']),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm sinh viên thành công!')));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                        child: const Text('Tạo tài khoản sinh viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B6E), _kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 8, right: 16, bottom: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.person_add_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          const Text('Thêm sinh viên mới', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (val) {},
          hint: Text('Chọn khoa', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        ),
      ],
    );
  }
}
