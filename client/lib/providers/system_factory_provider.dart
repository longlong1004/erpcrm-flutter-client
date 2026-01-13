import 'package:riverpod_annotation/riverpod_annotation.dart';
// import '../data/dao/system_factory_dao.dart'; // 文件不存在
// import '../data/sync/system_factory_sync_service.dart'; // 文件不存在
import '../data/database/system_factory_database.dart';
import 'navigation_provider.dart';

part 'system_factory_provider.g.dart';

// ---------------- DAO Provider ----------------

// 系统扩展工厂DAO Provider
@riverpod
SystemFactoryDao systemFactoryDao(SystemFactoryDaoRef ref) {
  return SystemFactoryDao();
}

// ---------------- 业务模块数据 ----------------

// 业务模块列表Provider - 从导航栏数据中动态生成
@riverpod
List<Map<String, dynamic>> businessModules(BusinessModulesRef ref) {
  // 从导航栏数据中提取所有业务模块
  final navigationItems = ref.watch(allNavigationItemsProvider);
  final List<Map<String, dynamic>> modules = [];
  
  // 遍历所有导航项，每个带有route的菜单项都是一个业务模块
  for (final item in navigationItems) {
    if (item.route != null && item.route!.isNotEmpty) {
      // 直接使用完整路由路径作为模块代码，确保唯一性
      final moduleCode = item.route!.substring(1); // 去除开头的斜杠
      
      // 提取模块层级信息
      final routeParts = moduleCode.split('/');
      final moduleLevel = routeParts.length;
      
      modules.add({
        'code': moduleCode,
        'name': item.title,
        'route': item.route,
        'level': moduleLevel,
        'description': item.description ?? '',
        'hasTable': item.tableHeaders != null && item.tableHeaders!.isNotEmpty,
        'hasActions': item.actionButtons != null && item.actionButtons!.isNotEmpty,
      });
    }
  }
  
  // 按模块层级和路由排序
  modules.sort((a, b) {
    final levelComparison = a['level'].compareTo(b['level']);
    if (levelComparison != 0) {
      return levelComparison;
    }
    return a['code'].compareTo(b['code']);
  });
  
  return modules;
}

// ---------------- UI配置状态管理 ----------------

// UI配置状态
class UiConfigState {
  final List<SysUiConfig> configs;
  final bool isLoading;
  final String? error;
  final String? selectedModule;
  final bool isSaving;
  final bool isDeleting;
  final String? operationMessage;
  final List<String> selectedModulePath; // 新增：模块选择路径，支持多级选择

  UiConfigState({
    required this.configs,
    this.isLoading = false,
    this.error,
    this.selectedModule,
    this.isSaving = false,
    this.isDeleting = false,
    this.operationMessage,
    this.selectedModulePath = const [], // 默认为空路径
  });

  UiConfigState copyWith({
    List<SysUiConfig>? configs,
    bool? isLoading,
    String? error,
    String? selectedModule,
    bool? isSaving,
    bool? isDeleting,
    String? operationMessage,
    List<String>? selectedModulePath, // 新增参数
  }) {
    return UiConfigState(
      configs: configs ?? this.configs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedModule: selectedModule ?? this.selectedModule,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      operationMessage: operationMessage ?? this.operationMessage,
      selectedModulePath: selectedModulePath ?? this.selectedModulePath, // 新增参数
    );
  }
}

// UI配置状态管理Notifier
@riverpod
class UiConfigNotifier extends _$UiConfigNotifier {
  @override
  UiConfigState build() {
    // 初始化状态
    return UiConfigState(configs: [], selectedModule: null);
  }

  // 加载指定模块的UI配置
  Future<void> loadConfigsByModule(String moduleCode) async {
    // 获取当前模块路径
    final currentPath = List<String>.from(state.selectedModulePath);
    
    // 检查是否是返回上一级
    if (currentPath.isNotEmpty && currentPath.last == moduleCode) {
      // 如果选择的是当前模块，不做处理
      return;
    }
    
    // 如果选择的是路径中已存在的模块，说明是返回上一级
    if (currentPath.contains(moduleCode)) {
      final index = currentPath.indexOf(moduleCode);
      state = state.copyWith(
        isLoading: true, 
        error: null, 
        selectedModule: moduleCode,
        selectedModulePath: currentPath.sublist(0, index + 1) // 截取到选定模块的路径
      );
    } else {
      // 新的下一级选择，添加到路径
      state = state.copyWith(
        isLoading: true, 
        error: null, 
        selectedModule: moduleCode,
        selectedModulePath: [...currentPath, moduleCode] // 添加新模块到路径
      );
    }
    
    try {
      final configs = await SystemFactoryDao.getUiConfigsByModule(moduleCode);
      state = state.copyWith(configs: configs, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: '加载UI配置失败: $e', isLoading: false);
    }
  }

