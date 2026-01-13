import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/providers/shortcut_key_provider.dart';
import 'package:erpcrm_client/models/shortcut_key.dart';

class ShortcutKeySettingsScreen extends ConsumerStatefulWidget {
  const ShortcutKeySettingsScreen({super.key});

  @override
  ConsumerState<ShortcutKeySettingsScreen> createState() => _ShortcutKeySettingsScreenState();
}

class _ShortcutKeySettingsScreenState extends ConsumerState<ShortcutKeySettingsScreen> {
  String? _capturedKey;
  bool _isCapturing = false;
  String? _capturingKeyId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showEditShortcutKeyDialog(ShortcutKey shortcutKey) {
    _isCapturing = false;
    _capturedKey = null;
    _capturingKeyId = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('编辑${shortcutKey.name}快捷键'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortcutKey.description,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('当前快捷键: '),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003366),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          shortcutKey.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('默认: ${shortcutKey.defaultKey}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '设置新的快捷键:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  // 修复条件渲染语法
                  (_isCapturing && _capturingKeyId == shortcutKey.id)
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF003366), width: 2),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(Icons.keyboard, size: 48, color: const Color(0xFF003366)),
                                const SizedBox(height: 8),
                                Text(
                                  '请按下键盘上的按键...',
                                  style: TextStyle(fontSize: 14, color: const Color(0xFF003366)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (event) {
                            if (event is KeyDownEvent) {
                              final key = event.logicalKey.keyLabel;
                              if (key != 'Control Left' && 
                                  key != 'Control Right' &&
                                  key != 'Alt Left' &&
                                  key != 'Alt Right' &&
                                  key != 'Shift Left' &&
                                  key != 'Shift Right') {
                                setState(() {
                                  _capturedKey = key;
                                  _isCapturing = false;
                                });
                              }
                            }
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isCapturing = true;
                                _capturingKeyId = shortcutKey.id;
                                _capturedKey = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.keyboard, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      '点击此处设置快捷键',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  _capturedKey != null && _capturingKeyId == shortcutKey.id
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            children: [
                              const Text('已选择: '),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF107C10),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _capturedKey!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  _capturedKey != null && _capturingKeyId == shortcutKey.id
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            '提示: 点击保存后，${shortcutKey.name}功能将使用新的快捷键',
                            style: TextStyle(fontSize: 12, color: Color(0xFF616161)),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: _capturedKey != null
                    ? () async {
                        final conflict = ref.read(shortcutKeyProvider.notifier).checkConflict(_capturedKey!, shortcutKey.id);
                        if (conflict) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('该快捷键已被其他功能使用，请选择其他快捷键'),
                                backgroundColor: Color(0xFFF44336),
                              ),
                            );
                          }
                        } else {
                          final updatedShortcut = shortcutKey.copyWith(currentKey: _capturedKey);
                          final success = await ref.read(shortcutKeyProvider.notifier).updateShortcutKey(updatedShortcut);
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('快捷键已保存')),
                            );
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _capturedKey != null ? const Color(0xFF003366) : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetShortcutKeyDialog(ShortcutKey shortcutKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置快捷键'),
        content: Text('确定要将"${shortcutKey.name}"快捷键重置为默认值"${shortcutKey.defaultKey}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(shortcutKeyProvider.notifier).resetShortcutKey(shortcutKey.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('快捷键已重置')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
  }

  void _showResetAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置所有快捷键'),
        content: const Text('确定要将所有快捷键重置为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(shortcutKeyProvider.notifier).resetAllShortcutKeys();
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有快捷键已重置')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportShortcutKeys() async {
    try {
      final data = await ref.read(shortcutKeyProvider.notifier).exportShortcutKeys();
      
      if (mounted) {
        final timestamp = DateTime.now().toIso8601String().split('.')[0];
        final fileName = 'shortcut_keys_$timestamp.json';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('快捷键配置已导出到: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importShortcutKeys() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final data = await file.readAsString();
        
        final success = await ref.read(shortcutKeyProvider.notifier).importShortcutKeys(data);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('快捷键配置已导入'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortcutKeyProvider);

    return MainLayout(
      title: '快捷键设置',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '快捷键设置',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showResetAllDialog,
                      icon: const Icon(Icons.restore),
                      label: const Text('恢复默认设置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _exportShortcutKeys,
                      icon: const Icon(Icons.download),
                      label: const Text('导出配置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _importShortcutKeys,
                      icon: const Icon(Icons.upload),
                      label: const Text('导入配置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: state.length,
                itemBuilder: (context, index) {
                  final shortcutKey = state[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Row(
                      children: [
                        Icon(
                          _getIconForShortcut(shortcutKey.id),
                          color: const Color(0xFF1976D2),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shortcutKey.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                shortcutKey.description,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Text(
                            shortcutKey.displayName,
                            style: const TextStyle(
                              color: Color(0xFF1F1F1F),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                          onPressed: () => _showEditShortcutKeyDialog(shortcutKey),
                          tooltip: '编辑快捷键',
                        ),
                        IconButton(
                          icon: const Icon(Icons.restore, color: Color(0xFFFF9800)),
                          onPressed: () => _showResetShortcutKeyDialog(shortcutKey),
                          tooltip: '恢复默认值',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF003366)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: const Color(0xFF003366)),
                      const SizedBox(width: 8),
                      const Text(
                        '使用说明',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• 点击编辑按钮可以修改快捷键',
                    style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
                  ),
                  const Text(
                    '• 点击恢复默认值可以将快捷键重置为系统默认值',
                    style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
                  ),
                  const Text(
                    '• 如果设置的快捷键与其他功能冲突，系统会提示并阻止保存',
                    style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
                  ),
                  const Text(
                    '• 可以随时点击"恢复默认设置"按钮将所有快捷键重置为默认值',
                    style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForShortcut(String id) {
    switch (id) {
      case 'refresh':
        return Icons.refresh;
      case 'back':
        return Icons.arrow_back;
      default:
        return Icons.keyboard;
    }
  }
}
