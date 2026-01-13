class Leave {
  final int? id;
  final String employeeName;
  final String status;
  final String leaveType;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final String? approvalComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Leave({
    this.id,
    required this.employeeName,
    required this.status,
    required this.leaveType,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.approvalComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      employeeName: json['employeeName'],
      status: json['status'],
      leaveType: json['leaveType'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      reason: json['reason'],
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
      'leaveType': leaveType,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'reason': reason,
      'approvalComment': approvalComment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Leave copyWith({
    int? id,
    String? employeeName,
    String? status,
    String? leaveType,
    DateTime? startTime,
    DateTime? endTime,
    String? reason,
    String? approvalComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Leave(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      leaveType: leaveType ?? this.leaveType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
      approvalComment: approvalComment ?? this.approvalComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 获取请假时长（小时）
  double getDuration() {
    final duration = endTime.difference(startTime);
    return duration.inHours.toDouble() + duration.inMinutes / 60.0;
  }
}
