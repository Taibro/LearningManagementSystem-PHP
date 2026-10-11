/// Mock data for Academic Results & Achievement screens

// ── Student Overview Info ────────────────────────────────────────────
class StudentOverview {
  final String hoTen;
  final int sinhVienNam;
  final String nienKhoa;
  final double thoiGianDaoTao;
  final double diemTBCHe4;
  final double diemTBCHe10;
  final int stcDaDangKy;
  final int stcDaTichLuy;
  final int stcNo;
  final double phanTramStcNo;
  final double stcPhaiTichLuy;

  const StudentOverview({
    required this.hoTen,
    required this.sinhVienNam,
    required this.nienKhoa,
    required this.thoiGianDaoTao,
    required this.diemTBCHe4,
    required this.diemTBCHe10,
    required this.stcDaDangKy,
    required this.stcDaTichLuy,
    required this.stcNo,
    required this.phanTramStcNo,
    required this.stcPhaiTichLuy,
  });
}

const kStudentOverview = StudentOverview(
  hoTen: 'Nguyễn Thành Tài',
  sinhVienNam: 3,
  nienKhoa: '2023 - 2027',
  thoiGianDaoTao: 4.0,
  diemTBCHe4: 3.54,
  diemTBCHe10: 8.29,
  stcDaDangKy: 88,
  stcDaTichLuy: 85,
  stcNo: 0,
  phanTramStcNo: 0.00,
  stcPhaiTichLuy: 151.00,
);

// ── Subject Grade ────────────────────────────────────────────────────
class SubjectGrade {
  final String maMon;
  final String tenMon;
  final int tinChi;
  final double? diemTB; // null means '-'

  const SubjectGrade({
    required this.maMon,
    required this.tenMon,
    required this.tinChi,
    this.diemTB,
  });
}

// ── Semester Summary ─────────────────────────────────────────────────
class SemesterSummary {
  final String label;          // e.g. "HK2 (2025 - 2026)"
  final List<SubjectGrade> subjects;
  final double? diemTBCHocLuc;
  final double? diemTBCTinChi;
  final String? xepLoaiHocLuc;
  final String? xepLoaiHanhKiem;
  final String? trangThaiHocVu;

  const SemesterSummary({
    required this.label,
    required this.subjects,
    this.diemTBCHocLuc,
    this.diemTBCTinChi,
    this.xepLoaiHocLuc,
    this.xepLoaiHanhKiem,
    this.trangThaiHocVu,
  });
}

final List<SemesterSummary> kSemesterSummaries = [
  const SemesterSummary(
    label: 'HK2 (2025 - 2026)',
    subjects: [
      SubjectGrade(maMon: '000002', tenMon: 'Công Nghệ Java', tinChi: 3),
      SubjectGrade(maMon: '101956', tenMon: 'Deep learning', tinChi: 3),
      SubjectGrade(maMon: '101970', tenMon: 'Khai phá dữ liệu', tinChi: 3),
      SubjectGrade(maMon: '101969', tenMon: 'Lập trình di động', tinChi: 3),
      SubjectGrade(maMon: '101976', tenMon: 'Phân tích thiết kế hệ thống', tinChi: 2),
      SubjectGrade(maMon: '101973', tenMon: 'Quản trị hệ thống mạng', tinChi: 3),
      SubjectGrade(maMon: '101977', tenMon: 'Thực hành phân tích thiết kế hệ thống', tinChi: 1, diemTB: 7.5),
    ],
  ),
  const SemesterSummary(
    label: 'HK1 (2025 - 2026)',
    subjects: [
      SubjectGrade(maMon: '101966', tenMon: 'Ảo hóa và điện toán đám mây', tinChi: 3, diemTB: 8.7),
      SubjectGrade(maMon: '101963', tenMon: 'Công nghệ phần mềm', tinChi: 3, diemTB: 9.1),
      SubjectGrade(maMon: '101960', tenMon: 'Hệ quản trị cơ sở dữ liệu', tinChi: 3, diemTB: 8.6),
      SubjectGrade(maMon: '101961', tenMon: 'Lập trình web', tinChi: 3, diemTB: 10.0),
      SubjectGrade(maMon: '101967', tenMon: 'Thực hành Trí tuệ nhân tạo', tinChi: 1, diemTB: 9.0),
      SubjectGrade(maMon: '101964', tenMon: 'Trí tuệ nhân tạo', tinChi: 3, diemTB: 8.6),
      SubjectGrade(maMon: '101962', tenMon: 'Xử lý ảnh', tinChi: 3, diemTB: 8.2),
    ],
    diemTBCHocLuc: 9.01,
    diemTBCTinChi: 8.92,
    xepLoaiHocLuc: 'Giỏi',
    xepLoaiHanhKiem: 'Tốt',
    trangThaiHocVu: 'Bình thường',
  ),
  const SemesterSummary(
    label: 'HK2 (2024 - 2025)',
    subjects: [
      SubjectGrade(maMon: '101950', tenMon: 'Cấu trúc dữ liệu và giải thuật', tinChi: 3, diemTB: 7.8),
      SubjectGrade(maMon: '101951', tenMon: 'Lập trình hướng đối tượng', tinChi: 3, diemTB: 8.5),
      SubjectGrade(maMon: '101952', tenMon: 'Mạng máy tính', tinChi: 3, diemTB: 7.9),
      SubjectGrade(maMon: '101953', tenMon: 'Hệ điều hành', tinChi: 3, diemTB: 8.0),
      SubjectGrade(maMon: '101954', tenMon: 'Toán rời rạc', tinChi: 3, diemTB: 7.5),
    ],
    diemTBCHocLuc: 7.94,
    diemTBCTinChi: 7.94,
    xepLoaiHocLuc: 'Khá',
    xepLoaiHanhKiem: 'Tốt',
    trangThaiHocVu: 'Bình thường',
  ),
];

