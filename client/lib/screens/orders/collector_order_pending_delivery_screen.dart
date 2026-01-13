import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 集货商订单待发货页面
class CollectorOrderPendingDeliveryScreen extends ConsumerStatefulWidget {
  const CollectorOrderPendingDeliveryScreen({super.key});

  @override
  ConsumerState<CollectorOrderPendingDeliveryScreen> createState() => _CollectorOrderPendingDeliveryScreenState();
}

class _CollectorOrderPendingDeliveryScreenState extends ConsumerState<CollectorOrderPendingDeliveryScreen> {
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
  // 模拟数据
  late List<Map<String, dynamic>> _pendingOrders;
  late List<Map<String, dynamic>> _filteredPendingOrders;

  @override
  void initState() {
    super.initState();
    // 生成模拟数据
    _pendingOrders = List.generate(30, (index) => {
      'id': index + 1,
      'salesperson': '业务员${(index % 5) + 1}',
      'status': index % 2 == 0 ? '待发货' : '已匹配',
      'orderNumber': 'COLLECTOR-20251228-${index.toString().padLeft(4, '0')}',
      'orderQuantity': index + 5,
      'matchQuantity': index + 3,
      'consigneeName': '收货人${index + 1}',
      'consigneePhone': '1380013800${index % 10}',
      'shippingAddress': '北京市朝阳区${index + 1}号',
      'railwayBureau': index % 3 == 0 ? '北京局' : index % 3 == 1 ? '上海局' : '广州局',
      'station': index % 3 == 0 ? '北京站' : index % 3 == 1 ? '上海站' : '广州站',
      'companyName': '公司${index + 1}',
      'logisticsCompany': '物流公司${index + 1}',
      'trackingNumber': index % 2 == 0 ? '' : 'LOG-${index.toString().padLeft(8, '0')}',
      'submittedDate': '2025-12-${(28 - index % 10).toString().padLeft(2, '0')}',
      'approvedDate': '2025-12-${(28 - index % 8).toString().padLeft(2, '0')}',
      'matchTime': '2025-12-28 16:${index.toString().padLeft(2, '0')}:00',
    });
    _filteredPendingOrders = List.from(_pendingOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 应用筛选
  void _applyFilters() {
    setState(() {
      _filteredPendingOrders = _pendingOrders.where((order) {
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
      _filteredPendingOrders = List.from(_pendingOrders);
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
      
      _filteredPendingOrders.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 计算分页数据
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > _filteredPendingOrders.length ? _filteredPendingOrders.length : startIndex + _rowsPerPage;
    final paginatedPendingOrders = _filteredPendingOrders.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 搜索和筛选
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
                        child: const Text('筛选'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 表格
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
                  sortColumnIndex: null,
                  sortAscending: true,
                  // 列定义
                  columns: const [
                    DataColumn(label: Text('业务员')),
                    DataColumn(label: Text('状态')),
                    DataColumn(label: Text('订单编号')),
                    DataColumn(label: Text('下单数量'), numeric: true),
                    DataColumn(label: Text('匹配数量'), numeric: true),
                    DataColumn(label: Text('收货人姓名')),
                    DataColumn(label: Text('收货人电话')),
                    DataColumn(label: Text('收货地址')),
                    DataColumn(label: Text('所属路局')),
                    DataColumn(label: Text('站段')),
                    DataColumn(label: Text('公司名称')),
                    DataColumn(label: Text('物流公司')),
                    DataColumn(label: Text('物流单号')),
                    DataColumn(label: Text('提交日期')),
                    DataColumn(label: Text('审批日期')),
                    DataColumn(label: Text('匹配时间')),
                    DataColumn(label: Text('操作')),
                  ],
                  // 行数据
                  rows: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}