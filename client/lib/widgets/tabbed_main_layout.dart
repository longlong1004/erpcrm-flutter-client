import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/sidebar.dart';
import 'package:erpcrm_client/widgets/tab_bar.dart';
import 'package:erpcrm_client/widgets/shortcut_key_handler.dart';

class TabbedMainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const TabbedMainLayout({super.key, required this.child});

  @override
  ConsumerState<TabbedMainLayout> createState() => _TabbedMainLayoutState();
}

class _TabbedMainLayoutState extends ConsumerState<TabbedMainLayout> {
  @override
  Widget build(BuildContext context) {
    return ShortcutKeyHandler(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            // 确保侧边栏显示在最左侧
            SizedBox(
              width: 280,
              child: const Sidebar(),
            ),
            
            Expanded(
              child: Column(
                children: [
                  // 标签栏 - 直接显示在侧边栏右侧，不显示任何菜单相关信息
                  const TabBarWidget(),
                  
                  // 主内容区 - 显示当前表单名称、详细页面信息和操作按钮
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
