import 'package:flutter/foundation.dart';

// 简化的审批人代理规则模型
class ApprovalDelegateRule {
  final int? id;
  final int originalApproverId;
  final String originalApproverName;
  final int delegateApproverId;
  final String delegateApproverName;
  final DateTime startTime;
  final DateTime endTime;
  final int status;
  final String? description;
  final int? createdBy;
  final DateTime? createdAt;
  final int? updatedBy;
  final DateTime? updatedAt;
  final int? isDeleted;
  final int? syncStatus;
  final List<String>? processIds; // 关联的审批流程ID列表
  final List<String>? nodeIds; // 关联的审批节点ID列表
  final bool isGlobal; // 是否为全局规则（适用于所有流程）

  ApprovalDelegateRule({
    this.id,
    required this.originalApproverId,
    required this.originalApproverName,
    required this.delegateApproverId,
    required this.delegateApproverName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.description,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.isDeleted,
    this.syncStatus,
    this.processIds = const [],
    this.nodeIds = const [],
    this.isGlobal = false,
  });

  // 从JSON创建对象
  factory ApprovalDelegateRule.fromJson(Map<String, dynamic> json) {
    // 安全获取整数值，处理可能的字符串类型
    int _safeInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }
    
    // 安全获取字符串值
    String _safeString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }
    
    // 安全获取日期时间值
    DateTime? _safeDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }
    
    // 安全获取字符串列表
    List<String> _safeStringList(dynamic value) {
      if (value == null) return [];
      if (value is List<String>) return value;
      if (value is List) return value.map((item) => _safeString(item)).toList();
      return [];
    }
    
    return ApprovalDelegateRule(
      id: _safeInt(json['id']),
      originalApproverId: _safeInt(json['originalApproverId']),
      originalApproverName: _safeString(json['originalApproverName']),
      delegateApproverId: _safeInt(json['delegateApproverId']),
      delegateApproverName: _safeString(json['delegateApproverName']),
      startTime: _safeDateTime(json['startTime']) ?? DateTime.now(),
      endTime: _safeDateTime(json['endTime']) ?? DateTime.now().add(const Duration(days: 7)),
      status: _safeInt(json['status'], defaultValue: 1),
      description: _safeString(json['description']),
      createdBy: _safeInt(json['createdBy']),
      createdAt: _safeDateTime(json['createdAt']),
      updatedBy: _safeInt(json['updatedBy']),
      updatedAt: _safeDateTime(json['updatedAt']),
      isDeleted: _safeInt(json['isDeleted'], defaultValue: 0),
      syncStatus: _safeInt(json['syncStatus'], defaultValue: 0),
      processIds: _safeStringList(json['processIds']),
      nodeIds: _safeStringList(json['nodeIds']),
      isGlobal: json['isGlobal'] ?? false,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalApproverId': originalApproverId,
      'originalApproverName': originalApproverName,
      'delegateApproverId': delegateApproverId,
      'delegateApproverName': delegateApproverName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'syncStatus': syncStatus,
      'processIds': processIds,
      'nodeIds': nodeIds,
      'isGlobal': isGlobal,
    };
  }

  // 复制方法
  ApprovalDelegateRule copyWith({
    int? id,
    int? originalApproverId,
    String? originalApproverName,
    int? delegateApproverId,
    String? delegateApproverName,
    DateTime? startTime,
    DateTime? endTime,
    int? status,
    String? description,
    int? createdBy,
    DateTime? createdAt,
    int? updatedBy,
    DateTime? updatedAt,
    int? isDeleted,
    int? syncStatus,
    List<String>? processIds,
    List<String>? nodeIds,
    bool? isGlobal,
  }) {
    return ApprovalDelegateRule(
      id: id ?? this.id,
      originalApproverId: originalApproverId ?? this.originalApproverId,
      originalApproverName: originalApproverName ?? this.originalApproverName,
      delegateApproverId: delegateApproverId ?? this.delegateApproverId,
      delegateApproverName: delegateApproverName ?? this.delegateApproverName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      processIds: processIds ?? this.processIds,
      nodeIds: nodeIds ?? this.nodeIds,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }
}


