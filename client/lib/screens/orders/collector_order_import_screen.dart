import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 集货商订单导入信息页面
class CollectorOrderImportScreen extends ConsumerStatefulWidget {
  const CollectorOrderImportScreen({super.key});

  @override
  ConsumerState<CollectorOrderImportScreen> createState() => _CollectorOrderImportScreenState();
}

class _CollectorOrderImportScreenState extends ConsumerState<CollectorOrderImportScreen> {
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
  late List<Map<String, dynamic>> _importInfo;
  late List<Map<String, dynamic>> _filteredImportInfo;

  @override
  void initState() {
    super.initState();
    // 生成模拟数据
    _importInfo = List.generate(30, (index) => {
      'id': index + 1,
      'salesperson': '业务员${(index % 5) + 1}',
      'orderNumber': 'COLLECTOR-20251228-${index.toString().padLeft(4, '0')}',
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
      'operationTime': '2025-12-28 14:${index.toString().padLeft(2, '0')}:30',
      'importTime': '2025-12-28 15:${index.toString().padLeft(2, '0')}:45',
    });
    _filteredImportInfo = List.from(_importInfo);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 应用筛选
  void _applyFilters() {
    setState(() {
      _filteredImportInfo = _importInfo.where((info) {
        // 搜索过滤
        final searchTerm = _searchController.text.toLowerCase();
        final matchesSearch = searchTerm.isEmpty || 
          (info['orderNumber'] as String).toLowerCase().contains(searchTerm) ||
          (info['salesperson'] as String).toLowerCase().contains(searchTerm) ||
          (info['consigneeName'] as String).toLowerCase().contains(searchTerm);
        // 路局筛选
        final matchesRailwayBureau = _selectedRailwayBureau == null || 
          info['railwayBureau'] == _selectedRailwayBureau;
        // 站段筛选
        final matchesStation = _selectedStation == null || 
          info['station'] == _selectedStation;
        
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
      _filteredImportInfo = List.from(_importInfo);
      _currentPage = 0;
    });
  }

  // 排序
  void _sort<T extends Comparable<dynamic>>(T Function(dynamic info) getField, String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
      
      _filteredImportInfo.sort((a, b) {
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
        final endIndex = (startIndex + _rowsPerPage) > _filteredImportInfo.length ? _filteredImportInfo.length : startIndex + _rowsPerPage;
        for (int i = startIndex; i < endIndex; i++) {
          _selectedOrderIds.add(_filteredImportInfo[i]['id'] as int);
        }
      } else {
        // 取消全选当前页
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage) > _filteredImportInfo.length ? _filteredImportInfo.length : startIndex + _rowsPerPage;
        for (int i = startIndex; i < endIndex; i++) {
          _selectedOrderIds.remove(_filteredImportInfo[i]['id'] as int);
        }
      }
    });
  }

  // 切换单行选择状态
  void _toggleSelection(int infoId, bool? value) {
    setState(() {
      if (value == true) {
        _selectedOrderIds.add(infoId);
      } else {
        _selectedOrderIds.remove(infoId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 计算分页数据
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > _filteredImportInfo.length ? _filteredImportInfo.length : startIndex + _rowsPerPage;
    final paginatedImportInfo = _filteredImportInfo.sublist(startIndex, endIndex);
    
    // 检查当前页是否全选
    final bool isAllSelected = paginatedImportInfo.every((info) => _selectedOrderIds.contains(info['id'] as int));
    final bool isSomeSelected = paginatedImportInfo.any((info) => _selectedOrderIds.contains(info['id'] as int));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                      const SnackBar(content: Text('请选择要删除的导入信息')),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('确认删除'),
                      content: Text('确定要删除选中的 ${_selectedOrderIds.length} 条导入信息吗？'),
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
                              // 从数据中删除选中的导入信息
                              _importInfo.removeWhere((info) => _selectedOrderIds.contains(info['id'] as int));
                              _filteredImportInfo.removeWhere((info) => _selectedOrderIds.contains(info['id'] as int));
                              _selectedOrderIds.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('已删除选中的导入信息')),
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
                icon: const Icon(Icons.delete),
                label: Text('删除 (${_selectedOrderIds.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  sortColumnIndex: _sortColumn == 'orderNumber' ? 2 :
                                      _sortColumn == 'submittedDate' ? 3 :
                                      _sortColumn == 'railwayAmount' ? 17 :
                                      _sortColumn == 'orderQuantity' ? 15 : null,
                  sortAscending: _sortAscending,
                  // 列定义
                  columns: [
                    DataColumn(
                      label: Checkbox(
                        value: isAllSelected,
                        tristate: isSomeSelected && !isAllSelected,
                        onChanged: _toggleAllSelection,
                      ),
                      numeric: true,
                    ),
                    const DataColumn(label: Text('业务员')),
                    DataColumn(
                      label: const Text('订单编号'),
                      onSort: (columnIndex, ascending) {
                        _sort((info) => info['orderNumber'] as String, 'orderNumber');
                      },
                    ),
                    DataColumn(
                      label: const Text('提交日期'),
                      onSort: (columnIndex, ascending) {
                        _sort((info) => info['submittedDate'] as String, 'submittedDate');
                      },
                    ),
                    const DataColumn(label: Text('审批日期')),
                    const DataColumn(label: Text('收货人姓名')),
                    const DataColumn(label: Text('收货人电话')),
                    const DataColumn(label: Text('收货地址')),
                    const DataColumn(label: Text('所属路局')),
                    const DataColumn(label: Text('站段')),
                    const DataColumn(label: Text('公司名称')),
                    const DataColumn(label: Text('品牌')),
                    const DataColumn(label: Text('单品编码')),
                    const DataColumn(label: Text('国铁名称')),
                    const DataColumn(label: Text('国铁型号')),
                    DataColumn(
                      label: const Text('下单数量'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        _sort((info) => info['orderQuantity'] as int, 'orderQuantity');
                      },
                    ),
                    const DataColumn(label: Text('国铁单价'), numeric: true),
                    DataColumn(
                      label: const Text('国铁金额'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        _sort((info) => info['railwayAmount'] as double, 'railwayAmount');
                      },
                    ),
                    const DataColumn(label: Text('操作时间')),
                    const DataColumn(label: Text('导入时间')),
                    const DataColumn(label: Text('操作')),
                  ],
                  // 行数据
                  rows: paginatedImportInfo.map((info) {
                    final infoId = info['id'] as int;
                    final isSelected = _selectedOrderIds.contains(infoId);
                    return DataRow(
                      cells: [
                        DataCell(Checkbox(
                          value: isSelected,
                          onChanged: (value) => _toggleSelection(infoId, value),
                        )),
                        DataCell(Text(info['salesperson'] as String)),
                        DataCell(Text(info['orderNumber'] as String)),
                        DataCell(Text(info['submittedDate'] as String)),
                        DataCell(Text(info['approvedDate'] as String)),
                        DataCell(Text(info['consigneeName'] as String)),
                        DataCell(Text(info['consigneePhone'] as String)),
                        DataCell(Text(info['shippingAddress'] as String)),
                        DataCell(Text(info['railwayBureau'] as String)),
                        DataCell(Text(info['station'] as String)),
                        DataCell(Text(info['companyName'] as String)),
                        DataCell(Text(info['brand'] as String)),
                        DataCell(Text(info['productCode'] as String)),
                        DataCell(Text(info['railwayName'] as String)),
                        DataCell(Text(info['railwayModel'] as String)),
                        DataCell(Text((info['orderQuantity'] as int).toString())),
                        DataCell(Text((info['railwayPrice'] as double).toStringAsFixed(2))),
                        DataCell(Text((info['railwayAmount'] as double).toStringAsFixed(2))),
                        DataCell(Text(info['operationTime'] as String)),
                        DataCell(Text(info['importTime'] as String)),
                        DataCell(Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // 查看操作
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('查看订单 ${info['orderNumber']}')),
                                );
                              },
                              child: const Text('查看'),
                            ),
                            TextButton(
                              onPressed: () {
                                // 打印合格证操作
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('打印合格证 ${info['orderNumber']}')),
                                );
                              },
                              child: const Text('打印合格证'),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // 分页控制
          if (_filteredImportInfo.length > _rowsPerPage)
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
                  Text('第 ${_currentPage + 1} 页，共 ${( _filteredImportInfo.length / _rowsPerPage).ceil()} 页，总计 ${_filteredImportInfo.length} 条'),
                  TextButton(
                    onPressed: (endIndex < _filteredImportInfo.length)
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