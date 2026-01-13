import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/crm_provider.dart';
import 'package:erpcrm_client/models/crm/customer.dart';
import '../../widgets/two_level_tab_layout.dart';
import '../../widgets/customer/customer_stat_card.dart';
import '../../widgets/customer/customer_growth_chart.dart';
import '../../services/customer_data_service.dart';
import './customer_category_list_screen.dart';
import './customer_tag_list_screen.dart';

class CustomersScreenEnhanced extends ConsumerStatefulWidget {
  const CustomersScreenEnhanced({super.key});

  @override
  ConsumerState<CustomersScreenEnhanced> createState() => _CustomersScreenEnhancedState();
}

class _CustomersScreenEnhancedState extends ConsumerState<CustomersScreenEnhanced> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 客户管理
      TabConfig(
        title: '客户管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '客户列表（增强版）',
            content: const _CustomerListViewEnhanced(),
          ),
          SecondLevelTabConfig(
            title: '客户列表（原版）',
            content: const _CustomerListView(),
          ),
          SecondLevelTabConfig(
            title: '客户分类',
            content: const CustomerCategoryListScreen(),
          ),
          SecondLevelTabConfig(
            title: '客户标签',
            content: const CustomerTagListScreen(),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
      moduleName: '客户管理',
    );
  }
}

// 客户列表增强版视图
class _CustomerListViewEnhanced extends ConsumerStatefulWidget {
  const _CustomerListViewEnhanced();

  @override
  ConsumerState<_CustomerListViewEnhanced> createState() => _CustomerListViewEnhancedState();
}

