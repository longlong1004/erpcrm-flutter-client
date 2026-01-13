import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/approval_delegate_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/employee_selector.dart';

class ApprovalDelegateScreen extends ConsumerStatefulWidget {
  const ApprovalDelegateScreen({super.key});

  @override
  ConsumerState<ApprovalDelegateScreen> createState() => _ApprovalDelegateScreenState();
}

class _ApprovalDelegateScreenState extends ConsumerState<ApprovalDelegateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isAddingRule = false;
  bool _initialized = false;
  
  // 选择审核人对话框
  void _showEmployeeSelector({required bool isOriginalApprover}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isOriginalApprover ? '选择原审核人' : '选择代理审核人'),
          content: SizedBox(
            width: 800,
            height: 500,
            child: EmployeeSelector(
              mode: SelectionMode.single,
              initialSelected: [],
              onSelectionChanged: (employees) {
                if (employees.isNotEmpty) {
                  final employee = employees.first;
                  if (isOriginalApprover) {
                    ref.read(approvalDelegateFormProvider.notifier)
                        .updateOriginalApprover(employee.id, employee.name);
                  } else {
                    ref.read(approvalDelegateFormProvider.notifier)
                        .updateDelegateApprover(employee.id, employee.name);
                  }
                  Navigator.pop(context);
                }
              },
              showRefreshButton: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // 保存代理规则
  Future<void> _saveRule() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final formState = ref.read(approvalDelegateFormProvider);
        await ref.read(approvalDelegateNotifierProvider.notifier)
            .createRule(formState);
        
        setState(() {
          _isAddingRule = false;
        });
        
        ref.read(approvalDelegateFormProvider.notifier).reset();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('代理规则创建成功')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  // 切换规则状态
  Future<void> _toggleRuleStatus(int id, int currentStatus) async {
    try {
      final db = ref.read(databaseProvider);
      final rule = await db.getApprovalDelegateRuleById(id);
      if (rule != null) {
        await ref.read(approvalDelegateNotifierProvider.notifier)
            .updateRule(rule.copyWith(status: currentStatus == 1 ? 0 : 1));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('状态更新成功')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: $e')),
      );
    }
  }

  // 删除规则
  Future<void> _deleteRule(int id) async {
    try {
      await ref.read(approvalDelegateNotifierProvider.notifier).deleteRule(id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('规则删除成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(approvalDelegateNotifierProvider);
    final formState = ref.watch(approvalDelegateFormProvider);
    
    // 初始化加载数据
    if (!_initialized) {
      _initialized = true;
      ref.read(approvalDelegateNotifierProvider.notifier).fetchRules();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('替换审批人'),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isAddingRule = !_isAddingRule;
              });
            },
            child: Text(_isAddingRule ? '取消' : '添加代理规则'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加规则表单
            if (_isAddingRule)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('创建代理规则', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        
                        // 原审核人选择
                        Row(
                          children: [
                            const Text('原审核人: ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showEmployeeSelector(isOriginalApprover: true),
                                child: Text(formState.originalApproverName.isEmpty 
                                    ? '请选择原审核人' 
                                    : formState.originalApproverName),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 代理审核人选择
                        Row(
                          children: [
                            const Text('代理审核人: ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showEmployeeSelector(isOriginalApprover: false),
                                child: Text(formState.delegateApproverName.isEmpty 
                                    ? '请选择代理审核人' 
                                    : formState.delegateApproverName),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 时间范围选择
                        const Text('代理时间范围:', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DateTimePickerFormField(
                                decoration: const InputDecoration(labelText: '开始时间'),
                                initialValue: formState.startTime,
                                onChanged: (value) {
                                  if (value != null) {
                                    ref.read(approvalDelegateFormProvider.notifier)
                                        .updateTimeRange(value, formState.endTime);
                                  }
                                },
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DateTimePickerFormField(
                                decoration: const InputDecoration(labelText: '结束时间'),
                                initialValue: formState.endTime,
                                onChanged: (value) {
                                  if (value != null) {
                                    ref.read(approvalDelegateFormProvider.notifier)
                                        .updateTimeRange(formState.startTime, value);
                                  }
                                },
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 状态选择
                        Row(
                          children: [
                            const Text('状态: ', style: TextStyle(fontSize: 16)),
                            Radio<int>(
                              value: 1,
                              groupValue: formState.status,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(approvalDelegateFormProvider.notifier)
                                      .updateStatus(value);
                                }
                              },
                            ),
                            const Text('启用'),
                            const SizedBox(width: 16),
                            Radio<int>(
                              value: 0,
                              groupValue: formState.status,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(approvalDelegateFormProvider.notifier)
                                      .updateStatus(value);
                                }
                              },
                            ),
                            const Text('禁用'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 描述
                        TextFormField(
                          decoration: const InputDecoration(labelText: '描述'),
                          initialValue: formState.description,
                          onChanged: (value) {
                            ref.read(approvalDelegateFormProvider.notifier)
                                .updateDescription(value);
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // 保存按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _saveRule,
                              child: const Text('保存规则'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // 规则列表
            const Text('代理规则列表', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            Expanded(
              child: rulesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('加载失败: $error'),
                ),
                data: (rules) {
                  final activeRules = rules.where((r) => r.isDeleted == 0).toList();
                  
                  if (activeRules.isEmpty) {
                    return const Center(child: Text('暂无代理规则'));
                  }
                  
                  return ListView.builder(
                    itemCount: activeRules.length,
                    itemBuilder: (context, index) {
                      final rule = activeRules[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${rule.originalApproverName} → ${rule.delegateApproverName}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Switch(
                                    value: rule.status == 1,
                                    onChanged: (value) => _toggleRuleStatus(
                                        rule.id!, rule.status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '时间范围: ${DateFormat('yyyy-MM-dd HH:mm').format(rule.startTime)} 至 ${DateFormat('yyyy-MM-dd HH:mm').format(rule.endTime)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (rule.description != null && rule.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('描述: ${rule.description}'),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _deleteRule(rule.id!),
                                    child: const Text('删除', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 日期选择器表单字段
class DateTimePickerFormField extends StatefulWidget {
  final InputDecoration decoration;
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  const DateTimePickerFormField({
    super.key,
    required this.decoration,
    required this.initialValue,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<DateTimePickerFormField> createState() => _DateTimePickerFormFieldState();
}

class _DateTimePickerFormFieldState extends State<DateTimePickerFormField> {
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: widget.decoration,
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );
        
        if (picked != null) {
          final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
          );
          
          if (time != null) {
            final DateTime combined = DateTime(
              picked.year, picked.month, picked.day,
              time.hour, time.minute,
            );
            setState(() {
              _selectedDate = combined;
            });
            widget.onChanged(combined);
          }
        }
      },
      controller: TextEditingController(
        text: _selectedDate != null 
            ? DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!)
            : '',
      ),
    );
  }
}
