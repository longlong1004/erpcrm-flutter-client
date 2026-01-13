import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/services/config_service.dart';

class ApiConfigScreen extends ConsumerStatefulWidget {
  const ApiConfigScreen({super.key});

  @override
  ConsumerState<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends ConsumerState<ApiConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiBaseUrlController = TextEditingController();
  final _connectTimeoutController = TextEditingController();
  final _receiveTimeoutController = TextEditingController();
  final _syncIntervalController = TextEditingController();
  bool _enableAutoSync = true;
  bool _enableWebSocket = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _apiBaseUrlController.dispose();
    _connectTimeoutController.dispose();
    _receiveTimeoutController.dispose();
    _syncIntervalController.dispose();
    super.dispose();
  }

  void _loadConfig() {
    final configService = ref.read(configServiceProvider);
    _apiBaseUrlController.text = configService.getApiBaseUrl();
    _connectTimeoutController.text = configService.getConnectTimeout().toString();
    _receiveTimeoutController.text = configService.getReceiveTimeout().toString();
    _syncIntervalController.text = configService.getSyncInterval().toString();
    _enableAutoSync = configService.isAutoSyncEnabled();
    _enableWebSocket = configService.isWebSocketEnabled();
    setState(() {});
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState?.validate() ?? false) {
      final configService = ref.read(configServiceProvider);
      
      await configService.setApiBaseUrl(_apiBaseUrlController.text);
      await configService.setConnectTimeout(int.parse(_connectTimeoutController.text));
      await configService.setReceiveTimeout(int.parse(_receiveTimeoutController.text));
      await configService.setSyncInterval(int.parse(_syncIntervalController.text));
      await configService.setAutoSyncEnabled(_enableAutoSync);
      await configService.setWebSocketEnabled(_enableWebSocket);

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配置保存成功！'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetConfig() async {
    final configService = ref.read(configServiceProvider);
    await configService.resetToDefaults();
    _loadConfig();
    
    // 显示重置消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('配置已重置为默认值！'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'API配置',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API配置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // API基础地址
                      TextFormField(
                        controller: _apiBaseUrlController,
                        decoration: const InputDecoration(
                          labelText: 'API基础地址',
                          hintText: 'http://localhost:8080/api',
                          border: OutlineInputBorder(),
                          helperText: '示例: http://192.168.1.100:8080/api',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'API地址不能为空';
                          }
                          if (!Uri.tryParse(value!)?.isAbsolute ?? false) {
                            return '请输入有效的URL地址';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 连接超时
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _connectTimeoutController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '连接超时',
                                hintText: '10',
                                border: OutlineInputBorder(),
                                suffixText: '秒',
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return '连接超时不能为空';
                                }
                                final intValue = int.tryParse(value!);
                                if (intValue == null || intValue <= 0) {
                                  return '请输入有效的正整数';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 接收超时
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _receiveTimeoutController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '接收超时',
                                hintText: '10',
                                border: OutlineInputBorder(),
                                suffixText: '秒',
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return '接收超时不能为空';
                                }
                                final intValue = int.tryParse(value!);
                                if (intValue == null || intValue <= 0) {
                                  return '请输入有效的正整数';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 同步间隔
                      TextFormField(
                        controller: _syncIntervalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '同步间隔',
                          hintText: '5',
                          border: OutlineInputBorder(),
                          suffixText: '分钟',
                          helperText: '数据自动同步的时间间隔',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '同步间隔不能为空';
                          }
                          final intValue = int.tryParse(value!);
                          if (intValue == null || intValue <= 0) {
                            return '请输入有效的正整数';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 自动同步开关
                      SwitchListTile(
                        title: const Text('启用自动同步'),
                        subtitle: const Text('网络恢复时自动同步本地数据'),
                        value: _enableAutoSync,
                        onChanged: (value) {
                          setState(() {
                            _enableAutoSync = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // WebSocket开关
                      SwitchListTile(
                        title: const Text('启用WebSocket实时推送'),
                        subtitle: const Text('接收服务器实时数据推送'),
                        value: _enableWebSocket,
                        onChanged: (value) {
                          setState(() {
                            _enableWebSocket = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // 操作按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _resetConfig,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('重置默认值'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _saveConfig,
                            icon: const Icon(Icons.save),
                            label: const Text('保存配置'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
