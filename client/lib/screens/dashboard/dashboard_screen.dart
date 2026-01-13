import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/theme/app_theme.dart';
import 'package:erpcrm_client/widgets/common/modern_card.dart';
import 'package:erpcrm_client/widgets/common/custom_date_range_picker.dart';
import 'package:erpcrm_client/widgets/charts/order_trend_chart.dart';
import 'package:erpcrm_client/widgets/charts/revenue_trend_chart.dart';
import 'package:erpcrm_client/widgets/charts/customer_growth_chart.dart';
import 'package:erpcrm_client/services/dashboard_data_service.dart';
import 'package:erpcrm_client/models/order/order.dart';
import 'package:erpcrm_client/models/crm/customer.dart';
import 'package:erpcrm_client/models/product/product.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// 完整版本的仪表盘界面
/// 集成了真实数据、图表、搜索和自定义时间范围功能
class DashboardScreenComplete extends ConsumerStatefulWidget {
  const DashboardScreenComplete({super.key});

  @override
  ConsumerState<DashboardScreenComplete> createState() => _DashboardScreenCompleteState();
}

class _DashboardScreenCompleteState extends ConsumerState<DashboardScreenComplete> {
  final _dataService = DashboardDataService();
  final _searchController = TextEditingController();
  
  String _selectedTimeRange = '今天';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  Map<String, dynamic>? _dashboardData;
  Map<String, List<dynamic>>? _searchResults;
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载仪表盘数据
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateRange = _getDateRange();
      final data = await _dataService.getDashboardData(
        startDate: dateRange['start'],
        endDate: dateRange['end'],
      );

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('加载仪表盘数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取日期范围
  Map<String, DateTime> _getDateRange() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedTimeRange) {
      case '今天':
        start = DateTime(now.year, now.month, now.day);
        break;
      case '本周':
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        start = DateTime(monday.year, monday.month, monday.day);
        break;
      case '本月':
        start = DateTime(now.year, now.month, 1);
        break;
      case '本季度':
        final quarter = ((now.month - 1) / 3).floor();
        final firstMonthOfQuarter = quarter * 3 + 1;
        start = DateTime(now.year, firstMonthOfQuarter, 1);
        break;
      case '本年':
        start = DateTime(now.year, 1, 1);
        break;
      case '自定义':
        start = _customStartDate ?? DateTime(now.year, now.month, 1);
        end = _customEndDate ?? end;
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }

    return {'start': start, 'end': end};
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部搜索和操作栏
            _buildTopBar(),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // 搜索结果（如果有）
            if (_isSearching && _searchResults != null)
              _buildSearchResults(),
            
