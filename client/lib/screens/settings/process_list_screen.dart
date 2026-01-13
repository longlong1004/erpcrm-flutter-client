import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';

class ProcessListScreen extends ConsumerStatefulWidget {
  const ProcessListScreen({super.key});

  @override
  ConsumerState<ProcessListScreen> createState() => _ProcessListScreenState();
}

class _ProcessListScreenState extends ConsumerState<ProcessListScreen> {
  // 模拟流程数据
  final List<Map<String, dynamic>> _processes = [
    {
      'id': '1',
      'name': '采购申请审批流程',
      'type': '采购管理',
      'createdAt': '2025-12-20',
      'status': '启用',
      'creator': '管理员',
      'nodeCount': 3,
      'associatedPage': {'name': '采购申请', 'route': '/procurement/applications'},
    },
    {
      'id': '2',
      'name': '请假审批流程',
      'type': '人力资源',
      'createdAt': '2025-12-18',
      'status': '启用',
      'creator': '管理员',
      'nodeCount': 2,
      'associatedPage': {'name': '请假申请', 'route': '/salary/leave'},
    },
    {
      'id': '3',
      'name': '报销审批流程',
      'type': '财务管理',
      'createdAt': '2025-12-15',
      'status': '禁用',
      'creator': '管理员',
      'nodeCount': 4,
      'associatedPage': {'name': '报销申请', 'route': '/finance/reimbursement'},
    },
  ];

  String _searchText = '';
  String _statusFilter = '全部';
  String _typeFilter = '全部';

  @override
  Widget build(BuildContext context) {
    // 过滤流程列表
    final filteredProcesses = _processes.where((process) {
      final matchesSearch = process['name'].toLowerCase().contains(_searchText.toLowerCase());
      final matchesStatus = _statusFilter == '全部' || process['status'] == _statusFilter;
      final matchesType = _typeFilter == '全部' || process['type'] == _typeFilter;
      return matchesSearch && matchesStatus && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('流程列表'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 返回流程设计主页面
            GoRouter.of(context).go('/settings/process-design');
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 刷新流程列表
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和筛选区域
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 搜索框
                  TextField(
                    decoration: InputDecoration(
                      labelText: '搜索流程名称',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 筛选条件
                  Row(
                    children: [
                      // 状态筛选
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '状态',
                            border: OutlineInputBorder(),
                          ),
                          value: _statusFilter,
                          items: ['全部', '启用', '禁用'].map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _statusFilter = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 类型筛选
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '流程类型',
                            border: OutlineInputBorder(),
                          ),
                          value: _typeFilter,
                          items: ['全部', '采购管理', '人力资源', '财务管理'].map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _typeFilter = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 筛选按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchText = '';
                            _statusFilter = '全部';
                            _typeFilter = '全部';
                          });
                        },
                        child: const Text('重置筛选'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // 执行筛选，这里已经通过setState实时筛选了
                        },
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

          // 流程列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProcesses.length,
              itemBuilder: (context, index) {
                final process = filteredProcesses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 流程基本信息
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              process['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(process['status']),
                              backgroundColor: process['status'] == '启用' ? Colors.green[100] : Colors.grey[100],
                              labelStyle: TextStyle(
                                color: process['status'] == '启用' ? Colors.green[800] : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '类型：${process['type']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '创建时间：${process['createdAt']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '节点数：${process['nodeCount']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '创建人：${process['creator']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            if (process['associatedPage'] != null) ...[
                              Text(
                                '关联页面：${process['associatedPage']['name']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 操作按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // 预览流程
                                _showProcessPreview(process);
                              },
                              child: const Text('预览'),
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
      // 创建新流程按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 使用标签页系统添加新标签页
          ref.read(tabProvider.notifier).addTab(
            title: '创建新流程',
            route: '/settings/process-design/create',
          );
          context.go('/settings/process-design/create');
        },
        backgroundColor: const Color(0xFF003366),
        child: const Icon(Icons.add),
        tooltip: '创建新流程',
      ),
    );
  }

  // 显示流程预览
  void _showProcessPreview(Map<String, dynamic> process) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('流程预览：${process['name']}'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Text('流程预览功能待实现'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(Map<String, dynamic> process) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除流程「${process['name']}」吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _processes.remove(process);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('流程「${process['name']}」已删除'),
                  ),
                );
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
