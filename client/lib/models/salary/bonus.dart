class Bonus {
  final int? id;
  final String employeeName;
  final double amount;
  final DateTime date;
  final String purpose;
  final String? approvalComment;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bonus({
    this.id,
    required this.employeeName,
    required this.amount,
    required this.date,
    required this.purpose,
    this.approvalComment,
    this.status = '待审批',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Bonus.fromJson(Map<String, dynamic> json) {
    return Bonus(
      id: json['id'],
      employeeName: json['employeeName'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      purpose: json['purpose'],
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
      'amount': amount,
      'date': date.toIso8601String(),
      'purpose': purpose,
      'approvalComment': approvalComment,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Bonus copyWith({
    int? id,
    String? employeeName,
    double? amount,
    DateTime? date,
    String? purpose,
    String? approvalComment,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bonus(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      purpose: purpose ?? this.purpose,
      approvalComment: approvalComment ?? this.approvalComment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}