import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/permissions/permission_model.dart';
import 'package:erpcrm_client/models/settings/setting_item.dart';
import 'package:erpcrm_client/services/api_service.dart';

// 权限状态
class PermissionsState {
  final bool isLoading;
  final String? errorMessage;
  final List<Permission> permissions;
  final List<Role> roles;
  final List<UserRole> userRoles;
  final List<OperationLog> operationLogs;
  final Map<String, Permission> permissionsMap;
  final Map<String, Role> rolesMap;
  final bool hasFetchedPermissions;
  final bool hasFetchedRoles;
  final bool hasFetchedUserRoles;
  final bool hasFetchedLogs;
  final List<SettingItem> settings;

  PermissionsState({
    this.isLoading = false,
    this.errorMessage,
    this.permissions = const [],
    this.roles = const [],
    this.userRoles = const [],
    this.operationLogs = const [],
    this.permissionsMap = const {},
    this.rolesMap = const {},
    this.hasFetchedPermissions = false,
    this.hasFetchedRoles = false,
    this.hasFetchedUserRoles = false,
    this.hasFetchedLogs = false,
    this.settings = const [],
  });

  // 复制状态，用于更新
  PermissionsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Permission>? permissions,
    List<Role>? roles,
    List<UserRole>? userRoles,
    List<OperationLog>? operationLogs,
    Map<String, Permission>? permissionsMap,
    Map<String, Role>? rolesMap,
    bool? hasFetchedPermissions,
    bool? hasFetchedRoles,
    bool? hasFetchedUserRoles,
    bool? hasFetchedLogs,
    List<SettingItem>? settings,
  }) {
    return PermissionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      permissions: permissions ?? this.permissions,
      roles: roles ?? this.roles,
      userRoles: userRoles ?? this.userRoles,
      operationLogs: operationLogs ?? this.operationLogs,
      permissionsMap: permissionsMap ?? this.permissionsMap,
      rolesMap: rolesMap ?? this.rolesMap,
      hasFetchedPermissions: hasFetchedPermissions ?? this.hasFetchedPermissions,
      hasFetchedRoles: hasFetchedRoles ?? this.hasFetchedRoles,
      hasFetchedUserRoles: hasFetchedUserRoles ?? this.hasFetchedUserRoles,
      hasFetchedLogs: hasFetchedLogs ?? this.hasFetchedLogs,
      settings: settings ?? this.settings,
    );
  }
}

// 权限状态管理类
class PermissionsNotifier extends StateNotifier<PermissionsState> {
  final ApiService _apiService;

  PermissionsNotifier(this._apiService)
      : super(PermissionsState());