            // 时间筛选标签
            if (!_isSearching) ...[
              _buildTimeRangeSelector(),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // 加载状态或数据展示
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_dashboardData != null) ...[
                // 核心业务指标卡片（8个）
                _buildMetricsSection(),
                
                const SizedBox(height: AppTheme.spacingExtraLarge),
                
                // 数据趋势图表（3个）
                _buildChartsSection(),
                
                const SizedBox(height: AppTheme.spacingExtraLarge),
                
                // 待办事项和业务关注
                _buildTodoAndFocusSection(),
                
                const SizedBox(height: AppTheme.spacingExtraLarge),
                
                // 快速操作区域
                _buildQuickActionsSection(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// 顶部搜索和操作栏
  Widget _buildTopBar() {
    return Row(
      children: [
        // 搜索框
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppTheme.spacingMedium),
                Icon(Icons.search, color: AppTheme.textSecondaryColor, size: 20),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '搜索客户、订单、商品...',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearch,
                  ),
                ),
                if (_isSearching)
                  IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(Icons.close, size: 20, color: AppTheme.textSecondaryColor),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingMedium),
        
        // 刷新按钮
        IconButton(
          onPressed: _onRefresh,
          icon: const Icon(Icons.refresh),
          tooltip: '刷新数据',
        ),
      ],
    );
  }

  /// 搜索结果展示
  Widget _buildSearchResults() {
    if (_searchResults == null || _searchResults!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: Text('未找到相关结果'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '搜索结果',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        
        // 客户结果
        if (_searchResults!['customers']!.isNotEmpty) ...[
          _buildSearchSection('客户', _searchResults!['customers']!),
          const SizedBox(height: AppTheme.spacingMedium),
        ],
        
        // 订单结果
        if (_searchResults!['orders']!.isNotEmpty) ...[
          _buildSearchSection('订单', _searchResults!['orders']!),
          const SizedBox(height: AppTheme.spacingMedium),
        ],
        
        // 商品结果
        if (_searchResults!['products']!.isNotEmpty) ...[
          _buildSearchSection('商品', _searchResults!['products']!),
        ],
      ],
    );
  }

  /// 构建搜索结果分组
  Widget _buildSearchSection(String title, List<dynamic> items) {
    return ModernCard(
      title: '$title (${items.length})',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length > 5 ? 5 : items.length,
        separatorBuilder: (context, index) => Divider(color: AppTheme.borderColor, height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildSearchResultItem(title, item);
        },
      ),
    );
  }

  /// 构建搜索结果项
  Widget _buildSearchResultItem(String category, dynamic item) {
    String title = '';
    String subtitle = '';
    IconData icon = Icons.description;
    String route = '';

    if (category == '客户') {
      final customer = item as Customer;
      title = customer.name;
      subtitle = '联系人: ${customer.contactPerson} | 电话: ${customer.contactPhone}';
      icon = Icons.person;
      route = '/customers/${customer.customerId}';
    } else if (category == '订单') {
      final order = item as Order;
      title = '订单号: ${order.orderNumber}';
      subtitle = '金额: ¥${order.totalAmount.toStringAsFixed(2)} | 状态: ${order.status}';
      icon = Icons.shopping_cart;
      route = '/orders/${order.id}';
    } else if (category == '商品') {
      final product = item as Product;
      title = product.name;
      subtitle = '编码: ${product.code} | 价格: ¥${product.price.toStringAsFixed(2)}';
      icon = Icons.inventory_2;
      route = '/products/${product.id}';
    }

    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondaryColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppTheme.borderColor),
      onTap: () {
        context.go(route);
      },
    );
  }

  /// 时间筛选标签
  Widget _buildTimeRangeSelector() {
    final timeRanges = ['今天', '本周', '本月', '本季度', '本年', '自定义'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeRanges.map((range) {
          final isSelected = _selectedTimeRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingSmall),
            child: InkWell(
              onTap: () => _onTimeRangeChanged(range),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical: AppTheme.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                  ),
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 核心业务指标卡片（8个，2行4列）
  Widget _buildMetricsSection() {
    final orders = _dashboardData!['orders'] as Map<String, dynamic>;
    final customers = _dashboardData!['customers'] as Map<String, dynamic>;
    final finance = _dashboardData!['finance'] as Map<String, dynamic>;
      final approvals = _dashboardData!['approvals'] as Map<String, dynamic>;
      final inventory = _dashboardData!['inventory'] as Map<String, dynamic>;
      final purchase = _dashboardData!['purchase'] as Map<String, dynamic>;
      final attendance = _dashboardData!['attendance'] as Map<String, dynamic>;
      final opportunities = _dashboardData!['opportunities'] as Map<String, dynamic>;
      final contacts = _dashboardData!['contacts'] as Map<String, dynamic>;

    return Column(
      children: [
        // 第一行：订单、收入、客户、商机
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              title: '今日订单',
              value: orders['totalCount'].toString(),
              unit: '单',
              subtitle: '订单金额 ¥${orders['totalAmount'].toStringAsFixed(0)}',
              trend: '${orders['countGrowth'].toStringAsFixed(1)}%',
              trendUp: orders['countGrowth'] > 0,
              icon: Icons.shopping_cart,
              color: AppTheme.primaryColor,
              onTap: () => _navigateTo('/orders'),
            )),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildMetricCard(
              title: '今日收入',
              value: '¥${finance['todayIncome'].toStringAsFixed(0)}',
              unit: '',
              subtitle: '本月累计 ¥${finance['monthlyIncome'].toStringAsFixed(0)}',
              trend: '${finance['growth'].toStringAsFixed(1)}%',
              trendUp: finance['growth'] > 0,
              icon: Icons.account_balance_wallet,
              color: AppTheme.successColor,
              onTap: () => _navigateTo('/finance'),
            )),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildMetricCard(
              title: '新增客户',
              value: customers['newCount'].toString(),
              unit: '家',
              subtitle: '客户总数 ${customers['totalCount']}',
              trend: '${customers['growth'].toStringAsFixed(1)}%',
              trendUp: customers['growth'] > 0,
              icon: Icons.people,
              color: AppTheme.infoColor,
              onTap: () => _navigateTo('/customers'),
            )),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildMetricCard(
              title: '新增商机',
              value: opportunities['newCount'].toString(),
              unit: '个',
              subtitle: '预估金额 ¥${(opportunities['expectedAmount'] / 10000).toStringAsFixed(1)}万',
              trend: '${opportunities['growth'].toStringAsFixed(1)}%',
              trendUp: opportunities['growth'] > 0,
              icon: Icons.trending_up,
              color: AppTheme.warningColor,
              onTap: () => _navigateTo('/opportunities'),
            )),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingMedium),
        
        // 第二行：库存、审批、采购、考勤
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              title: '库存总值',
              value: '¥${(inventory['totalValue'] / 10000).toStringAsFixed(0)}万',
              unit: '',
              subtitle: '预警商品 ${inventory['warningCount']}个',
              trend: '',
              trendUp: false,
              icon: Icons.inventory,
              color: AppTheme.secondaryColor,
              warning: inventory['warningCount'] > 0,
              onTap: () => _navigateTo('/warehouse'),
            )),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildMetricCard(
              title: '待我审批',
              value: approvals['pendingCount'].toString(),
              unit: '项',
              subtitle: '我发起的 ${approvals['myInitiatedCount']}项',
              trend: '',
              trendUp: false,
              icon: Icons.approval,
              color: AppTheme.errorColor,
              warning: approvals['pendingCount'] > 0,
              onTap: () => _navigateTo('/approvals'),
            )),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildMetricCard(
              title: '待采购',
              value: purchase['pendingCount'].toString(),
              unit: '单',
              subtitle: '本月采购 ¥${(purchase['monthlyAmount'] / 10000).toStringAsFixed(0)}万',
              trend: '${purchase['growth'].toStringAsFixed(1)}%',
              trendUp: purchase['growth'] > 0,
              icon: Icons.shopping_bag,
              color: const Color(0xFF9C27B0),
              onTap: () => _navigateTo('/purchase'),
            )),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildMetricCard(
              title: '今日出勤',
              value: '${attendance['attendanceRate'].toStringAsFixed(1)}%',
              unit: '',
              subtitle: '考勤异常 ${attendance['abnormalCount']}人',
              trend: '',
              trendUp: false,
              icon: Icons.access_time,
              color: const Color(0xFF00BCD4),
              onTap: () => _navigateTo('/attendance'),
            )),
          ],
        ),
      ],
    );
  }

  /// 构建单个指标卡片
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required String trend,
    required bool trendUp,
    required IconData icon,
    required Color color,
    bool warning = false,
    VoidCallback? onTap,
  }) {
    return ModernCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和图标
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingSmall),
            
            // 主指标值
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: warning ? AppTheme.errorColor : AppTheme.textPrimaryColor,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingSmall),
            
            // 副指标和趋势
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trend.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: trendUp ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 12,
                          color: trendUp ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 数据趋势图表区域
  Widget _buildChartsSection() {
    final orders = _dashboardData!['orders'] as Map<String, dynamic>;
    final customers = _dashboardData!['customers'] as Map<String, dynamic>;
    final finance = _dashboardData!['finance'] as Map<String, dynamic>;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ModernCard(
            child: SizedBox(
              height: 300,
              child: OrderTrendChart(
                data: List<Map<String, dynamic>>.from(orders['trendData'] ?? []),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: ModernCard(
            child: SizedBox(
              height: 300,
              child: RevenueTrendChart(
                data: List<Map<String, dynamic>>.from(finance['trendData'] ?? []),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: ModernCard(
            child: SizedBox(
              height: 300,
              child: CustomerGrowthChart(
                data: List<Map<String, dynamic>>.from(customers['trendData'] ?? []),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 待办事项和业务关注区域
  Widget _buildTodoAndFocusSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 待审批事项
        Expanded(
          child: ModernCard(
            title: '待审批事项',
            actions: [
              TextButton(
                onPressed: () => _navigateTo('/approvals'),
                child: const Text('查看全部'),
              ),
            ],
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dataService.getTodoList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildTodoList(snapshot.data!);
              },
            ),
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingMedium),
        
        // 业务关注
        Expanded(
          child: ModernCard(
            title: '业务关注',
            actions: [
              TextButton(
                onPressed: () => _navigateTo('/opportunities'),
                child: const Text('查看全部'),
              ),
            ],
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dataService.getBusinessFocusList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildFocusList(snapshot.data!);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 待审批事项列表
  Widget _buildTodoList(List<Map<String, dynamic>> todos) {
    if (todos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: Text('暂无待审批事项'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todos.length,
      separatorBuilder: (context, index) => Divider(color: AppTheme.borderColor, height: 1),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(Icons.assignment, size: 20, color: AppTheme.primaryColor),
          ),
          title: Text(
            todo['type']!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${todo['user']} · ${todo['time']}',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => logger.d('通过审批'),
                child: const Text('通过', style: TextStyle(fontSize: 12)),
              ),
              TextButton(
                onPressed: () => logger.d('拒绝审批'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                child: const Text('拒绝', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 业务关注列表
  Widget _buildFocusList(List<Map<String, dynamic>> focuses) {
    if (focuses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: Text('暂无业务关注'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: focuses.length,
      separatorBuilder: (context, index) => Divider(color: AppTheme.borderColor, height: 1),
      itemBuilder: (context, index) {
        final focus = focuses[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
          leading: CircleAvatar(
            backgroundColor: AppTheme.infoColor.withOpacity(0.1),
            child: Icon(Icons.business, size: 20, color: AppTheme.infoColor),
          ),
          title: Text(
            focus['customer']!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${focus['contact']} · ${focus['status']}',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => logger.d('查看详情'),
          ),
        );
      },
    );
  }

  /// 快速操作区域
  Widget _buildQuickActionsSection() {
    return ModernCard(
      title: '快速操作',
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Row(
          children: [
            Expanded(child: _buildQuickAction(Icons.add_shopping_cart, '新增订单', () => _navigateTo('/orders/create'))),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildQuickAction(Icons.person_add, '新增客户', () => _navigateTo('/customers/create'))),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildQuickAction(Icons.add_box, '新增商品', () => _navigateTo('/products/create'))),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildQuickAction(Icons.shopping_bag, '新增采购', () => _navigateTo('/purchase/create'))),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildQuickAction(Icons.input, '入库申请', () => _navigateTo('/warehouse/inbound'))),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildQuickAction(Icons.output, '出库申请', () => _navigateTo('/warehouse/outbound'))),
          ],
        ),
      ),
    );
  }

  /// 构建单个快速操作按钮
  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, size: 24, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 事件处理方法
  Future<void> _onRefresh() async {
    await _loadDashboardData();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _clearSearch();
    }
  }

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _dataService.globalSearch(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      logger.e('搜索失败: $e');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = null;
    });
  }

  void _onTimeRangeChanged(String range) async {
    if (range == '自定义') {
      await CustomDateRangePicker.show(
        context: context,
        initialStartDate: _customStartDate,
        initialEndDate: _customEndDate,
        onDateRangeSelected: (start, end) {
          setState(() {
            _selectedTimeRange = range;
            _customStartDate = start;
            _customEndDate = end;
          });
          _loadDashboardData();
        },
      );
    } else {
      setState(() {
        _selectedTimeRange = range;
      });
      _loadDashboardData();
    }
  }

  void _navigateTo(String route) {
    context.go(route);
  }
}
