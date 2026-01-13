import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/settings/setting_item.dart';
import 'package:erpcrm_client/services/api_service.dart';

// 配置项状态
class SettingsState {
  final bool isLoading;
  final String? errorMessage;
  final List<SettingItem> settings;
  final Map<String, SettingItem> settingsMap;
  final Map<String, List<SettingItem>> settingsByCategory;
  final bool hasFetched;

  SettingsState({
    this.isLoading = false,
    this.errorMessage,
    this.settings = const [],
    this.settingsMap = const {},
    this.settingsByCategory = const {},
    this.hasFetched = false,
  });

  // 复制状态，用于更新
  SettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SettingItem>? settings,
    Map<String, SettingItem>? settingsMap,
    Map<String, List<SettingItem>>? settingsByCategory,
    bool? hasFetched,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      settings: settings ?? this.settings,
      settingsMap: settingsMap ?? this.settingsMap,
      settingsByCategory: settingsByCategory ?? this.settingsByCategory,
      hasFetched: hasFetched ?? this.hasFetched,
    );
  }

  // 获取所有分类
  List<String> getCategories() {
    return settingsByCategory.keys.toList();
  }
}

// 配置项状态管理类
class SettingsNotifier extends StateNotifier<SettingsState> {
  final ApiService _apiService;

  SettingsNotifier(this._apiService) : super(SettingsState());

