import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/tab_provider.dart';
import '../models/tab_item.dart';
import '../utils/logger_service.dart';

class TabBarWidget extends ConsumerWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabProvider);
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border( bottom: BorderSide( color: Colors.grey.shade200, width: 1 ),
        ),
      ),
      child: Row(
        children: [
          // 标签页列表
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: tabs.length,
              onReorder: (oldIndex, newIndex) {
                // 如果新位置在旧位置之后，需要调整索引
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                ref.read(tabProvider.notifier).reorderTabs(oldIndex, newIndex);
              },
              buildDefaultDragHandles: false, // 不显示默认的拖拽手柄
              itemBuilder: (context, index) {
                final tab = tabs[index];
                
                return ReorderableDragStartListener(
                  key: Key(tab.id),
                  index: index,
                  child: _TabItemWidget(
                    tab: tab,
                    index: index,
                    isActive: tab.isActive,
                    onTap: () {
                      // 先更新标签页激活状态，再导航到对应路由，确保状态同步
                      ref.read(tabProvider.notifier).setActiveTab(index);
                      LoggerService.debug('标签页点击，导航到: ${tab.route}');
                      context.go(tab.route);
                    },
                    onClose: () => ref.read(tabProvider.notifier).closeTab(index),
                  ),
                );
              },
            ),
          ),
          
          // 全局搜索框
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '全局搜索...',
                  prefixIcon: const Icon(Icons.search, size: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      // 清空搜索内容
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF003366)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                  fillColor: Colors.grey.shade50,
                  filled: true,
                ),
                onChanged: (value) {
                  // 执行搜索操作
                  LoggerService.debug('搜索内容: $value');
                },
                onSubmitted: (value) {
                  // 提交搜索
                  LoggerService.debug('提交搜索: $value');
                },
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          
          // 新建标签页按钮
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              // 显示可用模块列表
              _showModuleListDialog(context, ref);
            },
            tooltip: '新建标签页',
          ),
        ],
      ),
    );
  }

  // 显示模块列表对话框
  void _showModuleListDialog(BuildContext context, WidgetRef ref) {
    // 简单的模块列表，实际应用中应从配置或路由表中动态获取
    final modules = [
      {'title': '仪表板', 'route': '/dashboard'},
      {'title': '订单管理', 'route': '/orders'},
      {'title': '业务管理', 'route': '/businesses'},
      {'title': '商品管理', 'route': '/products'},
      {'title': '采购管理', 'route': '/procurement'},
      {'title': '审批管理', 'route': '/approvals'},
      {'title': '客户管理', 'route': '/customers'},
      {'title': '仓库管理', 'route': '/warehouse'},
      {'title': '物流管理', 'route': '/logistics'},
      {'title': '薪酬管理', 'route': '/salary'},
      {'title': '系统设置', 'route': '/settings'},
      {'title': '演示表单', 'route': '/demo-form'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择模块'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return ListTile(
                title: Text(module['title']!),
                onTap: () {
                  // 添加新标签页
                  ref.read(tabProvider.notifier).addTab(
                    title: module['title']!,
                    route: module['route']!,
                  );
                  context.go(module['route']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

class _TabItemWidget extends StatelessWidget {
  final TabItem tab;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabItemWidget({
    required this.tab,
    required this.index,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey.shade50,
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF003366) : Colors.grey.shade200,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标签页标题
            SizedBox(
              width: 120,
              child: Text(
                tab.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFF003366) : Colors.black87,
                ),
              ),
            ),
            
            // 关闭按钮
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              tooltip: '关闭标签页',
            ),
          ],
        ),
      ),
    );
  }
}
