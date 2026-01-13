import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/two_level_tab_layout.dart';
import '../../providers/tab_provider.dart';

/// 标签页功能测试页面
class TabTestScreen extends ConsumerStatefulWidget {
  const TabTestScreen({super.key});

  @override
  ConsumerState<TabTestScreen> createState() => _TabTestScreenState();
}

class _TabTestScreenState extends ConsumerState<TabTestScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 第一组一级菜单
      TabConfig(
        title: '菜单组1',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '标签1-1',
            content: const _TestContent(title: '标签1-1内容'),
          ),
          SecondLevelTabConfig(
            title: '标签1-2',
            content: const _TestContent(title: '标签1-2内容'),
          ),
          SecondLevelTabConfig(
            title: '标签1-3',
            content: const _TestContent(title: '标签1-3内容'),
          ),
        ],
      ),
      // 第二组一级菜单
      TabConfig(
        title: '菜单组2',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '标签2-1',
            content: const _TestContent(title: '标签2-1内容'),
          ),
          SecondLevelTabConfig(
            title: '标签2-2',
            content: const _TestContent(title: '标签2-2内容'),
          ),
        ],
      ),
      // 第三组一级菜单
      TabConfig(
        title: '菜单组3',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '标签3-1',
            content: const _TestContent(title: '标签3-1内容'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('标签页功能测试'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Column(
        children: [
          // 标签页控制按钮
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 添加新标签页
                    ref.read(tabProvider.notifier).addTab(
                          title: '测试标签页',
                          route: '/test',
                        );
                  },
                  child: const Text('添加标签页'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 查看当前标签页
                    final activeTab = ref.read(tabProvider.notifier).getActiveTab();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('当前激活标签页: ${activeTab?.title}'),
                        backgroundColor: const Color(0xFF003366),
                      ),
                    );
                  },
                  child: const Text('查看当前标签页'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 关闭当前标签页
                    final tabs = ref.read(tabProvider);
                    final activeIndex = tabs.indexWhere((tab) => tab.isActive);
                    if (activeIndex != -1) {
                      ref.read(tabProvider.notifier).closeTab(activeIndex);
                    }
                  },
                  child: const Text('关闭当前标签页'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                ),
              ],
            ),
          ),
          // 两级标签页布局
          Expanded(
            child: TwoLevelTabLayout(
              firstLevelTabs: firstLevelTabs,
              initialFirstLevelIndex: 0,
              initialSecondLevelIndex: 0,
              moduleName: '测试模块',
            ),
          ),
        ],
      ),
    );
  }
}

/// 测试内容组件
class _TestContent extends StatelessWidget {
  final String title;

  const _TestContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '这是一个测试内容页面，用于测试标签页功能。',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
