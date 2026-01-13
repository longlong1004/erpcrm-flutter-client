import 'package:flutter/material.dart';
import 'dart:ui';

// 流程引擎数据模型

// 流程状态枚举
enum ProcessStatus {
  draft,      // 草稿
  active,     // 激活
  inactive,   // 停用
  archived,   // 归档
}

// 节点类型枚举
enum NodeType {
  start,          // 开始节点
  approval,       // 审批人节点
  condition,      // 条件分支节点
  auto,           // 自动执行节点
  notification,   // 消息通知节点
  end,            // 结束节点
  functionPage,   // 功能页面节点
}

// 审批模式枚举
enum ApprovalMode {
  sequential,    // 串行/线性审批
  parallel,      // 并行/会签审批
  conditional,   // 条件分支审批
  competitive,   // 抢占/竞争审批
  directManager, // 直属主管审批
}

// 审批规则类型枚举
enum ApprovalRuleType {
  single,        // 单人审批
  andSign,       // 会签（AND）
  orSign,        // 或签（OR）
  sequential,    // 依次审批
}

// 并行审批规则枚举
enum ParallelApprovalRule {
  allAgree,      // 全部同意
  majorityAgree, // 多数同意
}

// 流程变量类型枚举
enum VariableType {
  string,
  number,
  boolean,
  date,
  enumType,
  object,
}

// 流程基本信息类
class Process {
  final String id;
  final String name;
  final String description;
  final ProcessStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? associatedPageRoute;
  final String? associatedPageName;
  final List<ProcessNode> nodes;
  final List<ProcessEdge> edges;
  final List<ProcessVariable> variables;
  final Map<String, dynamic> metadata;

  Process({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.associatedPageRoute,
    this.associatedPageName,
    this.nodes = const [],
    this.edges = const [],
    this.variables = const [],
    this.metadata = const {},
  });

  // 从JSON创建Process实例
  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: ProcessStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      associatedPageRoute: json['associatedPageRoute'],
      associatedPageName: json['associatedPageName'],
      nodes: (json['nodes'] as List).map((e) => ProcessNode.fromJson(e)).toList(),
      edges: (json['edges'] as List).map((e) => ProcessEdge.fromJson(e)).toList(),
      variables: (json['variables'] as List).map((e) => ProcessVariable.fromJson(e)).toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.toString().split('.').last,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'associatedPageRoute': associatedPageRoute,
      'associatedPageName': associatedPageName,
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'edges': edges.map((edge) => edge.toJson()).toList(),
      'variables': variables.map((variable) => variable.toJson()).toList(),
      'metadata': metadata,
    };
  }
}

// 流程节点类
class ProcessNode {
  final String id;
  final NodeType type;
  final String name;
  final Offset position;
  final ApprovalMode? approvalMode;
  final ApprovalRule? approvalRule;
  final List<Condition> conditions;
  final Map<String, dynamic> properties;
  final bool isSelected;

  ProcessNode({
    required this.id,
    required this.type,
    required this.name,
    required this.position,
    this.approvalMode,
    this.approvalRule,
    this.conditions = const [],
    this.properties = const {},
    this.isSelected = false,
  });

  // 从JSON创建ProcessNode实例
  factory ProcessNode.fromJson(Map<String, dynamic> json) {
    return ProcessNode(
      id: json['id'],
      type: NodeType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      name: json['name'],
      position: Offset(json['position']['x'], json['position']['y']),
      approvalMode: json['approvalMode'] != null
          ? ApprovalMode.values.firstWhere((e) => e.toString().split('.').last == json['approvalMode'])
          : null,
      approvalRule: json['approvalRule'] != null
          ? ApprovalRule.fromJson(json['approvalRule'])
          : null,
      conditions: (json['conditions'] as List).map((e) => Condition.fromJson(e)).toList(),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      isSelected: json['isSelected'] ?? false,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'name': name,
      'position': {'x': position.dx, 'y': position.dy},
      'approvalMode': approvalMode?.toString().split('.').last,
      'approvalRule': approvalRule?.toJson(),
      'conditions': conditions.map((condition) => condition.toJson()).toList(),
      'properties': properties,
      'isSelected': isSelected,
    };
  }

  // 复制节点，用于更新属性
  ProcessNode copyWith({
    String? id,
    NodeType? type,
    String? name,
    Offset? position,
    ApprovalMode? approvalMode,
    ApprovalRule? approvalRule,
    List<Condition>? conditions,
    Map<String, dynamic>? properties,
    bool? isSelected,
  }) {
    return ProcessNode(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      position: position ?? this.position,
      approvalMode: approvalMode ?? this.approvalMode,
      approvalRule: approvalRule ?? this.approvalRule,
      conditions: conditions ?? this.conditions,
      properties: properties ?? this.properties,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // 获取节点图标
  IconData get icon {
    switch (type) {
      case NodeType.start:
        return Icons.play_arrow;
      case NodeType.approval:
        return Icons.person;
      case NodeType.condition:
        return Icons.call_split;
      case NodeType.auto:
        return Icons.auto_awesome;
      case NodeType.notification:
        return Icons.notifications;
      case NodeType.end:
        return Icons.stop;
      case NodeType.functionPage:
        return Icons.pageview;
      default:
        return Icons.circle;
    }
  }

  // 获取节点颜色
  Color get color {
    switch (type) {
      case NodeType.start:
        return Colors.green;
      case NodeType.approval:
        return Colors.blue;
      case NodeType.condition:
        return Colors.orange;
      case NodeType.auto:
        return Colors.purple;
      case NodeType.notification:
        return Colors.yellow;
      case NodeType.end:
        return Colors.red;
      case NodeType.functionPage:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

// 流程边（连接线）类
class ProcessEdge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String name;
  final String? conditionExpression;
  final Map<String, dynamic> properties;

  ProcessEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.name = '',
    this.conditionExpression,
    this.properties = const {},
  });

  // 从JSON创建ProcessEdge实例
  factory ProcessEdge.fromJson(Map<String, dynamic> json) {
    return ProcessEdge(
      id: json['id'],
      fromNodeId: json['fromNodeId'],
      toNodeId: json['toNodeId'],
      name: json['name'] ?? '',
      conditionExpression: json['conditionExpression'],
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'name': name,
      'conditionExpression': conditionExpression,
      'properties': properties,
    };
  }

  // 复制边，用于更新属性
  ProcessEdge copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    String? name,
    String? conditionExpression,
    Map<String, dynamic>? properties,
  }) {
    return ProcessEdge(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      name: name ?? this.name,
      conditionExpression: conditionExpression ?? this.conditionExpression,
      properties: properties ?? this.properties,
    );
  }
}

