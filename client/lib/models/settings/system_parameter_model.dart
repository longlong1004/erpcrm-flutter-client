/// 系统参数模型
class SystemParameter {
  final String id;
  final String paramKey;
  final String paramValue;
  final String paramType;
  final String description;
  final bool isSystem;
  final bool isEncrypted;
  final String? group;
  final String? defaultValue;
  final String? validationRule;
  final String? options;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;

  SystemParameter({
    required this.id,
    required this.paramKey,
    required this.paramValue,
    required this.paramType,
    required this.description,
    required this.isSystem,
    required this.isEncrypted,
    this.group,
    this.defaultValue,
    this.validationRule,
    this.options,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
  });

  // 从JSON创建SystemParameter实例
  factory SystemParameter.fromJson(Map<String, dynamic> json) {
    return SystemParameter(
      id: json['id'] as String,
      paramKey: json['paramKey'] as String,
      paramValue: json['paramValue'] as String,
      paramType: json['paramType'] as String,
      description: json['description'] as String,
      isSystem: json['isSystem'] as bool,
      isEncrypted: json['isEncrypted'] as bool,
      group: json['group'] as String?,
      defaultValue: json['defaultValue'] as String?,
      validationRule: json['validationRule'] as String?,
      options: json['options'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paramKey': paramKey,
      'paramValue': paramValue,
      'paramType': paramType,
      'description': description,
      'isSystem': isSystem,
      'isEncrypted': isEncrypted,
      'group': group,
      'defaultValue': defaultValue,
      'validationRule': validationRule,
      'options': options,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SystemParameter &&
        other.id == id &&
        other.paramKey == paramKey &&
        other.paramValue == paramValue &&
        other.paramType == paramType &&
        other.description == description &&
        other.isSystem == isSystem &&
        other.isEncrypted == isEncrypted &&
        other.group == group &&
        other.defaultValue == defaultValue &&
        other.validationRule == validationRule &&
        other.options == options &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.updatedBy == updatedBy;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      paramKey,
      paramValue,
      paramType,
      description,
      isSystem,
      isEncrypted,
      group,
      defaultValue,
      validationRule,
      options,
      createdAt,
      updatedAt,
      updatedBy,
    );
  }

  // 复制方法，用于更新参数属性
  SystemParameter copyWith({
    String? id,
    String? paramKey,
    String? paramValue,
    String? paramType,
    String? description,
    bool? isSystem,
    bool? isEncrypted,
    String? group,
    String? defaultValue,
    String? validationRule,
    String? options,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return SystemParameter(
      id: id ?? this.id,
      paramKey: paramKey ?? this.paramKey,
      paramValue: paramValue ?? this.paramValue,
      paramType: paramType ?? this.paramType,
      description: description ?? this.description,
      isSystem: isSystem ?? this.isSystem,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      group: group ?? this.group,
      defaultValue: defaultValue ?? this.defaultValue,
      validationRule: validationRule ?? this.validationRule,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// 参数类型枚举
enum ParamType {
  string,
  number,
  boolean,
  email,
  url,
  date,
  time,
  datetime,
  select,
  multiselect,
  textarea,
}

/// 参数类型扩展
extension ParamTypeExtension on ParamType {
  String get displayName {
    switch (this) {
      case ParamType.string:
        return '文本';
      case ParamType.number:
        return '数字';
      case ParamType.boolean:
        return '布尔值';
      case ParamType.email:
        return '邮箱';
      case ParamType.url:
        return 'URL';
      case ParamType.date:
        return '日期';
      case ParamType.time:
        return '时间';
      case ParamType.datetime:
        return '日期时间';
      case ParamType.select:
        return '下拉选择';
      case ParamType.multiselect:
        return '多选';
      case ParamType.textarea:
        return '多行文本';
    }
  }

  String get value {
    return name;
  }

  static ParamType fromValue(String value) {
    return ParamType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ParamType.string,
    );
  }
}