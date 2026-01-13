import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/device_manager.dart';

/// 设备管理服务提供者
final deviceManagerProvider = Provider<DeviceManager>((ref) {
  final manager = DeviceManager();
  manager.initialize();
  return manager;
});

/// 设备状态提供者
final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((ref) {
  final manager = ref.watch(deviceManagerProvider);
  return DeviceNotifier(manager);
});
