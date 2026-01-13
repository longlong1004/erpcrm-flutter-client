import 'package:hive/hive.dart';

part 'system_factory_database.g.dart';

/// 系统UI配置模型
@HiveType(typeId: 100)
class SysUiConfig extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? moduleCode;

  @HiveField(2)
  String? fieldCode;

  @HiveField(3)
  String? fieldName;

  @HiveField(4)
  String? fieldType;

  @HiveField(5)
  String? validationRule;

  @HiveField(6)
  String? validationParams;

  @HiveField(7)
  String? defaultValue;

  @HiveField(8)
  bool? visible;

  @HiveField(9)
  int? displayOrder;

  @HiveField(10)
  DateTime? createdAt;

  @HiveField(11)
  DateTime? updatedAt;

  SysUiConfig({
    this.id,
    this.moduleCode,
    this.fieldCode,
    this.fieldName,
    this.fieldType,
    this.validationRule,
    this.validationParams,
    this.defaultValue,
    this.visible,
    this.displayOrder,
    this.createdAt,
    this.updatedAt,
  });

  SysUiConfig copyWith({
    String? id,
    String? moduleCode,
    String? fieldCode,
    String? fieldName,
    String? fieldType,
    String? validationRule,
    String? validationParams,
    String? defaultValue,
    bool? visible,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SysUiConfig(
      id: id ?? this.id,
      moduleCode: moduleCode ?? this.moduleCode,
      fieldCode: fieldCode ?? this.fieldCode,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      validationRule: validationRule ?? this.validationRule,
      validationParams: validationParams ?? this.validationParams,
      defaultValue: defaultValue ?? this.defaultValue,
      visible: visible ?? this.visible,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleCode': moduleCode,
      'fieldCode': fieldCode,
      'fieldName': fieldName,
      'fieldType': fieldType,
      'validationRule': validationRule,
      'validationParams': validationParams,
      'defaultValue': defaultValue,
      'visible': visible,
      'displayOrder': displayOrder,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SysUiConfig.fromJson(Map<String, dynamic> json) {
    return SysUiConfig(
      id: json['id'] as String?,
      moduleCode: json['moduleCode'] as String?,
      fieldCode: json['fieldCode'] as String?,
      fieldName: json['fieldName'] as String?,
      fieldType: json['fieldType'] as String?,
      validationRule: json['validationRule'] as String?,
      validationParams: json['validationParams'] as String?,
      defaultValue: json['defaultValue'] as String?,
      visible: json['visible'] as bool?,
      displayOrder: json['displayOrder'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// 系统菜单配置模型
@HiveType(typeId: 101)
class SysMenuConfig extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? menuCode;

  @HiveField(2)
  String? menuName;

  @HiveField(3)
  String? parentId;

  @HiveField(4)
  String? icon;

  @HiveField(5)
  String? route;

  @HiveField(6)
  int? displayOrder;

  @HiveField(7)
  bool? visible;

  @HiveField(8)
  DateTime? createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  SysMenuConfig({
    this.id,
    this.menuCode,
    this.menuName,
    this.parentId,
    this.icon,
    this.route,
    this.displayOrder,
    this.visible,
    this.createdAt,
    this.updatedAt,
  });

  SysMenuConfig copyWith({
    String? id,
    String? menuCode,
    String? menuName,
    String? parentId,
    String? icon,
    String? route,
    int? displayOrder,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SysMenuConfig(
      id: id ?? this.id,
      menuCode: menuCode ?? this.menuCode,
      menuName: menuName ?? this.menuName,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      displayOrder: displayOrder ?? this.displayOrder,
      visible: visible ?? this.visible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuCode': menuCode,
      'menuName': menuName,
      'parentId': parentId,
      'icon': icon,
      'route': route,
      'displayOrder': displayOrder,
      'visible': visible,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SysMenuConfig.fromJson(Map<String, dynamic> json) {
    return SysMenuConfig(
      id: json['id'] as String?,
      menuCode: json['menuCode'] as String?,
      menuName: json['menuName'] as String?,
      parentId: json['parentId'] as String?,
      icon: json['icon'] as String?,
      route: json['route'] as String?,
      displayOrder: json['displayOrder'] as int?,
      visible: json['visible'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// 系统工厂数据访问对象
class SystemFactoryDao {
  static const String uiConfigBoxName = 'sys_ui_config';
  static const String menuConfigBoxName = 'sys_menu_config';

  /// 获取UI配置Box
  static Future<Box<SysUiConfig>> getUiConfigBox() async {
    if (!Hive.isBoxOpen(uiConfigBoxName)) {
      return await Hive.openBox<SysUiConfig>(uiConfigBoxName);
    }
    return Hive.box<SysUiConfig>(uiConfigBoxName);
  }

  /// 获取菜单配置Box
  static Future<Box<SysMenuConfig>> getMenuConfigBox() async {
    if (!Hive.isBoxOpen(menuConfigBoxName)) {
      return await Hive.openBox<SysMenuConfig>(menuConfigBoxName);
    }
    return Hive.box<SysMenuConfig>(menuConfigBoxName);
  }

  /// 保存UI配置
  static Future<void> saveUiConfig(SysUiConfig config) async {
    final box = await getUiConfigBox();
    await box.put(config.id, config);
  }

  /// 获取所有UI配置
  static Future<List<SysUiConfig>> getAllUiConfigs() async {
    final box = await getUiConfigBox();
    return box.values.toList();
  }

  /// 根据模块代码获取UI配置
  static Future<List<SysUiConfig>> getUiConfigsByModule(
      String moduleCode) async {
    final box = await getUiConfigBox();
    return box.values
        .where((config) => config.moduleCode == moduleCode)
        .toList();
  }

  /// 删除UI配置
  static Future<void> deleteUiConfig(String id) async {
    final box = await getUiConfigBox();
    await box.delete(id);
  }

  /// 保存菜单配置
  static Future<void> saveMenuConfig(SysMenuConfig config) async {
    final box = await getMenuConfigBox();
    await box.put(config.id, config);
  }

  /// 获取所有菜单配置
  static Future<List<SysMenuConfig>> getAllMenuConfigs() async {
    final box = await getMenuConfigBox();
    return box.values.toList();
  }

  /// 根据父ID获取菜单配置
  static Future<List<SysMenuConfig>> getMenuConfigsByParent(
      String? parentId) async {
    final box = await getMenuConfigBox();
    return box.values
        .where((config) => config.parentId == parentId)
        .toList();
  }

  /// 删除菜单配置
  static Future<void> deleteMenuConfig(String id) async {
    final box = await getMenuConfigBox();
    await box.delete(id);
  }

  /// 清空所有UI配置
  static Future<void> clearAllUiConfigs() async {
    final box = await getUiConfigBox();
    await box.clear();
  }

  /// 清空所有菜单配置
  static Future<void> clearAllMenuConfigs() async {
    final box = await getMenuConfigBox();
    await box.clear();
  }
}
