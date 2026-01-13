// 审批人替换日志模型
class ApprovalDelegateLog {
  final int? id;
  final int originalApproverId;
  final String originalApproverName;
  final int delegateApproverId;
  final String delegateApproverName;
  final String processId;
  final String processName;
  final String nodeId;
  final String nodeName;
  final DateTime replaceTime;
  final int triggerRuleId;
  final String triggerRuleName;
  final String? operatorName;
  final String? operatorIp;
  final String? description;
  final String status;
  final DateTime? createdAt;

  ApprovalDelegateLog({
    this.id,
    required this.originalApproverId,
    required this.originalApproverName,
    required this.delegateApproverId,
    required this.delegateApproverName,
    required this.processId,
    required this.processName,
    required this.nodeId,
    required this.nodeName,
    required this.replaceTime,
    required this.triggerRuleId,
    required this.triggerRuleName,
    this.operatorName,
    this.operatorIp,
    this.description,
    required this.status,
    this.createdAt,
  });

  // 从JSON创建对象
  factory ApprovalDelegateLog.fromJson(Map<String, dynamic> json) {
    return ApprovalDelegateLog(
      id: json['id'],
      originalApproverId: json['originalApproverId'],
      originalApproverName: json['originalApproverName'],
      delegateApproverId: json['delegateApproverId'],
      delegateApproverName: json['delegateApproverName'],
      processId: json['processId'],
      processName: json['processName'],
      nodeId: json['nodeId'],
      nodeName: json['nodeName'],
      replaceTime: DateTime.parse(json['replaceTime']),
      triggerRuleId: json['triggerRuleId'],
      triggerRuleName: json['triggerRuleName'],
      operatorName: json['operatorName'],
      operatorIp: json['operatorIp'],
      description: json['description'],
      status: json['status'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
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
      'processId': processId,
      'processName': processName,
      'nodeId': nodeId,
      'nodeName': nodeName,
      'replaceTime': replaceTime.toIso8601String(),
      'triggerRuleId': triggerRuleId,
      'triggerRuleName': triggerRuleName,
      'operatorName': operatorName,
      'operatorIp': operatorIp,
      'description': description,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