  // 保存UI配置
  Future<void> saveConfig(SysUiConfig config) async {
    state = state.copyWith(isSaving: true, error: null, operationMessage: '正在保存...');
    try {
      await SystemFactoryDao.saveOrUpdateUiConfig(config);
      // 重新加载配置
      if (state.selectedModule != null) {
        await loadConfigsByModule(state.selectedModule!);
      }
      state = state.copyWith(isSaving: false, operationMessage: '保存成功');
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '保存UI配置失败: $e', operationMessage: null);
    }
  }

  // 批量更新UI配置
  Future<void> updateConfigs(List<SysUiConfig> configs) async {
    state = state.copyWith(isSaving: true, error: null, operationMessage: '正在批量更新...');
    try {
      await SystemFactoryDao.batchSaveUiConfigs(configs);
      // 重新加载配置
      if (state.selectedModule != null) {
        await loadConfigsByModule(state.selectedModule!);
      }
      state = state.copyWith(isSaving: false, operationMessage: '批量更新成功');
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '批量更新UI配置失败: $e', operationMessage: null);
    }
  }
  
  // 删除UI配置
  Future<void> deleteConfig(int id) async {
    state = state.copyWith(isDeleting: true, error: null, operationMessage: '正在删除...');
    try {
      await SystemFactoryDao.deleteUiConfig(id.toString());
      // 重新加载配置
      if (state.selectedModule != null) {
        await loadConfigsByModule(state.selectedModule!);
      }
      state = state.copyWith(isDeleting: false, operationMessage: '删除成功');
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: '删除UI配置失败: $e', operationMessage: null);
    }
  }
  
  // 重置模块路径到首页
  void resetModulePath() {
    state = state.copyWith(selectedModule: null, selectedModulePath: []);
  }
  
  // 导航到指定路径索引的模块
  Future<void> navigateToModulePath(int pathIndex) async {
    if (pathIndex < 0 || pathIndex >= state.selectedModulePath.length) {
      return;
    }
    
    final targetModuleCode = state.selectedModulePath[pathIndex];
    final newPath = state.selectedModulePath.sublist(0, pathIndex + 1);
    
    state = state.copyWith(
      selectedModule: targetModuleCode,
      selectedModulePath: newPath,
      isLoading: true,
      error: null
    );
    
    try {
      final configs = await SystemFactoryDao.getUiConfigsByModule(targetModuleCode);
      state = state.copyWith(configs: configs, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: '加载UI配置失败: $e', isLoading: false);
    }
  }
}

// ---------------- 菜单配置状态管理 ----------------

// 菜单配置状态
class MenuConfigState {
  final List<SysMenuConfig> configs;
  final bool isLoading;
  final String? error;
  final SysMenuConfig? selectedMenu;
  final bool isSaving;
  final bool isDeleting;
  final String? operationMessage;

  MenuConfigState({
    required this.configs,
    this.isLoading = false,
    this.error,
    this.selectedMenu,
    this.isSaving = false,
    this.isDeleting = false,
    this.operationMessage,
  });

  MenuConfigState copyWith({
    List<SysMenuConfig>? configs,
    bool? isLoading,
    String? error,
    SysMenuConfig? selectedMenu,
    bool? isSaving,
    bool? isDeleting,
    String? operationMessage,
  }) {
    return MenuConfigState(
      configs: configs ?? this.configs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedMenu: selectedMenu ?? this.selectedMenu,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      operationMessage: operationMessage ?? this.operationMessage,
    );
  }
}

// 菜单配置状态管理Notifier
@riverpod
class MenuConfigNotifier extends _$MenuConfigNotifier {
  @override
  MenuConfigState build() {
    // 初始化状态
    loadMenuConfigs();
    return MenuConfigState(configs: []);
  }

