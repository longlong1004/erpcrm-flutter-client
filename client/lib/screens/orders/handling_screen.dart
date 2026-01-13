import 'package:flutter/material.dart';

class HandlingScreen extends StatefulWidget {
  const HandlingScreen({super.key});

  @override
  State<HandlingScreen> createState() => _HandlingScreenState();
}

class _HandlingScreenState extends State<HandlingScreen> {
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _searchQuery = '';
  bool _isSortAscending = true;
  int? _sortColumnIndex;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _handlingOrders = List.generate(20, (index) => {
    'id': index + 1,
    'salesperson': '业务员${index % 5 + 1}',
    'orderNumber': 'HDL-${2024}-${1000 + index}',
    'brand': '品牌${index % 3 + 1}',
    'station': '站段${index % 5 + 1}',
    'itemCode': 'ITEM-${index + 1}',
    'railwayName': '国铁名称${index + 1}',
    'railwayModel': '国铁型号${index + 1}',
    'unit': '件',
    'quantity': (index + 1) * 10,
    'unitPrice': (index + 1) * 100.0,
    'totalAmount': (index + 1) * 1000.0,
    'profit': (index + 1) * 200.0,
    'handlingPercentage': '${(index % 10 + 1) * 10}%',
    'handlingAmount': (index + 1) * 100.0,
    'time': '2024-0${index % 12 + 1}-${index % 28 + 1} ${index % 24}:${index % 60}:${index % 60}',
  });

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _handlingOrders.where((order) {
      final query = _searchQuery.toLowerCase();
      return order['orderNumber'].toLowerCase().contains(query) ||
             order['salesperson'].toLowerCase().contains(query) ||
             order['brand'].toLowerCase().contains(query);
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
        title: const Text('办理'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索订单编号、业务员、品牌...',
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
                    // 办理功能
                  },
                  child: const Text('办理'),
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
                    const DataColumn(label: Text('品牌')),
                    const DataColumn(label: Text('站段')),
                    const DataColumn(label: Text('单品编码')),
                    const DataColumn(label: Text('国铁名称')),
                    const DataColumn(label: Text('国铁型号')),
                    const DataColumn(label: Text('单位')),
                    DataColumn(
                      label: const Text('数量'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['quantity'].compareTo(b['quantity'])
                              : b['quantity'].compareTo(a['quantity']));
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('单价'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['unitPrice'].compareTo(b['unitPrice'])
                              : b['unitPrice'].compareTo(a['unitPrice']));
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('合计'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['totalAmount'].compareTo(b['totalAmount'])
                              : b['totalAmount'].compareTo(a['totalAmount']));
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('利润'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['profit'].compareTo(b['profit'])
                              : b['profit'].compareTo(a['profit']));
                        });
                      },
                    ),
                    const DataColumn(label: Text('办理百分比')),
                    DataColumn(
                      label: const Text('办理金额'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['handlingAmount'].compareTo(b['handlingAmount'])
                              : b['handlingAmount'].compareTo(a['handlingAmount']));
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('时间'),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _isSortAscending = ascending;
                          filteredOrders.sort((a, b) => ascending
                              ? a['time'].compareTo(b['time'])
                              : b['time'].compareTo(a['time']));
                        });
                      },
                    ),
                  ],
                  rows: currentOrders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order['salesperson'])),
                      DataCell(Text(order['orderNumber'])),
                      DataCell(Text(order['brand'])),
                      DataCell(Text(order['station'])),
                      DataCell(Text(order['itemCode'])),
                      DataCell(Text(order['railwayName'])),
                      DataCell(Text(order['railwayModel'])),
                      DataCell(Text(order['unit'])),
                      DataCell(Text(order['quantity'].toString())),
                      DataCell(Text(order['unitPrice'].toString())),
                      DataCell(Text(order['totalAmount'].toString())),
                      DataCell(Text(order['profit'].toString())),
                      DataCell(Text(order['handlingPercentage'])),
                      DataCell(Text(order['handlingAmount'].toString())),
                      DataCell(Text(order['time'])),
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
}