import 'package:flutter/material.dart';
import 'settings_sheet_helpers.dart';

class ChangePasswordSheet extends StatelessWidget {
  const ChangePasswordSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader('Đổi mật khẩu', Icons.lock_outline_rounded),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildSheetField('Mật khẩu hiện tại', '••••••••')),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildSheetField('Mật khẩu mới', '')),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildSheetField('Xác nhận mật khẩu mới', '')),
                  const SizedBox(height: 8),
                  buildSheetSubmitButton(
                      'Đổi mật khẩu', () => Navigator.pop(context)),
                ]))),
      ]),
    );
  }
}
