import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 消息类型枚举
enum MessageType {
  success,
  error,
  warning,
  info,
}

/// 消息配置类
class MessageConfig {
  final String title;
  final String message;
  final MessageType type;
  final bool autoClose;
  final Duration duration;
  final List<MessageAction>? actions;
  final String? operationLog;

  MessageConfig({
    required this.title,
    required this.message,
    required this.type,
    this.autoClose = true,
    this.duration = const Duration(seconds: 3),
    this.actions,
    this.operationLog,
  });
}

/// 消息操作按钮配置
class MessageAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  MessageAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}

/// 统一消息服务
class MessageService {
  /// 显示消息对话框
  static void showMessageDialog(BuildContext context, MessageConfig config) {
    final l10n = AppLocalizations.of(context)!;
    
    final icon = _getIconForType(config.type);
    final color = _getColorForType(config.type);
    
    showDialog(
      context: context,
      builder: (context) {
        // 如果是自动关闭，创建定时器
        if (config.autoClose) {
          Future.delayed(config.duration, () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }
        
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(config.title),
            ],
          ),
          content: Text(config.message),
          actions: [
            // 添加自定义操作按钮
            if (config.actions != null) ...config.actions!.map((action) => TextButton(
              onPressed: () {
                action.onPressed();
                Navigator.pop(context);
              },
              style: action.isPrimary ? TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ) : null,
              child: Text(action.label),
            )),
            
            // 关闭按钮（如果不是自动关闭或有自定义操作）
            if (!config.autoClose || (config.actions?.isEmpty ?? true))
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(l10n.close),
              ),
          ],
        );
      },
    );
  }
  
  /// 显示底部消息条
  static void showSnackBar(BuildContext context, MessageConfig config) {
    final l10n = AppLocalizations.of(context)!;
    
    final icon = _getIconForType(config.type);
    final color = _getColorForType(config.type);
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  config.message,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: config.duration,
      action: config.actions != null && config.actions!.isNotEmpty
          ? SnackBarAction(
              label: config.actions!.first.label,
              textColor: Colors.white,
              onPressed: config.actions!.first.onPressed,
            )
          : null,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  /// 显示操作成功消息
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    bool useDialog = false,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    final config = MessageConfig(
      title: title,
      message: message,
      type: MessageType.success,
      actions: actions,
      operationLog: operationLog,
    );
    
    if (useDialog) {
      showMessageDialog(context, config);
    } else {
      showSnackBar(context, config);
    }
  }
  
  /// 显示操作错误消息
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    bool useDialog = true,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    final config = MessageConfig(
      title: title,
      message: message,
      type: MessageType.error,
      autoClose: false,
      actions: actions,
      operationLog: operationLog,
    );
    
    if (useDialog) {
      showMessageDialog(context, config);
    } else {
      showSnackBar(context, config);
    }
  }
  
  /// 显示警告消息
  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
    bool useDialog = false,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    final config = MessageConfig(
      title: title,
      message: message,
      type: MessageType.warning,
      autoClose: true,
      duration: const Duration(seconds: 4),
      actions: actions,
      operationLog: operationLog,
    );
    
    if (useDialog) {
      showMessageDialog(context, config);
    } else {
      showSnackBar(context, config);
    }
  }
  
  /// 显示信息消息
  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
    bool useDialog = false,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    final config = MessageConfig(
      title: title,
      message: message,
      type: MessageType.info,
      autoClose: true,
      duration: const Duration(seconds: 3),
      actions: actions,
      operationLog: operationLog,
    );
    
    if (useDialog) {
      showMessageDialog(context, config);
    } else {
      showSnackBar(context, config);
    }
  }
  
  /// 根据消息类型获取图标
  static IconData _getIconForType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.error:
        return Icons.error;
      case MessageType.warning:
        return Icons.warning;
      case MessageType.info:
        return Icons.info;
    }
  }
  
  /// 根据消息类型获取颜色
  static Color _getColorForType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return Colors.green;
      case MessageType.error:
        return Colors.red;
      case MessageType.warning:
        return Colors.orange;
      case MessageType.info:
        return Colors.blue;
    }
  }
}

/// 扩展方法，方便直接在BuildContext上调用消息服务
extension MessageContextExtension on BuildContext {
  void showSuccessMessage({
    required String title,
    required String message,
    bool useDialog = false,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    MessageService.showSuccess(
      this,
      title: title,
      message: message,
      useDialog: useDialog,
      actions: actions,
      operationLog: operationLog,
    );
  }
  
  void showErrorMessage({
    required String title,
    required String message,
    bool useDialog = true,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    MessageService.showError(
      this,
      title: title,
      message: message,
      useDialog: useDialog,
      actions: actions,
      operationLog: operationLog,
    );
  }
  
  void showWarningMessage({
    required String title,
    required String message,
    bool useDialog = false,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    MessageService.showWarning(
      this,
      title: title,
      message: message,
      useDialog: useDialog,
      actions: actions,
      operationLog: operationLog,
    );
  }
  
  void showInfoMessage({
    required String title,
    required String message,
    bool useDialog = false,
    List<MessageAction>? actions,
    String? operationLog,
  }) {
    MessageService.showInfo(
      this,
      title: title,
      message: message,
      useDialog: useDialog,
      actions: actions,
      operationLog: operationLog,
    );
  }
}