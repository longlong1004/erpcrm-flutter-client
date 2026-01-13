import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import '../models/device/device.dart';
import '../services/network_service.dart';
import '../services/api_service.dart';
import '../utils/storage.dart';

class DeviceManager {
  static final DeviceManager _instance = DeviceManager._internal();
  factory DeviceManager() => _instance;
  DeviceManager._internal();

  final NetworkService _networkService = NetworkService();
  final ApiService _apiService;
  late Box<Device> _deviceBox;
  bool _isInitialized = false;
  Device? _currentDevice;

  Future<void> initialize() async {
    if (_isInitialized) return;

    Hive.registerAdapter(DeviceAdapter());
    _deviceBox = await Hive.openBox<Device>('devices');

    await _loadCurrentDevice();
    await _registerDevice();

    _isInitialized = true;
  }

  Future<void> _loadCurrentDevice() async {
    final deviceId = await _getDeviceId();
    final devices = _deviceBox.values.where((d) => d.deviceId == deviceId).toList();

    if (devices.isNotEmpty) {
      _currentDevice = devices.first;
    }
  }

  Future<String> _getDeviceId() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('web_device_id');
      if (deviceId == null) {
        deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('web_device_id', deviceId);
      }
      return deviceId!;
    } else if (Platform.isAndroid) {
      return 'android_${await _getAndroidId()}';
    } else if (Platform.isIOS) {
      return 'ios_${await _getIOSId()}';
    } else {
      return 'windows_${await _getWindowsId()}';
    }
  }

  Future<String> _getAndroidId() async {
    // final deviceInfo = DeviceInfoPlugin();
    // return deviceInfo.androidId;
    return 'android_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getIOSId() async {
    // final deviceInfo = DeviceInfoPlugin();
    // return deviceInfo.identifierForVendor ?? 'unknown_ios';
    return 'ios_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getWindowsId() async {
    return 'windows_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getDeviceName() async {
    if (kIsWeb) {
      return 'Web Browser';
    } else if (Platform.isAndroid) {
      // final deviceInfo = DeviceInfoPlugin();
      // return '${deviceInfo.brand} ${deviceInfo.model}';
      return 'Android Device';
    } else if (Platform.isIOS) {
      // final deviceInfo = DeviceInfoPlugin();
      // return '${deviceInfo.model} (${deviceInfo.systemVersion})';
      return 'iOS Device';
    } else {
      return 'Windows Desktop';
    }
  }

  Future<DeviceType> _getDeviceType() async {
    if (kIsWeb) {
      return DeviceType.WINDOWS;
    } else if (Platform.isAndroid) {
      return DeviceType.ANDROID;
    } else if (Platform.isIOS) {
      return DeviceType.IOS;
    } else {
      return DeviceType.WINDOWS;
    }
  }

  Future<String> _getOSVersion() async {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      // final deviceInfo = DeviceInfoPlugin();
      // return 'Android ${deviceInfo.version.release}';
      return 'Android';
    } else if (Platform.isIOS) {
      // final deviceInfo = DeviceInfoPlugin();
      // return 'iOS ${deviceInfo.systemVersion}';
      return 'iOS';
    } else {
      return 'Windows ${Platform.operatingSystemVersion}';
    }
  }

  Future<String> _getAppVersion() async {
    // final packageInfo = await PackageInfo.fromPlatform();
    // return packageInfo.version;
    return '1.0.0';
  }

  Future<void> _registerDevice() async {
    try {
      final currentUser = await StorageManager.getUserInfo();
      if (currentUser == null) return;

      final deviceId = await _getDeviceId();
      final deviceName = await _getDeviceName();
      final deviceType = await _getDeviceType();
      final osVersion = await _getOSVersion();
      final appVersion = await _getAppVersion();

      final device = Device(
        deviceId: deviceId,
        deviceName: deviceName,
        type: deviceType,
        lastActiveTime: DateTime.now(),
        isOnline: true,
        createdAt: DateTime.now(),
        userId: currentUser['id'] as int,
        osVersion: osVersion,
        appVersion: appVersion,
      );

      await _deviceBox.put(deviceId, device);
      _currentDevice = device;

      await _apiService.registerDevice({
        'deviceId': deviceId,
        'deviceName': deviceName,
        'type': deviceType.toString(),
        'osVersion': osVersion,
        'appVersion': appVersion,
      });
    } catch (e) {
      print('Failed to register device: $e');
    }
  }

  Future<void> updateDeviceLastActive() async {
    if (_currentDevice == null) return;

    final updatedDevice = _currentDevice!.copyWith(
      lastActiveTime: DateTime.now(),
      isOnline: true,
    );

    await _deviceBox.put(_currentDevice!.deviceId, updatedDevice);
    _currentDevice = updatedDevice;

    try {
      await _apiService.updateDevice({
        'deviceId': _currentDevice!.deviceId,
        'lastActiveTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update device last active time: $e');
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    if (_currentDevice == null) return;

    final updatedDevice = _currentDevice!.copyWith(
      isOnline: isOnline,
      lastActiveTime: DateTime.now(),
    );

    await _deviceBox.put(_currentDevice!.deviceId, updatedDevice);
    _currentDevice = updatedDevice;

    try {
      await _apiService.updateDeviceStatus({
        'deviceId': _currentDevice!.deviceId,
        'isOnline': isOnline,
      });
    } catch (e) {
      print('Failed to update device online status: $e');
    }
  }

  Future<List<Device>> getAllDevices() async {
    return _deviceBox.values.toList();
  }

  Future<Device?> getCurrentDevice() async {
    return _currentDevice;
  }

  Future<void> cleanupOldDevices() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final devices = _deviceBox.values.where((device) {
      return device.lastActiveTime.isBefore(thirtyDaysAgo);
    }).toList();

    for (final device in devices) {
      await _deviceBox.delete(device.deviceId);
    }
  }
}
