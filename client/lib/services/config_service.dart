import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

/// 配置服务，用于管理应用配置
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  late Box _configBox;
  bool _isInitialized = false;

  /// 初始化配置服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 打开配置存储箱
    _configBox = await Hive.openBox('app_config');
    _isInitialized = true;
  }

  /// 获取API基础地址
  String getApiBaseUrl() {
    // 如果未初始化，直接返回默认值
    if (!_isInitialized) {
      return 'http://localhost:5078/api';
    }
    return _configBox.get('api_base_url', defaultValue: 'http://localhost:5078/api');
  }

  /// 设置API基础地址
  Future<void> setApiBaseUrl(String baseUrl) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }
    await _configBox.put('api_base_url', baseUrl);
  }

  /// 获取WebSocket地址
  String getWebSocketUrl() {
    final apiUrl = getApiBaseUrl();
    // 将http转为ws，https转为wss
    return apiUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
  }

  /// 获取连接超时时间（秒）
  int getConnectTimeout() {
    // 如果未初始化，直接返回默认值
    if (!_isInitialized) {
      return 10;
    }
    return _configBox.get('connect_timeout', defaultValue: 10);
  }

  /// 设置连接超时时间（秒）
  Future<void> setConnectTimeout(int seconds) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }
    await _configBox.put('connect_timeout', seconds);
  }

  /// 获取接收超时时间（秒）
  int getReceiveTimeout() {
    // 如果未初始化，直接返回默认值
    if (!_isInitialized) {
      return 10;
    }
    return _configBox.get('receive_timeout', defaultValue: 10);
  }

  /// 设置接收超时时间（秒）
  Future<void> setReceiveTimeout(int seconds) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }
    await _configBox.put('receive_timeout', seconds);
  }

  /// 获取同步间隔（分钟）
  int getSyncInterval() {
    // 如果未初始化，直接返回默认值
    if (!_isInitialized) {
      return 5;
    }
    return _configBox.get('sync_interval', defaultValue: 5);
  }

  /// 设置同步间隔（分钟）
  Future<void> setSyncInterval(int minutes) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }
    await _configBox.put('sync_interval', minutes);
  }

  /// 获取是否启用自动同步
  bool isAutoSyncEnabled() {
    // 如果未初始化，直接返回默认值
    if (!_isInitialized) {
      return true;
    }
    return _configBox.get('auto_sync_enabled', defaultValue: true);
  }

  /// 设置是否启用自动同步
  Future<void> setAutoSyncEnabled(bool enabled) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }
    await _configBox.put('auto_sync_enabled', enabled);
  }

  /// 获取是否启用WebSocket
  bool isWebSocketEnabled() {
    // 如果未初始化，直接返回默认值
    if (!_isInitialized) {
      return true;
    }
    return _configBox.get('websocket_enabled', defaultValue: true);
  }

  /// 设置是否启用WebSocket
  Future<void> setWebSocketEnabled(bool enabled) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }
    await _configBox.put('websocket_enabled', enabled);
  }

  /// 重置所有配置到默认值
  Future<void> resetToDefaults() async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }
    await _configBox.clear();
  }
}

/// 配置服务提供者
final configServiceProvider = Provider<ConfigService>((ref) {
  final configService = ConfigService();
  // 尝试初始化，但不等待完成，避免阻塞
  configService.initialize().catchError((error) {
    print('Failed to initialize config service: $error');
  });
  return configService;
});

/// API基础地址提供者
final apiBaseUrlProvider = Provider<String>((ref) {
  final configService = ref.watch(configServiceProvider);
  return configService.getApiBaseUrl();
});

/// WebSocket地址提供者
final webSocketUrlProvider = Provider<String>((ref) {
  final configService = ref.watch(configServiceProvider);
  return configService.getWebSocketUrl();
});
