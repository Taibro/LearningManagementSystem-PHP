class ConductScore {
  final String semester;
  final int totalScore;
  final String classification;
  final List<ConductDetail> details;

  const ConductScore({
    required this.semester,
    required this.totalScore,
    required this.classification,
    required this.details,
  });
}

class ConductDetail {
  final String title;
  final int maxScore;
  final int achievedScore;

  const ConductDetail({
    required this.title,
    required this.maxScore,
    required this.achievedScore,
  });
}

const kConductScores = [
  ConductScore(
    semester: 'Học kỳ 1 - Năm 2023-2024',
    totalScore: 85,
    classification: 'Tốt',
    details: [
      ConductDetail(title: 'Ý thức học tập', maxScore: 20, achievedScore: 18),
      ConductDetail(title: 'Chấp hành nội quy', maxScore: 25, achievedScore: 25),
      ConductDetail(title: 'Tham gia hoạt động', maxScore: 20, achievedScore: 15),
      ConductDetail(title: 'Phẩm chất công dân', maxScore: 25, achievedScore: 20),
      ConductDetail(title: 'Cán bộ lớp', maxScore: 10, achievedScore: 7),
    ],
  ),
  ConductScore(
    semester: 'Học kỳ 2 - Năm 2022-2023',
    totalScore: 92,
    classification: 'Xuất sắc',
    details: [
      ConductDetail(title: 'Ý thức học tập', maxScore: 20, achievedScore: 20),
      ConductDetail(title: 'Chấp hành nội quy', maxScore: 25, achievedScore: 25),
      ConductDetail(title: 'Tham gia hoạt động', maxScore: 20, achievedScore: 20),
      ConductDetail(title: 'Phẩm chất công dân', maxScore: 25, achievedScore: 22),
      ConductDetail(title: 'Cán bộ lớp', maxScore: 10, achievedScore: 5),
    ],
  ),
];

class NewsItem {
  final String id;
  final String title;
  final String date;
  final String category;
  final String imageUrl;

  const NewsItem({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.imageUrl,
  });
}

const kNewsList = [
  NewsItem(
    id: '1',
    title: 'HUIT tổ chức Hội thảo Quốc tế về Trí tuệ Nhân tạo',
    date: '15/11/2023',
    category: 'Sự kiện',
    imageUrl: 'https://images.unsplash.com/photo-1591115765373-5207764f72e7?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
  ),
  NewsItem(
    id: '2',
    title: 'Lịch nghỉ Tết Nguyên Đán 2024 dành cho sinh viên',
    date: '10/11/2023',
    category: 'Thông báo',
    imageUrl: 'https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
  ),
  NewsItem(
    id: '3',
    title: 'Cuộc thi khởi nghiệp sinh viên HUIT 2023 chính thức khởi tranh',
    date: '05/11/2023',
    category: 'Sinh viên',
    imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
  ),
];

class SurveyItem {
  final String id;
  final String title;
  final String deadline;
  final bool isCompleted;

  const SurveyItem({
    required this.id,
    required this.title,
    required this.deadline,
    required this.isCompleted,
  });
}

const kSurveyList = [
  SurveyItem(
    id: '1',
    title: 'Khảo sát chất lượng giảng dạy Học kỳ 1 (2023-2024)',
    deadline: '30/12/2023',
    isCompleted: false,
  ),
  SurveyItem(
    id: '2',
    title: 'Lấy ý kiến về cơ sở vật chất thư viện mới',
    deadline: '15/12/2023',
    isCompleted: false,
  ),
  SurveyItem(
    id: '3',
    title: 'Đánh giá mức độ hài lòng về cổng thông tin sinh viên',
    deadline: '01/10/2023',
    isCompleted: true,
  ),
];
