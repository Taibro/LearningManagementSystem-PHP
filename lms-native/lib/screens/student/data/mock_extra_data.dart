// Mock data for Transaction History, Receipts, Attendance Stats, Curriculum

// ── Transaction History ──────────────────────────────────────────────
enum TransactionStatus { thanhCong, daHuy }

class Transaction {
  final String loai;
  final String ngayGio;
  final double soTien;
  final TransactionStatus status;

  const Transaction({
    required this.loai,
    required this.ngayGio,
    required this.soTien,
    required this.status,
  });
}

final List<Transaction> kTransactions = [
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '30/12/2025 19:59',
    soTien: 17205000,
    status: TransactionStatus.thanhCong,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '10/08/2025 18:54',
    soTien: 2785000,
    status: TransactionStatus.thanhCong,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '19/07/2025 10:35',
    soTien: 2785000,
    status: TransactionStatus.daHuy,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '19/07/2025 10:09',
    soTien: 2785000,
    status: TransactionStatus.thanhCong,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '18/07/2025 06:44',
    soTien: 2785000,
    status: TransactionStatus.daHuy,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '18/07/2025 06:41',
    soTien: 11280000,
    status: TransactionStatus.thanhCong,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '18/07/2025 06:37',
    soTien: 11280000,
    status: TransactionStatus.daHuy,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '09/01/2025 07:38',
    soTien: 17990000,
    status: TransactionStatus.thanhCong,
  ),
  const Transaction(
    loai: 'Thu học phí',
    ngayGio: '15/08/2024 14:22',
    soTien: 18363750,
    status: TransactionStatus.thanhCong,
  ),
];

// ── Receipts (Phiếu thu) ─────────────────────────────────────────────
class Receipt {
  final String soPhieu;
  final String ngayGio;
  final String donViThu;
  final double soTien;
  final bool hasInvoice;

  const Receipt({
    required this.soPhieu,
    required this.ngayGio,
    required this.donViThu,
    required this.soTien,
    this.hasInvoice = false,
  });
}

final List<Receipt> kReceipts = [
  const Receipt(
    soPhieu: '193813',
    ngayGio: '09:35, 20/01/2026',
    donViThu: 'Ngân hàng ngoài trường 2',
    soTien: 579150,
  ),
  const Receipt(
    soPhieu: '832565',
    ngayGio: '20:03, 30/12/2025',
    donViThu: 'NH Sacombank',
    soTien: 17205000,
    hasInvoice: true,
  ),
  const Receipt(
    soPhieu: '796667',
    ngayGio: '18:54, 10/08/2025',
    donViThu: 'NH Sacombank',
    soTien: 2785000,
  ),
  const Receipt(
    soPhieu: '786191',
    ngayGio: '10:09, 19/07/2025',
    donViThu: 'NH Sacombank',
    soTien: 2785000,
  ),
  const Receipt(
    soPhieu: '784429',
    ngayGio: '06:43, 18/07/2025',
    donViThu: 'NH Sacombank',
    soTien: 11280000,
  ),
];

// ── Attendance Statistics (Thống kê điểm danh) ───────────────────────
class AttendanceStatSubject {
  final String maMon;
  final String tenMon;
  final int dvht;
  final int cp;
  final int kp;

  const AttendanceStatSubject({
    required this.maMon,
    required this.tenMon,
    required this.dvht,
    required this.cp,
    required this.kp,
  });
}

class AttendanceStatSemester {
  final String label;
  final int totalDvht;
  final int totalCp;
  final int totalKp;
  final List<AttendanceStatSubject> subjects;

  const AttendanceStatSemester({
    required this.label,
    required this.totalDvht,
    required this.totalCp,
    required this.totalKp,
    required this.subjects,
  });
}