// ── Achievement Data (bar chart comparison) ──────────────────────────
class AchievementSubject {
  final String tenMon;
  final double diemCaNhan;
  final double diemTBLop;

  const AchievementSubject({
    required this.tenMon,
    required this.diemCaNhan,
    required this.diemTBLop,
  });
}

class SemesterAchievement {
  final String label;  // e.g. "HK1 (2025 - 2026)"
  final List<AchievementSubject> subjects;

  const SemesterAchievement({
    required this.label,
    required this.subjects,
  });
}

final List<SemesterAchievement> kSemesterAchievements = [
  const SemesterAchievement(
    label: 'HK1 (2025 - 2026)',
    subjects: [
      AchievementSubject(tenMon: 'Ảo hóa và điện toán đám mây', diemCaNhan: 8.7, diemTBLop: 7.7),
      AchievementSubject(tenMon: 'Lập trình web', diemCaNhan: 10.0, diemTBLop: 6.8),
      AchievementSubject(tenMon: 'Công nghệ phần mềm', diemCaNhan: 9.1, diemTBLop: 8.0),
      AchievementSubject(tenMon: 'Xử lý ảnh', diemCaNhan: 8.2, diemTBLop: 6.2),
      AchievementSubject(tenMon: 'Hệ quản trị cơ sở dữ liệu', diemCaNhan: 8.6, diemTBLop: 7.5),
      AchievementSubject(tenMon: 'Thực hành Trí tuệ nhân tạo', diemCaNhan: 9.0, diemTBLop: 7.2),
      AchievementSubject(tenMon: 'Trí tuệ nhân tạo', diemCaNhan: 8.6, diemTBLop: 7.5),
    ],
  ),
  const SemesterAchievement(
    label: 'HK2 (2024 - 2025)',
    subjects: [
      AchievementSubject(tenMon: 'Cấu trúc dữ liệu và giải thuật', diemCaNhan: 7.8, diemTBLop: 6.5),
      AchievementSubject(tenMon: 'Lập trình hướng đối tượng', diemCaNhan: 8.5, diemTBLop: 7.0),
      AchievementSubject(tenMon: 'Mạng máy tính', diemCaNhan: 7.9, diemTBLop: 6.8),
      AchievementSubject(tenMon: 'Hệ điều hành', diemCaNhan: 8.0, diemTBLop: 7.1),
      AchievementSubject(tenMon: 'Toán rời rạc', diemCaNhan: 7.5, diemTBLop: 6.2),
    ],
  ),
];
