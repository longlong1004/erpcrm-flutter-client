import 'package:hive_flutter/hive_flutter.dart';

part 'customer_contact_log.g.dart';

@HiveType(typeId: 7)
class CustomerContactLog {
  @HiveField(0)
  final int contactLogId;
  @HiveField(1)
  final int customerId;
  @HiveField(2)
  final String customerName;
  @HiveField(3)
  final String contactPerson;
  @HiveField(4)
  final String contactWay;
  @HiveField(5)
  final String contactContent;
  @HiveField(6)
  final String contactResult;
  @HiveField(7)
  final DateTime contactTime;
  @HiveField(8)
  final DateTime planNextTime;
  @HiveField(9)
  final int operatorId;
  @HiveField(10)
  final String operatorName;
  @HiveField(11)
  final DateTime createTime;
  @HiveField(12)
  final DateTime updateTime;
  @HiveField(13)
  final bool deleted;

  CustomerContactLog({
    required this.contactLogId,
    required this.customerId,
    required this.customerName,
    required this.contactPerson,
    required this.contactWay,
    required this.contactContent,
    required this.contactResult,
    required this.contactTime,
    required this.planNextTime,
    required this.operatorId,
    required this.operatorName,
    required this.createTime,
    required this.updateTime,
    required this.deleted,
  });

  factory CustomerContactLog.fromJson(Map<String, dynamic> json) {
    return CustomerContactLog(
      contactLogId: json['contactLogId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      contactPerson: json['contactPerson'],
      contactWay: json['contactWay'],
      contactContent: json['contactContent'],
      contactResult: json['contactResult'],
      contactTime: DateTime.parse(json['contactTime']),
      planNextTime: DateTime.parse(json['planNextTime']),
      operatorId: json['operatorId'],
      operatorName: json['operatorName'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
      deleted: json['deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactLogId': contactLogId,
      'customerId': customerId,
      'customerName': customerName,
      'contactPerson': contactPerson,
      'contactWay': contactWay,
      'contactContent': contactContent,
      'contactResult': contactResult,
      'contactTime': contactTime.toIso8601String(),
      'planNextTime': planNextTime.toIso8601String(),
      'operatorId': operatorId,
      'operatorName': operatorName,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'deleted': deleted,
    };
  }
}