class NotificationResponse {
  final int? id;
  final int? userId;
  final String? userName;
  final String? title;
  final String? body;
  final String? type;
  final bool? isRead;
  final String? createdAt;

  NotificationResponse({
    this.id,
    this.userId,
    this.userName,
    this.title,
    this.body,
    this.type,
    this.isRead,
    this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      isRead: json['isRead'],
      createdAt: json['createdAt'],
    );
  }
}
