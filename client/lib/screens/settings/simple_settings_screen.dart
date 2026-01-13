import 'package:flutter/material.dart';
import 'package:erpcrm_client/models/settings/setting_item.dart';

/// 简化版系统设置页面，直接显示模拟数据
class SimpleSettingsScreen extends StatelessWidget {
  const SimpleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接在UI层生成模拟数据，包含所有基本设置项
    final mockSettings = [
      // 系统基础设置
      SettingItem(
        id: '1',
        key: 'system_name',
        name: '系统名称',
        category: 'system',
        type: SettingType.string,
        value: 'ERP+CRM国铁商城系统',
        description: '系统的显示名称',
        required: true,
        editable: true,
        isSystem: true,
      ),
      SettingItem(
        id: '2',
        key: 'system_version',
        name: '系统版本',
        category: 'system',
        type: SettingType.string,
        value: '1.0.0',
        description: '系统的当前版本',
        required: true,
        editable: false,
        isSystem: true,
      ),
      SettingItem(
        id: '3',
        key: 'system_logo',
        name: '系统Logo',
        category: 'system',
        type: SettingType.string,
        value: 'https://example.com/logo.png',
        description: '系统的Logo图片URL',
        required: false,
        editable: true,
      ),
      SettingItem(
        id: '4',
        key: 'system_description',
        name: '系统描述',
        category: 'system',
        type: SettingType.textarea,
        value: 'ERP+CRM国铁商城系统是一款集成了ERP和CRM功能的企业级管理系统，专为铁路行业设计。',
        description: '系统的详细描述信息',
        required: false,
        editable: true,
      ),
      
      // 通知设置
      SettingItem(
        id: '5',
        key: 'enable_notification',
        name: '启用通知',
        category: 'notification',
        type: SettingType.boolean,
        value: true,
        description: '是否启用系统通知',
        required: false,
        editable: true,
      ),
      SettingItem(
        id: '6',
        key: 'notification_email',
        name: '通知邮箱',
        category: 'notification',
        type: SettingType.string,
        value: 'admin@example.com',
        description: '接收系统通知的邮箱地址',
        required: false,
        editable: true,
        validationRule: 'email',
      ),
      SettingItem(
        id: '7',
        key: 'notification_sms',
        name: '通知手机号',
        category: 'notification',
        type: SettingType.string,
        value: '13800138000',
        description: '接收系统通知的手机号',
        required: false,
        editable: true,
        validationRule: 'phone',
      ),
      
      // 安全设置
      SettingItem(
        id: '8',
        key: 'enable_https',
        name: '启用HTTPS',
        category: 'security',
        type: SettingType.boolean,
        value: true,
        description: '是否启用HTTPS加密传输',
        required: false,
        editable: true,
        isSystem: true,
      ),
      SettingItem(
        id: '9',
        key: 'session_timeout',
        name: '会话超时时间',
        category: 'security',
        type: SettingType.number,
        value: 30,
        description: '用户会话超时时间（分钟）',
        required: true,
        editable: true,
        unit: '分钟',
      ),
      SettingItem(
        id: '10',
        key: 'password_strength',
        name: '密码强度要求',
        category: 'security',
        type: SettingType.select,
        value: 'medium',
        options: [
          {'label': '弱', 'value': 'weak'},
          {'label': '中', 'value': 'medium'},
          {'label': '强', 'value': 'strong'},
        ],
        description: '系统要求的密码强度',
        required: true,
        editable: true,
      ),
      
      // 数据设置
      SettingItem(
        id: '11',
        key: 'data_backup_enable',
        name: '启用自动备份',
        category: 'data',
        type: SettingType.boolean,
        value: true,
        description: '是否启用数据自动备份',
        required: false,
        editable: true,
      ),
      SettingItem(
        id: '12',
        key: 'data_backup_interval',
        name: '备份间隔',
        category: 'data',
        type: SettingType.number,
        value: 24,
        description: '数据自动备份的时间间隔（小时）',
        required: true,
        editable: true,
        unit: '小时',
      ),
      SettingItem(
        id: '13',
        key: 'data_retention_days',
        name: '数据保留天数',
        category: 'data',
        type: SettingType.number,
        value: 365,
        description: '系统数据的保留天数',
        required: true,
        editable: true,
        unit: '天',
      ),
      
      // 界面设置
      SettingItem(
        id: '14',
        key: 'default_theme',
        name: '默认主题',
        category: 'interface',
        type: SettingType.select,
        value: 'light',
        options: [
          {'label': '浅色主题', 'value': 'light'},
          {'label': '深色主题', 'value': 'dark'},
          {'label': '自动', 'value': 'auto'},
        ],
        description: '系统的默认主题',
        required: false,
        editable: true,
      ),
      SettingItem(
        id: '15',
        key: 'default_language',
        name: '默认语言',
        category: 'interface',
        type: SettingType.select,
        value: 'zh_CN',
        options: [
          {'label': '简体中文', 'value': 'zh_CN'},
          {'label': 'English', 'value': 'en_US'},
        ],
        description: '系统的默认语言',
        required: true,
        editable: true,
      ),
      SettingItem(
        id: '16',
        key: 'enable_animation',
        name: '启用动画效果',
        category: 'interface',
        type: SettingType.boolean,
        value: true,
        description: '是否启用系统动画效果',
        required: false,
        editable: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('系统设置'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            Text(
              '系统设置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),

            // 配置项列表
            Expanded(
              child: ListView.builder(
                itemCount: mockSettings.length,
                itemBuilder: (context, index) {
                  final setting = mockSettings[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 配置项标题和描述
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      setting.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      setting.description,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 配置项类型和操作按钮
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Chip(
                                    label: Text(
                                      setting.type.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.blue[50],
                                    labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                                  ),
                                  const SizedBox(height: 8),
                                  if (setting.isSystem)
                                    Chip(
                                      label: const Text(
                                        '系统配置',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.grey[100],
                                      labelStyle: TextStyle(color: Colors.grey[700]),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 配置项值显示
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              setting.value?.toString() ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}