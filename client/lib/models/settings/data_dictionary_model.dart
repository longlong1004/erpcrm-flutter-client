/// 数据字典模型
class DataDictionary {
  final String id;
  final String dictType;
  final String dictCode;
  final String dictName;
  final String dictValue;
  final String? description;
  final int sort;
  final bool status;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;

  DataDictionary({
    required this.id,
    required this.dictType,
    required this.dictCode,
    required this.dictName,
    required this.dictValue,
    this.description,
    required this.sort,
    required this.status,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
  });

  // 从JSON创建DataDictionary实例
  factory DataDictionary.fromJson(Map<String, dynamic> json) {
    return DataDictionary(
      id: json['id'] as String,
      dictType: json['dictType'] as String,
      dictCode: json['dictCode'] as String,
      dictName: json['dictName'] as String,
      dictValue: json['dictValue'] as String,
      description: json['description'] as String?,
      sort: json['sort'] as int,
      status: json['status'] as bool,
      isSystem: json['isSystem'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dictType': dictType,
      'dictCode': dictCode,
      'dictName': dictName,
      'dictValue': dictValue,
      'description': description,
      'sort': sort,
      'status': status,
      'isSystem': isSystem,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataDictionary &&
        other.id == id &&
        other.dictType == dictType &&
        other.dictCode == dictCode &&
        other.dictName == dictName &&
        other.dictValue == dictValue &&
        other.description == description &&
        other.sort == sort &&
        other.status == status &&
        other.isSystem == isSystem &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.updatedBy == updatedBy;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      dictType,
      dictCode,
      dictName,
      dictValue,
      description,
      sort,
      status,
      isSystem,
      createdAt,
      updatedAt,
      updatedBy,
    );
  }

  // 复制方法，用于更新字典属性
  DataDictionary copyWith({
    String? id,
    String? dictType,
    String? dictCode,
    String? dictName,
    String? dictValue,
    String? description,
    int? sort,
    bool? status,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return DataDictionary(
      id: id ?? this.id,
      dictType: dictType ?? this.dictType,
      dictCode: dictCode ?? this.dictCode,
      dictName: dictName ?? this.dictName,
      dictValue: dictValue ?? this.dictValue,
      description: description ?? this.description,
      sort: sort ?? this.sort,
      status: status ?? this.status,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// 数据字典类型模型
class DictionaryType {
  final String typeCode;
  final String typeName;
  final String? description;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  DictionaryType({
    required this.typeCode,
    required this.typeName,
    this.description,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从JSON创建DictionaryType实例
  factory DictionaryType.fromJson(Map<String, dynamic> json) {
    return DictionaryType(
      typeCode: json['typeCode'] as String,
      typeName: json['typeName'] as String,
      description: json['description'] as String?,
      isSystem: json['isSystem'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'typeCode': typeCode,
      'typeName': typeName,
      'description': description,
      'isSystem': isSystem,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}