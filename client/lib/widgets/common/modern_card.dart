import 'package:flutter/material.dart';
import 'package:erpcrm_client/theme/app_theme.dart';

/// 现代化卡片组件
/// 提供统一的卡片样式，支持标题、内容、操作按钮
class ModernCard extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? backgroundColor;
  
  const ModernCard({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.actions,
    this.padding,
    this.onTap,
    this.showBorder = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || titleWidget != null || actions != null)
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                Expanded(
                  child: titleWidget ?? Text(
                    title!,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        if (title != null || titleWidget != null)
          Divider(height: 1, color: theme.dividerColor),
        Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingMedium),
          child: child,
        ),
      ],
    );
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: showBorder
            ? Border.all(color: theme.dividerColor)
            : null,
        boxShadow: AppTheme.cardShadow,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: cardContent,
            )
          : cardContent,
    );
  }
}
