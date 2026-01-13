import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

import '../../models/settings/data_dictionary.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/main_layout.dart';

class DataDictionaryScreen extends ConsumerStatefulWidget {
  const DataDictionaryScreen({super.key});

  @override
  ConsumerState<DataDictionaryScreen> createState() => _DataDictionaryScreenState();
}

class _DataDictionaryScreenState extends ConsumerState<DataDictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _dictTypeFilter = '全部';
  bool _showFilters = false;
  String _sortColumn = 'dictType';
  bool _sortAscending = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  // 字典类型列表
  final List<String> _dictTypes = [
    '全部', '订单状态', '产品类型', '客户类型', '支付方式', '物流方式', '发票类型'
  ];

  @override
  void initState() {
    super.initState();
    // 初始加载数据字典数据
    ref.read(dataDictionaryNotifierProvider);
  }

  // 过滤数据字典
  List<DataDictionary> _filterDictionaries(List<DataDictionary> dictionaries) {
    var filtered = dictionaries;

    // 搜索过滤
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered.where((dict) =>
        dict.dictType.toLowerCase().contains(searchText) ||
        dict.dictCode.toLowerCase().contains(searchText) ||
        dict.dictName.toLowerCase().contains(searchText) ||
        dict.dictValue.toLowerCase().contains(searchText)
      ).toList();
    }

    // 类型过滤
    if (_dictTypeFilter != '全部') {
      filtered = filtered.where((dict) =>
        dict.dictType == _dictTypeFilter
      ).toList();
    }

    // 排序
    return _sortDictionaries(filtered);
  }

  // 排序数据字典
  List<DataDictionary> _sortDictionaries(List<DataDictionary> dictionaries) {
    final sorted = List<DataDictionary>.from(dictionaries);
    sorted.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'dictType':
          comparison = a.dictType.compareTo(b.dictType);
          break;
        case 'dictCode':
          comparison = a.dictCode.compareTo(b.dictCode);
          break;
        case 'dictName':
          comparison = a.dictName.compareTo(b.dictName);
          break;
        case 'dictValue':
          comparison = a.dictValue.compareTo(b.dictValue);
          break;
        case 'sortOrder':
          comparison = a.sortOrder.compareTo(b.sortOrder);
          break;
        case 'isActive':
          comparison = a.isActive == b.isActive ? 0 : (a.isActive ? 1 : -1);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  // 排序处理
  void _onSort(String columnName, bool ascending) {
    setState(() {
      _sortColumn = columnName;
      _sortAscending = ascending;
    });
  }

  // 分页处理
  List<DataDictionary> _getPagedDictionaries(List<DataDictionary> dictionaries) {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    if (startIndex >= dictionaries.length) {
      return [];
    }
    return dictionaries.sublist(
      startIndex,
      endIndex < dictionaries.length ? endIndex : dictionaries.length,
    );
  }

  // 页面变更处理
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // 添加字典
  void _addDictionary() {
    // 这里应该打开添加字典的对话框
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _typeController = TextEditingController();
        final TextEditingController _codeController = TextEditingController();
        final TextEditingController _nameController = TextEditingController();
        final TextEditingController _valueController = TextEditingController();
        final TextEditingController _descriptionController = TextEditingController();
        final TextEditingController _sortController = TextEditingController(text: '1');
        bool _status = true;

        return AlertDialog(
          title: const Text('添加数据字典'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: '字典类型',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '字典编码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '字典名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: '字典值',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _sortController,
                    decoration: const InputDecoration(
                      labelText: '排序',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('状态：'),
                      const SizedBox(width: 16),
                      DropdownButton<bool>(
                        value: _status,
                        items: const [
                          DropdownMenuItem(value: true, child: Text('启用')),
                          DropdownMenuItem(value: false, child: Text('禁用')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                    ],
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
              onPressed: () async {
                try {
                  // 保存添加的字典
                  final newDict = DataDictionary(
                    dictType: _typeController.text.trim(),
                    dictCode: _codeController.text.trim(),
                    dictValue: _valueController.text.trim(),
                    dictName: _nameController.text.trim(),
                    description: _descriptionController.text.trim(),
                    sortOrder: int.parse(_sortController.text),
                    isActive: _status,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  await ref.read(dataDictionaryNotifierProvider.notifier).createDictionary({
                    'dictType': newDict.dictType,
                    'dictCode': newDict.dictCode,
                    'dictName': newDict.dictName,
                    'dictValue': newDict.dictValue,
                    'description': newDict.description,
                    'sortOrder': newDict.sortOrder,
                    'isActive': newDict.isActive,
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('字典已添加')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('添加字典失败: $e')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  // 编辑字典
  void _editDictionary(DataDictionary dict) {
    // 这里应该打开编辑字典的对话框
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _typeController = TextEditingController(text: dict.dictType);
        final TextEditingController _codeController = TextEditingController(text: dict.dictCode);
        final TextEditingController _nameController = TextEditingController(text: dict.dictName);
        final TextEditingController _valueController = TextEditingController(text: dict.dictValue);
        final TextEditingController _descriptionController = TextEditingController(text: dict.description ?? '');
        final TextEditingController _sortController = TextEditingController(text: dict.sortOrder.toString());
        bool _status = dict.isActive;

        return AlertDialog(
          title: const Text('编辑数据字典'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: '字典类型',
                      border: OutlineInputBorder(),
                    ),
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '字典编码',
                      border: OutlineInputBorder(),
                    ),
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '字典名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: '字典值',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _sortController,
                    decoration: const InputDecoration(
                      labelText: '排序',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('状态：'),
                      const SizedBox(width: 16),
                      DropdownButton<bool>(
                        value: _status,
                        items: const [
                          DropdownMenuItem(value: true, child: Text('启用')),
                          DropdownMenuItem(value: false, child: Text('禁用')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                    ],
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
              onPressed: () async {
                try {
                  // 保存修改的字典
                  final updates = {
                    'dictName': _nameController.text.trim(),
                    'dictValue': _valueController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'sortOrder': int.parse(_sortController.text),
                    'isActive': _status,
                    'updatedAt': DateTime.now().toIso8601String(),
                  };
                  
                  await ref.read(dataDictionaryNotifierProvider.notifier).updateDictionary(dict.id.toString(), updates);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('字典已修改')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('修改字典失败: $e')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  // 删除字典
  void _deleteDictionary(DataDictionary dict) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除数据字典'),
          content: Text('确定要删除字典 ${dict.dictName} 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // 删除字典
                  await ref.read(dataDictionaryNotifierProvider.notifier).deleteDictionary(dict.id.toString());
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('字典已删除')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除字典失败: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  // 导入/导出字典
  void _importExportDictionaries() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('导入/导出数据字典'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('请选择操作：'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.upload, size: 48, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('导入字典'),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.download, size: 48, color: Colors.green),
                      SizedBox(height: 8),
                      Text('导出字典'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                // 实现导入功能
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                    withData: true,
                  );
                  
                  if (result != null && result.files.single.bytes != null) {
                    // 解析JSON数据
                    final jsonString = String.fromCharCodes(result.files.single.bytes!);
                    final List<dynamic> jsonData = jsonDecode(jsonString);
                    final dictionaries = jsonData.map((item) => DataDictionary.fromJson(item)).toList();
                    
                    // 导入数据字典
                    await ref.read(dataDictionaryNotifierProvider.notifier).importDictionaries(dictionaries);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('数据字典导入成功')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导入失败: $e')),
                  );
                }
              },
              icon: const Icon(Icons.upload),
              label: const Text('导入字典'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                // 实现导出功能
                try {
                  // 获取所有数据字典
                  final dictionaries = await ref.read(dataDictionaryNotifierProvider.notifier).exportDictionaries();
                  
                  // 转换为JSON
                  final jsonData = dictionaries.map((dict) => dict.toJson()).toList();
                  final jsonString = jsonEncode(jsonData);
                  
                  // 保存到文件
                  final result = await FilePicker.platform.saveFile(
                    dialogTitle: '保存数据字典',
                    fileName: 'data_dictionary_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json',
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );
                  
                  if (result != null) {
                    final file = File(result);
                    await file.writeAsString(jsonString);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('数据字典导出成功')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导出失败: $e')),
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('导出字典'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dictionariesState = ref.watch(dataDictionaryNotifierProvider);

    return MainLayout(
      title: '数据字典',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // 搜索和筛选
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
                          labelText: '搜索字典类型、编码、名称或值',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) => setState(() {
                          _currentPage = 1; // 搜索时重置页码
                        }),
                      ),
                      const SizedBox(height: 16),
                      // 筛选选项
                      if (_showFilters)
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _dictTypeFilter,
                                decoration: const InputDecoration(
                                  labelText: '字典类型',
                                  border: OutlineInputBorder(),
                                ),
                                items: _dictTypes.map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _dictTypeFilter = value!;
                                    _currentPage = 1; // 筛选时重置页码
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      // 筛选按钮和操作按钮
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
                                onPressed: _importExportDictionaries,
                                icon: const Icon(Icons.import_export),
                                label: const Text('导入/导出'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _addDictionary,
                                icon: const Icon(Icons.add),
                                label: const Text('添加字典'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 字典表格
              dictionariesState.when(
                data: (dictionaries) {
                  final filteredDictionaries = _filterDictionaries(dictionaries);
                  final pagedDictionaries = _getPagedDictionaries(filteredDictionaries);
                  final totalPages = (filteredDictionaries.length / _pageSize).ceil();

                  return Column(
                    children: [
                      Card(
                        elevation: 2,
                        child: SizedBox(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              sortColumnIndex: _sortColumn == 'dictType' ? 0 : 
                                           _sortColumn == 'dictCode' ? 1 : 
                                           _sortColumn == 'dictName' ? 2 : 
                                           _sortColumn == 'dictValue' ? 3 : 
                                           _sortColumn == 'sortOrder' ? 4 : 
                                           _sortColumn == 'isActive' ? 5 : null,
                              sortAscending: _sortAscending,
                              columns: [
                                DataColumn(
                                  label: const Text('字典类型'),
                                  onSort: (columnIndex, ascending) => _onSort('dictType', ascending),
                                ),
                                DataColumn(
                                  label: const Text('字典编码'),
                                  onSort: (columnIndex, ascending) => _onSort('dictCode', ascending),
                                ),
                                DataColumn(
                                  label: const Text('字典名称'),
                                  onSort: (columnIndex, ascending) => _onSort('dictName', ascending),
                                ),
                                DataColumn(
                                  label: const Text('字典值'),
                                  onSort: (columnIndex, ascending) => _onSort('dictValue', ascending),
                                ),
                                DataColumn(
                                  label: const Text('排序'),
                                  onSort: (columnIndex, ascending) => _onSort('sortOrder', ascending),
                                ),
                                DataColumn(
                                  label: const Text('状态'),
                                  onSort: (columnIndex, ascending) => _onSort('isActive', ascending),
                                ),
                                const DataColumn(label: Text('操作')),
                              ],
                              rows: pagedDictionaries.map((dict) {
                                return DataRow(cells: [
                                  DataCell(Text(dict.dictType)),
                                  DataCell(Text(dict.dictCode)),
                                  DataCell(Text(dict.dictName)),
                                  DataCell(Text(dict.dictValue)),
                                  DataCell(Text(dict.sortOrder.toString())),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: dict.isActive ? Colors.green[100] : Colors.red[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        dict.isActive ? '启用' : '禁用',
                                        style: TextStyle(
                                          color: dict.isActive ? Colors.green[800] : Colors.red[800],
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _editDictionary(dict),
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: '编辑字典',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteDictionary(dict),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: '删除字典',
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
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
                                icon: const Icon(Icons.chevron_left),
                                tooltip: '上一页',
                              ),
                              Text('第 $_currentPage 页，共 $totalPages 页'),
                              IconButton(
                                onPressed: _currentPage < totalPages ? () => _onPageChanged(_currentPage + 1) : null,
                                icon: const Icon(Icons.chevron_right),
                                tooltip: '下一页',
                              ),
                            ],
                          ),
                        ),
                      // 数据统计
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('共 ${filteredDictionaries.length} 条记录', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                      ref.invalidate(dataDictionaryNotifierProvider);
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