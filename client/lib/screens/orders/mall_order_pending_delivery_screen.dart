import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 商城订单待发货页面
class MallOrderPendingDeliveryScreen extends ConsumerStatefulWidget {
  const MallOrderPendingDeliveryScreen({super.key});

  @override
  ConsumerState<MallOrderPendingDeliveryScreen> createState() => _MallOrderPendingDeliveryScreenState();
}

class _MallOrderPendingDeliveryScreenState extends ConsumerState<MallOrderPendingDeliveryScreen> {
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
  String? _selectedStatus;
  // 模拟数据
  late List<Map<String, dynamic>> _pendingDeliveries;
  late List<Map<String, dynamic>> _filteredPendingDeliveries;

  @override
  void initState() {
    super.initState();
    // 生成模拟数据
    _pendingDeliveries = List.generate(35, (index) => {
      'id': index + 1,
      'salesperson': '业务员${(index % 5) + 1}',
      'status': index % 3 == 0 ? '待发货' : index % 3 == 1 ? '部分发货' : '已取消',
      'orderNumber': 'MALL-20251228-${index.toString().padLeft(4, '0')}',
      'orderQuantity': index + 5,
      'matchedQuantity': index + 3,
      'consigneeName': '收货人${index + 1}',
      'consigneePhone': '1380013800${index % 10}',
      'shippingAddress': '北京市朝阳区${index + 1}号',
      'railwayBureau': index % 3 == 0 ? '北京局' : index % 3 == 1 ? '上海局' : '广州局',
      'station': index % 3 == 0 ? '北京站' : index % 3 == 1 ? '上海站' : '广州站',
      'companyName': '公司${index + 1}',
      'logisticsCompany': index % 4 == 0 ? '顺丰速运' : index % 4 == 1 ? '京东物流' : index % 4 == 2 ? '中通快递' : '圆通速递',
      'logisticsNumber': index % 2 == 0 ? 'SF1234567890$index' : 'JD0987654321$index',
      'submittedDate': '2025-12-${(28 - index % 10).toString().padLeft(2, '0')}',
      'approvedDate': '2025-12-${(28 - index % 8).toString().padLeft(2, '0')}',
      'matchedTime': '2025-12-${(28 - index % 15).toString().padLeft(2, '0')} ${((index + 5) % 24).toString().padLeft(2, '0')}:${(((index + 3) * 12) % 60).toString().padLeft(2, '0')}',
    });
    _filteredPendingDeliveries = List.from(_pendingDeliveries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 应用筛选
  void _applyFilters() {
    setState(() {
      _filteredPendingDeliveries = _pendingDeliveries.where((delivery) {
        // 搜索过滤
        final searchTerm = _searchController.text.toLowerCase();
        final matchesSearch = searchTerm.isEmpty || 
          (delivery['orderNumber'] as String).toLowerCase().contains(searchTerm) ||
          (delivery['salesperson'] as String).toLowerCase().contains(searchTerm) ||
          (delivery['consigneeName'] as String).toLowerCase().contains(searchTerm);
        // 路局筛选
        final matchesRailwayBureau = _selectedRailwayBureau == null || 
          delivery['railwayBureau'] == _selectedRailwayBureau;
        // 站段筛选
        final matchesStation = _selectedStation == null || 
          delivery['station'] == _selectedStation;
        // 状态筛选
        final matchesStatus = _selectedStatus == null || 
          delivery['status'] == _selectedStatus;
        
        return matchesSearch && matchesRailwayBureau && matchesStation && matchesStatus;
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
      _selectedStatus = null;
      _filteredPendingDeliveries = List.from(_pendingDeliveries);
      _currentPage = 0;
    });
  }

  // 排序
  void _sort<T extends Comparable>(T Function(dynamic delivery) getField, String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
      
      _filteredPendingDeliveries.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  // 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '待发货':
        return Colors.orange;
      case '部分发货':
        return Colors.purple;
      case '已取消':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算分页数据
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > _filteredPendingDeliveries.length ? _filteredPendingDeliveries.length : startIndex + _rowsPerPage;
    final paginatedPendingDeliveries = _filteredPendingDeliveries.sublist(startIndex, endIndex);

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
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '状态',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _selectedStatus,
                          hint: const Text('选择状态'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('全部状态'),
                            ),
                            for (final status in ['待发货', '部分发货', '已取消']) 
                              DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
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
                  sortColumnIndex: _sortColumn == 'orderNumber' ? 2 :
                                      _sortColumn == 'submittedDate' ? 13 :
                                      _sortColumn == 'orderQuantity' ? 3 : null,
                  sortAscending: _sortAscending,
                  // 列定义 - 按照用户要求的18列顺序排列
                  columns: [
                    // 1. 业务员
                    const DataColumn(label: Text('业务员')),
                    // 2. 状态
                    const DataColumn(label: Text('状态')),
                    // 3. 订单编号
                    DataColumn(
                      label: const Text('订单编号'),
                      onSort: (columnIndex, ascending) {
                        _sort((delivery) => delivery['orderNumber'] as String, 'orderNumber');
                      },
                    ),
                    // 4. 下单数量
                    DataColumn(
                      label: const Text('下单数量'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        _sort((delivery) => delivery['orderQuantity'] as int, 'orderQuantity');
                      },
                    ),
                    // 5. 匹配数量
                    const DataColumn(label: Text('匹配数量'), numeric: true),
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
                    // 12. 物流公司
                    const DataColumn(label: Text('物流公司')),
                    // 13. 物流单号
                    const DataColumn(label: Text('物流单号')),
                    // 14. 提交日期
                    DataColumn(
                      label: const Text('提交日期'),
                      onSort: (columnIndex, ascending) {
                        _sort((delivery) => delivery['submittedDate'] as String, 'submittedDate');
                      },
                    ),
                    // 15. 审批日期
                    const DataColumn(label: Text('审批日期')),
                    // 16. 匹配时间
                    const DataColumn(label: Text('匹配时间')),
                    // 17. 操作
                    const DataColumn(label: Text('操作')),
                  ],
                  // 行数据
                  rows: paginatedPendingDeliveries.map((delivery) {
                    return DataRow(
                      cells: [
                        // 1. 业务员
                        DataCell(Container(
                          width: 80,
                          child: Text(delivery['salesperson'] as String),
                        )),
                        // 2. 状态
                        DataCell(Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(delivery['status'] as String).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _getStatusColor(delivery['status'] as String)),
                          ),
                          child: Text(
                            delivery['status'] as String,
                            style: TextStyle(
                              color: _getStatusColor(delivery['status'] as String),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                        // 3. 订单编号
                        DataCell(Container(
                          width: 150,
                          child: Text(delivery['orderNumber'] as String),
                        )),
                        // 4. 下单数量
                        DataCell(Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Text((delivery['orderQuantity'] as int).toString()),
                        )),
                        // 5. 匹配数量
                        DataCell(Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Text((delivery['matchedQuantity'] as int).toString()),
                        )),
                        // 6. 收货人姓名
                        DataCell(Container(
                          width: 100,
                          child: Text(delivery['consigneeName'] as String),
                        )),
                        // 7. 收货人电话
                        DataCell(Container(
                          width: 120,
                          child: Text(delivery['consigneePhone'] as String),
                        )),
                        // 8. 收货地址
                        DataCell(Container(
                          width: 150,
                          child: Text(delivery['shippingAddress'] as String),
                        )),
                        // 9. 所属路局
                        DataCell(Container(
                          width: 80,
                          child: Text(delivery['railwayBureau'] as String),
                        )),
                        // 10. 站段
                        DataCell(Container(
                          width: 80,
                          child: Text(delivery['station'] as String),
                        )),
                        // 11. 公司名称
                        DataCell(Container(
                          width: 100,
                          child: Text(delivery['companyName'] as String),
                        )),
                        // 12. 物流公司
                        DataCell(Container(
                          width: 100,
                          child: Text(delivery['logisticsCompany'] as String),
                        )),
                        // 13. 物流单号
                        DataCell(Container(
                          width: 120,
                          child: Text(delivery['logisticsNumber'] as String),
                        )),
                        // 14. 提交日期
                        DataCell(Container(
                          width: 100,
                          child: Text(delivery['submittedDate'] as String),
                        )),
                        // 15. 审批日期
                        DataCell(Container(
                          width: 100,
                          child: Text(delivery['approvedDate'] as String),
                        )),
                        // 16. 匹配时间
                        DataCell(Container(
                          width: 120,
                          child: Text(delivery['matchedTime'] as String),
                        )),
                        // 17. 操作 - 五个功能按钮
                        DataCell(Container(
                          width: 350,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // 修改业务员
                                TextButton(
                                  onPressed: () {
                                    // 修改业务员操作
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('修改业务员 ${delivery['orderNumber']}')),
                                    );
                                  },
                                  child: const Text('修改业务员'),
                                ),
                                // 查看
                                TextButton(
                                  onPressed: () {
                                    // 查看操作
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('查看订单 ${delivery['orderNumber']}')),
                                    );
                                  },
                                  child: const Text('查看'),
                                ),
                                // 发货
                                TextButton(
                                  onPressed: () {
                                    // 发货操作
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('发货订单 ${delivery['orderNumber']}')),
                                    );
                                  },
                                  child: const Text('发货'),
                                ),
                                // 编辑
                                TextButton(
                                  onPressed: () {
                                    // 编辑操作
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('编辑订单 ${delivery['orderNumber']}')),
                                    );
                                  },
                                  child: const Text('编辑'),
                                ),
                                // 删除
                                TextButton(
                                  onPressed: () {
                                    // 删除操作
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('确认删除'),
                                        content: Text('确定要删除订单 ${delivery['orderNumber']} 吗？'),
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
                                              setState(() {
                                                // 从数据中删除选中的订单
                                                _pendingDeliveries.removeWhere((d) => d['id'] == delivery['id']);
                                                _filteredPendingDeliveries.removeWhere((d) => d['id'] == delivery['id']);
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('已删除订单 ${delivery['orderNumber']}')),
                                              );
                                            },
                                            child: const Text('删除'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text('删除'),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // 分页控制
          if (_filteredPendingDeliveries.length > _rowsPerPage)
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
                  Text('第 ${_currentPage + 1} 页，共 ${( _filteredPendingDeliveries.length / _rowsPerPage).ceil()} 页，总计 ${_filteredPendingDeliveries.length} 条'),
                  TextButton(
                    onPressed: (endIndex < _filteredPendingDeliveries.length)
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
