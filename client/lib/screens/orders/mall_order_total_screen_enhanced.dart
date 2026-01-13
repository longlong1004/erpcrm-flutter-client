import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/order/order_stat_card.dart';
import '../../widgets/order/order_trend_chart.dart';
import '../../theme/app_theme.dart';

/// 商城订单总表页面（增强版）
/// 
/// 优化内容：
/// 1. 添加统计卡片（今日订单、本月订单、待处理订单、总金额）
/// 2. 添加订单趋势图表
/// 3. 添加批量操作按钮（批量导出、批量打印）
/// 4. 保留所有原有功能（38列表格、搜索、筛选、排序、分页、多选）
class MallOrderTotalScreenEnhanced extends ConsumerStatefulWidget {
  const MallOrderTotalScreenEnhanced({super.key});

  @override
  ConsumerState<MallOrderTotalScreenEnhanced> createState() => _MallOrderTotalScreenEnhancedState();
}

class _MallOrderTotalScreenEnhancedState extends ConsumerState<MallOrderTotalScreenEnhanced> {
  // ========== 原有变量（完全保留）==========
  // 搜索控制器
  final _searchController = TextEditingController();
  // 分页变量
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  // 排序变量
  String? _sortColumn;
  bool _sortAscending = true;
  // 筛选变量
  String? _selectedRailwayBureau;
  String? _selectedStation;
  // 选中的订单ID列表
  final Set<int> _selectedOrderIds = {};
  // 模拟数据
  late List<Map<String, dynamic>> _orders;
  late List<Map<String, dynamic>> _filteredOrders;

