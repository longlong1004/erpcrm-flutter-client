import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/providers/notification_settings_provider.dart';
import 'package:erpcrm_client/models/settings/setting_item.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettingsState = ref.watch(notificationSettingsProvider);
    final notificationSettings = notificationSettingsState.notificationSettings;

    return MainLayout(
      title: '通知设置',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            Text(
              '通知设置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),

            // 通知设置列表
            Expanded(
              child: ListView.builder(
                itemCount: notificationSettings.length,
                itemBuilder: (context, index) {
                  final setting = notificationSettings[index];
                  return _buildSettingItem(context, ref, setting);
                },
              ),
            ),

            // 底部操作按钮
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(notificationSettingsProvider.notifier).resetNotificationSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('通知设置已重置为默认值')),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重置为默认值'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个设置项
  Widget _buildSettingItem(BuildContext context, WidgetRef ref, SettingItem setting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设置项标题和描述
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setting.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        setting.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    setting.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 设置项值编辑器
            _buildSettingEditor(context, ref, setting),
          ],
        ),
      ),
    );
  }

  /// 构建设置项编辑器
  Widget _buildSettingEditor(BuildContext context, WidgetRef ref, SettingItem setting) {
    final notifier = ref.read(notificationSettingsProvider.notifier);

    switch (setting.type) {
      case SettingType.boolean:
        return SwitchListTile.adaptive(
          title: Text(setting.name),
          value: setting.value as bool,
          onChanged: (value) {
            final updatedSetting = setting.copyWith(value: value);
            notifier.updateNotificationSetting(updatedSetting);
          },
          contentPadding: EdgeInsets.zero,
        );

      case SettingType.select:
        return DropdownButtonFormField<dynamic>(
          value: setting.value,
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          items: setting.options?.map((option) {
            return DropdownMenuItem(
              value: option['value'],
              child: Text(option['label'].toString()),
            );
          }).toList(),
          onChanged: (value) {
            final updatedSetting = setting.copyWith(value: value);
            notifier.updateNotificationSetting(updatedSetting);
          },
        );

      case SettingType.string:
      case SettingType.password:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          initialValue: setting.value?.toString(),
          obscureText: setting.type == SettingType.password,
          onChanged: (value) {
            final updatedSetting = setting.copyWith(value: value);
            notifier.updateNotificationSetting(updatedSetting);
          },
        );

      case SettingType.number:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          initialValue: setting.value?.toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final numValue = double.tryParse(value) ?? 0.0;
            final updatedSetting = setting.copyWith(value: numValue);
            notifier.updateNotificationSetting(updatedSetting);
          },
        );

      case SettingType.textarea:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          initialValue: setting.value?.toString(),
          maxLines: 3,
          onChanged: (value) {
            final updatedSetting = setting.copyWith(value: value);
            notifier.updateNotificationSetting(updatedSetting);
          },
        );

      case SettingType.datetime:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          initialValue: setting.value?.toString(),
          onChanged: (value) {
            final updatedSetting = setting.copyWith(value: value);
            notifier.updateNotificationSetting(updatedSetting);
          },
        );

      default:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          initialValue: setting.value?.toString(),
          onChanged: (value) {
            final updatedSetting = setting.copyWith(value: value);
            notifier.updateNotificationSetting(updatedSetting);
          },
        );
    }
  }
}
