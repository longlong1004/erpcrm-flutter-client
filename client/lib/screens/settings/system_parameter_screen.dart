import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../models/settings/system_parameter.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/main_layout.dart';

class SystemParameterScreen extends ConsumerStatefulWidget {
  const SystemParameterScreen({super.key});

  @override
  ConsumerState<SystemParameterScreen> createState() => _SystemParameterScreenState();
}

class _SystemParameterScreenState extends ConsumerState<SystemParameterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _groupFilter = '全部';
  bool _showFilters = false;
  int _currentPage = 0;
  int _pageSize = 20;
  String _sortColumn = 'parameterKey';
  bool _sortAscending = true;

  // 参数分组列表
  final List<String> _paramGroups = [
    '全部', '系统配置', '邮件设置', '打印模板', '业务参数', '安全设置'
  ];

  @override
  void initState() {
    super.initState();
    // 初始加载系统参数数据
    ref.read(systemParameterNotifierProvider);
  }

  // 修改参数
  void _modifyParameter(SystemParameter param) {
    // 这里应该打开修改参数的对话框
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _valueController = TextEditingController(text: param.parameterValue);
        return AlertDialog(
          title: const Text('修改参数'),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('参数名', param.parameterKey),
                  _detailRow('参数类型', param.parameterType),
                  _detailRow('参数描述', param.parameterDescription),
                  _detailRow('默认值', param.defaultValue),
                  if (!param.isEditable) const Text('（系统参数，谨慎修改）', style: TextStyle(color: Color(0xFFDC143C))),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: '参数值',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF003366), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    enabled: param.isEditable,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
                onPressed: param.isEditable ? () async {
                  try {
                    await ref.read(systemParameterNotifierProvider.notifier).updateParameter(
                      param.parameterKey,
                      {'parameterValue': _valueController.text}
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('参数修改成功'), backgroundColor: const Color(0xFF228B22)),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('参数修改失败: $e'), backgroundColor: const Color(0xFFDC143C)),
                    );
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  foregroundColor: Colors.white,
                ),
                child: const Text('保存'),
              ),
          ],
        );
      },
    );
  }

  // 重置参数
  void _resetParameter(SystemParameter param) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重置参数'),
          content: Text('确定要将参数 ${param.parameterKey} 重置为默认值 ${param.defaultValue} 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(systemParameterNotifierProvider.notifier).resetParameter(
                    param.parameterKey
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('参数重置成功'), backgroundColor: const Color(0xFF228B22)),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('参数重置失败: $e'), backgroundColor: const Color(0xFFDC143C)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('重置'),
            ),
          ],
        );
      },
    );
  }

  // 导出参数
  void _exportParameters() async {
    try {
      await ref.read(systemParameterNotifierProvider.notifier).exportParameters();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('参数导出成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('参数导出失败: $e')),
      );
    }
  }

  // 导入参数
  void _importParameters() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        await ref.read(systemParameterNotifierProvider.notifier).importParameters(
          result.files.single.bytes!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('参数导入成功')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('参数导入失败: $e')),
      );
    }
  }

  // 查看参数变更记录
  void _showChangeHistory(SystemParameter param) {
    // 模拟参数变更记录数据
    final changeHistory = [
      {
        'id': 1,
        'oldValue': 'old_value_1',
        'newValue': param.parameterValue,
        'changedBy': '管理员',
        'changedAt': DateTime.now().subtract(const Duration(days: 1)),
        'changeReason': '系统优化'
      },
      {
        'id': 2,
        'oldValue': 'old_value_2',
        'newValue': 'old_value_1',
        'changedBy': '管理员',
        'changedAt': DateTime.now().subtract(const Duration(days: 5)),
        'changeReason': '业务需求变更'
      },
      {
        'id': 3,
        'oldValue': 'initial_value',
        'newValue': 'old_value_2',
        'changedBy': '系统',
        'changedAt': DateTime.now().subtract(const Duration(days: 30)),
        'changeReason': '初始设置'
      }
    ];
    
    // 打开变更记录对话框
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('参数变更记录: ${param.parameterKey}'),
          content: SizedBox(
            width: 800,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('参数描述: ${param.parameterDescription}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('变更历史:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('变更时间')),
                      DataColumn(label: Text('变更人')),
                      DataColumn(label: Text('旧值')),
                      DataColumn(label: Text('新值')),
                      DataColumn(label: Text('变更原因')),
                    ],
                    rows: changeHistory.map((record) => DataRow(
                      cells: [
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(record['changedAt'] as DateTime))),
                        DataCell(Text(record['changedBy'] as String)),
                        DataCell(Text(record['oldValue'] as String)),
                        DataCell(Text(record['newValue'] as String)),
                        DataCell(Text(record['changeReason'] as String)),
                      ],
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // 模拟导出变更记录
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('变更记录已导出')),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.download),
              label: const Text('导出'),
            ),
          ],
        );
      },
    );
  }

  // 详情行组件
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:')),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 筛选参数
  List<SystemParameter> _filterParams(List<SystemParameter> params) {
    return params.where((param) {
      final matchesSearch = param.parameterKey.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          param.parameterDescription.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          param.parameterValue.toLowerCase().contains(_searchController.text.toLowerCase());
      
      // 暂时根据参数键前缀来模拟分组
      String paramGroup;
      if (param.parameterKey.startsWith('sys.')) {
        paramGroup = '系统配置';
      } else if (param.parameterKey.startsWith('email.')) {
        paramGroup = '邮件设置';
      } else if (param.parameterKey.startsWith('print.')) {
        paramGroup = '打印模板';
      } else if (param.parameterKey.startsWith('business.')) {
        paramGroup = '业务参数';
      } else if (param.parameterKey.startsWith('security.')) {
        paramGroup = '安全设置';
      } else {
        paramGroup = '其他';
      }
      final matchesGroup = _groupFilter == '全部' || paramGroup == _groupFilter;
      
      return matchesSearch && matchesGroup;
    }).toList();
  }

  // 排序参数
  List<SystemParameter> _sortParams(List<SystemParameter> params) {
    return List.from(params)..sort((a, b) {
      int comparison = 0;
      
      switch (_sortColumn) {
        case 'parameterKey':
          comparison = a.parameterKey.compareTo(b.parameterKey);
          break;
        case 'parameterValue':
          comparison = a.parameterValue.compareTo(b.parameterValue);
          break;
        case 'parameterType':
          comparison = a.parameterType.compareTo(b.parameterType);
          break;
        case 'parameterGroup':
          // 模拟分组比较
          String getGroup(SystemParameter param) {
            if (param.parameterKey.startsWith('sys.')) return '系统配置';
            if (param.parameterKey.startsWith('email.')) return '邮件设置';
            if (param.parameterKey.startsWith('print.')) return '打印模板';
            if (param.parameterKey.startsWith('business.')) return '业务参数';
            if (param.parameterKey.startsWith('security.')) return '安全设置';
            return '其他';
          }
          comparison = getGroup(a).compareTo(getGroup(b));
          break;
        case 'updatedAt':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
  }

  // 分页参数
  List<SystemParameter> _paginateParams(List<SystemParameter> params) {
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;
    return startIndex < params.length
        ? params.sublist(startIndex, endIndex > params.length ? params.length : endIndex)
        : [];
  }

  // 处理排序
  void _onSort(String columnName, bool ascending) {
    setState(() {
      _sortColumn = columnName;
      _sortAscending = ascending;
    });
  }

  // 处理分页
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paramsState = ref.watch(systemParameterNotifierProvider);

    return MainLayout(
      title: '系统参数',
      showBackButton: true,
      child: SingleChildScrollView(
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
                      onPressed: _importParameters,
                      icon: const Icon(Icons.upload),
                      label: const Text('导入'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _exportParameters,
                      icon: const Icon(Icons.download),
                      label: const Text('导出'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 搜索和筛选
            if (_showFilters)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 搜索框
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: '搜索参数名称、描述或值',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentPage = 0; // 搜索时重置到第一页
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // 筛选选项
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _groupFilter,
                              decoration: const InputDecoration(
                                labelText: '参数分组',
                                border: OutlineInputBorder(),
                              ),
                              items: _paramGroups.map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _groupFilter = value!;
                                  _currentPage = 0; // 筛选时重置到第一页
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // 参数表格
            paramsState.when(
              data: (params) {
                final filteredParams = _filterParams(params);
                final sortedParams = _sortParams(filteredParams);
                final paginatedParams = _paginateParams(sortedParams);
                final totalPages = (filteredParams.length / _pageSize).ceil();
                
                return Column(
                  children: [
                    Card(
                      elevation: 2,
                      child: SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortColumnIndex: _sortColumn == 'parameterKey' ? 0 :
                                         _sortColumn == 'parameterValue' ? 1 :
                                         _sortColumn == 'parameterType' ? 2 :
                                         _sortColumn == 'parameterGroup' ? 4 : 5,
                            sortAscending: _sortAscending,
                            columns: [
                              DataColumn(
                                label: const Text('参数名'),
                                onSort: (columnIndex, ascending) => _onSort('parameterKey', ascending),
                              ),
                              DataColumn(
                                label: const Text('参数值'),
                                onSort: (columnIndex, ascending) => _onSort('parameterValue', ascending),
                              ),
                              DataColumn(
                                label: const Text('参数类型'),
                                onSort: (columnIndex, ascending) => _onSort('parameterType', ascending),
                              ),
                              const DataColumn(label: Text('参数描述')),
                              DataColumn(
                                label: const Text('参数分组'),
                                onSort: (columnIndex, ascending) => _onSort('parameterGroup', ascending),
                              ),
                              DataColumn(
                                label: const Text('修改时间'),
                                onSort: (columnIndex, ascending) => _onSort('updatedAt', ascending),
                              ),
                              const DataColumn(label: Text('操作')),
                            ],
                            rows: paginatedParams.map((param) {
                              return DataRow(cells: [
                                DataCell(Text(param.parameterKey)),
                                DataCell(
                                  Text(param.parameterValue),
                                ),
                                DataCell(Text(param.parameterType)),
                                DataCell(Container(
                                  width: 200,
                                  child: Text(param.parameterDescription, overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Text(
                                  param.parameterKey.startsWith('sys.') ? '系统配置' :
                                  param.parameterKey.startsWith('email.') ? '邮件设置' :
                                  param.parameterKey.startsWith('print.') ? '打印模板' :
                                  param.parameterKey.startsWith('business.') ? '业务参数' :
                                  param.parameterKey.startsWith('security.') ? '安全设置' : '其他'
                                )),

                                DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(param.updatedAt))),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _modifyParameter(param),
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: '修改参数',
                                    ),
                                    IconButton(
                                      onPressed: () => _resetParameter(param),
                                      icon: const Icon(Icons.refresh, color: Colors.orange),
                                      tooltip: '重置参数',
                                    ),
                                    IconButton(
                                      onPressed: () => _showChangeHistory(param),
                                      icon: const Icon(Icons.history, color: Colors.green),
                                      tooltip: '查看变更记录',
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
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 0 ? () => _onPageChanged(_currentPage - 1) : null,
                              icon: const Icon(Icons.chevron_left),
                              tooltip: '上一页',
                            ),
                            Text('第 ${_currentPage + 1} 页，共 $totalPages 页'),
                            IconButton(
                              onPressed: _currentPage < totalPages - 1 ? () => _onPageChanged(_currentPage + 1) : null,
                              icon: const Icon(Icons.chevron_right),
                              tooltip: '下一页',
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: $error'),
                    ElevatedButton(
                      onPressed: () {
                      ref.invalidate(systemParameterNotifierProvider);
                    },
                    child: const Text('重试'),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}