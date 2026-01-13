import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/module_pages_provider.dart';
import '../providers/tab_provider.dart';

class ModulePageInfo extends ConsumerWidget {
  const ModulePageInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final modulePages = ref.watch(currentModulePagesProvider(currentLocation));
    final tabs = ref.watch(tabProvider);

    // 获取当前激活的标签页
    final activeTab = tabs.firstWhere((tab) => tab.isActive, orElse: () => tabs.first);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模块标题
          Text(
            activeTab.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF003366),
                ),
          ),
          const SizedBox(height: 8),
          // 页面列表
          Expanded(
            child: modulePages.isEmpty
                ? _buildEmptyState(context)
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: modulePages.length,
                    itemBuilder: (context, index) {
                      final page = modulePages[index];
                      return _buildPageCard(context, page, ref);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 构建页面卡片
  Widget _buildPageCard(BuildContext context, ModulePage page, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // 导航到对应页面
        context.go(page.route);
        // 添加或激活标签页
        ref.read(tabProvider.notifier).addTab(
              title: page.title,
              route: page.route,
            );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 页面标题
              Text(
                page.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF003366),
                    ),
              ),
              // 页面描述
              Text(
                page.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // 页面状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      page.status,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: page.status == 'active' ? Colors.green : Colors.grey,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '当前模块下没有页面信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '请联系系统管理员添加页面',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}
