class Point {
  final int? id;
  final String employeeName;
  final double points;
  final double changeAmount;
  final String reason;
  final DateTime date;
  final String? approvalComment;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Point({
    this.id,
    required this.employeeName,
    required this.points,
    required this.changeAmount,
    required this.reason,
    required this.date,
    this.approvalComment,
    this.status = '待审批',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json['id'],
      employeeName: json['employeeName'],
      points: json['points'].toDouble(),
      changeAmount: json['changeAmount'].toDouble(),
      reason: json['reason'],
      date: DateTime.parse(json['date']),
      approvalComment: json['approvalComment'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'points': points,
      'changeAmount': changeAmount,
      'reason': reason,
      'date': date.toIso8601String(),
      'approvalComment': approvalComment,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Point copyWith({
    int? id,
    String? employeeName,
    double? points,
    double? changeAmount,
    String? reason,
    DateTime? date,
    String? approvalComment,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Point(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      points: points ?? this.points,
      changeAmount: changeAmount ?? this.changeAmount,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      approvalComment: approvalComment ?? this.approvalComment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}