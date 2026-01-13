import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/models/settings/setting_item.dart';
import 'package:erpcrm_client/services/config_service.dart';

/// 可交互的系统设置页面，支持配置项编辑和保存
class InteractiveSettingsScreen extends ConsumerStatefulWidget {
  const InteractiveSettingsScreen({super.key});

  @override
  ConsumerState<InteractiveSettingsScreen> createState() => _InteractiveSettingsScreenState();
}

class _InteractiveSettingsScreenState extends ConsumerState<InteractiveSettingsScreen> {
  // 当前编辑的配置项值
  final Map<String, dynamic> _editingValues = {};
  // 已修改的配置项ID
  final Set<String> _editedItems = {};
  // 搜索关键词
  String _searchKeyword = '';
  // 选中的分类
  String _selectedCategory = '全部';
  // 批量保存状态
  bool _isBatchSaving = false;
  // 快捷键配置FocusNode
  final FocusNode _focusNode = FocusNode();
  // 当前正在编辑的快捷键配置项
  SettingItem? _currentShortcutSetting;
  
  @override
  void initState() {
    super.initState();
    // 监听全局键盘事件
    RawKeyboard.instance.addListener(_handleGlobalKeyEvent);
  }
  
  @override
  void dispose() {
    // 移除键盘事件监听
    RawKeyboard.instance.removeListener(_handleGlobalKeyEvent);
    _focusNode.dispose();
    super.dispose();
  }
  
  // 处理全局键盘事件
  void _handleGlobalKeyEvent(RawKeyEvent event) {
    // 监听Ctrl+S保存快捷键
    if (event.isKeyPressed(LogicalKeyboardKey.keyS) && event.isControlPressed) {
      if (event is RawKeyDownEvent) {
        // 执行保存操作
        if (_editedItems.isNotEmpty) {
          _saveAllChanges();
        }
      }
    }
  }