  // 加载所有配置项
  Future<void> loadSettings() async {
    if (state.hasFetched) return;

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

        // 按key构建map，方便快速查找
        final settingsMap = <String, SettingItem>{};
        for (final setting in settings) {
          settingsMap[setting.key] = setting;
        }

        // 按category构建map，方便分类显示
        final settingsByCategory = <String, List<SettingItem>>{};
        for (final setting in settings) {
          if (!settingsByCategory.containsKey(setting.category)) {
            settingsByCategory[setting.category] = [];
          }
          settingsByCategory[setting.category]!.add(setting);
        }

        state = state.copyWith(
          isLoading: false,
          settings: settings,
          settingsMap: settingsMap,
          settingsByCategory: settingsByCategory,
          hasFetched: true,
        );
      } else {
        throw Exception('Invalid settings data format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载配置项失败: ${e.toString()}',
      );
    }
  }

  // 更新单个配置项
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

        // 更新settingsMap
        final updatedSettingsMap = Map.from(state.settingsMap);
        updatedSettingsMap[updatedSetting.key] = updatedSetting;

        // 更新settingsByCategory
        final updatedSettingsByCategory =
            Map<String, List<SettingItem>>.from(state.settingsByCategory);
        for (final category in updatedSettingsByCategory.keys) {
          updatedSettingsByCategory[category] =
              updatedSettingsByCategory[category]!.map((item) {
            return item.id == updatedSetting.id ? updatedSetting : item;
          }).toList();
        }

        state = state.copyWith(
          isLoading: false,
          settings: updatedSettings,
          settingsMap: updatedSettingsMap as Map<String, SettingItem>,
          settingsByCategory: updatedSettingsByCategory,
        );

        return true;
      } else {
        throw Exception('Invalid update result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '更新配置项失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 批量更新配置项
  Future<bool> batchUpdateSettings(List<SettingItem> settings) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.batchUpdateSettings(
        settings.map((setting) => setting.toJson()).toList(),
      );

      if (result is List<dynamic>) {
        final updatedSettings = result
            .map((item) => SettingItem.fromJson(item as Map<String, dynamic>))
            .toList();

        // 更新settings列表
        final allSettings = List<SettingItem>.from(state.settings);
        for (final updatedSetting in updatedSettings) {
          final index =
              allSettings.indexWhere((item) => item.id == updatedSetting.id);
          if (index != -1) {
            allSettings[index] = updatedSetting;
          }
        }

        // 更新settingsMap
        final updatedSettingsMap =
            Map<String, SettingItem>.from(state.settingsMap);
        for (final updatedSetting in updatedSettings) {
          updatedSettingsMap[updatedSetting.key] = updatedSetting;
        }

        // 更新settingsByCategory
        final updatedSettingsByCategory =
            Map<String, List<SettingItem>>.from(state.settingsByCategory);
        for (final category in updatedSettingsByCategory.keys) {
          updatedSettingsByCategory[category] =
              updatedSettingsByCategory[category]!.map((item) {
            final updated = updatedSettings.firstWhere(
              (updated) => updated.id == item.id,
              orElse: () => item,
            );
            return updated;
          }).toList();
        }

        state = state.copyWith(
          isLoading: false,
          settings: allSettings,
          settingsMap: updatedSettingsMap,
          settingsByCategory: updatedSettingsByCategory,
        );

        return true;
      } else {
        throw Exception('Invalid batch update result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '批量更新配置项失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 重置配置项到默认值
  Future<bool> resetSetting(String settingId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.resetSetting(settingId);

      if (result is Map<String, dynamic>) {
        final resetSetting = SettingItem.fromJson(result);

        // 更新settings列表
        final updatedSettings = state.settings.map((item) {
          return item.id == resetSetting.id ? resetSetting : item;
        }).toList();

        // 更新settingsMap
        final updatedSettingsMap = Map.from(state.settingsMap);
        updatedSettingsMap[resetSetting.key] = resetSetting;

        // 更新settingsByCategory
        final updatedSettingsByCategory =
            Map<String, List<SettingItem>>.from(state.settingsByCategory);
        for (final category in updatedSettingsByCategory.keys) {
          updatedSettingsByCategory[category] =
              updatedSettingsByCategory[category]!.map((item) {
            return item.id == resetSetting.id ? resetSetting : item;
          }).toList();
        }

        state = state.copyWith(
          isLoading: false,
          settings: updatedSettings,
          settingsMap: updatedSettingsMap as Map<String, SettingItem>,
          settingsByCategory: updatedSettingsByCategory,
        );

        return true;
      } else {
        throw Exception('Invalid reset result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '重置配置项失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 创建配置项
  Future<bool> createSetting(SettingItem setting) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.createSetting(setting.toJson());

      if (result is Map<String, dynamic>) {
        final newSetting = SettingItem.fromJson(result);

        // 更新settings列表
        final updatedSettings = [...state.settings, newSetting];

        // 更新settingsMap
        final updatedSettingsMap = Map.from(state.settingsMap);
        updatedSettingsMap[newSetting.key] = newSetting;

        // 更新settingsByCategory
        final updatedSettingsByCategory =
            Map<String, List<SettingItem>>.from(state.settingsByCategory);
        if (!updatedSettingsByCategory.containsKey(newSetting.category)) {
          updatedSettingsByCategory[newSetting.category] = [];
        }
        updatedSettingsByCategory[newSetting.category]!.add(newSetting);

        state = state.copyWith(
          isLoading: false,
          settings: updatedSettings,
          settingsMap: updatedSettingsMap as Map<String, SettingItem>,
          settingsByCategory: updatedSettingsByCategory,
        );

        return true;
      } else {
        throw Exception('Invalid create setting result format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '创建配置项失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 删除配置项
  Future<bool> deleteSetting(String settingId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.deleteSetting(settingId);

      if (result is Map<String, dynamic> && result['success'] == true) {
        // 更新settings列表
        final updatedSettings =
            state.settings.where((item) => item.id != settingId).toList();

        // 更新settingsMap
        final updatedSettingsMap = Map.from(state.settingsMap);
        final settingToDelete = state.settings.firstWhere(
            (item) => item.id == settingId,
            orElse: () => throw Exception('Setting not found'));
        updatedSettingsMap.remove(settingToDelete.key);

        // 更新settingsByCategory
        final updatedSettingsByCategory =
            Map<String, List<SettingItem>>.from(state.settingsByCategory);
        for (final category in updatedSettingsByCategory.keys) {
          updatedSettingsByCategory[category] =
              updatedSettingsByCategory[category]!
                  .where((item) => item.id != settingId)
                  .toList();
          if (updatedSettingsByCategory[category]!.isEmpty) {
            updatedSettingsByCategory.remove(category);
          }
        }

        state = state.copyWith(
          isLoading: false,
          settings: updatedSettings,
          settingsMap: updatedSettingsMap as Map<String, SettingItem>,
          settingsByCategory: updatedSettingsByCategory,
        );

        return true;
      } else {
        throw Exception('Delete setting failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '删除配置项失败: ${e.toString()}',
      );
      return false;
    }
  }

  // 搜索配置项
  List<SettingItem> searchSettings(String keyword) {
    if (keyword.isEmpty) {
      return state.settings;
    }

    final lowerKeyword = keyword.toLowerCase();
    return state.settings.where((setting) {
      return setting.name.toLowerCase().contains(lowerKeyword) ||
          setting.key.toLowerCase().contains(lowerKeyword) ||
          setting.description.toLowerCase().contains(lowerKeyword) ||
          setting.category.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  // 按分类获取配置项
  List<SettingItem> getSettingsByCategory(String category) {
    return state.settingsByCategory[category] ?? [];
  }
}

// 创建settingsNotifierProvider
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return SettingsNotifier(apiService);
});

// 创建配置项搜索Provider
final settingsSearchProvider =
    Provider.family<List<SettingItem>, String>((ref, keyword) {
  final settingsState = ref.watch(settingsNotifierProvider);
  final settingsNotifier = ref.watch(settingsNotifierProvider.notifier);

  return settingsNotifier.searchSettings(keyword);
});

// 创建单个配置项Provider
final settingItemProvider = Provider.family<SettingItem?, String>((ref, key) {
  final settingsState = ref.watch(settingsNotifierProvider);
  return settingsState.settingsMap[key];
});

// 创建分类Provider
final settingsCategoriesProvider = Provider<List<String>>((ref) {
  final settingsState = ref.watch(settingsNotifierProvider);
  return settingsState.getCategories();
});
