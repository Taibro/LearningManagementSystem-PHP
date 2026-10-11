class Room {
  final int? id;
  final int? schoolBranchId;
  final String? schoolBranchName;
  final String? roomNumber;
  final String? building;
  final String? roomType;
  final int? capacity;
  final List<String>? equipment;
  final bool? isActive;

  Room({
    this.id,
    this.schoolBranchId,
    this.schoolBranchName,
    this.roomNumber,
    this.building,
    this.roomType,
    this.capacity,
    this.equipment,
    this.isActive,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      schoolBranchId: json['schoolBranchId'],
      schoolBranchName: json['schoolBranchName'],
      roomNumber: json['roomNumber'],
      building: json['building'],
      roomType: json['roomType'],
      capacity: json['capacity'],
      equipment: json['equipment'] != null
          ? List<String>.from(json['equipment'])
          : null,
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolBranchId': schoolBranchId,
      'schoolBranchName': schoolBranchName,
      'roomNumber': roomNumber,
      'building': building,
      'roomType': roomType,
      'capacity': capacity,
      'equipment': equipment,
      'isActive': isActive,
    };
  }
}
