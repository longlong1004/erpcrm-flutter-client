import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/services/api_service.dart';

// 分析模块类型枚举
enum AnalysisModule {
  customerLevel,
  customerProfile,
  salesTrend,
  productSales,
  salesForecast,
  anomalyDetection,
  dashboard,
  reportAutoSend,
  chat,
}

// 通用图表数据模型
class ChartData {
  final String category;
  final double value;
  final Color? color;

  ChartData(this.category, this.value, {this.color});
}

// 仪表盘数据模型
class DashboardData {
  final int totalCustomers;
  final int pendingFollowups;
  final int totalProducts;
  final int newCustomersThisMonth;
  final int todayOrders;
  final int totalOrders;
  final int pendingSalesOpportunities;
  final double totalRevenueThisMonth;

  DashboardData({
    required this.totalCustomers,
    required this.pendingFollowups,
    required this.totalProducts,
    required this.newCustomersThisMonth,
    required this.todayOrders,
    required this.totalOrders,
    required this.pendingSalesOpportunities,
    required this.totalRevenueThisMonth,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalCustomers: int.tryParse(json['totalCustomers'].toString()) ?? 0,
      pendingFollowups: int.tryParse(json['pendingFollowups'].toString()) ?? 0,
      totalProducts: int.tryParse(json['totalProducts'].toString()) ?? 0,
      newCustomersThisMonth: int.tryParse(json['newCustomersThisMonth'].toString()) ?? 0,
      todayOrders: int.tryParse(json['todayOrders'].toString()) ?? 0,
      totalOrders: int.tryParse(json['totalOrders'].toString()) ?? 0,
      pendingSalesOpportunities: int.tryParse(json['pendingSalesOpportunities'].toString()) ?? 0,
      totalRevenueThisMonth: double.tryParse(json['totalRevenueThisMonth'].toString()) ?? 0.0,
    );
  }
}

class SimpleAIAnalysisScreen extends ConsumerStatefulWidget {
  const SimpleAIAnalysisScreen({super.key});

  @override
  ConsumerState<SimpleAIAnalysisScreen> createState() => _SimpleAIAnalysisScreenState();
}

class _SimpleAIAnalysisScreenState extends ConsumerState<SimpleAIAnalysisScreen> {
  // 当前选中的分析模块
  AnalysisModule _selectedModule = AnalysisModule.dashboard;
  
  // 真实API数据
  DashboardData? _dashboardData;
  List<dynamic>? _productsData;
  List<dynamic>? _ordersData;
  List<dynamic>? _customersData;
  Map<String, dynamic>? _integratedData;
  
  // 加载状态
  bool _isLoading = false;
  String _errorMessage = '';
  Map<AnalysisModule, bool> _moduleLoadingStates = {
    for (var module in AnalysisModule.values)
      module: false
  };
  Map<AnalysisModule, String> _moduleErrorMessages = {
    for (var module in AnalysisModule.values)
      module: ''
  };

  @override
  void initState() {
    super.initState();
    // 组件加载时自动获取仪表盘数据，这是所有模块的基础
    _loadDashboardData();
  }
  
  // 加载仪表盘数据（所有模块的基础数据）
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      print('开始加载仪表盘数据...');
      final response = await apiService.getDashboardData();
      
