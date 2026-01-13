import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 网络状态服务，用于检测网络连接状态
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  Stream<bool>? _connectionStream;

  // 静态初始化标记
  static bool _isInitialized = false;

  /// 初始化网络状态监听
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // 初始网络状态
    final result = await _connectivity.checkConnectivity();
    _isConnected = _mapConnectivityResult(result);

    // 监听网络状态变化
    _connectionStream = _connectivity.onConnectivityChanged
        .map((result) => _mapConnectivityResult(result))
        .distinct();
        
    _isInitialized = true;
  }

  /// 检查当前是否连接到网络
  Future<bool> isConnected() async {
    // 如果未初始化，先初始化
    if (!_isInitialized) {
      await initialize();
    }
    
    final result = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(result);
  }

  /// 获取网络状态流
  Stream<bool> get connectionStream {
    // 如果未初始化，先初始化
    if (!_isInitialized) {
      // 这里不能直接调用initialize()，因为它是异步的
      // 我们将返回一个空流，避免抛出异常
      return Stream.value(_isConnected);
    }
    
    if (_connectionStream == null) {
      return Stream.value(_isConnected);
    }
    return _connectionStream!;
  }

  /// 将List<ConnectivityResult>转换为bool
  bool _mapConnectivityResult(List<ConnectivityResult> result) {
    return result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);
  }
}

/// 网络状态提供器
final networkServiceProvider = Provider<NetworkService>((ref) {
  final networkService = NetworkService();
  networkService.initialize();
  return networkService;
});
