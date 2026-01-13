import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shortcut_key.dart';
import '../utils/storage.dart';
import '../services/api_service.dart';

class ShortcutKeyNotifier extends StateNotifier<List<ShortcutKey>> {
  final ApiService _apiService;

  ShortcutKeyNotifier(this._apiService) : super(_getDefaultShortcutKeys());

  static List<ShortcutKey> _getDefaultShortcutKeys() {
    return [
      ShortcutKey(
        id: 'refresh',
        name: '刷新',
        description: '刷新当前页面数据',
        defaultKey: 'F5',
      ),
      ShortcutKey(
        id: 'back',
        name: '返回上一步',
        description: '返回到上一级页面',
        defaultKey: 'ESC',
      ),
    ];
  }

  Future<void> loadShortcutKeys() async {
    try {
      final storage = StorageManager();
      
      try {
        final apiKeys = await _apiService.getShortcutKeys();
        if (apiKeys.isNotEmpty) {
          final shortcutKeys = apiKeys.map((data) => ShortcutKey(
            id: data['functionId'],
            name: data['functionName'],
            description: data['description'],
            defaultKey: data['defaultKey'],
            currentKey: data['currentKey'],
          )).toList();
          
          state = shortcutKeys;
          await StorageManager.saveShortcutKeys(shortcutKeys);
          return;
        }
      } catch (e) {
        print('从服务器加载快捷键失败，使用本地存储: $e');
      }
      
      final savedKeys = await StorageManager.getShortcutKeys();
      
      if (savedKeys.isEmpty) {
        final defaultKeys = _getDefaultShortcutKeys();
        state = defaultKeys;
        await StorageManager.saveShortcutKeys(defaultKeys);
        return;
      }
      
      state = savedKeys;
    } catch (e) {
      print('加载快捷键失败: $e');
      state = _getDefaultShortcutKeys();
    }
  }

  Future<bool> updateShortcutKey(ShortcutKey shortcutKey) async {
    try {
      final storage = StorageManager();
      
      try {
        final id = shortcutKey.id;
        final data = {
          'functionId': shortcutKey.id,
          'functionName': shortcutKey.name,
          'description': shortcutKey.description,
          'defaultKey': shortcutKey.defaultKey,
          'currentKey': shortcutKey.currentKey,
        };
        
        await _apiService.updateShortcutKey(id, data);
      } catch (e) {
        print('同步到服务器失败，仅保存到本地: $e');
      }
      
      final success = await StorageManager.saveShortcutKey(shortcutKey);
      
      if (success) {
        final index = state.indexWhere((k) => k.id == shortcutKey.id);
        if (index != -1) {
          state = [
            ...state.sublist(0, index),
            shortcutKey,
            ...state.sublist(index + 1),
          ];
        }
      }
      
      return success;
    } catch (e) {
      print('更新快捷键失败: $e');
      return false;
    }
  }

  Future<bool> resetShortcutKey(String id) async {
    try {
      final storage = StorageManager();
      final defaultKeys = _getDefaultShortcutKeys();
      final defaultKey = defaultKeys.firstWhere((k) => k.id == id);
      
      try {
        await _apiService.resetSingleShortcutKey(id);
      } catch (e) {
        print('同步到服务器失败，仅保存到本地: $e');
      }
      
      final success = await StorageManager.saveShortcutKey(defaultKey);
      
      if (success) {
        final index = state.indexWhere((k) => k.id == id);
        if (index != -1) {
          state = [
            ...state.sublist(0, index),
            defaultKey,
            ...state.sublist(index + 1),
          ];
        }
      }
      
      return success;
    } catch (e) {
      print('重置快捷键失败: $e');
      return false;
    }
  }

  Future<bool> resetAllShortcutKeys() async {
    try {
      final storage = StorageManager();
      final defaultKeys = _getDefaultShortcutKeys();
      
      try {
        await _apiService.resetShortcutKeys();
      } catch (e) {
        print('同步到服务器失败，仅保存到本地: $e');
      }
      
      final success = await StorageManager.saveShortcutKeys(defaultKeys);
      
      if (success) {
        state = defaultKeys;
      }
      
      return success;
    } catch (e) {
      print('重置所有快捷键失败: $e');
      return false;
    }
  }

  bool checkConflict(String newKey, String excludeId) {
    for (final shortcutKey in state) {
      if (shortcutKey.id != excludeId && shortcutKey.currentKey == newKey) {
        return true;
      }
    }
    return false;
  }

  ShortcutKey? getShortcutKeyById(String id) {
    try {
      return state.firstWhere((key) => key.id == id);
    } catch (e) {
      return null;
    }
  }

  static bool checkConflictStatic(List<ShortcutKey> keys, String newKey, String excludeId) {
    for (final shortcutKey in keys) {
      final currentKey = shortcutKey.currentKey ?? shortcutKey.defaultKey;
      if (shortcutKey.id != excludeId && currentKey == newKey) {
        return true;
      }
    }
    return false;
  }

  static ShortcutKey? getShortcutKeyByIdStatic(List<ShortcutKey> keys, String id) {
    try {
      return keys.firstWhere((key) => key.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<String> exportShortcutKeys() async {
    try {
      final data = StorageManager.encodeShortcutKeys(state);
      final timestamp = DateTime.now().toIso8601String().split('.')[0];
      final fileName = 'shortcut_keys_$timestamp.json';
      
      return data;
    } catch (e) {
      print('导出快捷键失败: $e');
      rethrow;
    }
  }

  Future<bool> importShortcutKeys(String data) async {
    try {
      final shortcutKeys = StorageManager.decodeShortcutKeys(data);
      
      if (shortcutKeys.isEmpty) {
        throw Exception('导入的快捷键数据为空');
      }
      
      final success = await StorageManager.saveShortcutKeys(shortcutKeys);
      
      if (success) {
        state = shortcutKeys;
      }
      
      return success;
    } catch (e) {
      print('导入快捷键失败: $e');
      rethrow;
    }
  }
}

final shortcutKeyProvider = StateNotifierProvider<ShortcutKeyNotifier, List<ShortcutKey>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ShortcutKeyNotifier(apiService);
});
