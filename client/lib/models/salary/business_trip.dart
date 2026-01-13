class BusinessTrip {
  final int? id;
  final String employeeName;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final String railwayStation;
  final String location;
  final String purpose;
  final String? approvalComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessTrip({
    this.id,
    required this.employeeName,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.railwayStation,
    required this.location,
    required this.purpose,
    this.approvalComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BusinessTrip.fromJson(Map<String, dynamic> json) {
    return BusinessTrip(
      id: json['id'],
      employeeName: json['employeeName'],
      status: json['status'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      railwayStation: json['railwayStation'],
      location: json['location'],
      purpose: json['purpose'],
      approvalComment: json['approvalComment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'status': status,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'railwayStation': railwayStation,
      'location': location,
      'purpose': purpose,
      'approvalComment': approvalComment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BusinessTrip copyWith({
    int? id,
    String? employeeName,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    String? railwayStation,
    String? location,
    String? purpose,
    String? approvalComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessTrip(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      railwayStation: railwayStation ?? this.railwayStation,
      location: location ?? this.location,
      purpose: purpose ?? this.purpose,
      approvalComment: approvalComment ?? this.approvalComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 获取出差时长（天）
  double getDurationDays() {
    final duration = endTime.difference(startTime);
    return duration.inDays.toDouble() + duration.inHours / 24.0;
  }
}