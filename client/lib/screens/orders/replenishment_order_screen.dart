import 'package:flutter/material.dart';

class ReplenishmentOrderScreen extends StatefulWidget {
  const ReplenishmentOrderScreen({super.key});

  @override
  State<ReplenishmentOrderScreen> createState() => _ReplenishmentOrderScreenState();
}

class _ReplenishmentOrderScreenState extends State<ReplenishmentOrderScreen> {
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _searchQuery = '';
  bool _isSortAscending = true;
  int? _sortColumnIndex;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _replenishmentOrders = List.generate(20, (index) => {
    'id': index + 1,
    'salesperson': '业务员${index % 5 + 1}',
    'status': index % 3 == 0 ? '待处理' : index % 3 == 1 ? '处理中' : '已完成',
    'orderType': index % 2 == 0 ? '换货' : '补货',
    'orderNumber': 'RPL-${2024}-${1000 + index}',
    'companyName': '公司${index % 4 + 1}',
    'railwayBureau': '路局${index % 3 + 1}',
    'station': '站段${index % 5 + 1}',
    'consigneeName': '收货人${index + 1}',
    'consigneePhone': '1380013800${index % 10}',
    'consigneeAddress': '收货地址${index + 1}',
    'remark': '备注${index + 1}',
    'createTime': '2024-0${index % 12 + 1}-${index % 28 + 1} ${index % 24}:${index % 60}:${index % 60}',
  });

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _replenishmentOrders.where((order) {
      final query = _searchQuery.toLowerCase();
      return order['orderNumber'].toLowerCase().contains(query) ||
             order['salesperson'].toLowerCase().contains(query) ||
             order['companyName'].toLowerCase().contains(query);
    }).toList();

    final totalPages = (filteredOrders.length / _rowsPerPage).ceil();
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    final currentOrders = filteredOrders.sublist(
      startIndex,
      endIndex > filteredOrders.length ? filteredOrders.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('补发货（退换货）'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索订单编号、业务员、公司名称...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 操作区
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 新增补发货订单功能
                  },
                  child: const Text('新增'),
                ),
              ],
            ),
          ),
          
          // 表格区
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  sortAscending: _isSortAscending,
                  sortColumnIndex: _sortColumnIndex,
                  columns: [
                    DataColumn(
                      label: const Text('业务员'),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['salesperson'].compareTo(b['salesperson'])
                              : b['salesperson'].compareTo(a['salesperson']));
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('状态'),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['status'].compareTo(b['status'])
                              : b['status'].compareTo(a['status']));
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('订单类型'),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['orderType'].compareTo(b['orderType'])
                              : b['orderType'].compareTo(a['orderType']));
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('订单编号'),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['orderNumber'].compareTo(b['orderNumber'])
                              : b['orderNumber'].compareTo(a['orderNumber']));
                        });
                      },
                    ),
                    const DataColumn(label: Text('公司名称')),
                    const DataColumn(label: Text('所属路局')),
                    const DataColumn(label: Text('所属站段')),
                    const DataColumn(label: Text('收货人姓名')),
                    const DataColumn(label: Text('收货人电话')),
                    const DataColumn(label: Text('收货地址')),
                    const DataColumn(label: Text('备注')),
                    DataColumn(
                      label: const Text('创建时间'),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['createTime'].compareTo(b['createTime'])
                              : b['createTime'].compareTo(a['createTime']));
                        });
                      },
                    ),
                    const DataColumn(label: Text('操作')),
                  ],
                  rows: currentOrders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order['salesperson'])),
                      DataCell(Text(order['status'])),
                      DataCell(Text(order['orderType'])),
                      DataCell(Text(order['orderNumber'])),
                      DataCell(Text(order['companyName'])),
                      DataCell(Text(order['railwayBureau'])),
                      DataCell(Text(order['station'])),
                      DataCell(Text(order['consigneeName'])),
                      DataCell(Text(order['consigneePhone'])),
                      DataCell(Text(order['consigneeAddress'])),
                      DataCell(Text(order['remark'])),
                      DataCell(Text(order['createTime'])),
                      DataCell(Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // 查看功能
                            },
                            child: const Text('查看'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // 编辑功能
                            },
                            child: const Text('编辑'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // 删除功能
                              _showDeleteConfirmationDialog(order['orderNumber']);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('删除'),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // 分页控件
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('每页显示：'),
                    DropdownButton<int>(
                      value: _rowsPerPage,
                      items: [5, 10, 20, 50].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _rowsPerPage = value!;
                          _currentPage = 0;
                        });
                      },
                    ),
                  ],
                ),
                Text('共 ${filteredOrders.length} 条记录，第 ${_currentPage + 1} / $totalPages 页'),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage == 0
                          ? null
                          : () {
                              setState(() {
                                _currentPage--;
                              });
                            },
                      child: const Text('上一页'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _currentPage == totalPages - 1
                          ? null
                          : () {
                              setState(() {
                                _currentPage++;
                              });
                            },
                      child: const Text('下一页'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String orderNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除补发货订单 $orderNumber 吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 删除订单逻辑
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}