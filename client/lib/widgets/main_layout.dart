import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final String title;
  final bool showBackButton;
  final Widget? topContent;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
    this.topContent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 直接返回内容，不包含Scaffold和AppBar，避免嵌套Scaffold问题
    return Column(
      children: [
        // 在顶部显示的内容（标签页上方）
        if (topContent != null)
          topContent!,
        
        // 主要内容区域
        Expanded(
          child: child,
        ),
      ],
    );
  }
}