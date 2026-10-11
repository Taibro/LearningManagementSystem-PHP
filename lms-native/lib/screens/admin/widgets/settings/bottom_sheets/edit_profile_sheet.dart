import 'package:flutter/material.dart';
import 'settings_sheet_helpers.dart';

class EditProfileSheet extends StatelessWidget {
  const EditProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader('Chỉnh sửa hồ sơ Admin', Icons.person_outlined),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildSheetField('Tên hiển thị', 'Quản trị viên')),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildSheetField('Email', 'admin@huit.edu.vn')),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildSheetField('Điện thoại', '0901 234 567')),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildSheetField('Đơn vị', 'Phòng Đào tạo – HUIT')),
                  const SizedBox(height: 8),
                  buildSheetSubmitButton(
                      'Lưu thay đổi', () => Navigator.pop(context)),
                ]))),
      ]),
    );
  }
}