  // 加载菜单配置
  Future<void> loadMenuConfigs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final configs = await SystemFactoryDao.getAllMenuConfigs();
      state = state.copyWith(configs: configs, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: '加载菜单配置失败: $e', isLoading: false);
    }
  }

  // 保存菜单配置
  Future<void> saveConfig(SysMenuConfig config) async {
    state = state.copyWith(isSaving: true, error: null, operationMessage: '正在保存...');
    try {
      await SystemFactoryDao.saveOrUpdateMenuConfig(config);
      // 重新加载配置
      await loadMenuConfigs();
      state = state.copyWith(isSaving: false, operationMessage: '保存成功');
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '保存菜单配置失败: $e', operationMessage: null);
    }
  }

  // 删除菜单配置
  Future<void> deleteConfig(int id) async {
    state = state.copyWith(isDeleting: true, error: null, operationMessage: '正在删除...');
    try {
      await SystemFactoryDao.deleteMenuConfig(id.toString());
      // 重新加载配置
      await loadMenuConfigs();
      state = state.copyWith(isDeleting: false, operationMessage: '删除成功');
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: '删除菜单配置失败: $e', operationMessage: null);
    }
  }

  // 选择菜单
  void selectMenu(SysMenuConfig? menu) {
    state = state.copyWith(selectedMenu: menu);
  }
}

// ---------------- 同步状态管理 ----------------

// 同步状态
class SyncState {
  final bool isSyncing;
  final bool isSynced;
  final String? lastSyncTime;
  final String? error;
  final String? syncProgress;

  SyncState({
    this.isSyncing = false,
    this.isSynced = false,
    this.lastSyncTime,
    this.error,
    this.syncProgress,
  });

  SyncState copyWith({
    bool? isSyncing,
    bool? isSynced,
    String? lastSyncTime,
    String? error,
    String? syncProgress,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isSynced: isSynced ?? this.isSynced,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error ?? this.error,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }
}

// 同步状态管理Notifier
@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  SyncState build() {
    // 初始化状态
    return SyncState();
  }

  // 同步本地草稿到服务器
  Future<void> syncLocalDrafts() async {
    state = state.copyWith(isSyncing: true, error: null, syncProgress: '准备同步...');
    try {
      final syncService = SystemFactorySyncService();
      final success = await syncService.syncLocalDrafts();
      if (success) {
        final now = DateTime.now().toString();
        state = state.copyWith(
          isSyncing: false,
          isSynced: true,
          lastSyncTime: now,
          syncProgress: '同步成功',
        );
      } else {
        state = state.copyWith(
          isSyncing: false,
          error: '同步失败，请稍后重试',
          syncProgress: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: '同步过程中发生错误: $e',
        syncProgress: null,
      );
    }
  }
}

// ---------------- 发布流程状态管理 ----------------

// 发布状态
class PublishState {
  final bool isPublishing;
  final bool isPublished;
  final String? error;
  final String? publishProgress;

  PublishState({
    this.isPublishing = false,
    this.isPublished = false,
    this.error,
    this.publishProgress,
  });

  PublishState copyWith({
    bool? isPublishing,
    bool? isPublished,
    String? error,
    String? publishProgress,
  }) {
    return PublishState(
      isPublishing: isPublishing ?? this.isPublishing,
      isPublished: isPublished ?? this.isPublished,
      error: error ?? this.error,
      publishProgress: publishProgress ?? this.publishProgress,
    );
  }
}

// 发布状态管理Notifier
@riverpod
class PublishNotifier extends _$PublishNotifier {
  @override
  PublishState build() {
    // 初始化状态
    return PublishState();
  }

  // 模拟发布
  Future<bool> simulatePublish(String publishType) async {
    state = state.copyWith(isPublishing: true, error: null, publishProgress: '准备模拟发布...');
    try {
      final syncService = SystemFactorySyncService();
      final success = await syncService.simulatePublish(publishType);
      state = state.copyWith(
        isPublishing: false, 
        isPublished: success,
        publishProgress: success ? '模拟发布成功' : null
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: '模拟发布失败: $e',
        publishProgress: null,
      );
      return false;
    }
  }

  // 正式发布
  Future<bool> officialPublish(String publishType) async {
    state = state.copyWith(isPublishing: true, error: null, publishProgress: '准备正式发布...');
    try {
      final syncService = SystemFactorySyncService();
      final success = await syncService.officialPublish(publishType);
      state = state.copyWith(
        isPublishing: false, 
        isPublished: success,
        publishProgress: success ? '正式发布成功' : null
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: '正式发布失败: $e',
        publishProgress: null,
      );
      return false;
    }
  }
}
