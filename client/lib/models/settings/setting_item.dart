import 'package:flutter/foundation.dart';

/// 配置项类型枚举
enum SettingType {
  string,
  number,
  boolean,
  select,
  textarea,
  password,
  datetime,
  shortcut,
}

/// SettingType的扩展方法
extension SettingTypeExtension on SettingType {
  // 获取中文显示名称
  String get displayName {
    switch (this) {
      case SettingType.string:
        return '字符串';
      case SettingType.number:
        return '数字';
      case SettingType.boolean:
        return '布尔值';
      case SettingType.select:
        return '下拉选择';
      case SettingType.textarea:
        return '多行文本';
      case SettingType.password:
        return '密码';
      case SettingType.datetime:
        return '日期时间';
      case SettingType.shortcut:
        return '快捷键';
      default:
        return '未知';
    }
  }
}

/// 配置项模型
class SettingItem {
  final String id;
  final String key;
  final String name;
  final String category;
  final String? parentKey;
  final SettingType type;
  final dynamic value;
  final List<Map<String, dynamic>>? options;
  final String description;
  final bool required;
  final bool editable;
  final String? validationRule;
  final String? defaultValue;
  final String? unit;
  final bool isSystem;

  SettingItem({
    required this.id,
    required this.key,
    required this.name,
    required this.category,
    this.parentKey,
    required this.type,
    required this.value,
    this.options,
    required this.description,
    this.required = false,
    this.editable = true,
    this.validationRule,
    this.defaultValue,
    this.unit,
    this.isSystem = false,
  });

  // 从JSON创建SettingItem实例
  factory SettingItem.fromJson(Map<String, dynamic> json) {
    // 安全获取字符串值
    String safeGetString(Map<String, dynamic> json, String key, {String defaultValue = ''}) {
      final value = json[key];
      if (value is String) return value;
      if (value != null) return value.toString();
      return defaultValue;
    }
    
    // 安全获取布尔值
    bool safeGetBool(Map<String, dynamic> json, String key, {bool defaultValue = false}) {
      final value = json[key];
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
      return defaultValue;
    }
    
    // 安全获取SettingType
    SettingType safeGetSettingType(Map<String, dynamic> json, String key, {SettingType defaultValue = SettingType.string}) {
      final value = json[key];
      if (value is String) {
        try {
          return SettingType.values.byName(value);
        } catch (e) {
          print('无效的SettingType值: $value, 使用默认值 $defaultValue');
          return defaultValue;
        }
      }
      return defaultValue;
    }
    
    // 安全获取选项列表
    List<Map<String, dynamic>>? safeGetOptions(Map<String, dynamic> json, String key) {
      final value = json[key];
      if (value is List) {
        try {
          return value.whereType<Map<String, dynamic>>().toList();
        } catch (e) {
          print('无效的选项列表: $value, 返回null');
          return null;
        }
      }
      return null;
    }
    
    return SettingItem(
      id: safeGetString(json, 'id'),
      key: safeGetString(json, 'key'),
      name: safeGetString(json, 'name'),
      category: safeGetString(json, 'category'),
      parentKey: json['parentKey'] != null ? safeGetString(json, 'parentKey') : null,
      type: safeGetSettingType(json, 'type'),
      value: json['value'], // 保持原始值，不强制转换
      options: safeGetOptions(json, 'options'),
      description: safeGetString(json, 'description'),
      required: safeGetBool(json, 'required'),
      editable: safeGetBool(json, 'editable', defaultValue: true),
      validationRule: json['validationRule'] != null ? safeGetString(json, 'validationRule') : null,
      defaultValue: json['defaultValue'] != null ? safeGetString(json, 'defaultValue') : null,
      unit: json['unit'] != null ? safeGetString(json, 'unit') : null,
      isSystem: safeGetBool(json, 'isSystem'),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'category': category,
      'parentKey': parentKey,
      'type': type.name,
      'value': value,
      'options': options,
      'description': description,
      'required': required,
      'editable': editable,
      'validationRule': validationRule,
      'defaultValue': defaultValue,
      'unit': unit,
      'isSystem': isSystem,
    };
  }

  // 创建副本，用于编辑
  SettingItem copyWith({
    String? id,
    String? key,
    String? name,
    String? category,
    String? parentKey,
    SettingType? type,
    dynamic value,
    List<Map<String, dynamic>>? options,
    String? description,
    bool? required,
    bool? editable,
    String? validationRule,
    String? defaultValue,
    String? unit,
    bool? isSystem,
  }) {
    return SettingItem(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      category: category ?? this.category,
      parentKey: parentKey ?? this.parentKey,
      type: type ?? this.type,
      value: value ?? this.value,
      options: options ?? this.options,
      description: description ?? this.description,
      required: required ?? this.required,
      editable: editable ?? this.editable,
      validationRule: validationRule ?? this.validationRule,
      defaultValue: defaultValue ?? this.defaultValue,
      unit: unit ?? this.unit,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingItem &&
        other.id == id &&
        other.key == key &&
        other.name == name &&
        other.category == category &&
        other.parentKey == parentKey &&
        other.type == type &&
        other.value == value &&
        listEquals(other.options, options) &&
        other.description == description &&
        other.required == required &&
        other.editable == editable &&
        other.validationRule == validationRule &&
        other.defaultValue == defaultValue &&
        other.unit == unit &&
        other.isSystem == isSystem;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      key,
      name,
      category,
      parentKey,
      type,
      value,
      options,
      description,
      required,
      editable,
      validationRule,
      defaultValue,
      unit,
      isSystem,
    );
  }
}
