import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shortcut_key_provider.dart';
import '../services/api_service.dart';
import '../utils/logger_service.dart';

class ShortcutKeyHandler extends ConsumerStatefulWidget {
  final Widget child;

  const ShortcutKeyHandler({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ShortcutKeyHandler> createState() => _ShortcutKeyHandlerState();
}

class _ShortcutKeyHandlerState extends ConsumerState<ShortcutKeyHandler> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shortcutKeyProvider.notifier).loadShortcutKeys();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleShortcutKey(String key) {
    final state = ref.read(shortcutKeyProvider);
    final apiService = ref.read(apiServiceProvider);
    
    for (final shortcutKey in state) {
      final currentKey = shortcutKey.currentKey ?? shortcutKey.defaultKey;
      if (currentKey == key) {
        try {
          apiService.recordShortcutUsage(shortcutKey.id);
        } catch (e) {
          LoggerService.error('记录快捷键使用失败: $e');
        }
        
        switch (shortcutKey.id) {
          case 'refresh':
            _triggerRefresh();
            break;
          case 'back':
            _triggerBack();
            break;
        }
        break;
      }
    }
  }

  void _triggerRefresh() {
    final currentState = context.findAncestorStateOfType<_RefreshableState>();
    if (currentState != null) {
      currentState.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('刷新功能已触发'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('当前页面不支持刷新功能'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _triggerBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('返回上一步功能已触发'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法返回，已经是第一级页面'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey.keyLabel;
          _handleShortcutKey(key);
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}

mixin _RefreshableState on State {
  void onRefresh();
}
