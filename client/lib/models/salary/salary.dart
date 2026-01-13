class Salary {
  final int id;
  final String employeeName;
  final String employeeId;
  final String month;
  final double baseSalary;
  final double attendanceBonus;
  final double performanceBonus;
  final double overtimePay;
  final double leaveDeduction;
  final double socialInsurance;
  final double tax;
  final double totalSalary;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Salary({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.month,
    required this.baseSalary,
    required this.attendanceBonus,
    required this.performanceBonus,
    required this.overtimePay,
    required this.leaveDeduction,
    required this.socialInsurance,
    required this.tax,
    required this.totalSalary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'] as int,
      employeeName: json['employeeName'] as String,
      employeeId: json['employeeId'] as String,
      month: json['month'] as String,
      baseSalary: (json['baseSalary'] as num).toDouble(),
      attendanceBonus: (json['attendanceBonus'] as num).toDouble(),
      performanceBonus: (json['performanceBonus'] as num).toDouble(),
      overtimePay: (json['overtimePay'] as num).toDouble(),
      leaveDeduction: (json['leaveDeduction'] as num).toDouble(),
      socialInsurance: (json['socialInsurance'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      totalSalary: (json['totalSalary'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'month': month,
      'baseSalary': baseSalary,
      'attendanceBonus': attendanceBonus,
      'performanceBonus': performanceBonus,
      'overtimePay': overtimePay,
      'leaveDeduction': leaveDeduction,
      'socialInsurance': socialInsurance,
      'tax': tax,
      'totalSalary': totalSalary,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SalaryDetail {
  final int id;
  final int salaryId;
  final String itemName;
  final String itemType;
  final double amount;
  final String? description;
  final DateTime createdAt;

  SalaryDetail({
    required this.id,
    required this.salaryId,
    required this.itemName,
    required this.itemType,
    required this.amount,
    this.description,
    required this.createdAt,
  });

  factory SalaryDetail.fromJson(Map<String, dynamic> json) {
    return SalaryDetail(
      id: json['id'] as int,
      salaryId: json['salaryId'] as int,
      itemName: json['itemName'] as String,
      itemType: json['itemType'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salaryId': salaryId,
      'itemName': itemName,
      'itemType': itemType,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SalaryStatistics {
  final String month;
  final int totalEmployees;
  final double totalSalaryPaid;
  final double averageSalary;
  final double maxSalary;
  final double minSalary;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  SalaryStatistics({
    required this.month,
    required this.totalEmployees,
    required this.totalSalaryPaid,
    required this.averageSalary,
    required this.maxSalary,
    required this.minSalary,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
  });

  factory SalaryStatistics.fromJson(Map<String, dynamic> json) {
    return SalaryStatistics(
      month: json['month'] as String,
      totalEmployees: json['totalEmployees'] as int,
      totalSalaryPaid: (json['totalSalaryPaid'] as num).toDouble(),
      averageSalary: (json['averageSalary'] as num).toDouble(),
      maxSalary: (json['maxSalary'] as num).toDouble(),
      minSalary: (json['minSalary'] as num).toDouble(),
      pendingCount: json['pendingCount'] as int,
      approvedCount: json['approvedCount'] as int,
      rejectedCount: json['rejectedCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'totalEmployees': totalEmployees,
      'totalSalaryPaid': totalSalaryPaid,
      'averageSalary': averageSalary,
      'maxSalary': maxSalary,
      'minSalary': minSalary,
      'pendingCount': pendingCount,
      'approvedCount': approvedCount,
      'rejectedCount': rejectedCount,
    };
  }
}
