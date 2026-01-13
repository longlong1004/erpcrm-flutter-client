import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/settings/setting_item.dart';

/// 消息通知设置提供者
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  return NotificationSettingsNotifier();
});

/// 消息通知设置状态
class NotificationSettingsState {
  final bool isEnabled;
  final bool soundEnabled;
  final String soundType;
  final bool vibrationEnabled;
  final bool desktopNotificationsEnabled;
  final List<SettingItem> notificationSettings;

  NotificationSettingsState({
    this.isEnabled = true,
    this.soundEnabled = true,
    this.soundType = 'default',
    this.vibrationEnabled = true,
    this.desktopNotificationsEnabled = true,
    this.notificationSettings = const [],
  });

  NotificationSettingsState copyWith({
    bool? isEnabled,
    bool? soundEnabled,
    String? soundType,
    bool? vibrationEnabled,
    bool? desktopNotificationsEnabled,
    List<SettingItem>? notificationSettings,
  }) {
    return NotificationSettingsState(
      isEnabled: isEnabled ?? this.isEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundType: soundType ?? this.soundType,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      desktopNotificationsEnabled: desktopNotificationsEnabled ?? this.desktopNotificationsEnabled,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

/// 消息通知设置状态管理
class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier() : super(NotificationSettingsState()) {
    // 初始化加载通知设置
    _loadNotificationSettings();
  }

  /// 加载通知设置
  void _loadNotificationSettings() {
    // 模拟加载通知设置，实际应该从API或本地存储获取
    final settings = [
      SettingItem(
        id: '1',
        key: 'notification.enabled',
        name: '启用消息通知',
        category: '通知设置',
        type: SettingType.boolean,
        value: true,
        description: '是否启用消息通知',
        required: false,
        editable: true,
        isSystem: false,
      ),
      SettingItem(
        id: '2',
        key: 'notification.sound.enabled',
        name: '启用通知铃声',
        category: '通知设置',
        type: SettingType.boolean,
        value: true,
        description: '是否启用通知铃声',
        required: false,
        editable: true,
        isSystem: false,
      ),
      SettingItem(
        id: '3',
        key: 'notification.sound.type',
        name: '通知铃声类型',
        category: '通知设置',
        type: SettingType.select,
        value: 'default',
        options: [
          {'value': 'default', 'label': '默认铃声'},
          {'value': 'ringtone1', 'label': '铃声1'},
          {'value': 'ringtone2', 'label': '铃声2'},
          {'value': 'ringtone3', 'label': '铃声3'},
        ],
        description: '选择通知铃声类型',
        required: false,
        editable: true,
        isSystem: false,
      ),
      SettingItem(
        id: '4',
        key: 'notification.vibration.enabled',
        name: '启用震动',
        category: '通知设置',
        type: SettingType.boolean,
        value: true,
        description: '是否启用通知震动',
        required: false,
        editable: true,
        isSystem: false,
      ),
      SettingItem(
        id: '5',
        key: 'notification.desktop.enabled',
        name: '启用桌面通知',
        category: '通知设置',
        type: SettingType.boolean,
        value: true,
        description: '是否启用桌面通知',
        required: false,
        editable: true,
        isSystem: false,
      ),
    ];

    state = state.copyWith(
      notificationSettings: settings,
      isEnabled: settings[0].value as bool,
      soundEnabled: settings[1].value as bool,
      soundType: settings[2].value as String,
      vibrationEnabled: settings[3].value as bool,
      desktopNotificationsEnabled: settings[4].value as bool,
    );
  }

  /// 更新通知设置
  void updateNotificationSetting(SettingItem setting) {
    final updatedSettings = state.notificationSettings.map((s) {
      if (s.id == setting.id) {
        return setting;
      }
      return s;
    }).toList();

    // 更新对应的状态
    switch (setting.key) {
      case 'notification.enabled':
        state = state.copyWith(
          notificationSettings: updatedSettings,
          isEnabled: setting.value as bool,
        );
        break;
      case 'notification.sound.enabled':
        state = state.copyWith(
          notificationSettings: updatedSettings,
          soundEnabled: setting.value as bool,
        );
        break;
      case 'notification.sound.type':
        state = state.copyWith(
          notificationSettings: updatedSettings,
          soundType: setting.value as String,
        );
        break;
      case 'notification.vibration.enabled':
        state = state.copyWith(
          notificationSettings: updatedSettings,
          vibrationEnabled: setting.value as bool,
        );
        break;
      case 'notification.desktop.enabled':
        state = state.copyWith(
          notificationSettings: updatedSettings,
          desktopNotificationsEnabled: setting.value as bool,
        );
        break;
      default:
        state = state.copyWith(notificationSettings: updatedSettings);
    }
  }

  /// 重置通知设置为默认值
  void resetNotificationSettings() {
    _loadNotificationSettings();
  }
}
