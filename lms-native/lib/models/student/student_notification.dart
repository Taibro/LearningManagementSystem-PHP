class StudentNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? type;
  final bool? isRead;
  final DateTime? createdAt;

  StudentNotification({
    this.id,
    this.title,
    this.body,
    this.type,
    this.isRead,
    this.createdAt,
  });

  factory StudentNotification.fromJson(Map<String, dynamic> json) {
    return StudentNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      isRead: json['isRead'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
