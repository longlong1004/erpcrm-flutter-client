import 'package:hive_flutter/hive_flutter.dart';

part 'sales_opportunity.g.dart';

@HiveType(typeId: 8)
class SalesOpportunity {
  @HiveField(0)
  final int opportunityId;
  @HiveField(1)
  final int customerId;
  @HiveField(2)
  final String customerName;
  @HiveField(3)
  final String opportunityName;
  @HiveField(4)
  final double expectedAmount;
  @HiveField(5)
  final String stage;
  @HiveField(6)
  final String probability;
  @HiveField(7)
  final DateTime expectedCloseDate;
  @HiveField(8)
  final String responsiblePerson;
  @HiveField(9)
  final String description;
  @HiveField(10)
  final DateTime createTime;
  @HiveField(11)
  final DateTime updateTime;
  @HiveField(12)
  final bool deleted;

  SalesOpportunity({
    required this.opportunityId,
    required this.customerId,
    required this.customerName,
    required this.opportunityName,
    required this.expectedAmount,
    required this.stage,
    required this.probability,
    required this.expectedCloseDate,
    required this.responsiblePerson,
    required this.description,
    required this.createTime,
    required this.updateTime,
    required this.deleted,
  });

  factory SalesOpportunity.fromJson(Map<String, dynamic> json) {
    return SalesOpportunity(
      opportunityId: json['opportunityId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      opportunityName: json['opportunityName'],
      expectedAmount: json['expectedAmount'].toDouble(),
      stage: json['stage'],
      probability: json['probability'],
      expectedCloseDate: DateTime.parse(json['expectedCloseDate']),
      responsiblePerson: json['responsiblePerson'],
      description: json['description'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
      deleted: json['deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opportunityId': opportunityId,
      'customerId': customerId,
      'customerName': customerName,
      'opportunityName': opportunityName,
      'expectedAmount': expectedAmount,
      'stage': stage,
      'probability': probability,
      'expectedCloseDate': expectedCloseDate.toIso8601String(),
      'responsiblePerson': responsiblePerson,
      'description': description,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'deleted': deleted,
    };
  }
}