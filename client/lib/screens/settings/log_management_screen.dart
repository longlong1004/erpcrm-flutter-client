import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/settings/operation_log.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/main_layout.dart';

class LogManagementScreen extends ConsumerStatefulWidget {
  const LogManagementScreen({super.key});

  @override
  ConsumerState<LogManagementScreen> createState() => _LogManagementScreenState();
}

class _LogManagementScreenState extends ConsumerState<LogManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _operationTypeFilter = '全部';
  DateTimeRange? _dateRange;
  bool _showFilters = false;
  int _currentPage = 0;
  int _pageSize = 20;
  String _sortColumn = 'createdAt';
  bool _sortAscending = false;

  // 操作类型列表
  final List<String> _operationTypes = [
    '全部', '新增', '修改', '删除', '查询', '导出', '导入', '登录', '登出'
  ];

  @override
  void initState() {
    super.initState();
    // 初始加载日志数据
    ref.read(logManagementNotifierProvider.notifier).fetchLogs();
  }

  // 查看日志详情
  void _viewLogDetail(OperationLog log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('日志详情'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('日志ID', log.id.toString()),
                  _detailRow('操作人', log.userName),
                  _detailRow('操作类型', log.operationType),
                  _detailRow('操作模块', log.operationModule),
                  _detailRow('操作内容', log.operationContent),
                  _detailRow('操作结果', log.operationResult ?? '成功'),
                  if (log.errorMessage != null)
                    _detailRow('错误信息', log.errorMessage!),
                  _detailRow('IP地址', log.clientIp),
                  _detailRow('操作时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  // 详情行组件
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 导出日志
  void _exportLogs() async {
    try {
      await ref.read(logManagementNotifierProvider.notifier).exportLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日志导出成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('日志导出失败: $e')),
      );
    }
  }

  // 清空日志
  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认清空'),
          content: const Text('确定要清空所有日志吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(logManagementNotifierProvider.notifier).clearLogs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('日志清空成功')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('日志清空失败: $e')),
                  );
                }
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 处理排序
  void _onSort(String columnName, bool ascending) {
    setState(() {
      _sortColumn = columnName;
      _sortAscending = ascending;
    });
    // 调用API进行排序
    ref.read(logManagementNotifierProvider.notifier).fetchLogs(
      keyword: _searchController.text,
      operationType: _operationTypeFilter == '全部' ? null : _operationTypeFilter,
      dateRange: _dateRange,
      sortColumn: columnName,
      sortAscending: ascending,
      page: _currentPage + 1, // 转换为从1开始的页码
      pageSize: _pageSize,
    );
  }

  // 处理分页
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // 调用API进行分页
    ref.read(logManagementNotifierProvider.notifier).fetchLogs(
      keyword: _searchController.text,
      operationType: _operationTypeFilter == '全部' ? null : _operationTypeFilter,
      dateRange: _dateRange,
      sortColumn: _sortColumn,
      sortAscending: _sortAscending,
      page: page + 1, // 转换为从1开始的页码
      pageSize: _pageSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final logsState = ref.watch(logManagementNotifierProvider);

    return MainLayout(
      title: '日志管理',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
                  label: Text(_showFilters ? '隐藏筛选' : '显示筛选'),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _exportLogs,
                      icon: const Icon(Icons.download),
                      label: const Text('导出'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _clearLogs,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('清空'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 搜索和筛选
            if (_showFilters)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('筛选条件', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                          
                      // 搜索框
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: '搜索（用户名、操作内容、模块）',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(logManagementNotifierProvider.notifier).fetchLogs(
                                keyword: '',
                                operationType: _operationTypeFilter == '全部' ? null : _operationTypeFilter,
                                dateRange: _dateRange,
                                sortColumn: _sortColumn,
                                sortAscending: _sortAscending,
                                page: 1,
                                pageSize: _pageSize,
                              );
                            },
                          ),
                        ),
                        onChanged: (value) {
                          ref.read(logManagementNotifierProvider.notifier).fetchLogs(
                            keyword: value,
                            operationType: _operationTypeFilter == '全部' ? null : _operationTypeFilter,
                            dateRange: _dateRange,
                            sortColumn: _sortColumn,
                            sortAscending: _sortAscending,
                            page: 1,
                            pageSize: _pageSize,
                          );
                          // 重置到第一页
                          setState(() {
                            _currentPage = 0;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                          
                      // 操作类型筛选
                      DropdownButtonFormField<String>(
                        value: _operationTypeFilter,
                        decoration: InputDecoration(
                          labelText: '操作类型',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _operationTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _operationTypeFilter = value;
                              _currentPage = 0;
                            });
                            ref.read(logManagementNotifierProvider.notifier).fetchLogs(
                              keyword: _searchController.text,
                              operationType: value == '全部' ? null : value,
                              dateRange: _dateRange,
                              sortColumn: _sortColumn,
                              sortAscending: _sortAscending,
                              page: 1,
                              pageSize: _pageSize,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                          
                      // 日期范围选择
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now(),
                                  initialDateRange: _dateRange,
                                );
                                if (range != null) {
                                  setState(() {
                                    _dateRange = range;
                                    _currentPage = 0;
                                  });
                                  ref.read(logManagementNotifierProvider.notifier).fetchLogs(
                                    keyword: _searchController.text,
                                    operationType: _operationTypeFilter == '全部' ? null : _operationTypeFilter,
                                    dateRange: range,
                                    sortColumn: _sortColumn,
                                    sortAscending: _sortAscending,
                                    page: 1,
                                    pageSize: _pageSize,
                                  );
                                }
                              },
                              child: Text(
                                _dateRange == null
                                    ? '选择日期范围'
                                    : '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} 至 ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}',
                              ),
                            ),
                          ),
                          if (_dateRange != null)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _dateRange = null;
                                  _currentPage = 0;
                                });
                                ref.read(logManagementNotifierProvider.notifier).fetchLogs(
                                  keyword: _searchController.text,
                                  operationType: _operationTypeFilter == '全部' ? null : _operationTypeFilter,
                                  dateRange: null,
                                  sortColumn: _sortColumn,
                                  sortAscending: _sortAscending,
                                  page: 1,
                                  pageSize: _pageSize,
                                );
                              },
                              icon: const Icon(Icons.clear),
                              tooltip: '清除日期范围',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // 日志列表
            Expanded(
              child: logsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('获取日志失败: $error'),
                      ElevatedButton(
                        onPressed: () => ref.read(logManagementNotifierProvider.notifier).fetchLogs(
                          sortColumn: _sortColumn,
                          sortAscending: _sortAscending,
                          page: 1,
                          pageSize: _pageSize,
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
                data: (logsWithTotal) {
                  final logs = logsWithTotal.logs;
                  final total = logsWithTotal.total;
                  
                  if (logs.isEmpty) {
                    return const Center(child: Text('没有找到日志记录'));
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () => ref.read(logManagementNotifierProvider.notifier).fetchLogs(
                      keyword: _searchController.text,
                      operationType: _operationTypeFilter == '全部' ? null : _operationTypeFilter,
                      dateRange: _dateRange,
                      sortColumn: _sortColumn,
                      sortAscending: _sortAscending,
                      page: 1,
                      pageSize: _pageSize,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              sortColumnIndex: _sortColumn == 'createdAt' ? 5 : 
                                           _sortColumn == 'userName' ? 1 : 
                                           _sortColumn == 'operationType' ? 2 : null,
                              sortAscending: _sortAscending,
                              columns: [
                                const DataColumn(label: Text('日志ID')),
                                DataColumn(
                                  label: const Text('操作人'),
                                  onSort: (columnIndex, ascending) => _onSort('userName', ascending),
                                ),
                                DataColumn(
                                  label: const Text('操作类型'),
                                  onSort: (columnIndex, ascending) => _onSort('operationType', ascending),
                                ),
                                const DataColumn(label: Text('操作内容')),
                                const DataColumn(label: Text('操作模块')),
                                DataColumn(
                                  label: const Text('操作时间'),
                                  onSort: (columnIndex, ascending) => _onSort('createdAt', ascending),
                                ),
                                const DataColumn(label: Text('IP地址')),
                                const DataColumn(label: Text('操作')),
                              ],
                              rows: logs.map((log) => DataRow(
                                cells: [
                                  DataCell(Text(log.id.toString())),
                                  DataCell(Text(log.userName)),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getOperationTypeColor(log.operationType),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      log.operationType,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  )),
                                  DataCell(Text(log.operationContent)),
                                  DataCell(Text(log.operationModule)),
                                  DataCell(Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt))),
                                  DataCell(Text(log.clientIp)),
                                  DataCell(Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => _viewLogDetail(log),
                                        child: const Text('详情'),
                                      ),
                                    ],
                                  )),
                                ],
                              )).toList(),
                            ),
                          ),
                          // 分页控件
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('第 ${_currentPage + 1} 页，共 ${(total / _pageSize).ceil()} 页，总计 $total 条记录'),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _currentPage > 0 ? () => _onPageChanged(_currentPage - 1) : null,
                                    child: const Text('上一页'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(80, 40),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: (_currentPage + 1) * _pageSize < total ? () => _onPageChanged(_currentPage + 1) : null,
                                    child: const Text('下一页'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(80, 40),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // 获取操作类型对应的颜色
  Color _getOperationTypeColor(String type) {
    switch (type) {
      case '新增':
        return const Color(0xFF228B22); // 森林绿
      case '修改':
        return const Color(0xFF1E90FF); // 深天蓝
      case '删除':
        return const Color(0xFFDC143C); // 深红色
      case '登录':
        return const Color(0xFF9370DB); // 中紫色
      case '登出':
        return const Color(0xFFFF8C00); // 暗橙色
      case '导出':
        return const Color(0xFF32CD32); // 酸橙绿
      case '导入':
        return const Color(0xFF4169E1); // 皇家蓝
      case '查询':
        return const Color(0xFF6A5ACD); // 石板蓝
      default:
        return const Color(0xFF808080); // 灰色
    }
  }
}