final List<AttendanceStatSemester> kAttendanceStats = [
  const AttendanceStatSemester(
    label: 'HK2 (2024 - 2025)',
    totalDvht: 21,
    totalCp: 0,
    totalKp: 0,
    subjects: [],
  ),
  const AttendanceStatSemester(
    label: 'HK1 (2025 - 2026)',
    totalDvht: 19,
    totalCp: 0,
    totalKp: 0,
    subjects: [],
  ),
  const AttendanceStatSemester(
    label: 'HK2 (2025 - 2026)',
    totalDvht: 20,
    totalCp: 0,
    totalKp: 2,
    subjects: [
      AttendanceStatSubject(maMon: '101976', tenMon: 'Phân tích thiết kế hệ thống', dvht: 2, cp: 0, kp: 0),
      AttendanceStatSubject(maMon: '101973', tenMon: 'Quản trị hệ thống mạng', dvht: 3, cp: 0, kp: 0),
      AttendanceStatSubject(maMon: '101974', tenMon: 'Thực hành quản trị hệ thống mạng', dvht: 1, cp: 0, kp: 0),
      AttendanceStatSubject(maMon: '101969', tenMon: 'Lập trình di động', dvht: 3, cp: 0, kp: 0),
      AttendanceStatSubject(maMon: '000002', tenMon: 'Công Nghệ Java', dvht: 3, cp: 0, kp: 0),
      AttendanceStatSubject(maMon: '101970', tenMon: 'Khai phá dữ liệu', dvht: 3, cp: 0, kp: 0),
      AttendanceStatSubject(maMon: '097290', tenMon: 'Sinh hoạt giữa khóa năm 3 gặp khoa chuyên ngành', dvht: 0, cp: 0, kp: 0),
      AttendanceStatSubject(maMon: '101956', tenMon: 'Deep learning', dvht: 3, cp: 0, kp: 1),
      AttendanceStatSubject(maMon: '101977', tenMon: 'Thực hành phân tích thiết kế hệ thống', dvht: 1, cp: 0, kp: 1),
    ],
  ),
];

// ── Curriculum (Chương trình khung) ──────────────────────────────────
enum SubjectStatus { completed, inProgress, notStarted }

class CurriculumSubject {
  final String tenHocPhan;
  final String maHP;
  final int tinChi;
  final SubjectStatus trangThai;

  const CurriculumSubject({
    required this.tenHocPhan,
    required this.maHP,
    required this.tinChi,
    required this.trangThai,
  });
}

class CurriculumCategory {
  final String label;
  final int totalTC;
  final List<CurriculumSubject> subjects;

  const CurriculumCategory({
    required this.label,
    required this.totalTC,
    required this.subjects,
  });
}

class CurriculumSemester {
  final String label;
  final int totalTC;
  final List<CurriculumCategory> categories;

  const CurriculumSemester({
    required this.label,
    required this.totalTC,
    required this.categories,
  });
}

class CurriculumInfo {
  final String chuyenNganh;
  final String nganh;
  final String heDaoTao;
  final String loaiDaoTao;
  final List<CurriculumSemester> semesters;

  const CurriculumInfo({
    required this.chuyenNganh,
    required this.nganh,
    required this.heDaoTao,
    required this.loaiDaoTao,
    required this.semesters,
  });
}

