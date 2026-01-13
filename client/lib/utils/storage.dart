import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/shortcut_key.dart';
import './logger_service.dart';

class StorageManager {
  static late Box _appBox;
  static late SharedPreferences _prefs;
  static late FlutterSecureStorage _secureStorage;

  // 存储键常量
  static const String tokenKey = 'auth_token';
  static const String userInfoKey = 'user_info';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String lastSyncTimeKey = 'last_sync_time';
  static const String shortcutKeysKey = 'shortcut_keys';

  /// 初始化存储管理器
  static Future<void> init() async {
    // 初始化Hive
    await Hive.initFlutter();
    _appBox = await Hive.openBox('app_data');

    // 初始化SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // 初始化FlutterSecureStorage
    _secureStorage = const FlutterSecureStorage();
  }

  /// 保存认证令牌
  static Future<void> saveToken(String token) async {
    // 在 Web 平台上，FlutterSecureStorage 可能无法正常工作，使用 SharedPreferences 替代
    await _prefs.setString(tokenKey, token);
  }

  /// 获取认证令牌
  static Future<String?> getToken() async {
    // 在 Web 平台上，FlutterSecureStorage 可能无法正常工作，使用 SharedPreferences 替代
    return _prefs.getString(tokenKey);
  }

  /// 删除认证令牌
  static Future<void> deleteToken() async {
    // 在 Web 平台上，FlutterSecureStorage 可能无法正常工作，使用 SharedPreferences 替代
    await _prefs.remove(tokenKey);
  }

  /// 保存用户信息
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _appBox.put(userInfoKey, userInfo);
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final userInfo = _appBox.get(userInfoKey);
    if (userInfo is Map<String, dynamic>) {
      return userInfo;
    }
    return null;
  }

  /// 删除用户信息
  static Future<void> deleteUserInfo() async {
    await _appBox.delete(userInfoKey);
  }

  /// 清除所有认证信息
  static Future<void> clearAuthInfo() async {
    await deleteToken();
    await deleteUserInfo();
  }

  /// 保存主题模式
  static Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(themeModeKey, themeMode);
  }

  /// 获取主题模式
  static String? getThemeMode() {
    return _prefs.getString(themeModeKey);
  }

  /// 保存语言设置
  static Future<void> saveLanguage(String language) async {
    await _prefs.setString(languageKey, language);
  }

  /// 获取语言设置
  static String? getLanguage() {
    return _prefs.getString(languageKey);
  }

  /// 保存最后同步时间
  static Future<void> saveLastSyncTime(DateTime time) async {
    await _appBox.put(lastSyncTimeKey, time.toIso8601String());
  }

  /// 获取最后同步时间
  static DateTime? getLastSyncTime() {
    final timeStr = _appBox.get(lastSyncTimeKey);
    if (timeStr is String) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  /// 保存通用数据到Hive
  static Future<void> saveData(String key, dynamic value) async {
    await _appBox.put(key, value);
  }

  /// 获取通用数据从Hive
  static dynamic getData(String key) {
    return _appBox.get(key);
  }

  /// 删除通用数据从Hive
  static Future<void> deleteData(String key) async {
    await _appBox.delete(key);
  }

  /// 清除所有数据
  static Future<void> clearAllData() async {
    await _appBox.clear();
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  /// 保存快捷键配置
  static Future<bool> saveShortcutKey(ShortcutKey shortcutKey) async {
    try {
      final shortcutKeys = await getShortcutKeys();
      final index = shortcutKeys.indexWhere((k) => k.id == shortcutKey.id);
      final updatedKeys = index != -1
          ? [...shortcutKeys.sublist(0, index), shortcutKey, ...shortcutKeys.sublist(index + 1)]
          : [...shortcutKeys, shortcutKey];
      
      await _prefs.setString(shortcutKeysKey, encodeShortcutKeys(updatedKeys));
      return true;
    } catch (e) {
        LoggerService.error('保存快捷键失败: $e');
        return false;
      }
  }

  /// 保存所有快捷键配置
  static Future<bool> saveShortcutKeys(List<ShortcutKey> shortcutKeys) async {
    try {
      await _prefs.setString(shortcutKeysKey, encodeShortcutKeys(shortcutKeys));
      return true;
    } catch (e) {
        LoggerService.error('保存快捷键失败: $e');
        return false;
      }
  }

  /// 获取快捷键配置
  static Future<List<ShortcutKey>> getShortcutKeys() async {
    try {
      final data = _prefs.getString(shortcutKeysKey);
      if (data != null) {
        return decodeShortcutKeys(data!);
      }
      return [];
    } catch (e) {
      LoggerService.error('获取快捷键失败: $e');
      return [];
    }
  }

  /// 编码快捷键列表为JSON字符串
  static String encodeShortcutKeys(List<ShortcutKey> shortcutKeys) {
    try {
      final List<Map<String, dynamic>> data = shortcutKeys.map((key) => key.toJson()).toList();
      return jsonEncode(data);
    } catch (e) {
      LoggerService.error('编码快捷键失败: $e');
      return '[]';
    }
  }

  /// 解码JSON字符串为快捷键列表
  static List<ShortcutKey> decodeShortcutKeys(String data) {
    try {
      if (data.isEmpty || data == '[]') {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => ShortcutKey.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      LoggerService.error('解码快捷键失败: $e');
      return [];
    }
  }
}