  @override
  void initState() {
    super.initState();
    // 生成模拟数据（完全保留）
    _orders = List.generate(50, (index) => {
      'id': index + 1,
      'salesperson': '业务员${(index % 5) + 1}',
      'orderNumber': 'MALL-20251228-${index.toString().padLeft(4, '0')}',
      'submittedDate': '2025-12-${(28 - index % 10).toString().padLeft(2, '0')}',
      'approvedDate': '2025-12-${(28 - index % 8).toString().padLeft(2, '0')}',
      'consigneeName': '收货人${index + 1}',
      'consigneePhone': '1380013800${index % 10}',
      'shippingAddress': '北京市朝阳区${index + 1}号',
      'railwayBureau': index % 3 == 0 ? '北京局' : index % 3 == 1 ? '上海局' : '广州局',
      'station': index % 3 == 0 ? '北京站' : index % 3 == 1 ? '上海站' : '广州站',
      'companyName': '公司${index + 1}',
      'brand': '品牌${(index % 3) + 1}',
      'productCode': 'PROD-${index.toString().padLeft(6, '0')}',
      'railwayName': '国铁商品${index + 1}',
      'railwayModel': '型号${index + 1}',
      'orderQuantity': index + 5,
      'railwayPrice': 100.0 + index * 10,
      'railwayAmount': (100.0 + index * 10) * (index + 5),
      'invoiceApplyTime': '2025-12-${(28 - index % 12).toString().padLeft(2, '0')}',
      'paymentReceivedTime': '2025-12-${(28 - index % 15).toString().padLeft(2, '0')}',
      'paymentTime': '2025-12-${(28 - index % 20).toString().padLeft(2, '0')}',
      'supplier': '供应商${(index % 4) + 1}',
      'actualName': '实发商品${index + 1}',
      'actualModel': '实发型号${index + 1}',
      'purchasePrice': 90.0 + index * 10,
      'actualQuantity': index + 5,
      'unit': '件',
      'purchaseAmount': (90.0 + index * 10) * (index + 5),
      'notes': '备注${index + 1}',
      'paymentMethod': index % 2 == 0 ? '微信支付' : '支付宝支付',
      'invoiceType': index % 2 == 0 ? '增值税专用发票' : '增值税普通发票',
      'inputInvoiceTime': '2025-12-${(28 - index % 25).toString().padLeft(2, '0')}',
      'shippingFee': 10.0,
      'supplementType': index % 3 == 0 ? '换货' : index % 3 == 1 ? '退货' : '',
      'supplementName': index % 3 == 0 ? '补发货${index + 1}' : '',
      'supplementAmount': index % 3 == 0 ? 50.0 : 0.0,
      'handlingFee': 20.0,
    });
    _filteredOrders = List.from(_orders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ========== 原有方法（完全保留）==========
  
  // 应用筛选
  void _applyFilters() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        // 搜索过滤
        final searchTerm = _searchController.text.toLowerCase();
        final matchesSearch = searchTerm.isEmpty || 
          (order['orderNumber'] as String).toLowerCase().contains(searchTerm) ||
          (order['salesperson'] as String).toLowerCase().contains(searchTerm) ||
          (order['consigneeName'] as String).toLowerCase().contains(searchTerm);
        // 路局筛选
        final matchesRailwayBureau = _selectedRailwayBureau == null || 
          order['railwayBureau'] == _selectedRailwayBureau;
        // 站段筛选
        final matchesStation = _selectedStation == null || 
          order['station'] == _selectedStation;
        
        return matchesSearch && matchesRailwayBureau && matchesStation;
      }).toList();
      // 重置当前页面
      _currentPage = 0;
    });
  }

  // 重置筛选
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedRailwayBureau = null;
      _selectedStation = null;
      _filteredOrders = List.from(_orders);
      _currentPage = 0;
    });
  }

  // 排序
  void _sort<T extends Comparable<dynamic>>(T Function(dynamic order) getField, String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
      
      _filteredOrders.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  // 切换全选状态
  void _toggleAllSelection(bool? value) {
    setState(() {
      if (value == true) {
        // 全选当前页
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage) > _filteredOrders.length ? _filteredOrders.length : startIndex + _rowsPerPage;
        for (int i = startIndex; i < endIndex; i++) {
          _selectedOrderIds.add(_filteredOrders[i]['id'] as int);
        }
      } else {
        // 取消全选当前页
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage) > _filteredOrders.length ? _filteredOrders.length : startIndex + _rowsPerPage;
        for (int i = startIndex; i < endIndex; i++) {
          _selectedOrderIds.remove(_filteredOrders[i]['id'] as int);
        }
      }
    });
  }

  // 切换单行选择状态
  void _toggleSelection(int orderId, bool? value) {
    setState(() {
      if (value == true) {
        _selectedOrderIds.add(orderId);
      } else {
        _selectedOrderIds.remove(orderId);
      }
    });
  }

  // ========== 新增方法 ==========
  
  // 计算统计数据
  Map<String, dynamic> _calculateStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonth = DateTime(now.year, now.month, 1);
    
    // 今日订单
    final todayOrders = _orders.where((order) {
      final date = DateTime.parse(order['submittedDate'] as String);
      return date.isAfter(today) || date.isAtSameMomentAs(today);
    }).length;
    
    // 本月订单
    final thisMonthOrders = _orders.where((order) {
      final date = DateTime.parse(order['submittedDate'] as String);
      return date.isAfter(thisMonth) || date.isAtSameMomentAs(thisMonth);
    }).length;
    
    // 待处理订单（假设提交日期在最近3天内的为待处理）
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final pendingOrders = _orders.where((order) {
      final date = DateTime.parse(order['submittedDate'] as String);
      return date.isAfter(threeDaysAgo);
    }).length;
    
    // 总金额
    final totalAmount = _orders.fold<double>(
      0.0,
      (sum, order) => sum + (order['railwayAmount'] as double),
    );
    
    return {
      'todayOrders': todayOrders,
      'thisMonthOrders': thisMonthOrders,
      'pendingOrders': pendingOrders,
      'totalAmount': totalAmount,
    };
  }

  // 生成趋势数据
  List<Map<String, dynamic>> _generateTrendData() {
    final Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    
    for (var order in _orders) {
      final date = order['submittedDate'] as String;
      if (!groupedByDate.containsKey(date)) {
        groupedByDate[date] = [];
      }
      groupedByDate[date]!.add(order);
    }
    
    final trendData = <Map<String, dynamic>>[];
    final sortedDates = groupedByDate.keys.toList()..sort();
    
    for (var date in sortedDates.take(10)) {
      final orders = groupedByDate[date]!;
      final count = orders.length;
      final amount = orders.fold<double>(0.0, (sum, order) => sum + (order['railwayAmount'] as double));
      
      trendData.add({
        'date': date,
        'count': count,
        'amount': amount,
      });
    }
    
    return trendData;
  }

  // 批量导出
  void _batchExport() {
    if (_selectedOrderIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要导出的订单')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在导出 ${_selectedOrderIds.length} 个订单...')),
    );
    
    // TODO: 实现实际的导出逻辑
  }

  // 批量打印
  void _batchPrint() {
    if (_selectedOrderIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要打印的订单')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在打印 ${_selectedOrderIds.length} 个订单...')),
    );
    
    // TODO: 实现实际的打印逻辑
  }

  // ========== 构建UI ==========

  @override
  Widget build(BuildContext context) {
    // 计算统计数据
    final stats = _calculateStatistics();
    final trendData = _generateTrendData();
    
    // 计算分页数据
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > _filteredOrders.length ? _filteredOrders.length : startIndex + _rowsPerPage;
    final paginatedOrders = _filteredOrders.sublist(startIndex, endIndex);
    
    // 检查当前页是否全选
    final bool isAllSelected = paginatedOrders.every((order) => _selectedOrderIds.contains(order['id'] as int));
    final bool isSomeSelected = paginatedOrders.any((order) => _selectedOrderIds.contains(order['id'] as int));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ========== 新增：统计卡片区域 ==========
          Row(
            children: [
              Expanded(
                child: OrderStatCard(
                  title: '今日订单',
                  value: '${stats['todayOrders']}',
                  subtitle: '商城订单',
                  icon: Icons.shopping_cart,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OrderStatCard(
                  title: '本月订单',
                  value: '${stats['thisMonthOrders']}',
                  subtitle: '累计订单',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OrderStatCard(
                  title: '待处理',
                  value: '${stats['pendingOrders']}',
                  subtitle: '需要处理',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OrderStatCard(
                  title: '总金额',
                  value: '¥${(stats['totalAmount'] as double).toStringAsFixed(0)}',
                  subtitle: '订单总额',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // ========== 新增：趋势图表区域 ==========
          OrderTrendChart(
            trendData: trendData,
            title: '商城订单趋势（最近10天）',
          ),
          const SizedBox(height: 16),
          
          // ========== 原有：操作按钮（保留+新增批量操作）==========
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 原有按钮
              ElevatedButton.icon(
                onPressed: () {
                  // 导入操作
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('导入功能已触发')),
                  );
                },
                icon: const Icon(Icons.upload),
                label: const Text('导入'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // 删除操作
                  if (_selectedOrderIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请选择要删除的订单')),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('确认删除'),
                      content: Text('确定要删除选中的 ${_selectedOrderIds.length} 个订单吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              // 从数据中删除选中的订单
                              _orders.removeWhere((order) => _selectedOrderIds.contains(order['id'] as int));
                              _filteredOrders.removeWhere((order) => _selectedOrderIds.contains(order['id'] as int));
                              _selectedOrderIds.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已删除选中的订单')),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                label: Text('删除 (${_selectedOrderIds.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              
              // ========== 新增：批量操作按钮 ==========
              if (_selectedOrderIds.isNotEmpty) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _batchExport,
                  icon: const Icon(Icons.download),
                  label: const Text('批量导出'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _batchPrint,
                  icon: const Icon(Icons.print),
                  label: const Text('批量打印'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // ========== 原有：搜索和筛选（完全保留）==========
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 搜索框
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索订单号、业务员或收货人',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                  const SizedBox(height: 12),
                  // 筛选条件
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '所属路局',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _selectedRailwayBureau,
                          hint: const Text('选择路局'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('全部路局'),
                            ),
                            for (final bureau in ['北京局', '上海局', '广州局']) 
                              DropdownMenuItem(
                                value: bureau,
                                child: Text(bureau),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRailwayBureau = value;
                              _selectedStation = null; // 清空站段筛选
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '站段',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _selectedStation,
                          hint: const Text('选择站段'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('全部站段'),
                            ),
                            // 根据选中的路局动态生成站段列表
                            if (_selectedRailwayBureau == '北京局') ...[
                              for (final station in ['北京站', '北京西站', '北京南站']) 
                                DropdownMenuItem(
                                  value: station,
                                  child: Text(station),
                                ),
                            ] else if (_selectedRailwayBureau == '上海局') ...[
                              for (final station in ['上海站', '上海虹桥站', '上海南站']) 
                                DropdownMenuItem(
                                  value: station,
                                  child: Text(station),
                                ),
                            ] else if (_selectedRailwayBureau == '广州局') ...[
                              for (final station in ['广州站', '广州南站', '广州东站']) 
                                DropdownMenuItem(
                                  value: station,
                                  child: Text(station),
                                ),
                            ],
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStation = value;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 筛选按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('重置'),
                      ),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                        child: const Text('筛选'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // ========== 原有：表格（完全保留所有38列）==========
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  // 表格样式
                  headingRowColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF003366)),
                  headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.grey.withOpacity(0.1);
                    }
                    return null;
                  }),
                  // 排序配置
                  sortColumnIndex: _sortColumn == 'orderNumber' ? 2 :
                                    _sortColumn == 'submittedDate' ? 3 :
                                    _sortColumn == 'railwayAmount' ? 17 :
                                    _sortColumn == 'orderQuantity' ? 15 : null,
                  sortAscending: _sortAscending,
                  // 列定义 - 按照用户要求的38列顺序排列（完全保留）
                  columns: [
                    // 1. 勾选
                    DataColumn(
                      label: Checkbox(
                        value: isAllSelected,
                        tristate: isSomeSelected && !isAllSelected,
                        onChanged: _toggleAllSelection,
                      ),
                      numeric: true,
                    ),
                    // 2. 业务员
                    const DataColumn(label: Text('业务员')),
                    // 3. 订单编号
                    DataColumn(
                      label: const Text('订单编号'),
                      onSort: (columnIndex, ascending) {
                        _sort((order) => order['orderNumber'] as String, 'orderNumber');
                      },
                    ),
                    // 4. 提交日期
                    DataColumn(
                      label: const Text('提交日期'),
                      onSort: (columnIndex, ascending) {
                        _sort((order) => order['submittedDate'] as String, 'submittedDate');
                      },
                    ),
                    // 5. 审批日期
                    const DataColumn(label: Text('审批日期')),
                    // 6. 收货人姓名
                    const DataColumn(label: Text('收货人姓名')),
                    // 7. 收货人电话
                    const DataColumn(label: Text('收货人电话')),
                    // 8. 收货地址
                    const DataColumn(label: Text('收货地址')),
                    // 9. 所属路局
                    const DataColumn(label: Text('所属路局')),
                    // 10. 站段
                    const DataColumn(label: Text('站段')),
                    // 11. 公司名称
                    const DataColumn(label: Text('公司名称')),
                    // 12. 品牌
                    const DataColumn(label: Text('品牌')),
                    // 13. 单品编码
                    const DataColumn(label: Text('单品编码')),
                    // 14. 国铁名称
                    const DataColumn(label: Text('国铁名称')),
                    // 15. 国铁型号
                    const DataColumn(label: Text('国铁型号')),
                    // 16. 下单数量
                    DataColumn(
                      label: const Text('下单数量'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        _sort((order) => order['orderQuantity'] as int, 'orderQuantity');
                      },
                    ),
                    // 17. 国铁单价
                    const DataColumn(label: Text('国铁单价'), numeric: true),
                    // 18. 国铁金额
                    DataColumn(
                      label: const Text('国铁金额'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        _sort((order) => order['railwayAmount'] as double, 'railwayAmount');
                      },
                    ),
                    // 19. 发票申请时间
                    const DataColumn(label: Text('发票申请时间')),
                    // 20. 回款时间
                    const DataColumn(label: Text('回款时间')),
                    // 21. 付款时间
                    const DataColumn(label: Text('付款时间')),
                    // 22. 供应商
                    const DataColumn(label: Text('供应商')),
                    // 23. 实发名称
                    const DataColumn(label: Text('实发名称')),
                    // 24. 实发型号
                    const DataColumn(label: Text('实发型号')),
                    // 25. 采购单价
                    const DataColumn(label: Text('采购单价'), numeric: true),
                    // 26. 实发数量
                    const DataColumn(label: Text('实发数量'), numeric: true),
                    // 27. 单位
                    const DataColumn(label: Text('单位')),
                    // 28. 采购金额
                    const DataColumn(label: Text('采购金额'), numeric: true),
                    // 29. 备注
                    const DataColumn(label: Text('备注')),
                    // 30. 付款方式
                    const DataColumn(label: Text('付款方式')),
                    // 31. 发票类型
                    const DataColumn(label: Text('发票类型')),
                    // 32. 进项发票时间
                    const DataColumn(label: Text('进项发票时间')),
                    // 33. 运费
                    const DataColumn(label: Text('运费'), numeric: true),
                    // 34. 补发货类型
                    const DataColumn(label: Text('补发货类型')),
                    // 35. 补发货名称
                    const DataColumn(label: Text('补发货名称')),
                    // 36. 补发货金额
                    const DataColumn(label: Text('补发货金额'), numeric: true),
                    // 37. 办理费用
                    const DataColumn(label: Text('办理费用'), numeric: true),
                    // 38. 操作
                    const DataColumn(label: Text('操作')),
                  ],
                  // 行数据（完全保留所有38列）
                  rows: paginatedOrders.map((order) {
                    final orderId = order['id'] as int;
                    final isSelected = _selectedOrderIds.contains(orderId);
                    return DataRow(
                      cells: [
                        // 1. 勾选
                        DataCell(Checkbox(
                          value: isSelected,
                          onChanged: (value) => _toggleSelection(orderId, value),
                        )),
                        // 2. 业务员
                        DataCell(Text(order['salesperson'] as String)),
                        // 3. 订单编号
                        DataCell(Text(order['orderNumber'] as String)),
                        // 4. 提交日期
                        DataCell(Text(order['submittedDate'] as String)),
                        // 5. 审批日期
                        DataCell(Text(order['approvedDate'] as String)),
                        // 6. 收货人姓名
                        DataCell(Text(order['consigneeName'] as String)),
                        // 7. 收货人电话
                        DataCell(Text(order['consigneePhone'] as String)),
                        // 8. 收货地址
                        DataCell(Text(order['shippingAddress'] as String)),
                        // 9. 所属路局
                        DataCell(Text(order['railwayBureau'] as String)),
                        // 10. 站段
                        DataCell(Text(order['station'] as String)),
                        // 11. 公司名称
                        DataCell(Text(order['companyName'] as String)),
                        // 12. 品牌
                        DataCell(Text(order['brand'] as String)),
                        // 13. 单品编码
                        DataCell(Text(order['productCode'] as String)),
                        // 14. 国铁名称
                        DataCell(Text(order['railwayName'] as String)),
                        // 15. 国铁型号
                        DataCell(Text(order['railwayModel'] as String)),
                        // 16. 下单数量
                        DataCell(Text((order['orderQuantity'] as int).toString())),
                        // 17. 国铁单价
                        DataCell(Text((order['railwayPrice'] as double).toStringAsFixed(2))),
                        // 18. 国铁金额
                        DataCell(Text((order['railwayAmount'] as double).toStringAsFixed(2))),
                        // 19. 发票申请时间
                        DataCell(Text(order['invoiceApplyTime'] as String)),
                        // 20. 回款时间
                        DataCell(Text(order['paymentReceivedTime'] as String)),
                        // 21. 付款时间
                        DataCell(Text(order['paymentTime'] as String)),
                        // 22. 供应商
                        DataCell(Text(order['supplier'] as String)),
                        // 23. 实发名称
                        DataCell(Text(order['actualName'] as String)),
                        // 24. 实发型号
                        DataCell(Text(order['actualModel'] as String)),
                        // 25. 采购单价
                        DataCell(Text((order['purchasePrice'] as double).toStringAsFixed(2))),
                        // 26. 实发数量
                        DataCell(Text((order['actualQuantity'] as int).toString())),
                        // 27. 单位
                        DataCell(Text(order['unit'] as String)),
                        // 28. 采购金额
                        DataCell(Text((order['purchaseAmount'] as double).toStringAsFixed(2))),
                        // 29. 备注
                        DataCell(Text(order['notes'] as String)),
                        // 30. 付款方式
                        DataCell(Text(order['paymentMethod'] as String)),
                        // 31. 发票类型
                        DataCell(Text(order['invoiceType'] as String)),
                        // 32. 进项发票时间
                        DataCell(Text(order['inputInvoiceTime'] as String)),
                        // 33. 运费
                        DataCell(Text((order['shippingFee'] as double).toStringAsFixed(2))),
                        // 34. 补发货类型
                        DataCell(Text(order['supplementType'] as String)),
                        // 35. 补发货名称
                        DataCell(Text(order['supplementName'] as String)),
                        // 36. 补发货金额
                        DataCell(Text((order['supplementAmount'] as double).toStringAsFixed(2))),
                        // 37. 办理费用
                        DataCell(Text((order['handlingFee'] as double).toStringAsFixed(2))),
                        // 38. 操作
                        DataCell(TextButton(
                          onPressed: () {
                            // 查看操作
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('查看订单 ${order['orderNumber']}')),
                            );
                          },
                          child: const Text('查看'),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // ========== 原有：分页控制（完全保留）==========
          if (_filteredOrders.length > _rowsPerPage)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                    child: const Text('上一页'),
                  ),
                  Text('第 ${_currentPage + 1} 页，共 ${(_filteredOrders.length / _rowsPerPage).ceil()} 页，总计 ${_filteredOrders.length} 条'),
                  TextButton(
                    onPressed: (endIndex < _filteredOrders.length)
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                    child: const Text('下一页'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