class _CustomerListViewEnhancedState extends ConsumerState<_CustomerListViewEnhanced> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _metrics = {};
  List<Map<String, dynamic>> _trendData = [];
  Map<String, dynamic> _valueAnalysis = {};
  bool _isLoadingMetrics = true;
  Set<int> _selectedCustomerIds = {};

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoadingMetrics = true;
    });

    final metrics = await CustomerDataService.getCustomerMetrics();
    final trendData = await CustomerDataService.getCustomerGrowthTrend();
    final valueAnalysis = await CustomerDataService.getCustomerValueAnalysis();

    setState(() {
      _metrics = metrics;
      _trendData = trendData;
      _valueAnalysis = valueAnalysis;
      _isLoadingMetrics = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);

    return Column(
      children: [
        // 统计卡片区域
        if (_isLoadingMetrics)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF003366),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 统计卡片
                Row(
                  children: [
                    Expanded(
                      child: CustomerStatCard(
                        title: '总客户数',
                        value: _metrics['totalCustomers'].toString(),
                        subtitle: '累计客户数量',
                        icon: Icons.people,
                        color: const Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomerStatCard(
                        title: '新增客户',
                        value: _metrics['newCustomers'].toString(),
                        subtitle: '最近30天',
                        icon: Icons.person_add,
                        color: Colors.green,
                        trend: _metrics['growthRate'] >= 0
                            ? '+${_metrics['growthRate'].toStringAsFixed(1)}%'
                            : '${_metrics['growthRate'].toStringAsFixed(1)}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomerStatCard(
                        title: '活跃客户',
                        value: _metrics['activeCustomers'].toString(),
                        subtitle: '最近30天有跟进',
                        icon: Icons.trending_up,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomerStatCard(
                        title: '商机客户',
                        value: _metrics['opportunityCustomers'].toString(),
                        subtitle: '有商机的客户',
                        icon: Icons.star,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 客户增长趋势图表
                CustomerGrowthChartWidget(
                  trendData: _trendData,
                  title: '客户增长趋势（最近30天）',
                ),
                const SizedBox(height: 16),
                // 客户价值分析
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '客户价值分布',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildValueCard(
                                '高价值客户',
                                _valueAnalysis['highValueCustomers'].toString(),
                                '${_valueAnalysis['highValuePercentage']}%',
                                Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildValueCard(
                                '中价值客户',
                                _valueAnalysis['mediumValueCustomers'].toString(),
                                '${_valueAnalysis['mediumValuePercentage']}%',
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildValueCard(
                                '低价值客户',
                                _valueAnalysis['lowValueCustomers'].toString(),
                                '${_valueAnalysis['lowValuePercentage']}%',
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '客户列表',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366),
                ),
              ),
              Row(
                children: [
                  // 批量操作按钮（只有选中客户时显示）
                  if (_selectedCustomerIds.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        _batchExport();
                      },
                      icon: const Icon(Icons.download),
                      label: Text('批量导出 (${_selectedCustomerIds.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _batchAddTag();
                      },
                      icon: const Icon(Icons.label),
                      label: const Text('批量标签'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/customers/new');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('添加客户'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 搜索框
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索客户名称、联系人、电话或邮箱',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  ref.refresh(customersProvider);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF003366)),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (keyword) {
              if (keyword.isNotEmpty) {
                ref.read(customersProvider.notifier).searchCustomers(keyword);
              } else {
                ref.refresh(customersProvider);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        // 客户列表
        Expanded(
          child: customers.when(
            data: (customerList) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    itemCount: customerList.length,
                    itemBuilder: (context, index) {
                      final customer = customerList[index];
                      final isSelected = _selectedCustomerIds.contains(customer.customerId);
                      
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              context.push('/customers/${customer.customerId}');
                            },
                            hoverColor: const Color(0xFFF5F5F5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  // 多选框
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedCustomerIds.add(customer.customerId);
                                        } else {
                                          _selectedCustomerIds.remove(customer.customerId);
                                        }
                                      });
                                    },
                                    activeColor: const Color(0xFF003366),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF003366),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '联系人: ${customer.contactPerson}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '电话: ${customer.contactPhone}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '邮箱: ${customer.contactEmail}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(Icons.category_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '分类: ${customer.categoryName}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF003366),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < customerList.length - 1)
                            const Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Color(0xFFE0E0E0),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF003366),
                ),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败: $error',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(customersProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard(String title, String value, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _batchExport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量导出'),
        content: Text('确定要导出选中的 ${_selectedCustomerIds.length} 个客户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await CustomerDataService.exportCustomers(_selectedCustomerIds.toList());
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
                setState(() {
                  _selectedCustomerIds.clear();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _batchAddTag() {
    final tagController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量添加标签'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('为选中的 ${_selectedCustomerIds.length} 个客户添加标签'),
            const SizedBox(height: 16),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: '标签名称',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tagController.text.isNotEmpty) {
                final success = await CustomerDataService.batchAddTag(
                  _selectedCustomerIds.toList(),
                  tagController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? '标签添加成功' : '标签添加失败'),
                    ),
                  );
                  if (success) {
                    setState(() {
                      _selectedCustomerIds.clear();
                    });
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// 客户列表原版视图（保留原有功能）
class _CustomerListView extends ConsumerWidget {
  const _CustomerListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    final searchController = TextEditingController();

    return Column(
      children: [
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '客户列表',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/customers/new');
                },
                icon: const Icon(Icons.add),
                label: const Text('添加客户'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
        // 搜索框
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索客户名称或联系人',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  searchController.clear();
                  ref.refresh(customersProvider);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF003366)),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (keyword) {
              if (keyword.isNotEmpty) {
                ref.read(customersProvider.notifier).searchCustomers(keyword);
              } else {
                ref.refresh(customersProvider);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        // 客户列表
        Expanded(
          child: customers.when(
            data: (customerList) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    itemCount: customerList.length,
                    itemBuilder: (context, index) {
                      final customer = customerList[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              context.push('/customers/${customer.customerId}');
                            },
                            hoverColor: const Color(0xFFF5F5F5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF003366),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '联系人: ${customer.contactPerson}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '电话: ${customer.contactPhone}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '邮箱: ${customer.contactEmail}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(Icons.category_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '分类: ${customer.categoryName}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF003366),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < customerList.length - 1)
                            const Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Color(0xFFE0E0E0),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF003366),
                ),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败: $error',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(customersProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
