import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/providers/logistics_provider.dart';
import '../../widgets/two_level_tab_layout.dart';
import './logistics_screen.dart';

class LogisticsListScreen extends ConsumerStatefulWidget {
  const LogisticsListScreen({super.key});

  @override
  ConsumerState<LogisticsListScreen> createState() => _LogisticsListScreenState();
}

class _LogisticsListScreenState extends ConsumerState<LogisticsListScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 物流管理
      TabConfig(
        title: '物流管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '物流列表',
            content: const _LogisticsListView(),
          ),
          SecondLevelTabConfig(
            title: '先发货物流',
            content: const LogisticsScreen(),
          ),
          SecondLevelTabConfig(
            title: '商城物流',
            content: const LogisticsScreen(),
          ),
          SecondLevelTabConfig(
            title: '集货商物流',
            content: const LogisticsScreen(),
          ),
          SecondLevelTabConfig(
            title: '其他物流',
            content: const LogisticsScreen(),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      moduleName: 'logistics',
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
    );
  }
}

// 物流列表视图
class _LogisticsListView extends ConsumerWidget {
  const _LogisticsListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 'pre-delivery' 作为默认的物流类型参数
    return Column(
      children: [
        Expanded(
          child: ref.watch(logisticsProvider('pre-delivery')).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('加载失败: $error'),
                ],
              ),
            ),
            data: (logisticsData) {
              if (logisticsData.isEmpty) {
                return const Center(child: Text('暂无物流数据'));
              }
              return ListView.builder(
                itemCount: logisticsData.length,
                itemBuilder: (context, index) {
                  final logistics = logisticsData[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text('物流单号: ${logistics['物流单号']}'),
                      subtitle: Text('发货类型: ${logistics['发货类型']}'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('状态: ${logistics['状态']}'),
                          Text('发货时间: ${logistics['发货时间']}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
