class TeacherMaterial {
  final int? id;
  final String? title;
  final String? classInfo;
  final String? fileSize;
  final String? uploadDate;
  final String? fileUrl;
  final String? docType;

  TeacherMaterial({
    this.id,
    this.title,
    this.classInfo,
    this.fileSize,
    this.uploadDate,
    this.fileUrl,
    this.docType,
  });

  factory TeacherMaterial.fromJson(Map<String, dynamic> json) {
    return TeacherMaterial(
      id: json['id'],
      title: json['title'],
      classInfo: json['classInfo'],
      fileSize: json['fileSize'],
      uploadDate: json['uploadDate'],
      fileUrl: json['fileUrl'],
      docType: json['docType'],
    );
  }
}
