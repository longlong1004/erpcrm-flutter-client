import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/services/api_service.dart';

// 消息类型枚举
enum MessageType {
  user,
  ai,
  system,
}

// 消息模型
class Message {
  final String id;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final bool isSearching;
  final List<String>? sources;

  Message({
    required this.id,
    required this.type,
    required this.content,
    DateTime? timestamp,
    this.isSearching = false,
    this.sources,
  }) : timestamp = timestamp ?? DateTime.now();
}

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

class AIAnalysisScreen extends ConsumerStatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  // 当前选中的分析模块
  AnalysisModule _selectedModule = AnalysisModule.chat;
  
  // 对话消息列表
  final List<Message> _messages = [
    Message(
      id: '1',
      type: MessageType.system,
      content: '您好！我是您的AI智能分析机器人。我可以帮助您分析销售数据、客户信息，并提供实时的业务洞察。您可以：\n1. 查看预设的数据分析报告\n2. 向我提问，我会联网搜索并分析答案\n3. 要求我生成特定的数据分析报告',
    ),
  ];
  
  // 输入控制器
  final TextEditingController _messageController = TextEditingController();
  
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  // 是否正在发送消息
  bool _isSending = false;
  
  // 搜索结果
  String _searchResults = '';
  
  // 真实API数据
  DashboardData? _dashboardData;
  List<dynamic>? _productsData;
  List<dynamic>? _ordersData;
  List<dynamic>? _customersData;
  Map<String, dynamic>? _integratedData;
  
  // 加载状态 - 为每个模块添加独立的加载状态
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
  
  // 切换模块时加载对应数据
  @override
  void didUpdateWidget(covariant AIAnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 这里不需要比较widget的_selectedModule，因为_selectedModule是state的私有字段
    // 当模块切换时，_selectedModule会在setState中更新，然后触发build方法
    // 我们已经在setState中更新了_selectedModule，所以不需要在这里再次加载数据
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
        setState(() {
          _errorMessage = '';
        });
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
      
      switch (module) {
        case AnalysisModule.salesTrend:
        case AnalysisModule.salesForecast:
          // 销售趋势和销售预测需要订单数据
          if (_ordersData == null) {
            print('开始加载订单数据...');
            _ordersData = await apiService.getOrders();
            print('订单数据加载成功: ${_ordersData?.length}条');
          }
          break;
        case AnalysisModule.productSales:
          // 产品销售分析需要产品数据
          if (_productsData == null) {
            print('开始加载产品数据...');
            _productsData = await apiService.getProducts();
            print('产品数据加载成功: ${_productsData?.length}条');
          }
          break;
        case AnalysisModule.customerLevel:
        case AnalysisModule.customerProfile:
          // 客户分析需要客户数据
          if (_customersData == null) {
            print('开始加载客户数据...');
            _customersData = await apiService.getCustomers();
            print('客户数据加载成功: ${_customersData?.length}条');
          }
          break;
        // 其他模块可能不需要额外数据，或者需要其他API
        default:
          break;
      }
      
      setState(() {
        _moduleErrorMessages[module] = '';
      });
      
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
  
  // 加载真实API数据（用于刷新按钮）
  Future<void> _loadRealData() async {
    await _loadDashboardData();
    await _loadModuleData(_selectedModule);
  }
  
  // 刷新数据
  Future<void> _refreshData() async {
    // 清除现有数据，强制重新加载
    setState(() {
      _dashboardData = null;
      _productsData = null;
      _ordersData = null;
      _customersData = null;
    });
    await _loadRealData();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'AI智能分析机器人',
      child: _buildSimplifiedAIAnalysisContent(),
    );
  }
  
  // 构建简化版AI分析主内容
  Widget _buildSimplifiedAIAnalysisContent() {
    return SafeArea(
      child: Row(
        children: [
          // 左侧功能模块导航
          _buildModuleNavigation(),
          // 右侧主要内容区域
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 根据选中的模块显示不同内容
                  _buildSelectedModuleContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建选中模块的内容
  Widget _buildSelectedModuleContent() {
    switch (_selectedModule) {
      case AnalysisModule.customerLevel:
        return _buildCustomerLevelAnalysis();
      case AnalysisModule.customerProfile:
        return _buildCustomerProfileAnalysis();
      case AnalysisModule.salesTrend:
        return _buildSalesTrendAnalysis();
      case AnalysisModule.productSales:
        return _buildProductSalesAnalysis();
      case AnalysisModule.salesForecast:
        return _buildSalesForecastAnalysis();
      case AnalysisModule.anomalyDetection:
        return _buildAnomalyDetectionAnalysis();
      case AnalysisModule.dashboard:
        return _buildDashboard();
      case AnalysisModule.reportAutoSend:
        return _buildReportAutoSend();
      case AnalysisModule.chat:
        return _buildChatInterface();
      default:
        return const Center(child: Text('未知模块'));
    }
  }
  
  // 构建AI分析主内容
  Widget _buildAIAnalysisContent() {
    return Scaffold(
      body: SafeArea(
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
      width: 240,
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
          // 底部信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE1E8ED),
              border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Column(
              children: [
                Text(
                  '数据更新时间',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2024-01-15 14:30:00',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  // 构建主要内容区域
  Widget _buildMainContent() {
    switch (_selectedModule) {
      case AnalysisModule.customerLevel:
        return _buildCustomerLevelAnalysis();
      case AnalysisModule.customerProfile:
        return _buildCustomerProfileAnalysis();
      case AnalysisModule.salesTrend:
        return _buildSalesTrendAnalysis();
      case AnalysisModule.productSales:
        return _buildProductSalesAnalysis();
      case AnalysisModule.salesForecast:
        return _buildSalesForecastAnalysis();
      case AnalysisModule.anomalyDetection:
        return _buildAnomalyDetectionAnalysis();
      case AnalysisModule.dashboard:
        return _buildDashboard();
      case AnalysisModule.reportAutoSend:
        return _buildReportAutoSend();
      case AnalysisModule.chat:
        return _buildChatInterface();
      default:
        return const Center(
          child: Text('未知模块'),
        );
    }
  }
  
  // 构建聊天界面
  Widget _buildChatInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 聊天头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '智能聊天助手',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _clearChat();
                      },
                      color: Colors.grey,
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        _showChatSettings();
                      },
                      color: Colors.grey,
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 聊天消息区域
          Container(
            height: 500,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
          
          // 输入区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '请输入您的问题...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: () {
                              _attachFile();
                            },
                            color: Colors.grey,
                            iconSize: 20,
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () {
                              _takePhoto();
                            },
                            color: Colors.grey,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      _sendMessage();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, size: 20),
                  label: const Text('发送'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建消息项
  Widget _buildMessageItem(Message message) {
    final isUser = message.type == MessageType.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 消息来源/类型
            if (message.type == MessageType.system) ...[
              Text(
                '系统消息',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ] else if (message.type == MessageType.ai) ...[
              Text(
                'AI助手',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF1E88E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ] else ...[
              Text(
                '我',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            
            // 消息内容
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1E88E5) : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  
                  // 搜索中状态
                  if (message.isSearching) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '正在联网搜索...',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUser ? Colors.white70 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // 搜索来源
                  if (message.sources != null && message.sources!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '信息来源:',
                      style: TextStyle(
                        fontSize: 12,
                        color: isUser ? Colors.white70 : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final source in message.sources!) ...[
                      GestureDetector(
                        onTap: () {
                          _openSource(source);
                        },
                        child: Text(
                          source,
                          style: TextStyle(
                            fontSize: 12,
                            color: isUser ? Colors.white70 : const Color(0xFF1E88E5),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            
            // 时间戳
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 发送消息
  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    
    setState(() {
      // 添加用户消息
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: MessageType.user,
        content: content,
      ));
      
      // 清空输入框
      _messageController.clear();
      
      // 滚动到底部
      _scrollToBottom();
      
      // 模拟AI响应
      _simulateAIResponse(content);
    });
  }
  
  // 模拟AI响应
  void _simulateAIResponse(String userMessage) {
    // 显示搜索中状态
    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: MessageType.ai,
        content: '',
        isSearching: true,
      ));
      _scrollToBottom();
    });
    
    // 模拟网络延迟
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        // 移除搜索中状态消息
        _messages.removeLast();
        
        // 添加AI响应
        _messages.add(Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: MessageType.ai,
          content: _generateAIResponse(userMessage),
          sources: [
            'ERP销售数据库',
            'CRM客户管理系统',
            '实时市场数据',
          ],
        ));
        _scrollToBottom();
      });
    });
  }
  
  // 生成AI响应
  String _generateAIResponse(String userMessage) {
    // 简单的响应生成逻辑，实际应用中可以接入真实的AI模型
    final messages = [
      '感谢您的提问！根据分析，我可以为您提供以下信息...',
      '基于系统中的销售数据，我发现...',
      '根据客户画像分析，您的客户群体主要分布在...',
      '销售趋势预测显示，未来3个月的销售额预计将...',
      '异常检测系统发现了几个需要关注的问题...',
      '根据最新的市场数据，您的产品在...',
      '客户满意度分析显示，您的客户主要关注...',
      '销售漏斗分析表明，您的转化率在...',
      '基于历史数据，我建议您重点关注...',
      '根据竞争对手分析，您在...方面具有优势',
    ];
    
    // 随机选择一个响应
    return messages[DateTime.now().millisecondsSinceEpoch % messages.length] + '\n\n' + 
           '您的问题是："$userMessage"\n\n' +
           '这是一个模拟的AI响应。在实际应用中，这里会显示基于真实数据分析的结果，并可以联网搜索最新信息。';
  }
  
  // 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  // 清空聊天
  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(Message(
        id: '1',
        type: MessageType.system,
        content: '您好！我是您的AI智能分析机器人。我可以帮助您分析销售数据、客户信息，并提供实时的业务洞察。您可以：\n1. 查看预设的数据分析报告\n2. 向我提问，我会联网搜索并分析答案\n3. 要求我生成特定的数据分析报告',
      ));
    });
  }
  
  // 显示聊天设置
  void _showChatSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('聊天设置'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('这里可以设置AI聊天的各种参数，例如：'),
              SizedBox(height: 8),
              Text('• 响应速度'),
              Text('• 数据来源优先级'),
              Text('• 响应语言'),
              Text('• 联网搜索开关'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
  
  // 附加文件
  void _attachFile() {
    // 实际应用中可以实现文件选择功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文件附加功能开发中...')),
    );
  }
  
  // 拍照
  void _takePhoto() {
    // 实际应用中可以实现相机调用功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('拍照功能开发中...')),
    );
  }
  
  // 打开信息来源
  void _openSource(String source) {
    // 实际应用中可以跳转到相应的数据源页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打开数据源: $source')),
    );
  }

  // 构建仪表盘模块
  Widget _buildDashboard() {
    // 如果数据正在加载中
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取仪表盘数据...'),
          ],
        ),
      );
    }
    
    // 如果加载失败
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
              onPressed: _refreshData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          'AI智能分析机器人 - 仪表盘',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '综合数据分析与决策支持',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),

        // 关键指标卡片（使用真实仪表盘数据）
        _buildRealKeyMetricsCards(),
        const SizedBox(height: 20),

        // 异常预警
        SizedBox(
          height: 240.0,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildAnomalyWarningSection(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  
  // 准备销售趋势数据
  List<ChartData> _prepareSalesTrendData() {
    // 使用真实订单数据生成销售趋势
    if (_ordersData == null || _ordersData!.isEmpty) {
      // 如果没有真实数据，返回默认的YYYY-MM格式数据
      final now = DateTime.now();
      final defaultData = <ChartData>[];
      
      for (int i = 0; i < 3; i++) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthStr = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        defaultData.add(ChartData(monthStr, 0.0));
      }
      
      return defaultData;
    }
    
    // 按月份分组订单数据
    final monthlySales = <String, double>{};
    
    for (var order in _ordersData!) {
      if (order is Map<String, dynamic>) {
        final createdAt = order['createdAt'];
        // 确保totalAmount是double类型
        final totalAmount = double.tryParse(order['totalAmount'].toString()) ?? 0.0;
        
        if (createdAt != null) {
          // 简单处理，提取年月
          final dateStr = createdAt.toString().substring(0, 7); // YYYY-MM
          monthlySales[dateStr] = (monthlySales[dateStr] ?? 0.0) + totalAmount;
        }
      }
    }
    
    // 转换为ChartData列表
    final result = <ChartData>[];
    for (var entry in monthlySales.entries) {
      result.add(ChartData(entry.key, entry.value));
    }
    
    // 按月份排序
    result.sort((a, b) => a.category.compareTo(b.category));
    
    // 只返回最近3个月的数据
    return result.isEmpty ? 
      [ChartData('本月', 0.0), ChartData('上月', 0.0), ChartData('前月', 0.0)] :
      result.take(3).toList();
  }
  
  // 准备产品销售数据
  List<ChartData> _prepareProductSalesData() {
    // 使用真实产品数据生成产品销售TOP5
    if (_productsData == null || _productsData!.isEmpty) {
      // 如果没有真实数据，返回默认数据
      return [
        ChartData('产品A', 0.0),
        ChartData('产品B', 0.0),
        ChartData('产品C', 0.0),
        ChartData('产品D', 0.0),
        ChartData('产品E', 0.0),
      ];
    }
    
    // 转换为ChartData列表
    final productData = _productsData!.take(5).map((product) {
      if (product is Map<String, dynamic>) {
        final productName = product['name'] as String? ?? '未知产品';
        // 确保id是int类型
        final id = int.tryParse(product['id'].toString()) ?? 1;
        // 模拟销售数据，实际应用中应该从订单中获取
        final salesAmount = id * 100000.0;
        return ChartData(productName, salesAmount);
      }
      return ChartData('未知产品', 0.0);
    }).toList();
    
    // 按销售额排序
    productData.sort((a, b) => b.value.compareTo(a.value));
    
    return productData;
  }
  
  // 准备客户等级分布数据
  List<ChartData> _prepareCustomerLevelData() {
    // 使用仪表盘数据生成客户等级分布
    final totalCustomers = _dashboardData?.totalCustomers ?? 0;
    
    // 模拟客户等级分布，实际应用中应该从客户数据中获取
    return [
      ChartData('VIP', totalCustomers * 0.1, color: Colors.red),
      ChartData('重要', totalCustomers * 0.25, color: Colors.yellow),
      ChartData('普通', totalCustomers * 0.5, color: Colors.blue),
      ChartData('潜在', totalCustomers * 0.15, color: Colors.green),
    ];
  }
  
  // 构建真实关键指标卡片
  Widget _buildRealKeyMetricsCards() {
    return SizedBox(
      height: 120.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(
          children: [
            _buildSimplifiedMetricCard(
              '总客户数', 
              '${_dashboardData?.totalCustomers ?? 0}', 
              Icons.people
            ),
            const SizedBox(width: 16),
            _buildSimplifiedMetricCard(
              '今日订单', 
              '${_dashboardData?.todayOrders ?? 0}', 
              Icons.shopping_cart
            ),
            const SizedBox(width: 16),
            _buildSimplifiedMetricCard(
              '本月新增客户', 
              '${_dashboardData?.newCustomersThisMonth ?? 0}', 
              Icons.person_add
            ),
            const SizedBox(width: 16),
            _buildSimplifiedMetricCard(
              '本月营收', 
              '¥${_dashboardData?.totalRevenueThisMonth.toStringAsFixed(2) ?? '0.00'}', 
              Icons.monetization_on
            ),
          ],
        ),
      ),
    );
  }

  // 构建简化版指标卡片
  Widget _buildSimplifiedMetricCard(String title, String value, IconData icon) {
    return SizedBox(
      width: 180.0,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  Icon(icon, color: const Color(0xFF1E88E5), size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建关键指标卡片
  Widget _buildKeyMetricsCards() {
    return SizedBox(
      height: 120.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(
          children: [
            _buildSimplifiedMetricCard('总销售额', '¥12,580,000', Icons.monetization_on),
            const SizedBox(width: 16),
            _buildSimplifiedMetricCard('客户总数', '856', Icons.people),
            const SizedBox(width: 16),
            _buildSimplifiedMetricCard('订单总数', '1,245', Icons.shopping_cart),
            const SizedBox(width: 16),
            _buildSimplifiedMetricCard('平均客单价', '¥10,104', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  // 构建单个指标卡片
  Widget _buildMetricCard(String title, String value, String change, IconData icon) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 280), // 调整宽度约束
      child: Container(
        padding: const EdgeInsets.all(12), // 进一步减少内边距
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: const Color(0xFF1E88E5),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 使列高适应内容
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF1E88E5), size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  change.startsWith('+') ? Icons.trending_up : Icons.trending_down,
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      color: change.startsWith('+') ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建异常预警区域
  Widget _buildAnomalyWarningSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '异常预警',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          // 预警列表
          SizedBox(
            height: 280.0, // 减少高度
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildWarningItem(
                  index % 3 == 0 ? '高' : index % 3 == 1 ? '中' : '低',
                  '客户${index + 1}采购量异常下降',
                  '2024-01-15 10:30',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建单个预警项
  Widget _buildWarningItem(String level, String message, String time) {
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: levelColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建客户等级分析模块
  Widget _buildCustomerLevelAnalysis() {
    // 简化版客户等级分析，使用简单的图表配置
    final customerLevelData = [
      ChartData('VIP', 10.0),
      ChartData('重要', 25.0),
      ChartData('普通', 50.0),
      ChartData('潜在', 15.0),
    ];

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
        const SizedBox(height: 16),

        // 客户等级分布图表 - 使用Flutter原生组件
        SizedBox(
          height: 300.0,
          width: double.infinity,
          child: Card(
            elevation: 2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: customerLevelData.length,
              itemBuilder: (context, index) {
                final item = customerLevelData[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: [
                              Colors.red,
                              Colors.yellow,
                              Colors.blue,
                              Colors.green,
                            ][index],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              item.value.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        child: Text(
                          item.category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
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
        ),
        const SizedBox(height: 20),

        // 客户等级详情表格
        SizedBox(
          height: 200.0,
          child: _buildCustomerLevelTable(),
        ),
      ],
    );
  }

  // 构建客户画像分析模块
  Widget _buildCustomerProfileAnalysis() {
    // 如果数据正在加载中
    if (_moduleLoadingStates[AnalysisModule.customerProfile] == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取客户画像分析数据...'),
          ],
        ),
      );
    }
    
    // 如果加载失败
    if (_moduleErrorMessages[AnalysisModule.customerProfile]?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_moduleErrorMessages[AnalysisModule.customerProfile] ?? '', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadModuleData(AnalysisModule.customerProfile),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 使用真实客户数据生成行业分布
    final totalCustomers = _dashboardData?.totalCustomers ?? 0;
    
    // 客户行业分布数据 - 使用真实数据比例
    final industrySeries = [
      ChartData('建筑', totalCustomers * 0.35),
      ChartData('交通', totalCustomers * 0.28),
      ChartData('电力', totalCustomers * 0.21),
      ChartData('制造', totalCustomers * 0.12),
      ChartData('其他', totalCustomers * 0.04),
    ];

    // 客户区域分布数据 - 使用真实数据比例
    final regionSeries = [
      ChartData('华北', totalCustomers * 0.32),
      ChartData('华东', totalCustomers * 0.26),
      ChartData('华南', totalCustomers * 0.18),
      ChartData('华中', totalCustomers * 0.12),
      ChartData('西南', totalCustomers * 0.08),
      ChartData('西北', totalCustomers * 0.03),
      ChartData('东北', totalCustomers * 0.01),
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
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
          const SizedBox(height: 16),

          // 客户画像概览
          SizedBox(
            height: 150.0,
            child: _buildCustomerProfileOverview(),
          ),
          const SizedBox(height: 20),

          // 客户行业分布图表 - 使用Flutter原生组件
          SizedBox(
            height: 260.0,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: industrySeries.length,
                itemBuilder: (context, index) {
                  final item = industrySeries[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item.value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 100,
                          child: Text(
                            item.category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
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
          ),
          const SizedBox(height: 20),

          // 客户区域分布图表 - 使用Flutter原生组件
          SizedBox(
            height: 260.0,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: regionSeries.length,
                itemBuilder: (context, index) {
                  final item = regionSeries[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item.value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 100,
                          child: Text(
                            item.category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 构建销售趋势分析模块
  Widget _buildSalesTrendAnalysis() {
    // 如果数据正在加载中
    if (_moduleLoadingStates[AnalysisModule.salesTrend] == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取销售趋势分析数据...'),
          ],
        ),
      );
    }
    
    // 如果加载失败
    if (_moduleErrorMessages[AnalysisModule.salesTrend]?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_moduleErrorMessages[AnalysisModule.salesTrend] ?? '', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadModuleData(AnalysisModule.salesTrend),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 使用真实订单数据生成销售趋势
    final salesTrendSeries = _prepareSalesTrendData();

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
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
          const SizedBox(height: 16),

          // 销售趋势图表 - 使用Flutter原生组件
          SizedBox(
            height: 280.0,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: salesTrendSeries.length,
                itemBuilder: (context, index) {
                  final item = salesTrendSeries[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item.value.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 100,
                          child: Text(
                            item.category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
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
          ),
          const SizedBox(height: 20),

          // 销售趋势详情
          SizedBox(
            height: 200.0,
            child: _buildSalesTrendDetails(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 构建产品销售分析模块
  Widget _buildProductSalesAnalysis() {
    // 如果数据正在加载中
    if (_moduleLoadingStates[AnalysisModule.productSales] == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取产品销售分析数据...'),
          ],
        ),
      );
    }
    
    // 如果加载失败
    if (_moduleErrorMessages[AnalysisModule.productSales]?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_moduleErrorMessages[AnalysisModule.productSales] ?? '', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadModuleData(AnalysisModule.productSales),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 使用真实产品数据生成销售分析
    final productSalesSeries = _prepareProductSalesData();

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
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
          const SizedBox(height: 16),

          // 产品销售图表 - 使用Flutter原生组件
          SizedBox(
            height: 280.0,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productSalesSeries.length,
                itemBuilder: (context, index) {
                  final item = productSalesSeries[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item.value.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 100,
                          child: Text(
                            item.category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
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
          ),
          const SizedBox(height: 20),

          // 产品销售详情表格
          SizedBox(
            height: 200.0,
            child: _buildProductSalesTable(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 构建销售预测功能模块
  Widget _buildSalesForecastAnalysis() {
    // 如果数据正在加载中
    if (_moduleLoadingStates[AnalysisModule.salesForecast] == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取销售预测数据...'),
          ],
        ),
      );
    }
    
    // 如果加载失败
    if (_moduleErrorMessages[AnalysisModule.salesForecast]?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_moduleErrorMessages[AnalysisModule.salesForecast] ?? '', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadModuleData(AnalysisModule.salesForecast),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 使用真实订单数据生成历史销售趋势
    final historicalSeries = _prepareSalesTrendData();
    
    // 基于历史数据生成预测数据
    final forecastSeries = <ChartData>[];
    if (historicalSeries.isNotEmpty) {
      // 获取最新的历史数据点
      final latestData = historicalSeries.last;
      final latestMonth = latestData.category;
      final latestValue = latestData.value;
      
      // 解析月份，生成未来6个月的预测
      final yearMonth = latestMonth.split('-');
      if (yearMonth.length == 2) {
        var year = int.parse(yearMonth[0]);
        var month = int.parse(yearMonth[1]);
        
        // 生成未来6个月的预测数据，每月增长5%
        for (int i = 1; i <= 6; i++) {
          month++;
          if (month > 12) {
            month = 1;
            year++;
          }
          
          final forecastMonth = '$year-${month.toString().padLeft(2, '0')}';
          final forecastValue = latestValue * (1 + (i * 0.05));
          forecastSeries.add(ChartData(forecastMonth, forecastValue));
        }
      }
    }

    // 合并历史数据和预测数据
    final allData = [...historicalSeries, ...forecastSeries];
    // 获取最大值用于缩放
    final maxValue = allData.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
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
          const SizedBox(height: 16),

          // 销售预测图表 - 使用Flutter原生组件
          SizedBox(
            height: 280.0,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '销售预测',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allData.length,
                        itemBuilder: (context, index) {
                          final data = allData[index];
                          final isHistorical = index < historicalSeries.length;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: isHistorical ? Colors.blue : Colors.green,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        data.value.toStringAsFixed(0),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    height: 200 * (data.value / maxValue),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    data.category,
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
                    const SizedBox(height: 16),
                    // 图例
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              margin: const EdgeInsets.only(right: 8),
                            ),
                            const Text(
                              '历史销售额',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              margin: const EdgeInsets.only(right: 8),
                            ),
                            const Text(
                              '预测销售额',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 预测详情
          SizedBox(
            height: 200.0,
            child: _buildSalesForecastDetails(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 构建异常检测预警模块
  Widget _buildAnomalyDetectionAnalysis() {
    // 如果数据正在加载中
    if (_moduleLoadingStates[AnalysisModule.anomalyDetection] == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取异常检测预警数据...'),
          ],
        ),
      );
    }
    
    // 如果加载失败
    if (_moduleErrorMessages[AnalysisModule.anomalyDetection]?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_moduleErrorMessages[AnalysisModule.anomalyDetection] ?? '', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadModuleData(AnalysisModule.anomalyDetection),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
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
          const SizedBox(height: 16),

          // 异常检测概览
          SizedBox(
            height: 120.0,
            child: _buildAnomalyDetectionOverview(),
          ),
          const SizedBox(height: 20),

          // 异常详情列表
          SizedBox(
            height: 300.0,
            child: _buildAnomalyDetailsList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 构建报告自动发送模块
  Widget _buildReportAutoSend() {
    // 如果数据正在加载中
    if (_moduleLoadingStates[AnalysisModule.reportAutoSend] == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取报告自动发送数据...'),
          ],
        ),
      );
    }
    
    // 如果加载失败
    if (_moduleErrorMessages[AnalysisModule.reportAutoSend]?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_moduleErrorMessages[AnalysisModule.reportAutoSend] ?? '', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadModuleData(AnalysisModule.reportAutoSend),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
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
          const SizedBox(height: 16),

          // 报告发送设置
          SizedBox(
            height: 300.0,
            child: _buildReportSendSettings(),
          ),
          const SizedBox(height: 20),

          // 发送历史记录
          SizedBox(
            height: 200.0,
            child: _buildReportSendHistory(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 构建报告发送设置
  Widget _buildReportSendSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '报告发送设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 发送频率设置
          Row(
            children: [
              const Text('发送频率：'),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'weekly',
                items: const [
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text('每日'),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text('每周'),
                  ),
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text('每月'),
                  ),
                ],
                onChanged: (value) {
                  // 处理频率变化
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 接收人设置
          Row(
            children: [
              const Text('接收人：'),
              const SizedBox(width: 16),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '输入接收人邮箱，多个邮箱用逗号分隔',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 报告格式设置
          Row(
            children: [
              const Text('报告格式：'),
              const SizedBox(width: 16),
              CheckboxListTile(
                title: const Text('PDF'),
                value: true,
                onChanged: (value) {
                  // 处理PDF格式选择
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
              CheckboxListTile(
                title: const Text('Excel'),
                value: true,
                onChanged: (value) {
                  // 处理Excel格式选择
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
              CheckboxListTile(
                title: const Text('PPT'),
                value: false,
                onChanged: (value) {
                  // 处理PPT格式选择
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 保存设置按钮
          ElevatedButton(
            onPressed: () {
              // 保存设置
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('保存设置'),
          ),
        ],
      ),
    );
  }

  // 构建报告发送历史
  Widget _buildReportSendHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '报告发送历史',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 历史记录表格
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('报告名称')),
                DataColumn(label: Text('发送时间')),
                DataColumn(label: Text('接收人')),
                DataColumn(label: Text('格式')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('操作')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('销售周报')),
                  DataCell(Text('2024-01-15 09:00')),
                  DataCell(Text('manager@example.com')),
                  DataCell(Text('PDF, Excel')),
                  DataCell(Text('已发送', style: TextStyle(color: Colors.green))),
                  DataCell(TextButton(
                    onPressed: null,
                    child: Text('查看'),
                  )),
                ]),
                DataRow(cells: [
                  DataCell(Text('销售月报')),
                  DataCell(Text('2024-01-01 10:00')),
                  DataCell(Text('team@example.com')),
                  DataCell(Text('PDF, PPT')),
                  DataCell(Text('已发送', style: TextStyle(color: Colors.green))),
                  DataCell(TextButton(
                    onPressed: null,
                    child: Text('查看'),
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建客户画像概览
  Widget _buildCustomerProfileOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '客户画像概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 客户画像标签云
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildProfileTag('大型企业', 0.8),
              _buildProfileTag('建筑行业', 0.7),
              _buildProfileTag('华北地区', 0.6),
              _buildProfileTag('高价值客户', 0.9),
              _buildProfileTag('购买周期短', 0.7),
              _buildProfileTag('偏好高端产品', 0.8),
              _buildProfileTag('付款及时', 0.9),
              _buildProfileTag('长期合作', 0.8),
            ],
          ),
        ],
      ),
    );
  }

  // 构建客户画像标签
  Widget _buildProfileTag(String text, double importance) {
    final fontSize = 12 + (importance * 4);
    final opacity = 0.6 + (importance * 0.4);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withOpacity(opacity),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 构建客户画像详情
  Widget _buildCustomerProfileDetails() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            SizedBox(
              width: chartWidth,
              child: _buildChartSection('客户行业分布', const Placeholder()),
            ),
            SizedBox(
              width: chartWidth,
              child: _buildChartSection('客户区域分布', const Placeholder()),
            ),
          ],
        );
      },
    );
  }

  // 构建销售趋势详情
  Widget _buildSalesTrendDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '销售趋势详情',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 趋势详情表格
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('时间')),
                DataColumn(label: Text('销售额')),
                DataColumn(label: Text('同比增长')),
                DataColumn(label: Text('环比增长')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('2024-01')),
                  DataCell(Text('¥1,250,000')),
                  DataCell(Text('+15.2%', style: TextStyle(color: Colors.green))),
                  DataCell(Text('+8.7%', style: TextStyle(color: Colors.green))),
                ]),
                DataRow(cells: [
                  DataCell(Text('2024-02')),
                  DataCell(Text('¥1,380,000')),
                  DataCell(Text('+18.5%', style: TextStyle(color: Colors.green))),
                  DataCell(Text('+10.4%', style: TextStyle(color: Colors.green))),
                ]),
                DataRow(cells: [
                  DataCell(Text('2024-03')),
                  DataCell(Text('¥1,420,000')),
                  DataCell(Text('+20.3%', style: TextStyle(color: Colors.green))),
                  DataCell(Text('+2.9%', style: TextStyle(color: Colors.green))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建产品销售表格
  Widget _buildProductSalesTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '产品销售详情',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 产品销售表格
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('产品名称')),
                DataColumn(label: Text('销售额')),
                DataColumn(label: Text('销售量')),
                DataColumn(label: Text('毛利率')),
                DataColumn(label: Text('同比增长')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('产品A')),
                  DataCell(Text('¥2,500,000')),
                  DataCell(Text('1,250')),
                  DataCell(Text('35.2%')),
                  DataCell(Text('+12.5%', style: TextStyle(color: Colors.green))),
                ]),
                DataRow(cells: [
                  DataCell(Text('产品B')),
                  DataCell(Text('¥1,800,000')),
                  DataCell(Text('900')),
                  DataCell(Text('32.1%')),
                  DataCell(Text('+8.7%', style: TextStyle(color: Colors.green))),
                ]),
                DataRow(cells: [
                  DataCell(Text('产品C')),
                  DataCell(Text('¥1,200,000')),
                  DataCell(Text('600')),
                  DataCell(Text('28.5%')),
                  DataCell(Text('-2.3%', style: TextStyle(color: Colors.red))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建销售预测详情
  Widget _buildSalesForecastDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '销售预测详情',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 预测详情表格
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('时间')),
                DataColumn(label: Text('预测销售额')),
                DataColumn(label: Text('置信度')),
                DataColumn(label: Text('趋势')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('2024-04')),
                  DataCell(Text('¥1,480,000')),
                  DataCell(Text('92%')),
                  DataCell(Text('上升', style: TextStyle(color: Colors.green))),
                ]),
                DataRow(cells: [
                  DataCell(Text('2024-05')),
                  DataCell(Text('¥1,520,000')),
                  DataCell(Text('89%')),
                  DataCell(Text('上升', style: TextStyle(color: Colors.green))),
                ]),
                DataRow(cells: [
                  DataCell(Text('2024-06')),
                  DataCell(Text('¥1,550,000')),
                  DataCell(Text('87%')),
                  DataCell(Text('上升', style: TextStyle(color: Colors.green))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建异常检测概览
  Widget _buildAnomalyDetectionOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '异常检测概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 异常类型分布
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnomalyTypeCard('销售异常', 12, Colors.red),
              _buildAnomalyTypeCard('客户异常', 8, Colors.orange),
              _buildAnomalyTypeCard('库存异常', 5, Colors.yellow),
              _buildAnomalyTypeCard('回款异常', 3, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  // 构建异常类型卡片
  Widget _buildAnomalyTypeCard(String type, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(top: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 构建异常详情列表
  Widget _buildAnomalyDetailsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 400.0, // 设置固定高度，确保列表不会无限扩展
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '异常详情列表',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 异常详情列表
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildAnomalyItem(
                  index % 3 == 0 ? '高' : index % 3 == 1 ? '中' : '低',
                  index % 2 == 0 ? '销售异常' : '客户异常',
                  '2024-01-15 14:30',
                  '客户${index + 1}的销售额在过去7天内下降了35%，低于正常水平',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建异常项
  Widget _buildAnomalyItem(String level, String type, String time, String description) {
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: levelColor, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // 查看详情
                  },
                  child: const Text('查看详情'),
                ),
                TextButton(
                  onPressed: () {
                    // 标记已处理
                  },
                  child: const Text('标记已处理'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建客户等级表格
  Widget _buildCustomerLevelTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '客户等级详情',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),

          // 客户等级表格
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('客户名称')),
                DataColumn(label: Text('等级')),
                DataColumn(label: Text('采购金额')),
                DataColumn(label: Text('采购频次')),
                DataColumn(label: Text('回款速度')),
                DataColumn(label: Text('合同履约率')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('客户A')),
                  DataCell(Text('VIP', style: TextStyle(color: Colors.red))),
                  DataCell(Text('¥5,200,000')),
                  DataCell(Text('12次/年')),
                  DataCell(Text('15天')),
                  DataCell(Text('98%')),
                ]),
                DataRow(cells: [
                  DataCell(Text('客户B')),
                  DataCell(Text('重要', style: TextStyle(color: Colors.orange))),
                  DataCell(Text('¥2,800,000')),
                  DataCell(Text('8次/年')),
                  DataCell(Text('20天')),
                  DataCell(Text('95%')),
                ]),
                DataRow(cells: [
                  DataCell(Text('客户C')),
                  DataCell(Text('普通', style: TextStyle(color: Colors.blue))),
                  DataCell(Text('¥1,200,000')),
                  DataCell(Text('4次/年')),
                  DataCell(Text('30天')),
                  DataCell(Text('90%')),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建图表部分
  Widget _buildChartSection(String title, Widget chart, {double height = 300.0}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: chart,
          ),
        ],
      ),
    );
  }



  // 导出报告
  void _exportReport() {
    // 实现报告导出逻辑
    print('导出报告');
  }

  // 打开设置
  void _openSettings() {
    // 实现设置打开逻辑
    print('打开设置');
  }
}
