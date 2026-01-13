/// 权限模型
class Permission {
  final String id;
  final String name;
  final String code;
  final String type;
  final String description;
  final String? parentId;
  final List<String> childrenIds;
  final String path;
  final String? icon;
  final bool enable;
  final bool isMenu;
  final int sort;

  Permission({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.description,
    this.parentId,
    this.childrenIds = const [],
    required this.path,
    this.icon,
    required this.enable,
    required this.isMenu,
    required this.sort,
  });

  // 从JSON创建Permission实例
  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      parentId: json['parentId'] as String?,
      childrenIds: List<String>.from(json['childrenIds'] as List<dynamic>),
      path: json['path'] as String,
      icon: json['icon'] as String?,
      enable: json['enable'] as bool,
      isMenu: json['isMenu'] as bool,
      sort: json['sort'] as int,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'description': description,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'path': path,
      'icon': icon,
      'enable': enable,
      'isMenu': isMenu,
      'sort': sort,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.type == type &&
        other.description == description &&
        other.parentId == parentId &&
        other.childrenIds == childrenIds &&
        other.path == path &&
        other.icon == icon &&
        other.enable == enable &&
        other.isMenu == isMenu &&
        other.sort == sort;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      code,
      type,
      description,
      parentId,
      childrenIds,
      path,
      icon,
      enable,
      isMenu,
      sort,
    );
  }
  
  // 复制方法，用于更新权限属性
  Permission copyWith({
    String? id,
    String? name,
    String? code,
    String? type,
    String? description,
    String? parentId,
    List<String>? childrenIds,
    String? path,
    String? icon,
    bool? enable,
    bool? isMenu,
    int? sort,
  }) {
    return Permission(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      path: path ?? this.path,
      icon: icon ?? this.icon,
      enable: enable ?? this.enable,
      isMenu: isMenu ?? this.isMenu,
      sort: sort ?? this.sort,
    );
  }
}

/// 角色模型
class Role {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<String> permissionIds;
  final bool enable;
  final bool isSystem;
  final int sort;

  Role({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    this.permissionIds = const [],
    required this.enable,
    required this.isSystem,
    required this.sort,
  });

  // 从JSON创建Role实例
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      permissionIds: List<String>.from(json['permissionIds'] as List<dynamic>),
      enable: json['enable'] as bool,
      isSystem: json['isSystem'] as bool,
      sort: json['sort'] as int,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'permissionIds': permissionIds,
      'enable': enable,
      'isSystem': isSystem,
      'sort': sort,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.description == description &&
        other.permissionIds == permissionIds &&
        other.enable == enable &&
        other.isSystem == isSystem &&
        other.sort == sort;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      code,
      description,
      permissionIds,
      enable,
      isSystem,
      sort,
    );
  }
  
  // 复制方法，用于更新角色属性
  Role copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    List<String>? permissionIds,
    bool? enable,
    bool? isSystem,
    int? sort,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      permissionIds: permissionIds ?? this.permissionIds,
      enable: enable ?? this.enable,
      isSystem: isSystem ?? this.isSystem,
      sort: sort ?? this.sort,
    );
  }
}

/// 用户角色关联模型
class UserRole {
  final String id;
  final String userId;
  final String roleId;
  final String userName;
  final String roleName;
  final DateTime createdAt;

  UserRole({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.userName,
    required this.roleName,
    required this.createdAt,
  });

  // 从JSON创建UserRole实例
  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] as String,
      userId: json['userId'] as String,
      roleId: json['roleId'] as String,
      userName: json['userName'] as String,
      roleName: json['roleName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roleId': roleId,
      'userName': userName,
      'roleName': roleName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRole &&
        other.id == id &&
        other.userId == userId &&
        other.roleId == roleId &&
        other.userName == userName &&
        other.roleName == roleName &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      roleId,
      userName,
      roleName,
      createdAt,
    );
  }
}

/// 操作日志模型
class OperationLog {
  final String id;
  final String userId;
  final String userName;
  final String operationType;
  final String operationModule;
  final String operationContent;
  final String? operationResult;
  final String? errorMessage;
  final String clientIp;
  final String userAgent;
  final DateTime operationTime;

  OperationLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.operationType,
    required this.operationModule,
    required this.operationContent,
    this.operationResult,
    this.errorMessage,
    required this.clientIp,
    required this.userAgent,
    required this.operationTime,
  });

  // 从JSON创建OperationLog实例
  factory OperationLog.fromJson(Map<String, dynamic> json) {
    return OperationLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      operationType: json['operationType'] as String,
      operationModule: json['operationModule'] as String,
      operationContent: json['operationContent'] as String,
      operationResult: json['operationResult'] as String?,
      errorMessage: json['errorMessage'] as String?,
      clientIp: json['clientIp'] as String,
      userAgent: json['userAgent'] as String,
      operationTime: DateTime.parse(json['operationTime'] as String),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'operationType': operationType,
      'operationModule': operationModule,
      'operationContent': operationContent,
      'operationResult': operationResult,
      'errorMessage': errorMessage,
      'clientIp': clientIp,
      'userAgent': userAgent,
      'operationTime': operationTime.toIso8601String(),
    };
  }
}
