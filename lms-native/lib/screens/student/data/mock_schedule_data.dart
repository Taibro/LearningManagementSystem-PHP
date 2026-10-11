import 'package:flutter/material.dart';
import 'package:learning_management_app/core/enum/ScheduleType.dart';
import 'package:learning_management_app/models/Schedule.dart';

const Color kPrimary = Color(0xFF1565C0);
const Color kGreen = Color(0xFF43A047);
const Color kYellow = Color(0xFFFFC107);
const Color kRed = Color(0xFFE53935);
const Color kOrange = Color(0xFFFFA726);
const Color kBg = Color(0xFFF0F4FF);
const Color kCardBg = Colors.white;
const Color kTextMain = Color(0xFF212121);
const Color kTextGrey = Color(0xFF757575);

final DateTime kToday = DateTime(2026, 4, 19);

const List<String> kMonthNames = [
  'Tháng 1',
  'Tháng 2',
  'Tháng 3',
  'Tháng 4',
  'Tháng 5',
  'Tháng 6',
  'Tháng 7',
  'Tháng 8',
  'Tháng 9',
  'Tháng 10',
  'Tháng 11',
  'Tháng 12',
];

final Map<String, List<Schedule>> kData = {
  '2026-04-01': [
    const Schedule(
      subjectName: 'Thực hành phân tích thiết kế hệ thống',
      tiet: '7 - 11',
      phong: 'A110 - Phòng máy tính - 140 Lê Trọng Tấn',
      giangVien: 'Đặng Đức Trung',
    ),
  ],
  '2026-04-02': [
    const Schedule(
      subjectName: 'Khai phá dữ liệu',
      tiet: '1 - 3',
      phong: 'A301 - 140 Lê Trọng Tấn',
      giangVien: 'Nguyễn Minh Tuấn',
      type: ScheduleType.lichTrucTuyen,
    ),
    const Schedule(
      subjectName: 'Lập trình Web nâng cao',
      tiet: '4 - 6',
      phong: 'B102 - 140 Lê Trọng Tấn',
      giangVien: 'Trần Thị Mai',
    ),
  ],
  '2026-04-06': [
    const Schedule(
      subjectName: 'Công nghệ Java',
      tiet: '1 - 3',
      phong: 'A202 - Phòng máy tính - 140 Lê Trọng Tấn',
      giangVien: 'Nguyễn Văn An',
    ),
  ],
  '2026-04-07': [
    const Schedule(
      subjectName: 'Mạng máy tính',
      tiet: '4 - 6',
      phong: 'B301 - 140 Lê Trọng Tấn',
      giangVien: 'Lê Văn Bình',
    ),
  ],
  '2026-04-08': [
    const Schedule(
      subjectName: 'Cơ sở dữ liệu',
      tiet: '1 - 4',
      phong: 'A101 - 140 Lê Trọng Tấn',
      giangVien: 'Trần Văn Cường',
    ),
  ],
  '2026-04-09': [
    const Schedule(
      subjectName: 'Hệ điều hành',
      tiet: '7 - 9',
      phong: 'A202 - 140 Lê Trọng Tấn',
      giangVien: 'Phạm Thị Dung',
    ),
  ],
  '2026-04-10': [
    const Schedule(
      subjectName: 'Trí tuệ nhân tạo',
      tiet: '10 - 12',
      phong: 'B101 - 140 Lê Trọng Tấn',
      giangVien: 'Hoàng Văn Em',
    ),
  ],
  '2026-04-13': [
    const Schedule(
      subjectName: 'Thực hành quản trị hệ thống mạng',
      tiet: '1 - 6',
      phong: 'A205 - Phòng máy tính - 140 Lê Trọng Tấn',
      giangVien: 'Đinh Huy Hoàng',
    ),
    const Schedule(
      subjectName: 'Lập trình di động',
      tiet: '7 - 11',
      phong: 'A104 - Phòng máy tính - 140 Lê Trọng Tấn',
      giangVien: 'Nguyễn Quang Huy',
    ),
  ],
  '2026-04-14': [
    const Schedule(
      subjectName: 'Công Nghệ Java',
      tiet: '2 - 6',
      phong: 'A202 - Phòng máy tính - 140 Lê Trọng Tấn',
      giangVien: 'Nguyễn Văn Lê',
    ),
  ],
  '2026-04-15': [
    const Schedule(
      subjectName: 'Kiểm thử phần mềm',
      tiet: '7 - 9',
      phong: 'B201 - 140 Lê Trọng Tấn',
      giangVien: 'Lê Thị Phương',
    ),
  ],
  '2026-04-16': [
    const Schedule(
      subjectName: 'Quản trị hệ thống mạng',
      tiet: '7 - 9',
      phong: 'A302 - 140 Lê Trọng Tấn',
      giangVien: 'Dương Bảo Ninh',
    ),
    const Schedule(
      subjectName: 'Phân tích thiết kế hệ thống',
      tiet: '10 - 12',
      phong: 'B201 - 140 Lê Trọng Tấn',
      giangVien: 'Nguyễn Văn Lê',
    ),
  ],
  '2026-04-17': [
    const Schedule(
      subjectName: 'An toàn thông tin',
      tiet: '1 - 3',
      phong: 'A301 - 140 Lê Trọng Tấn',
      giangVien: 'Trần Minh Quân',
    ),
  ],
  '2026-04-20': [
    const Schedule(
      subjectName: 'Đồ án tốt nghiệp',
      tiet: '1 - 6',
      phong: 'A301 - 140 Lê Trọng Tấn',
      giangVien: 'Nguyễn Văn Hùng',
    ),
  ],
  '2026-04-21': [
    const Schedule(
      subjectName: 'Lập trình C++',
      tiet: '7 - 9',
      phong: 'B102 - 140 Lê Trọng Tấn',
      giangVien: 'Phạm Văn Inh',
    ),
  ],
  '2026-04-22': [
    const Schedule(
      subjectName: 'Phương pháp nghiên cứu khoa học',
      tiet: '10 - 12',
      phong: 'A201 - 140 Lê Trọng Tấn',
      giangVien: 'Lê Thị Kim',
    ),
  ],
  '2026-04-23': [
    const Schedule(
      subjectName: 'Thực hành lập trình web',
      tiet: '1 - 6',
      phong: 'A105 - Phòng máy tính - 140 Lê Trọng Tấn',
      giangVien: 'Nguyễn Thị Lan',
    ),
  ],
  '2026-04-24': [
    const Schedule(
      subjectName: 'Kiến trúc máy tính',
      tiet: '7 - 9',
      phong: 'B201 - 140 Lê Trọng Tấn',
      giangVien: 'Trần Văn Minh',
    ),
  ],
};
