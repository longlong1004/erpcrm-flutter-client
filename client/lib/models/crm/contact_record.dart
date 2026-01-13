import 'package:hive_flutter/hive_flutter.dart';

part 'contact_record.g.dart';

@HiveType(typeId: 9)
class ContactRecord {
  @HiveField(0)
  final int recordId;
  @HiveField(1)
  final int customerId;
  @HiveField(2)
  final int contactId;
  @HiveField(3)
  final String contactType;
  @HiveField(4)
  final String contactDate;
  @HiveField(5)
  final String contactContent;
  @HiveField(6)
  final String contactPerson;
  @HiveField(7)
  final String nextContactPlan;
  @HiveField(8)
  final String contactStatus;
  @HiveField(9)
  final String createdBy;
  @HiveField(10)
  final String createdAt;
  @HiveField(11)
  final String updatedBy;
  @HiveField(12)
  final String updatedAt;

  ContactRecord({
    required this.recordId,
    required this.customerId,
    required this.contactId,
    required this.contactType,
    required this.contactDate,
    required this.contactContent,
    required this.contactPerson,
    required this.nextContactPlan,
    required this.contactStatus,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory ContactRecord.fromJson(Map<String, dynamic> json) {
    return ContactRecord(
      recordId: json['recordId'],
      customerId: json['customerId'],
      contactId: json['contactId'],
      contactType: json['contactType'],
      contactDate: json['contactDate'],
      contactContent: json['contactContent'],
      contactPerson: json['contactPerson'],
      nextContactPlan: json['nextContactPlan'],
      contactStatus: json['contactStatus'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      updatedBy: json['updatedBy'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordId': recordId,
      'customerId': customerId,
      'contactId': contactId,
      'contactType': contactType,
      'contactDate': contactDate,
      'contactContent': contactContent,
      'contactPerson': contactPerson,
      'nextContactPlan': nextContactPlan,
      'contactStatus': contactStatus,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
    };
  }
}