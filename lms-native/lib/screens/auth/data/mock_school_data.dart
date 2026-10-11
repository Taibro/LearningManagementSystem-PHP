/// Mock data for schools list
class SchoolInfo {
  final String name;
  final String code;
  final String? logoAsset; // Could be asset path or network URL

  const SchoolInfo({
    required this.name,
    required this.code,
    this.logoAsset,
  });
}

const List<SchoolInfo> mockSchools = [
  SchoolInfo(
    name: 'Công ty Cổ Phần Tiến Bộ Sài Gòn',
    code: 'ASC',
  ),
  SchoolInfo(
    name: 'Trường Đại học Bà Rịa - Vũng Tàu',
    code: 'BVU',
  ),
  SchoolInfo(
    name: 'Trường Đại Học Nguyễn Tất Thành',
    code: 'NTT',
  ),
  SchoolInfo(
    name: 'Trường Đại học Công nghiệp Việt-Hung',
    code: 'VIU',
  ),
  SchoolInfo(
    name: 'Trường Đại Học Sao Đỏ',
    code: 'SDU',
  ),
  SchoolInfo(
    name: 'Trường Cao đẳng Bình Thuận',
    code: 'DNBT',
  ),
  SchoolInfo(
    name: 'Đại học Công nghiệp Thành phố Hồ Chí Minh',
    code: 'IUH',
  ),
  SchoolInfo(
    name: 'Trường Đại học Kinh tế - Kỹ thuật Công nghiệp',
    code: 'UNETI',
  ),
  SchoolInfo(
    name: 'Trường Đại Học Công Thương Tp.HCM',
    code: 'HUIT',
  ),
  SchoolInfo(
    name: 'Trường Đại học Sư phạm Kỹ thuật TP.HCM',
    code: 'HCMUTE',
  ),
];
