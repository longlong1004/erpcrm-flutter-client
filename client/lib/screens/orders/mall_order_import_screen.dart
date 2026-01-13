import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 商城订单导入信息页面
class MallOrderImportScreen extends ConsumerStatefulWidget {
  const MallOrderImportScreen({super.key});

  @override
  ConsumerState<MallOrderImportScreen> createState() => _MallOrderImportScreenState();
}

class _MallOrderImportScreenState extends ConsumerState<MallOrderImportScreen> {
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
  late List<Map<String, dynamic>> _imports;
  late List<Map<String, dynamic>> _filteredImports;

  @override
  void initState() {
    super.initState();
    // 生成模拟数据
    _imports = List.generate(40, (index) => {
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
      'operationTime': '2025-12-${(28 - index % 12).toString().padLeft(2, '0')} ${(index % 24).toString().padLeft(2, '0')}:${((index * 15) % 60).toString().padLeft(2, '0')}',
      'importTime': '2025-12-${(28 - index % 15).toString().padLeft(2, '0')} ${((index + 5) % 24).toString().padLeft(2, '0')}:${(((index + 3) * 12) % 60).toString().padLeft(2, '0')}',
    });
    _filteredImports = List.from(_imports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 应用筛选
  void _applyFilters() {
    setState(() {
      _filteredImports = _imports.where((import) {
        // 搜索过滤
        final searchTerm = _searchController.text.toLowerCase();
        final matchesSearch = searchTerm.isEmpty || 
          (import['orderNumber'] as String).toLowerCase().contains(searchTerm) ||
          (import['salesperson'] as String).toLowerCase().contains(searchTerm) ||
          (import['consigneeName'] as String).toLowerCase().contains(searchTerm);
        // 路局筛选
        final matchesRailwayBureau = _selectedRailwayBureau == null || 
          import['railwayBureau'] == _selectedRailwayBureau;
        // 站段筛选
        final matchesStation = _selectedStation == null || 
          import['station'] == _selectedStation;
        
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
      _filteredImports = List.from(_imports);
      _currentPage = 0;
    });
  }

  // 排序
  void _sort<T extends Comparable>(T Function(dynamic import) getField, String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
      
      _filteredImports.sort((a, b) {
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
        final endIndex = (startIndex + _rowsPerPage) > _filteredImports.length ? _filteredImports.length : startIndex + _rowsPerPage;
        for (int i = startIndex; i < endIndex; i++) {
          _selectedOrderIds.add(_filteredImports[i]['id'] as int);
        }
      } else {
        // 取消全选当前页
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage) > _filteredImports.length ? _filteredImports.length : startIndex + _rowsPerPage;
        for (int i = startIndex; i < endIndex; i++) {
          _selectedOrderIds.remove(_filteredImports[i]['id'] as int);
        }
      }
    });
  }

  // 切换单行选择状态
  void _toggleSelection(int importId, bool? value) {
    setState(() {
      if (value == true) {
        _selectedOrderIds.add(importId);
      } else {
        _selectedOrderIds.remove(importId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 计算分页数据
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > _filteredImports.length ? _filteredImports.length : startIndex + _rowsPerPage;
    final paginatedImports = _filteredImports.sublist(startIndex, endIndex);
    
    // 检查当前页是否全选
    final bool isAllSelected = paginatedImports.every((import) => _selectedOrderIds.contains(import['id'] as int));
    final bool isSomeSelected = paginatedImports.any((import) => _selectedOrderIds.contains(import['id'] as int));

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
                              _imports.removeWhere((import) => _selectedOrderIds.contains(import['id'] as int));
                              _filteredImports.removeWhere((import) => _selectedOrderIds.contains(import['id'] as int));
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
                  // 列定义 - 按照用户要求的17列顺序排列
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
                        _sort((import) => import['orderNumber'] as String, 'orderNumber');
                      },
                    ),
                    // 4. 提交日期
                    DataColumn(
                      label: const Text('提交日期'),
                      onSort: (columnIndex, ascending) {
                        _sort((import) => import['submittedDate'] as String, 'submittedDate');
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
                        _sort((import) => import['orderQuantity'] as int, 'orderQuantity');
                      },
                    ),
                    // 17. 国铁单价
                    const DataColumn(label: Text('国铁单价'), numeric: true),
                    // 18. 国铁金额
                    DataColumn(
                      label: const Text('国铁金额'),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        _sort((import) => import['railwayAmount'] as double, 'railwayAmount');
                      },
                    ),
                    // 19. 操作时间
                    const DataColumn(label: Text('操作时间')),
                    // 20. 导入时间
                    const DataColumn(label: Text('导入时间')),
                    // 21. 操作
                    const DataColumn(label: Text('操作')),
                  ],
                  // 行数据
                  rows: paginatedImports.map((import) {
                    final importId = import['id'] as int;
                    final isSelected = _selectedOrderIds.contains(importId);
                    return DataRow(
                      cells: [
                        // 1. 勾选
                        DataCell(Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (value) => _toggleSelection(importId, value),
                          ),
                        )),
                        // 2. 业务员
                        DataCell(Container(
                          width: 80,
                          child: Text(import['salesperson'] as String),
                        )),
                        // 3. 订单编号
                        DataCell(Container(
                          width: 150,
                          child: Text(import['orderNumber'] as String),
                        )),
                        // 4. 提交日期
                        DataCell(Container(
                          width: 100,
                          child: Text(import['submittedDate'] as String),
                        )),
                        // 5. 审批日期
                        DataCell(Container(
                          width: 100,
                          child: Text(import['approvedDate'] as String),
                        )),
                        // 6. 收货人姓名
                        DataCell(Container(
                          width: 100,
                          child: Text(import['consigneeName'] as String),
                        )),
                        // 7. 收货人电话
                        DataCell(Container(
                          width: 120,
                          child: Text(import['consigneePhone'] as String),
                        )),
                        // 8. 收货地址
                        DataCell(Container(
                          width: 150,
                          child: Text(import['shippingAddress'] as String),
                        )),
                        // 9. 所属路局
                        DataCell(Container(
                          width: 80,
                          child: Text(import['railwayBureau'] as String),
                        )),
                        // 10. 站段
                        DataCell(Container(
                          width: 80,
                          child: Text(import['station'] as String),
                        )),
                        // 11. 公司名称
                        DataCell(Container(
                          width: 120,
                          child: Text(import['companyName'] as String),
                        )),
                        // 12. 品牌
                        DataCell(Container(
                          width: 80,
                          child: Text(import['brand'] as String),
                        )),
                        // 13. 单品编码
                        DataCell(Container(
                          width: 120,
                          child: Text(import['productCode'] as String),
                        )),
                        // 14. 国铁名称
                        DataCell(Container(
                          width: 120,
                          child: Text(import['railwayName'] as String),
                        )),
                        // 15. 国铁型号
                        DataCell(Container(
                          width: 120,
                          child: Text(import['railwayModel'] as String),
                        )),
                        // 16. 下单数量
                        DataCell(Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Text((import['orderQuantity'] as int).toString()),
                        )),
                        // 17. 国铁单价
                        DataCell(Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          child: Text((import['railwayPrice'] as double).toStringAsFixed(2)),
                        )),
                        // 18. 国铁金额
                        DataCell(Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          child: Text((import['railwayAmount'] as double).toStringAsFixed(2)),
                        )),
                        // 19. 操作时间
                        DataCell(Container(
                          width: 150,
                          child: Text(import['operationTime'] as String),
                        )),
                        // 20. 导入时间
                        DataCell(Container(
                          width: 150,
                          child: Text(import['importTime'] as String),
                        )),
                        // 21. 操作
                        DataCell(Container(
                          width: 80,
                          child: TextButton(
                            onPressed: () {
                              // 查看操作
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('查看导入信息 ${import['orderNumber']}')),
                              );
                            },
                            child: const Text('查看'),
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
          if (_filteredImports.length > _rowsPerPage)
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
                  Text('第 ${_currentPage + 1} 页，共 ${( _filteredImports.length / _rowsPerPage).ceil()} 页，总计 ${_filteredImports.length} 条'),
                  TextButton(
                    onPressed: (endIndex < _filteredImports.length)
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