      // 确保response是Map类型
      if (response is Map<String, dynamic>) {
        _dashboardData = DashboardData.fromJson(response);
        print('仪表盘数据加载成功: $_dashboardData');
      } else {
        print('仪表盘数据格式错误: $response');
        setState(() {
          _errorMessage = '仪表盘数据格式错误';
        });
      }
      
    } catch (e, stackTrace) {
      print('加载仪表盘数据时发生错误: $e');
      print('错误堆栈: $stackTrace');
      setState(() {
        _errorMessage = '获取仪表盘数据失败，请稍后重试';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 根据模块加载对应数据
  Future<void> _loadModuleData(AnalysisModule module) async {
    setState(() {
      _moduleLoadingStates[module] = true;
      _moduleErrorMessages[module] = '';
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      print('开始加载${_getModuleTitle(module)}数据...');
      
      // 根据不同模块加载不同数据
      switch (module) {
        case AnalysisModule.salesTrend:
        case AnalysisModule.salesForecast:
          // 销售趋势和销售预测需要订单数据
          if (_ordersData == null) {
            _ordersData = await apiService.getOrders();
            print('订单数据加载成功: ${_ordersData?.length}条');
          }
          break;
        case AnalysisModule.productSales:
          // 产品销售分析需要产品数据
          if (_productsData == null) {
            _productsData = await apiService.getProducts();
            print('产品数据加载成功: ${_productsData?.length}条');
          }
          break;
        case AnalysisModule.customerLevel:
        case AnalysisModule.customerProfile:
          // 客户分析需要客户数据
          if (_customersData == null) {
            _customersData = await apiService.getCustomers();
            print('客户数据加载成功: ${_customersData?.length}条');
          }
          break;
        // 其他模块可能不需要额外数据，或者需要其他API
        default:
          break;
      }
      
    } catch (e, stackTrace) {
      print('加载模块数据时发生错误: $e');
      print('错误堆栈: $stackTrace');
      setState(() {
        _moduleErrorMessages[module] = '获取${_getModuleTitle(module)}数据失败，请稍后重试';
      });
    } finally {
      setState(() {
        _moduleLoadingStates[module] = false;
      });
    }
  }
  
  // 获取模块标题
  String _getModuleTitle(AnalysisModule module) {
    switch (module) {
      case AnalysisModule.customerLevel:
        return '客户等级分析';
      case AnalysisModule.customerProfile:
        return '客户画像构建';
      case AnalysisModule.salesTrend:
        return '销售趋势分析';
      case AnalysisModule.productSales:
        return '产品销售分析';
      case AnalysisModule.salesForecast:
        return '销售预测功能';
      case AnalysisModule.anomalyDetection:
        return '异常检测预警';
      case AnalysisModule.dashboard:
        return '可视化仪表盘';
      case AnalysisModule.reportAutoSend:
        return '报告自动发送';
      case AnalysisModule.chat:
        return '智能聊天助手';
      default:
        return '未知模块';
    }
  }
  
  // 获取模块图标
  IconData _getModuleIcon(AnalysisModule module) {
    switch (module) {
      case AnalysisModule.customerLevel:
        return Icons.people_outline;
      case AnalysisModule.customerProfile:
        return Icons.person_outline;
      case AnalysisModule.salesTrend:
        return Icons.trending_up_outlined;
      case AnalysisModule.productSales:
        return Icons.shopping_cart_outlined;
      case AnalysisModule.salesForecast:
        return Icons.analytics_outlined;
      case AnalysisModule.anomalyDetection:
        return Icons.warning_outlined;
      case AnalysisModule.dashboard:
        return Icons.dashboard_outlined;
      case AnalysisModule.reportAutoSend:
        return Icons.send_outlined;
      case AnalysisModule.chat:
        return Icons.chat_outlined;
      default:
        return Icons.help_outline;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'AI智能分析机器人',
      child: SafeArea(
        child: Row(
          children: [
            // 左侧功能模块导航
            _buildModuleNavigation(),
            // 右侧主要内容区域
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建左侧功能模块导航
  Widget _buildModuleNavigation() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        children: [
          // 模块标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE1E8ED),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: const Text(
              '分析模块',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5),
              ),
            ),
          ),
          // 模块列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: AnalysisModule.values.length,
              itemBuilder: (context, index) {
                final module = AnalysisModule.values[index];
                final isSelected = _selectedModule == module;
                
                return ListTile(
                  leading: Icon(
                    _getModuleIcon(module),
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.grey,
                  ),
                  title: Text(
                    _getModuleTitle(module),
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF1E88E5) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: const Color(0xFFE3F2FD),
                  onTap: () {
                    setState(() {
                      _selectedModule = module;
                    });
                    // 切换模块时加载对应数据
                    _loadModuleData(module);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建主要内容区域
  Widget _buildMainContent() {
    // 显示加载状态
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载数据...'),
          ],
        ),
      );
    }
    
    // 显示错误信息
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    
    // 根据选中的模块显示不同内容
    switch (_selectedModule) {
      case AnalysisModule.dashboard:
        return _buildDashboardModule();
      case AnalysisModule.customerLevel:
        return _buildCustomerLevelModule();
      case AnalysisModule.customerProfile:
        return _buildCustomerProfileModule();
      case AnalysisModule.salesTrend:
        return _buildSalesTrendModule();
      case AnalysisModule.productSales:
        return _buildProductSalesModule();
      case AnalysisModule.salesForecast:
        return _buildSalesForecastModule();
      case AnalysisModule.anomalyDetection:
        return _buildAnomalyDetectionModule();
      case AnalysisModule.reportAutoSend:
        return _buildReportAutoSendModule();
      case AnalysisModule.chat:
        return _buildChatModule();
      default:
        return const Center(child: Text('未知模块'));
    }
  }
  
  // 构建仪表盘模块
  Widget _buildDashboardModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '可视化仪表盘',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 关键指标卡片
        _buildMetricCards(),
        const SizedBox(height: 24),
        
        // 销售趋势图表
        _buildSimpleChart(
          '销售趋势',
          _prepareSalesTrendData(),
        ),
        const SizedBox(height: 24),
        
        // 客户等级分布图表
        _buildSimpleChart(
          '客户等级分布',
          _prepareCustomerLevelData(),
        ),
      ],
    );
  }
  
  // 构建关键指标卡片
  Widget _buildMetricCards() {
    final metrics = [
      {
        'title': '总客户数',
        'value': '${_dashboardData?.totalCustomers ?? 0}',
        'icon': Icons.people,
      },
      {
        'title': '今日订单',
        'value': '${_dashboardData?.todayOrders ?? 0}',
        'icon': Icons.shopping_cart,
      },
      {
        'title': '本月新增客户',
        'value': '${_dashboardData?.newCustomersThisMonth ?? 0}',
        'icon': Icons.person_add,
      },
      {
        'title': '本月营收',
        'value': '¥${_dashboardData?.totalRevenueThisMonth.toStringAsFixed(2) ?? '0.00'}',
        'icon': Icons.monetization_on,
      },
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        children: metrics.map((metric) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            metric['value'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(metric['icon'] as IconData, color: const Color(0xFF1E88E5), size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // 构建简单图表（使用Flutter原生组件替代charts_flutter）
  Widget _buildSimpleChart(String title, List<ChartData> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: item.color ?? Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item.value.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            item.category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 准备销售趋势数据
  List<ChartData> _prepareSalesTrendData() {
    // 使用模拟数据
    return [
      ChartData('1月', 1250000.0),
      ChartData('2月', 1380000.0),
      ChartData('3月', 1560000.0),
    ];
  }
  
  // 准备客户等级分布数据
  List<ChartData> _prepareCustomerLevelData() {
    final totalCustomers = _dashboardData?.totalCustomers ?? 100;
    return [
      ChartData('VIP', totalCustomers * 0.1),
      ChartData('重要', totalCustomers * 0.25),
      ChartData('普通', totalCustomers * 0.5),
      ChartData('潜在', totalCustomers * 0.15),
    ];
  }
  
  // 构建客户等级分析模块
  Widget _buildCustomerLevelModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '客户等级分析',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 客户等级分布图表
        _buildSimpleChart(
          '客户等级分布',
          _prepareCustomerLevelData(),
        ),
        const SizedBox(height: 24),
        
        // 简单说明
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '客户等级分析模块显示了不同等级客户的分布情况，帮助您了解客户结构，制定针对性的营销策略。',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
  
  // 构建客户画像分析模块
  Widget _buildCustomerProfileModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '客户画像构建',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 客户行业分布图表
        _buildSimpleChart(
          '客户行业分布',
          _prepareCustomerIndustryData(),
        ),
        const SizedBox(height: 24),
        
        // 简单说明
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '客户画像构建模块帮助您了解客户的基本特征，包括行业分布、区域分布等，为精准营销提供数据支持。',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
  
  // 准备客户行业分布数据
  List<ChartData> _prepareCustomerIndustryData() {
    return [
      ChartData('建筑', 35.0),
      ChartData('交通', 28.0),
      ChartData('电力', 21.0),
      ChartData('制造', 12.0),
      ChartData('其他', 4.0),
    ];
  }
  
  // 构建销售趋势分析模块
  Widget _buildSalesTrendModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '销售趋势分析',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 销售趋势图表
        _buildSimpleChart(
          '销售趋势',
          _prepareSalesTrendData(),
        ),
        const SizedBox(height: 24),
        
        // 简单说明
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '销售趋势分析模块显示了公司的销售变化趋势，帮助您了解销售增长情况，制定合理的销售目标。',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
  
  // 构建产品销售分析模块
  Widget _buildProductSalesModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '产品销售分析',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 产品销售图表
        _buildSimpleChart(
          '产品销售TOP5',
          _prepareProductSalesData(),
        ),
        const SizedBox(height: 24),
        
        // 简单说明
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '产品销售分析模块显示了产品的销售情况，帮助您了解哪些产品销售较好，优化产品结构。',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
  
  // 准备产品销售数据
  List<ChartData> _prepareProductSalesData() {
    return [
      ChartData('产品A', 2500000.0),
      ChartData('产品B', 1800000.0),
      ChartData('产品C', 1200000.0),
      ChartData('产品D', 950000.0),
      ChartData('产品E', 780000.0),
    ];
  }
  
  // 构建销售预测功能模块
  Widget _buildSalesForecastModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '销售预测功能',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 销售预测图表
        _buildSimpleChart(
          '销售预测',
          _prepareSalesForecastData(),
        ),
        const SizedBox(height: 24),
        
        // 简单说明
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '销售预测功能模块基于历史数据预测未来的销售趋势，帮助您提前规划生产和库存。',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
  
  // 准备销售预测数据
  List<ChartData> _prepareSalesForecastData() {
    return [
      ChartData('1月', 1250000.0),
      ChartData('2月', 1380000.0),
      ChartData('3月', 1560000.0),
      ChartData('4月(预测)', 1680000.0),
      ChartData('5月(预测)', 1750000.0),
    ];
  }
  
  // 构建异常检测预警模块
  Widget _buildAnomalyDetectionModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '异常检测预警',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 异常预警列表
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '异常预警列表',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnomalyItem('高', '客户123采购量异常下降'),
                _buildAnomalyItem('中', '产品ABC销售额异常波动'),
                _buildAnomalyItem('低', '地区XYZ订单量略有下降'),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // 构建异常项
  Widget _buildAnomalyItem(String level, String description) {
    Color levelColor;
    switch (level) {
      case '高':
        levelColor = Colors.red;
        break;
      case '中':
        levelColor = Colors.orange;
        break;
      case '低':
        levelColor = Colors.yellow;
        break;
      default:
        levelColor = Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: levelColor,
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.only(right: 12),
          ),
          Expanded(
            child: Text(
              description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            level,
            style: TextStyle(
              color: levelColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建报告自动发送模块
  Widget _buildReportAutoSendModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '报告自动发送',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 报告发送设置
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '报告发送设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('报告自动发送功能允许您设置定期发送分析报告到指定邮箱。'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // 打开设置页面
                  },
                  child: const Text('设置报告发送'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // 构建智能聊天助手模块
  Widget _buildChatModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '智能聊天助手',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 20),
        
        // 聊天界面
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '智能聊天助手',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('智能聊天助手可以帮助您分析数据，回答您的问题。'),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: '请输入您的问题...',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // 发送消息
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