  // 加载所有权限
  Future<void> loadPermissions() async {
    if (state.hasFetchedPermissions) return;
    
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getPermissions();
      
      if (result is List<dynamic>) {
        final permissions = result
            .map((item) => Permission.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // 按id构建map，方便快速查找
        final permissionsMap = <String, Permission>{};
        for (final permission in permissions) {
          permissionsMap[permission.id] = permission;
        }
        
        state = state.copyWith(
          isLoading: false,
          permissions: permissions,
          permissionsMap: permissionsMap,
          hasFetchedPermissions: true,
        );
      } else {
        throw Exception('Invalid permissions data format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载权限失败: ${e.toString()}',
      );
    }
  }

  // 加载所有角色
  Future<void> loadRoles() async {
    if (state.hasFetchedRoles) return;
    
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getRoles();
      
      if (result is List<dynamic>) {
        final roles = result
            .map((item) => Role.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // 按id构建map，方便快速查找
        final rolesMap = <String, Role>{};
        for (final role in roles) {
          rolesMap[role.id] = role;
        }
        
        state = state.copyWith(
          isLoading: false,
          roles: roles,
          rolesMap: rolesMap,
          hasFetchedRoles: true,
        );
      } else {
        throw Exception('Invalid roles data format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载角色失败: ${e.toString()}',
      );
    }
  }

  // 加载所有用户角色关联
  Future<void> loadUserRoles() async {
    if (state.hasFetchedUserRoles) return;
    
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getUserRoles();
      
      if (result is List<dynamic>) {
        final userRoles = result
            .map((item) => UserRole.fromJson(item as Map<String, dynamic>))
            .toList();
        
        state = state.copyWith(
          isLoading: false,
          userRoles: userRoles,
          hasFetchedUserRoles: true,
        );
      } else {
        throw Exception('Invalid user roles data format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载用户角色关联失败: ${e.toString()}',
      );
    }
  }

  // 加载操作日志
  Future<void> loadOperationLogs() async {
    if (state.hasFetchedLogs) return;
    
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getOperationLogs();
      
      if (result is List<dynamic>) {
        final operationLogs = result
            .map((item) => OperationLog.fromJson(item as Map<String, dynamic>))
            .toList();
        
        state = state.copyWith(
          isLoading: false,
          operationLogs: operationLogs,
          hasFetchedLogs: true,
        );
      } else {
        throw Exception('Invalid operation logs data format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载操作日志失败: ${e.toString()}',
      );
    }
  }

  // 创建角色
  Future<bool> createRole(Role role) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.createRole(role.toJson());
      
      if (result is Map<String, dynamic>) {
        final newRole = Role.fromJson(result);
        
        // 更新roles列表
        final updatedRoles = [...state.roles, newRole];
        
        // 更新rolesMap
        final updatedRolesMap = <String, Role>{...state.rolesMap};
        updatedRolesMap[newRole.id] = newRole;
        
        state = state.copyWith(
          isLoading: false,
          roles: updatedRoles,
          rolesMap: updatedRolesMap,
        );
        
        // 记录操作日志
        // TODO: 实现日志记录功能
        
        return true;
      } else {
        throw Exception('Invalid create role result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '创建角色失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 更新角色
  Future<bool> updateRole(Role role) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.updateRole(role.toJson());
      
      if (result is Map<String, dynamic>) {
        final updatedRole = Role.fromJson(result);
        
        // 更新roles列表
        final updatedRoles = state.roles.map((item) {
          return item.id == updatedRole.id ? updatedRole : item;
        }).toList();
        
        // 更新rolesMap
        final updatedRolesMap = <String, Role>{...state.rolesMap};
        updatedRolesMap[updatedRole.id] = updatedRole;
        
        state = state.copyWith(
          isLoading: false,
          roles: updatedRoles,
          rolesMap: updatedRolesMap,
        );
        
        // 记录操作日志
        // TODO: 实现日志记录功能
        
        return true;
      } else {
        throw Exception('Invalid update role result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '更新角色失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 删除角色
  Future<bool> deleteRole(String roleId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.deleteRole(roleId);
      
      if (result is Map<String, dynamic> && result['success'] == true) {
        // 更新roles列表
        final updatedRoles = state.roles.where((item) => item.id != roleId).toList();
        
        // 更新rolesMap
        final updatedRolesMap = <String, Role>{...state.rolesMap};
        updatedRolesMap.remove(roleId);
        
        // 更新userRoles列表
        final updatedUserRoles = state.userRoles.where((item) => item.roleId != roleId).toList();
        
        state = state.copyWith(
          isLoading: false,
          roles: updatedRoles,
          rolesMap: updatedRolesMap,
          userRoles: updatedUserRoles,
        );
        
        // 记录操作日志
        // TODO: 实现日志记录功能
        
        return true;
      } else {
        throw Exception('Delete role failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '删除角色失败: ${e.toString()}',
      );
      return false;
    }
  }
  
  // 分配权限给角色
  Future<bool> assignPermissionsToRole(String roleId, List<String> permissionIds) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.assignPermissionsToRole(roleId, permissionIds);
      
      if (result is Map<String, dynamic>) {
        final updatedRole = Role.fromJson(result);
        
        // 更新roles列表
        final updatedRoles = state.roles.map((item) {
          return item.id == updatedRole.id ? updatedRole : item;
        }).toList();
        
        // 更新rolesMap
        final updatedRolesMap = <String, Role>{...state.rolesMap};
        updatedRolesMap[updatedRole.id] = updatedRole;
        
        state = state.copyWith(
          isLoading: false,
          roles: updatedRoles,
          rolesMap: updatedRolesMap,
        );
        
        return true;
      } else {
        throw Exception('Invalid assign permissions result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '分配权限失败: ${e.toString()}',
      );
      return false;
    }
  }
  
  // 更新权限
  Future<bool> updatePermission(Permission permission) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.updatePermission(permission.toJson());
      
      if (result is Map<String, dynamic>) {
        final updatedPermission = Permission.fromJson(result);
        
        // 更新permissions列表
        final updatedPermissions = state.permissions.map((item) {
          return item.id == updatedPermission.id ? updatedPermission : item;
        }).toList();
        
        // 更新permissionsMap
        final updatedPermissionsMap = <String, Permission>{...state.permissionsMap};
        updatedPermissionsMap[updatedPermission.id] = updatedPermission;
        
        state = state.copyWith(
          isLoading: false,
          permissions: updatedPermissions,
          permissionsMap: updatedPermissionsMap,
        );
        
        return true;
      } else {
        throw Exception('Invalid update permission result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '更新权限失败: ${e.toString()}',
      );
      return false;
    }
  }
  
  // 切换权限状态
  Future<bool> togglePermissionStatus(String permissionId) async {
    // 先获取当前权限信息
    final currentPermission = state.permissionsMap[permissionId];
    if (currentPermission == null) {
      state = state.copyWith(
        errorMessage: '权限不存在',
      );
      return false;
    }
    
    // 创建更新后的权限对象
    final updatedPermission = currentPermission.copyWith(
      enable: !currentPermission.enable,
    );
    
    // 调用更新权限方法
    return updatePermission(updatedPermission);
  }
  
  // 分配角色给用户
  Future<bool> assignRolesToUser(String userId, List<String> roleIds) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.assignRolesToUser(userId, roleIds);
      
      if (result is List<dynamic>) {
        final updatedUserRoles = result
            .map((item) => UserRole.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // 更新userRoles列表
        // 先移除该用户的所有现有角色
        final allUserRoles = state.userRoles.where((item) => item.userId != userId).toList();
        // 再添加新分配的角色
        allUserRoles.addAll(updatedUserRoles);
        
        state = state.copyWith(
          isLoading: false,
          userRoles: allUserRoles,
        );
        
        return true;
      } else {
        throw Exception('Invalid assign roles result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '分配角色给用户失败: ${e.toString()}',
      );
      return false;
    }
  }
  
  // 搜索角色
  List<Role> searchRoles(String keyword) {
    if (keyword.isEmpty) {
      return state.roles;
    }
    
    final lowerKeyword = keyword.toLowerCase();
    return state.roles.where((role) {
      return role.name.toLowerCase().contains(lowerKeyword) ||
             role.code.toLowerCase().contains(lowerKeyword) ||
             role.description.toLowerCase().contains(lowerKeyword);
    }).toList();
  }
  
  // 搜索权限
  List<Permission> searchPermissions(String keyword) {
    if (keyword.isEmpty) {
      return state.permissions;
    }
    
    final lowerKeyword = keyword.toLowerCase();
    return state.permissions.where((permission) {
      return permission.name.toLowerCase().contains(lowerKeyword) ||
             permission.code.toLowerCase().contains(lowerKeyword) ||
             permission.description.toLowerCase().contains(lowerKeyword) ||
             permission.type.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  // 加载设置
  Future<void> loadSettings() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getSettings();
      
      if (result is List<dynamic>) {
        final settings = result
            .map((item) => SettingItem.fromJson(item as Map<String, dynamic>))
            .toList();
        
        state = state.copyWith(
          isLoading: false,
          settings: settings,
        );
      } else {
        throw Exception('Invalid settings data format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载设置失败: ${e.toString()}',
      );
    }
  }

  // 更新设置
  Future<bool> updateSetting(SettingItem setting) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.updateSetting(setting.toJson());
      
      if (result is Map<String, dynamic>) {
        final updatedSetting = SettingItem.fromJson(result);
        
        // 更新settings列表
        final updatedSettings = state.settings.map((item) {
          return item.id == updatedSetting.id ? updatedSetting : item;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          settings: updatedSettings,
        );
        
        return true;
      } else {
        throw Exception('Invalid update setting result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '更新设置失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 重置设置
  Future<bool> resetSetting(String settingId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final setting = state.settings.firstWhere(
        (s) => s.id == settingId,
        orElse: () => throw Exception('设置不存在'),
      );

      final updatedSetting = setting.copyWith(value: setting.defaultValue);
      
      final result = await _apiService.updateSetting(updatedSetting.toJson());
      
      if (result is Map<String, dynamic>) {
        final resetSettingItem = SettingItem.fromJson(result);
        
        // 更新settings列表
        final updatedSettings = state.settings.map((item) {
          return item.id == resetSettingItem.id ? resetSettingItem : item;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          settings: updatedSettings,
        );
        
        return true;
      } else {
        throw Exception('Invalid reset setting result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '重置设置失败: ${e.toString()}',
      );
      return false;
    }
  }
}

// 创建permissionsNotifierProvider
final permissionsNotifierProvider = StateNotifierProvider<PermissionsNotifier, PermissionsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PermissionsNotifier(apiService);
});

// 创建角色搜索Provider
final rolesSearchProvider = Provider.family<List<Role>, String>((ref, keyword) {
  final permissionsState = ref.watch(permissionsNotifierProvider);
  final permissionsNotifier = ref.watch(permissionsNotifierProvider.notifier);
  
  return permissionsNotifier.searchRoles(keyword);
});

// 创建权限搜索Provider
final permissionsSearchProvider = Provider.family<List<Permission>, String>((ref, keyword) {
  final permissionsState = ref.watch(permissionsNotifierProvider);
  final permissionsNotifier = ref.watch(permissionsNotifierProvider.notifier);
  
  return permissionsNotifier.searchPermissions(keyword);
});
