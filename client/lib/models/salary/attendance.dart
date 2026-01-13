class Attendance {
  final int? id;
  final String employeeName;
  final String status;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    this.id,
    required this.employeeName,
    required this.status,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeName: json['employeeName'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'status': status,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Attendance copyWith({
    int? id,
    String? employeeName,
    String? status,
    DateTime? date,
    String? checkInTime,
    String? checkOutTime,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
