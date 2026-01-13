import 'package:hive/hive.dart';
import 'dart:convert';

part 'approval.g.dart';

@HiveType(typeId: 10)
class Approval {
  @HiveField(0)
  final int approvalId;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final int requesterId;
  
  @HiveField(4)
  final String requesterName;
  
  @HiveField(5)
  final int approverId;
  
  @HiveField(6)
  final String approverName;
  
  @HiveField(7)
  final String status;
  
  @HiveField(8)
  final String type;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
  
  @HiveField(11)
  final Map<String, dynamic>? relatedData;
  
  @HiveField(12)
  String? comment;
  
  @HiveField(13)
  bool isSynced;
  
  Approval({
    required this.approvalId,
    required this.title,
    required this.content,
    required this.requesterId,
    required this.requesterName,
    required this.approverId,
    required this.approverName,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.relatedData,
    this.comment,
    this.isSynced = true,
  });
  
  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      approvalId: json['approvalId'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      requesterId: json['requesterId'] ?? 0,
      requesterName: json['requesterName'] ?? '',
      approverId: json['approverId'] ?? 0,
      approverName: json['approverName'] ?? '',
      status: json['status'] ?? 'pending',
      type: json['type'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      relatedData: json['relatedData'] as Map<String, dynamic>?,
      comment: json['comment'],
      isSynced: json['isSynced'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'approvalId': approvalId,
      'title': title,
      'content': content,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'approverId': approverId,
      'approverName': approverName,
      'status': status,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'relatedData': relatedData,
      'comment': comment,
      'isSynced': isSynced,
    };
  }
  
  @override
  String toString() {
    return json.encode(toJson());
  }
}