final kCurriculum = const CurriculumInfo(
  chuyenNganh: 'Công nghệ phần mềm',
  nganh: 'Công nghệ thông tin',
  heDaoTao: 'Đại học',
  loaiDaoTao: 'Chính quy',
  semesters: [
    CurriculumSemester(
      label: 'Học kì 1',
      totalTC: 16,
      categories: [
        CurriculumCategory(
          label: 'Học phần bắt buộc',
          totalTC: 16,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Nhập môn lập trình', maHP: '0101101941', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Toán cao cấp 1', maHP: '0101100012', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Vật lý đại cương', maHP: '0101100023', tinChi: 2, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Triết học Mác-Lênin', maHP: '0101100034', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Giáo dục thể chất 1', maHP: '0101100045', tinChi: 2, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Giáo dục quốc phòng - an ninh 1', maHP: '0101001561', tinChi: 3, trangThai: SubjectStatus.completed),
          ],
        ),
      ],
    ),
    CurriculumSemester(
      label: 'Học kì 2',
      totalTC: 16,
      categories: [
        CurriculumCategory(
          label: 'Học phần bắt buộc',
          totalTC: 12,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Anh văn 1', maHP: '0101100822', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Cấu trúc dữ liệu và Giải thuật', maHP: '0101101943', tinChi: 2, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Giáo dục quốc phòng - an ninh 2', maHP: '0101001662', tinChi: 2, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Mạng máy tính', maHP: '0101003158', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Thực hành cấu trúc dữ liệu và giải thuật', maHP: '0101101961', tinChi: 1, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Thực hành mạng máy tính', maHP: '0101005322', tinChi: 1, trangThai: SubjectStatus.completed),
          ],
        ),
        CurriculumCategory(
          label: 'Học phần tự chọn',
          totalTC: 4,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Toán cao cấp 2', maHP: '0101100056', tinChi: 2, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Xác suất thống kê', maHP: '0101100067', tinChi: 2, trangThai: SubjectStatus.completed),
          ],
        ),
      ],
    ),
    CurriculumSemester(
      label: 'Học kì 3',
      totalTC: 18,
      categories: [
        CurriculumCategory(
          label: 'Học phần bắt buộc',
          totalTC: 18,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Anh văn 2', maHP: '0101100833', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Lập trình hướng đối tượng', maHP: '0101101955', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Cơ sở dữ liệu', maHP: '0101101966', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Hệ điều hành', maHP: '0101101977', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Kinh tế chính trị Mác-Lênin', maHP: '0101100088', tinChi: 2, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Toán rời rạc', maHP: '0101100099', tinChi: 2, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Giáo dục thể chất 2', maHP: '0101100100', tinChi: 2, trangThai: SubjectStatus.completed),
          ],
        ),
      ],
    ),
    CurriculumSemester(
      label: 'Học kì 4',
      totalTC: 19,
      categories: [
        CurriculumCategory(
          label: 'Học phần bắt buộc',
          totalTC: 19,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Ảo hóa và điện toán đám mây', maHP: '1019660001', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Công nghệ phần mềm', maHP: '1019630002', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Lập trình web', maHP: '1019610003', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Hệ quản trị cơ sở dữ liệu', maHP: '1019600004', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Xử lý ảnh', maHP: '1019620005', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Trí tuệ nhân tạo', maHP: '1019640006', tinChi: 3, trangThai: SubjectStatus.completed),
            CurriculumSubject(tenHocPhan: 'Thực hành Trí tuệ nhân tạo', maHP: '1019670007', tinChi: 1, trangThai: SubjectStatus.completed),
          ],
        ),
      ],
    ),
    CurriculumSemester(
      label: 'Học kì 5',
      totalTC: 20,
      categories: [
        CurriculumCategory(
          label: 'Học phần bắt buộc',
          totalTC: 20,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Công Nghệ Java', maHP: '0000020001', tinChi: 3, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Deep learning', maHP: '1019560002', tinChi: 3, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Khai phá dữ liệu', maHP: '1019700003', tinChi: 3, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Lập trình di động', maHP: '1019690004', tinChi: 3, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Phân tích thiết kế hệ thống', maHP: '1019760005', tinChi: 2, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Quản trị hệ thống mạng', maHP: '1019730006', tinChi: 3, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Thực hành phân tích thiết kế hệ thống', maHP: '1019770007', tinChi: 1, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Thực hành quản trị hệ thống mạng', maHP: '1019740008', tinChi: 1, trangThai: SubjectStatus.inProgress),
            CurriculumSubject(tenHocPhan: 'Sinh hoạt giữa khóa năm 3', maHP: '0972900009', tinChi: 0, trangThai: SubjectStatus.inProgress),
          ],
        ),
      ],
    ),
    CurriculumSemester(
      label: 'Học kì 6',
      totalTC: 18,
      categories: [
        CurriculumCategory(
          label: 'Học phần bắt buộc',
          totalTC: 12,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Kiểm thử phần mềm', maHP: '1019800001', tinChi: 3, trangThai: SubjectStatus.notStarted),
            CurriculumSubject(tenHocPhan: 'An toàn thông tin', maHP: '1019810002', tinChi: 3, trangThai: SubjectStatus.notStarted),
            CurriculumSubject(tenHocPhan: 'Đồ án chuyên ngành', maHP: '1019820003', tinChi: 3, trangThai: SubjectStatus.notStarted),
            CurriculumSubject(tenHocPhan: 'Quản lý dự án phần mềm', maHP: '1019830004', tinChi: 3, trangThai: SubjectStatus.notStarted),
          ],
        ),
        CurriculumCategory(
          label: 'Học phần tự chọn',
          totalTC: 6,
          subjects: [
            CurriculumSubject(tenHocPhan: 'Phát triển ứng dụng IoT', maHP: '1019840005', tinChi: 3, trangThai: SubjectStatus.notStarted),
            CurriculumSubject(tenHocPhan: 'Blockchain và ứng dụng', maHP: '1019850006', tinChi: 3, trangThai: SubjectStatus.notStarted),
          ],
        ),
      ],
    ),
  ],
);
