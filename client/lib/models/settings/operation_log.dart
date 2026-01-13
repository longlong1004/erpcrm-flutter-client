import 'package:hive/hive.dart';
import 'dart:convert';

part 'operation_log.g.dart';

@HiveType(typeId: 100)
class OperationLog {
  @HiveField(0)
  int? id;
  
  @HiveField(1)
  int userId;
  
  @HiveField(2)
  String userName;
  
  @HiveField(3)
  String operationModule;
  
  @HiveField(4)
  String operationType;
  
  @HiveField(5)
  String operationContent;
  
  @HiveField(6)
  String operationResult;
  
  @HiveField(7)
  String errorMessage;
  
  @HiveField(8)
  String clientIp;
  
  @HiveField(9)
  String userAgent;
  
  @HiveField(10)
  DateTime createdAt;
  
  @HiveField(11)
  bool isSynced;

  OperationLog({
    this.id,
    required this.userId,
    required this.userName,
    required this.operationModule,
    required this.operationType,
    required this.operationContent,
    required this.operationResult,
    required this.errorMessage,
    required this.clientIp,
    required this.userAgent,
    required this.createdAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'operationModule': operationModule,
      'operationType': operationType,
      'operationContent': operationContent,
      'operationResult': operationResult,
      'errorMessage': errorMessage,
      'clientIp': clientIp,
      'userAgent': userAgent,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory OperationLog.fromJson(Map<String, dynamic> json) {
    return OperationLog(
      id: json['id']?.toInt(),
      userId: json['userId'].toInt(),
      userName: json['userName'],
      operationModule: json['operationModule'],
      operationType: json['operationType'],
      operationContent: json['operationContent'],
      operationResult: json['operationResult'] ?? '',
      errorMessage: json['errorMessage'] ?? '',
      clientIp: json['clientIp'] ?? '',
      userAgent: json['userAgent'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isSynced: json['isSynced'] ?? true,
    );
  }
}
