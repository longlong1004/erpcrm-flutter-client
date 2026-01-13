import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 错误处理服务
class ErrorHandlerService {
  /// 显示错误对话框
  static void showErrorDialog(BuildContext context, String error, {
    String? errorCode,
    String? solution,
    String? contactInfo,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.error('')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 错误代码
                if (errorCode != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${l10n.errorCode}: $errorCode',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                // 错误描述
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(error),
                ),
                // 解决方案
                if (solution != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.solution}:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(solution),
                      ],
                    ),
                  ),
                // 解决步骤
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.solutionSteps}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      _buildSolutionSteps(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // 复制错误信息按钮
            TextButton(
              onPressed: () {
                _copyErrorInfo(context, error, errorCode);
              },
              child: Text(l10n.copyErrorInfo),
            ),
            // 联系技术支持按钮
            TextButton(
              onPressed: () {
                _contactSupport(context, contactInfo);
              },
              child: Text(l10n.contactTechnicalSupport),
            ),
            // 关闭按钮
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
  
  /// 构建解决步骤列表
  static Widget _buildSolutionSteps(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      l10n.checkNetworkConnection,
      l10n.refreshPage,
      l10n.retryOperation,
      l10n.contactAdministrator,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            '${entry.key + 1}. ${entry.value}',
          ),
        );
      }).toList(),
    );
  }
  
  /// 复制错误信息到剪贴板
  static Future<void> _copyErrorInfo(BuildContext context, String error, String? errorCode) async {
    final l10n = AppLocalizations.of(context)!;
    final errorText = errorCode != null ? '[$errorCode] $error' : error;
    
    try {
      await Clipboard.setData(ClipboardData(text: errorText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.copySuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.copyFailed)),
      );
    }
  }
  
  /// 联系技术支持
  static void _contactSupport(BuildContext context, String? contactInfo) {
    final l10n = AppLocalizations.of(context)!;
    final supportInfo = contactInfo ?? l10n.defaultSupportInfo;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.contactTechnicalSupport),
          content: Text(supportInfo),
          actions: [
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
  
  /// 处理网络错误
  static void handleNetworkError(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context)!;
    showErrorDialog(
      context,
      l10n.networkError,
      errorCode: 'NETWORK_ERROR',
      solution: l10n.networkErrorSolution,
    );
  }
  
  /// 处理权限不足错误
  static void handlePermissionError(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context)!;
    showErrorDialog(
      context,
      l10n.permissionDenied,
      errorCode: 'PERMISSION_DENIED',
      solution: l10n.permissionDeniedSolution,
    );
  }
  
  /// 处理数据验证错误
  static void handleValidationError(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context)!;
    showErrorDialog(
      context,
      l10n.dataValidationFailed(error),
      errorCode: 'VALIDATION_ERROR',
      solution: l10n.validationErrorSolution,
    );
  }
  
  /// 处理未知错误
  static void handleUnknownError(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context)!;
    showErrorDialog(
      context,
      l10n.unknownError,
      errorCode: 'UNKNOWN_ERROR',
      solution: l10n.unknownErrorSolution,
      contactInfo: l10n.supportEmail,
    );
  }
  
  /// 根据错误类型处理错误
  static void handleError(BuildContext context, dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('SocketException') || 
        errorMessage.contains('NetworkError') ||
        errorMessage.contains('Connection')) {
      handleNetworkError(context, errorMessage);
    } else if (errorMessage.contains('Permission') || 
               errorMessage.contains('Auth') ||
               errorMessage.contains('Unauthorized')) {
      handlePermissionError(context, errorMessage);
    } else if (errorMessage.contains('Validation') || 
               errorMessage.contains('Invalid') ||
               errorMessage.contains('Required')) {
      handleValidationError(context, errorMessage);
    } else {
      handleUnknownError(context, errorMessage);
    }
  }
}