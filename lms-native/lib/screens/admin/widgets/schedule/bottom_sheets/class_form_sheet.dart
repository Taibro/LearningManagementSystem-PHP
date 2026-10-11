import 'package:flutter/material.dart';
import 'schedule_sheet_helpers.dart';

class ClassFormSheet extends StatelessWidget {
  final Map<String, dynamic>? existing;
  const ClassFormSheet({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    final isEdit = existing != null;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader(isEdit ? 'Chỉnh sửa lịch học' : 'Thêm lịch học mới',
            isEdit ? Icons.edit_outlined : Icons.add_box_outlined),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  buildSheetField('Môn học', existing?['subject'] ?? 'Nhập tên môn học'),
                  const SizedBox(height: 12),
                  buildSheetField('Mã học phần', existing?['code'] ?? 'VD: 010110218801'),
                  const SizedBox(height: 12),
                  buildSheetField('Nhóm lớp', existing?['group'] ?? 'VD: 14DHTH04'),
                  const SizedBox(height: 12),
                  buildSheetField('Giảng viên', existing?['lecturer'] ?? 'Chọn giảng viên'),
                  const SizedBox(height: 12),
                  buildSheetField('Phòng học', existing?['room'] ?? 'Chọn phòng học'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: buildSheetField('Thứ', existing?['day'] ?? 'Thứ 2')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: buildSheetField(
                            'Tiết học', existing?['session'] ?? 'Tiết 1–3')),
                  ]),
                  const SizedBox(height: 12),
                  buildSheetField('Loại lớp', 'Lý thuyết'),
                  const SizedBox(height: 20),
                  buildSheetSubmitBtn(
                      context, isEdit ? 'Lưu thay đổi' : 'Tạo lịch học'),
                ]))),
      ]),
    );
  }
}
