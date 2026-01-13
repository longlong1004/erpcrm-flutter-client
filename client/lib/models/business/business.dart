import 'package:hive/hive.dart';

part 'business.g.dart';

@HiveType(typeId: 10)
class Business {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String businessType;
  @HiveField(4)
  final String status;
  @HiveField(5)
  final DateTime? startDate;
  @HiveField(6)
  final DateTime? endDate;
  @HiveField(7)
  final double? amount;
  @HiveField(8)
  final int? customerId;
  @HiveField(9)
  final String? createdBy;
  @HiveField(10)
  final String? updatedBy;
  @HiveField(11)
  final DateTime createdAt;
  @HiveField(12)
  final DateTime updatedAt;

  Business({
    required this.id,
    required this.name,
    this.description,
    required this.businessType,
    required this.status,
    this.startDate,
    this.endDate,
    this.amount,
    this.customerId,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      businessType: json['businessType'],
      status: json['status'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : null,
      customerId: json['customerId'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'businessType': businessType,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'amount': amount,
      'customerId': customerId,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}