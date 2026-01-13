import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/approval_delegate_provider.dart';

class ProcessConfigurationScreen extends ConsumerStatefulWidget {
  final String? processId;

  const ProcessConfigurationScreen({super.key, this.processId});

  @override
  ConsumerState<ProcessConfigurationScreen> createState() => _ProcessConfigurationScreenState();
}

class _ProcessConfigurationScreenState extends ConsumerState<ProcessConfigurationScreen> {
  // 表单控制器
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _triggerConditionController;

  // 表单数据
  String _processType = '采购管理';
  String _status = '启用';
  bool _allowMultipleInstances = false;
  bool _sendNotification = true;
  String _associatedPageRoute = '';
  String _associatedPageName = '';
  List<int> _selectedDelegateRuleIds = [];
  String? _selectedDelegateRuleId; // 当前选择的替换审批人规则ID

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _triggerConditionController = TextEditingController();

    // 如果是编辑现有流程，加载流程数据
    if (widget.processId != null) {
      _loadProcessData();
    }
  }

  @override
  void dispose() {
    // 释放控制器资源
    _nameController.dispose();
    _descriptionController.dispose();
    _triggerConditionController.dispose();
    super.dispose();
  }

  // 加载流程数据
  void _loadProcessData() {
    // 这里应该从API加载流程数据，现在使用模拟数据
    setState(() {
      _nameController.text = '采购申请审批流程';
      _descriptionController.text = '员工提交采购申请后的审批流程，包括部门经理审批和金额大于1万时的总经理加签';
      _processType = '采购管理';
      _status = '启用';
      _allowMultipleInstances = false;
      _sendNotification = true;
      _triggerConditionController.text = 'amount > 0';
      _associatedPageRoute = '/procurement/applications';
      _associatedPageName = '采购申请';
    });
  }

  // 保存流程配置
  void _saveConfiguration() {
    // 验证表单
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('流程名称不能为空')),
      );
      return;
    }

    // 这里应该调用API保存流程配置
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('保存成功'),
          content: const Text('流程配置已成功保存！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 返回流程列表
                context.go('/settings/process-design/list');
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.processId != null ? '编辑流程配置' : '新建流程配置'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 返回流程列表页面
            GoRouter.of(context).go('/settings/process-design/list');
          },
        ),
        actions: [
          IconButton(
            onPressed: _saveConfiguration,
            icon: const Icon(Icons.save),
            tooltip: '保存',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 流程基本信息
                const Text(
                  '流程基本信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 流程名称
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '流程名称 *',
                    border: OutlineInputBorder(),
                    hintText: '请输入流程名称',
                  ),
                  onChanged: (value) {
                    // 可以在这里添加实时验证
                  },
                ),
                const SizedBox(height: 16),

                // 流程类型
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '流程类型',
                    border: OutlineInputBorder(),
                  ),
                  value: _processType,
                  items: ['采购管理', '人力资源', '财务管理', '仓库管理', '其他'].map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _processType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 流程描述
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '流程描述',
                    border: OutlineInputBorder(),
                    hintText: '请输入流程描述',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // 可以在这里添加实时验证
                  },
                ),
                const SizedBox(height: 16),

                // 流程状态
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '流程状态',
                    border: OutlineInputBorder(),
                  ),
                  value: _status,
                  items: ['启用', '禁用'].map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 允许同时存在多个实例
                CheckboxListTile(
                  title: const Text('允许同时存在多个实例'),
                  value: _allowMultipleInstances,
                  onChanged: (value) {
                    setState(() {
                      _allowMultipleInstances = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),

                // 发送通知
                CheckboxListTile(
                  title: const Text('发送通知'),
                  value: _sendNotification,
                  onChanged: (value) {
                    setState(() {
                      _sendNotification = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 32),

                // 关联功能页面
                const Text(
                  '关联功能页面',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 关联页面路由
                TextField(
                  decoration: const InputDecoration(
                    labelText: '关联页面路由',
                    border: OutlineInputBorder(),
                    hintText: '例如：/procurement/applications',
                    helperText: '流程关联的功能页面路由',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _associatedPageRoute = value;
                    });
                  },
                  controller: TextEditingController(text: _associatedPageRoute),
                ),
                const SizedBox(height: 16),

                // 关联页面名称
                TextField(
                  decoration: const InputDecoration(
                    labelText: '关联页面名称',
                    border: OutlineInputBorder(),
                    hintText: '例如：采购申请',
                    helperText: '流程关联的功能页面名称',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _associatedPageName = value;
                    });
                  },
                  controller: TextEditingController(text: _associatedPageName),
                ),
                const SizedBox(height: 32),

                // 触发条件配置
                const Text(
                  '触发条件配置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 触发条件
                TextField(
                  controller: _triggerConditionController,
                  decoration: const InputDecoration(
                    labelText: '触发条件表达式',
                    border: OutlineInputBorder(),
                    hintText: '例如：amount > 0',
                    helperText: '当满足此条件时，流程将被触发',
                  ),
                  onChanged: (value) {
                    // 可以在这里添加实时验证
                  },
                ),
                const SizedBox(height: 32),

                // 流程权限配置
                const Text(
                  '流程权限配置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 可发起流程的角色
                const Text('可发起流程的角色'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: const Text('员工'),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        // 移除角色
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('角色移除功能待实现')),
                        );
                      },
                    ),
                    Chip(
                      label: const Text('部门经理'),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        // 移除角色
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('角色移除功能待实现')),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('+ 添加角色'),
                      onPressed: () {
                        // 添加角色
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('角色添加功能待实现')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 可查看流程的角色
                const Text('可查看流程的角色'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: const Text('员工'),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        // 移除角色
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('角色移除功能待实现')),
                        );
                      },
                    ),
                    Chip(
                      label: const Text('部门经理'),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        // 移除角色
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('角色移除功能待实现')),
                        );
                      },
                    ),
                    Chip(
                      label: const Text('总经理'),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        // 移除角色
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('角色移除功能待实现')),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('+ 添加角色'),
                      onPressed: () {
                        // 添加角色
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('角色添加功能待实现')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 审批人替换规则配置
                const Text(
                  '审批人替换规则配置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 替换审批人规则选择
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('关联替换审批人规则'),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final rulesState = ref.watch(approvalDelegateNotifierProvider);
                        final rules = rulesState.value ?? [];
                        
                        return DropdownButtonFormField<String?>(
                          decoration: const InputDecoration(
                            labelText: '选择替换审批人规则',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDelegateRuleId,
                          items: rules.map((rule) => DropdownMenuItem(
                            value: rule.id.toString(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (rule.description ?? '').isEmpty 
                                      ? '${rule.originalApproverName} -> ${rule.delegateApproverName}'
                                      : rule.description!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${rule.startTime.toString().substring(0, 10)} 至 ${rule.endTime.toString().substring(0, 10)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDelegateRuleId = value;
                            });
                          },
                          hint: const Text('选择替换审批人规则'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // 跳转到替换审批人页面创建新规则
                            GoRouter.of(context).go('/settings/approval-delegate');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('新建替换规则'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _selectedDelegateRuleId != null ? () {
                            // 查看已关联的规则详情
                            final ruleId = int.tryParse(_selectedDelegateRuleId!);
                            if (ruleId != null) {
                              GoRouter.of(context).go('/settings/approval-delegate/detail/$ruleId');
                            }
                          } : null,
                          icon: const Icon(Icons.list),
                          label: const Text('查看规则详情'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '说明：选择的替换审批人规则将应用到此流程的所有审批节点，或在流程设计器中为特定节点单独配置',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 保存和取消按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // 取消操作，返回流程列表页面
                        GoRouter.of(context).go('/settings/process-design/list');
                      },
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveConfiguration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