// 审批规则类
class ApprovalRule {
  final ApprovalRuleType type;
  final List<String> approverIds;
  final List<String> approverNames;
  final ParallelApprovalRule? parallelRule;
  final int? majorityThreshold;
  final Map<String, dynamic> properties;
  final List<int>? delegateRuleIds; // 关联的替换审批人规则ID列表

  ApprovalRule({
    required this.type,
    this.approverIds = const [],
    this.approverNames = const [],
    this.parallelRule,
    this.majorityThreshold,
    this.properties = const {},
    this.delegateRuleIds = const [],
  });

  // 从JSON创建ApprovalRule实例
  factory ApprovalRule.fromJson(Map<String, dynamic> json) {
    return ApprovalRule(
      type: ApprovalRuleType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      approverIds: List<String>.from(json['approverIds'] ?? []),
      approverNames: List<String>.from(json['approverNames'] ?? []),
      parallelRule: json['parallelRule'] != null
          ? ParallelApprovalRule.values.firstWhere((e) => e.toString().split('.').last == json['parallelRule'])
          : null,
      majorityThreshold: json['majorityThreshold'],
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      delegateRuleIds: json['delegateRuleIds'] != null
          ? List<int>.from(json['delegateRuleIds'])
          : [],
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'approverIds': approverIds,
      'approverNames': approverNames,
      'parallelRule': parallelRule?.toString().split('.').last,
      'majorityThreshold': majorityThreshold,
      'properties': properties,
      'delegateRuleIds': delegateRuleIds,
    };
  }
  
  // 复制方法
  ApprovalRule copyWith({
    ApprovalRuleType? type,
    List<String>? approverIds,
    List<String>? approverNames,
    ParallelApprovalRule? parallelRule,
    int? majorityThreshold,
    Map<String, dynamic>? properties,
    List<int>? delegateRuleIds,
  }) {
    return ApprovalRule(
      type: type ?? this.type,
      approverIds: approverIds ?? this.approverIds,
      approverNames: approverNames ?? this.approverNames,
      parallelRule: parallelRule ?? this.parallelRule,
      majorityThreshold: majorityThreshold ?? this.majorityThreshold,
      properties: properties ?? this.properties,
      delegateRuleIds: delegateRuleIds ?? this.delegateRuleIds,
    );
  }
}

// 条件类
class Condition {
  final String id;
  final String field;
  final String operator;
  final dynamic value;
  final String? expression;
  final Map<String, dynamic> properties;

  Condition({
    required this.id,
    required this.field,
    required this.operator,
    required this.value,
    this.expression,
    this.properties = const {},
  });

  // 从JSON创建Condition实例
  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id'],
      field: json['field'],
      operator: json['operator'],
      value: json['value'],
      expression: json['expression'],
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field': field,
      'operator': operator,
      'value': value,
      'expression': expression,
      'properties': properties,
    };
  }
}

// 流程变量类
class ProcessVariable {
  final String id;
  final String name;
  final String key;
  final VariableType type;
  final dynamic defaultValue;
  final bool isRequired;
  final List<dynamic>? options;
  final Map<String, dynamic> properties;

  ProcessVariable({
    required this.id,
    required this.name,
    required this.key,
    required this.type,
    this.defaultValue,
    this.isRequired = false,
    this.options,
    this.properties = const {},
  });

  // 从JSON创建ProcessVariable实例
  factory ProcessVariable.fromJson(Map<String, dynamic> json) {
    return ProcessVariable(
      id: json['id'],
      name: json['name'],
      key: json['key'],
      type: VariableType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      defaultValue: json['defaultValue'],
      isRequired: json['isRequired'] ?? false,
      options: json['options'] != null ? List<dynamic>.from(json['options']) : null,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key,
      'type': type.toString().split('.').last,
      'defaultValue': defaultValue,
      'isRequired': isRequired,
      'options': options,
      'properties': properties,
    };
  }
}

// 流程设计向导状态类
class ProcessWizardState {
  final String? processName;
  final String? processDescription;
  final String? selectedPageRoute;
  final String? selectedPageName;
  final List<String> selectedPath;

  ProcessWizardState({
    this.processName,
    this.processDescription,
    this.selectedPageRoute,
    this.selectedPageName,
    this.selectedPath = const [],
  });

  ProcessWizardState copyWith({
    String? processName,
    String? processDescription,
    String? selectedPageRoute,
    String? selectedPageName,
    List<String>? selectedPath,
  }) {
    return ProcessWizardState(
      processName: processName ?? this.processName,
      processDescription: processDescription ?? this.processDescription,
      selectedPageRoute: selectedPageRoute ?? this.selectedPageRoute,
      selectedPageName: selectedPageName ?? this.selectedPageName,
      selectedPath: selectedPath ?? this.selectedPath,
    );
  }
}
