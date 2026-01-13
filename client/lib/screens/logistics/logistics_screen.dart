import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/providers/logistics_provider.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';

class LogisticsScreen extends ConsumerWidget {
  const LogisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = Router.of(context).routeInformationProvider?.value.uri.path ?? '';
    
    // 根据当前路径显示不同的内容
    Widget content = _buildDefaultContent(context, currentPath);
    
    if (currentPath == '/logistics/pre-delivery') {
      content = _buildPreDeliveryScreen(context, ref);
    } else if (currentPath == '/logistics/mall') {
      content = _buildMallOrderScreen(context, ref);
    } else if (currentPath == '/logistics/collector') {
      content = _buildCollectorOrderScreen(context, ref);
    } else if (currentPath == '/logistics/other') {
      content = _buildOtherBusinessScreen(context, ref);
    }

    return MainLayout(
      title: _getPageTitle(currentPath),
      child: content,
    );
  }
  
  // 获取页面标题
  String _getPageTitle(String path) {
    switch (path) {
      case '/logistics/pre-delivery':
        return '先发货物流';
      case '/logistics/mall':
        return '商城订单物流';
      case '/logistics/collector':
        return '集货商订单物流';
      case '/logistics/other':
        return '其它业务物流';
      default:
        return '物流管理';
    }
  }
  
  // 默认内容
  Widget _buildDefaultContent(BuildContext context, String currentPath) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '物流管理',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: Center(
              child: Text(
                '请从左侧菜单选择具体的物流管理功能',
                style: TextStyle(fontSize: 18, color: Color(0xFF616161)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 先发货物流页面
  Widget _buildPreDeliveryScreen(BuildContext context, WidgetRef ref) {
    final tableHeaders = ['业务员', '状态', '发货类型', '编号', '所属路局', '站段', '国铁名称', '国铁型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'];
    final actionButtons = ['查看', '发货'];
    
    // 使用真实数据
    final logisticsType = 'pre-delivery';
    final logisticsAsync = ref.watch(logisticsProvider(logisticsType));
    
    return logisticsAsync.when(
      loading: () => _buildLoadingState(context),
      error: (error, stackTrace) => _buildErrorState(context, error, ref, logisticsType),
      data: (mockData) => _buildTableContent(context, ref, tableHeaders, actionButtons, mockData, logisticsType),
    );
  }
  
  // 商城订单物流页面
  Widget _buildMallOrderScreen(BuildContext context, WidgetRef ref) {
    final tableHeaders = ['业务员', '状态', '发货类型', '订单编号', '所属路局', '站段', '国铁名称', '国铁型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'];
    final actionButtons = ['查看', '发货'];
    
    // 使用真实数据
    final logisticsType = 'mall';
    final logisticsAsync = ref.watch(logisticsProvider(logisticsType));
    
    return logisticsAsync.when(
      loading: () => _buildLoadingState(context),
      error: (error, stackTrace) => _buildErrorState(context, error, ref, logisticsType),
      data: (mockData) => _buildTableContent(context, ref, tableHeaders, actionButtons, mockData, logisticsType),
    );
  }
  
  // 集货商订单物流页面
  Widget _buildCollectorOrderScreen(BuildContext context, WidgetRef ref) {
    final tableHeaders = ['业务员', '状态', '发货类型', '订单编号', '所属路局', '站段', '国铁名称', '国铁型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'];
    final actionButtons = ['查看', '发货'];
    
    // 使用真实数据
    final logisticsType = 'collector';
    final logisticsAsync = ref.watch(logisticsProvider(logisticsType));
    
    return logisticsAsync.when(
      loading: () => _buildLoadingState(context),
      error: (error, stackTrace) => _buildErrorState(context, error, ref, logisticsType),
      data: (mockData) => _buildTableContent(context, ref, tableHeaders, actionButtons, mockData, logisticsType),
    );
  }
  
  // 其它业务物流页面
  Widget _buildOtherBusinessScreen(BuildContext context, WidgetRef ref) {
    final tableHeaders = ['业务员', '状态', '订单编号', '发货类型', '客户名称', '物资名称', '规格型号', '数量', '收货人', '电话', '物流公司', '物流单号', '发货时间', '操作'];
    final actionButtons = ['查看', '发货'];
    
    // 使用真实数据
    final logisticsType = 'other';
    final logisticsAsync = ref.watch(logisticsProvider(logisticsType));
    
    return logisticsAsync.when(
      loading: () => _buildLoadingState(context),
      error: (error, stackTrace) => _buildErrorState(context, error, ref, logisticsType),
      data: (mockData) => _buildTableContent(context, ref, tableHeaders, actionButtons, mockData, logisticsType),
    );
  }
  
  // 加载状态
  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '加载中...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
  
  // 错误状态
  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref, String logisticsType) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('获取物流数据失败: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(logisticsProvider(logisticsType));
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 通用表格内容构建方法
  Widget _buildTableContent(BuildContext context, WidgetRef ref, List<String> tableHeaders, List<String> actionButtons, List<Map<String, dynamic>> mockData, String logisticsType) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          Text(
            _getPageTitle(Router.of(context).routeInformationProvider?.value.uri.path ?? ''),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
          ),
          const SizedBox(height: 32),
          // 表格容器
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 表格标题
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: tableHeaders.map((header) => Expanded(
                        flex: header == '操作' ? 3 : 2,
                        child: Text(
                          header,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F1F1F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )).toList(),
                    ),
                  ),
                  // 表格内容
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 300, // 调整宽度以适应内容
                        child: ListView.builder(
                          itemCount: mockData.length,
                          itemBuilder: (context, index) {
                            final item = mockData[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: const Color(0xFFE0E0E0)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // 动态生成表格单元格
                                  ...tableHeaders.where((header) => header != '操作').map((header) => Expanded(
                                    flex: header == '操作' ? 3 : 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        item[header].toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )),
                                  // 操作按钮
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: actionButtons.map((button) => ElevatedButton(
                        onPressed: () {
                          // 处理按钮点击事件
                          if (button == '查看') {
                            print('查看物流记录');
                          } else if (button == '发货') {
                            // 使用标签页系统添加新标签页
                            ref.read(tabProvider.notifier).addTab(
                              title: '发货',
                              route: '/logistics/delivery',
                            );
                            // 导航到路由
                            context.go('/logistics/delivery');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: button == '查看' 
                              ? const Color(0xFF003366)
                              : const Color(0xFF107C10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: Text(button),
                      )).toList(),
                    ),
                  ),
                ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // 如果没有数据，显示提示信息
                  if (mockData.isEmpty) 
                    Expanded(
                      child: Center(
                        child: Text(
                          '暂无数据',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}