  // 从配置服务获取的设置项列表
  List<SettingItem> get _settings {
    final configService = ref.read(configServiceProvider);
    
    return [
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
        key: 'enable_system_log',
        name: '启用系统日志',
        category: 'system',
        type: SettingType.boolean,
        value: true,
        description: '是否启用系统日志记录',
        required: false,
        editable: true,
      ),
      
      // API配置
      SettingItem(
        id: '9',
        key: 'api_base_url',
        name: 'API基础地址',
        category: 'api',
        type: SettingType.string,
        value: configService.getApiBaseUrl(),
        description: '系统连接的后端API服务地址',
        required: true,
        editable: true,
        validationRule: 'url',
        isSystem: true,
      ),
      SettingItem(
        id: '10',
        key: 'connect_timeout',
        name: '连接超时时间',
        category: 'api',
        type: SettingType.number,
        value: configService.getConnectTimeout(),
        description: 'API请求的连接超时时间（秒）',
        required: true,
        editable: true,
        unit: '秒',
        isSystem: true,
      ),
      SettingItem(
        id: '11',
        key: 'receive_timeout',
        name: '接收超时时间',
        category: 'api',
        type: SettingType.number,
        value: configService.getReceiveTimeout(),
        description: 'API请求的接收超时时间（秒）',
        required: true,
        editable: true,
        unit: '秒',
        isSystem: true,
      ),
      SettingItem(
        id: '12',
        key: 'auto_sync_enabled',
        name: '启用自动同步',
        category: 'api',
        type: SettingType.boolean,
        value: configService.isAutoSyncEnabled(),
        description: '是否启用本地数据自动同步到服务器',
        required: false,
        editable: true,
        isSystem: true,
      ),
      SettingItem(
        id: '13',
        key: 'sync_interval',
        name: '同步间隔',
        category: 'api',
        type: SettingType.number,
        value: configService.getSyncInterval(),
        description: '本地数据自动同步到服务器的间隔时间（分钟）',
        required: true,
        editable: true,
        unit: '分钟',
        isSystem: true,
      ),
      SettingItem(
        id: '14',
        key: 'websocket_enabled',
        name: '启用WebSocket',
        category: 'api',
        type: SettingType.boolean,
        value: configService.isWebSocketEnabled(),
        description: '是否启用WebSocket实时通信',
        required: false,
        editable: true,
        isSystem: true,
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
      
      // 安全设置
      SettingItem(
        id: '7',
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
        id: '8',
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 获取所有分类
    final categories = ['全部', ..._getAllCategories()];
    
    // 过滤配置项
    final filteredSettings = _filterSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('系统设置'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 返回主页面，使用GoRouter的go方法确保导航到正确页面
            GoRouter.of(context).go('/dashboard');
          },
        ),
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

            // 系统设置子页面导航
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '系统设置子页面',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F1F1F),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            GoRouter.of(context).go('/settings/process-design');
                          },
                          icon: const Icon(Icons.assignment_ind),
                          label: const Text('流程设计'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            GoRouter.of(context).go('/settings/system-factory');
                          },
                          icon: const Icon(Icons.factory_outlined),
                          label: const Text('系统扩展工厂'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 搜索和筛选栏
            _buildSearchAndFilterBar(categories),
            const SizedBox(height: 24),

            // 批量操作按钮
            _buildBatchOperationButtons(),
            const SizedBox(height: 24),

            // 配置项列表
            Expanded(
              child: ListView.builder(
                itemCount: filteredSettings.length,
                itemBuilder: (context, index) {
                  final setting = filteredSettings[index];
                  return _buildSettingItem(setting);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 获取所有分类
  List<String> _getAllCategories() {
    final categories = <String>{};
    for (final setting in _settings) {
      categories.add(setting.category);
    }
    return categories.toList()..sort();
  }

  // 过滤配置项
  List<SettingItem> _filterSettings() {
    var filtered = _settings;
    
    // 按分类筛选
    if (_selectedCategory != '全部') {
      filtered = filtered.where((setting) => setting.category == _selectedCategory).toList();
    }
    
    // 按关键词搜索
    if (_searchKeyword.isNotEmpty) {
      final lowerKeyword = _searchKeyword.toLowerCase();
      filtered = filtered.where((setting) {
        return setting.name.toLowerCase().contains(lowerKeyword) ||
               setting.description.toLowerCase().contains(lowerKeyword) ||
               setting.key.toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    
    return filtered;
  }

  // 构建搜索和筛选栏
  Widget _buildSearchAndFilterBar(List<String> categories) {
    return Row(
      children: [
        // 搜索框
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchKeyword = value;
              });
            },
            decoration: InputDecoration(
              hintText: '搜索配置项...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 分类筛选
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // 构建批量操作按钮
  Widget _buildBatchOperationButtons() {
    if (_editedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _isBatchSaving ? null : _saveAllChanges,
          icon: _isBatchSaving ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
          label: Text(_isBatchSaving ? '保存中...' : '保存所有更改'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: _isBatchSaving ? null : _cancelAllChanges,
          icon: const Icon(Icons.cancel),
          label: const Text('取消所有更改'),
        ),
        const SizedBox(width: 12),
        Chip(
          label: Text('已修改 ${_editedItems.length} 项'),
          backgroundColor: Colors.blue[50],
          labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
        ),
      ],
    );
  }

  // 构建单个配置项
  Widget _buildSettingItem(SettingItem setting) {
    // 获取当前值（编辑值或原始值）
    final currentValue = _editingValues[setting.key] ?? setting.value;
    // 是否正在编辑
    final isEditing = _editedItems.contains(setting.id);

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
                // 配置项类型标签（显示中文）
                Chip(
                  label: Text(
                    setting.type.displayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 配置项值编辑区域
            if (setting.editable)
              _buildEditableValue(setting, currentValue, isEditing)
            else
              _buildReadonlyValue(setting, currentValue),
          ],
        ),
      ),
    );
  }

  // 构建可编辑的值
  Widget _buildEditableValue(SettingItem setting, dynamic currentValue, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 根据配置项类型显示不同的编辑器
        _buildInputField(setting, currentValue),
        const SizedBox(height: 12),
        // 操作按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isEditing)
              TextButton(
                onPressed: () => _saveSetting(setting),
                child: const Text('保存'),
              )
            else
              TextButton(
                onPressed: () => _startEditing(setting),
                child: const Text('编辑'),
              ),
            const SizedBox(width: 8),
            if (isEditing)
              TextButton(
                onPressed: () => _cancelEditing(setting),
                child: const Text('取消'),
              )
            else
              TextButton.icon(
                onPressed: () => _resetSetting(setting),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重置'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 构建只读值
  Widget _buildReadonlyValue(SettingItem setting, dynamic currentValue) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatValue(currentValue, setting),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: () => _resetSetting(setting),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('重置'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  // 构建输入字段
  Widget _buildInputField(SettingItem setting, dynamic currentValue) {
    switch (setting.type) {
      case SettingType.string:
      case SettingType.password:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
            suffixText: setting.unit,
          ),
          obscureText: setting.type == SettingType.password,
          initialValue: currentValue?.toString(),
          onChanged: (value) => _updateEditingValue(setting, value),
        );
      case SettingType.number:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
            suffixText: setting.unit,
          ),
          keyboardType: TextInputType.number,
          initialValue: currentValue?.toString(),
          onChanged: (value) {
            final numValue = double.tryParse(value);
            if (numValue != null || value.isEmpty) {
              _updateEditingValue(setting, numValue);
            }
          },
        );
      case SettingType.boolean:
        return SwitchListTile.adaptive(
          title: Text(setting.name),
          value: currentValue as bool,
          onChanged: (value) => _updateEditingValue(setting, value),
          contentPadding: EdgeInsets.zero,
        );
      case SettingType.select:
        return DropdownButtonFormField<dynamic>(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          value: currentValue,
          items: setting.options?.map((option) {
            return DropdownMenuItem(
              value: option['value'],
              child: Text(option['label'].toString()),
            );
          }).toList(),
          onChanged: (value) => _updateEditingValue(setting, value),
        );
      case SettingType.textarea:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          initialValue: currentValue?.toString(),
          onChanged: (value) => _updateEditingValue(setting, value),
        );
      case SettingType.datetime:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          initialValue: currentValue?.toString(),
          onChanged: (value) => _updateEditingValue(setting, value),
        );
      case SettingType.shortcut:
        return GestureDetector(
          onTap: () {
            // 开始编辑快捷键
            _currentShortcutSetting = setting;
            _focusNode.requestFocus();
          },
          child: Focus(
            focusNode: _focusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                // 获得焦点时，显示提示
                _showSnackBar('按下快捷键进行设置，Esc取消');
              } else {
                // 失去焦点时，清除当前编辑的快捷键配置项
                _currentShortcutSetting = null;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _focusNode.hasFocus && _currentShortcutSetting?.id == setting.id ? Colors.blue : Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    setting.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentValue?.toString() ?? '未设置',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _focusNode.hasFocus && _currentShortcutSetting?.id == setting.id 
                        ? '正在等待快捷键输入...' 
                        : '点击输入框后按下快捷键进行设置',
                    style: TextStyle(
                      fontSize: 12,
                      color: _focusNode.hasFocus && _currentShortcutSetting?.id == setting.id ? Colors.blue : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return TextFormField(
          decoration: InputDecoration(
            labelText: setting.name,
            border: const OutlineInputBorder(),
          ),
          initialValue: currentValue?.toString(),
          onChanged: (value) => _updateEditingValue(setting, value),
        );
    }
  }

  // 格式化值
  String _formatValue(dynamic value, SettingItem setting) {
    if (value == null) return '';
    
    final valueStr = value.toString();
    return setting.unit != null ? '$valueStr ${setting.unit}' : valueStr;
  }

  // 开始编辑
  void _startEditing(SettingItem setting) {
    setState(() {
      _editingValues[setting.key] = setting.value;
      _editedItems.add(setting.id);
    });
  }

  // 更新编辑值
  void _updateEditingValue(SettingItem setting, dynamic value) {
    setState(() {
      _editingValues[setting.key] = value;
      _editedItems.add(setting.id);
    });
  }

  // 保存单个配置项
  void _saveSetting(SettingItem setting) {
    final updatedValue = _editingValues[setting.key];
    final configService = ref.read(configServiceProvider);
    
    // 根据配置项key调用相应的配置服务方法
    Future<void> saveConfig() async {
      switch (setting.key) {
        case 'api_base_url':
          await configService.setApiBaseUrl(updatedValue as String);
          break;
        case 'connect_timeout':
          await configService.setConnectTimeout((updatedValue as double).toInt());
          break;
        case 'receive_timeout':
          await configService.setReceiveTimeout((updatedValue as double).toInt());
          break;
        case 'auto_sync_enabled':
          await configService.setAutoSyncEnabled(updatedValue as bool);
          break;
        case 'sync_interval':
          await configService.setSyncInterval((updatedValue as double).toInt());
          break;
        case 'websocket_enabled':
          await configService.setWebSocketEnabled(updatedValue as bool);
          break;
        // 其他配置项可以在这里添加
        default:
          // 对于不支持的配置项，只显示成功消息
          break;
      }
    }
    
    saveConfig().then((_) {
      setState(() {
        _editingValues.remove(setting.key);
        _editedItems.remove(setting.id);
      });
      _showSnackBar('${setting.name} 保存成功');
    }).catchError((error) {
      _showSnackBar('保存失败: $error');
    });
  }

  // 取消编辑
  void _cancelEditing(SettingItem setting) {
    setState(() {
      _editingValues.remove(setting.key);
      _editedItems.remove(setting.id);
    });
  }

  // 重置配置项
  void _resetSetting(SettingItem setting) {
    final configService = ref.read(configServiceProvider);
    
    // 根据配置项key调用相应的重置方法
    Future<void> resetConfig() async {
      switch (setting.key) {
        case 'api_base_url':
          await configService.setApiBaseUrl('http://localhost:5078/api');
          break;
        case 'connect_timeout':
          await configService.setConnectTimeout(10);
          break;
        case 'receive_timeout':
          await configService.setReceiveTimeout(10);
          break;
        case 'auto_sync_enabled':
          await configService.setAutoSyncEnabled(true);
          break;
        case 'sync_interval':
          await configService.setSyncInterval(5);
          break;
        case 'websocket_enabled':
          await configService.setWebSocketEnabled(true);
          break;
        // 其他配置项可以在这里添加
        default:
          // 对于不支持的配置项，只显示成功消息
          break;
      }
    }
    
    resetConfig().then((_) {
      _showSnackBar('${setting.name} 已重置为默认值');
    }).catchError((error) {
      _showSnackBar('重置失败: $error');
    });
  }

  // 保存所有更改
  void _saveAllChanges() {
    setState(() {
      _isBatchSaving = true;
    });
    
    final configService = ref.read(configServiceProvider);
    
    // 保存所有修改的配置项
    Future<void> saveAllConfig() async {
      for (final setting in _settings) {
        if (_editedItems.contains(setting.id)) {
          final updatedValue = _editingValues[setting.key];
          
          switch (setting.key) {
            case 'api_base_url':
              await configService.setApiBaseUrl(updatedValue as String);
              break;
            case 'connect_timeout':
              await configService.setConnectTimeout((updatedValue as double).toInt());
              break;
            case 'receive_timeout':
              await configService.setReceiveTimeout((updatedValue as double).toInt());
              break;
            case 'auto_sync_enabled':
              await configService.setAutoSyncEnabled(updatedValue as bool);
              break;
            case 'sync_interval':
              await configService.setSyncInterval((updatedValue as double).toInt());
              break;
            case 'websocket_enabled':
              await configService.setWebSocketEnabled(updatedValue as bool);
              break;
            // 其他配置项可以在这里添加
          }
        }
      }
    }
    
    saveAllConfig().then((_) {
      setState(() {
        _isBatchSaving = false;
        _editingValues.clear();
        _editedItems.clear();
      });
      _showSnackBar('所有配置项保存成功');
    }).catchError((error) {
      setState(() {
        _isBatchSaving = false;
      });
      _showSnackBar('保存失败: $error');
    });
  }

  // 取消所有更改
  void _cancelAllChanges() {
    setState(() {
      _editingValues.clear();
      _editedItems.clear();
    });
    _showSnackBar('所有更改已取消');
  }

  // 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
