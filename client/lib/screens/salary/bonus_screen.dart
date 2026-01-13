import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/salary/bonus.dart';
import 'package:erpcrm_client/providers/bonus_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/salary_menu.dart';

class BonusScreen extends ConsumerWidget {
  const BonusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonusState = ref.watch(bonusProvider);

    return MainLayout(
      title: '其它奖金',
      topContent: const SalaryMenu(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '其它奖金',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAddBonusDialog(context, ref);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('新增'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showBonusStatisticsDialog(context, ref);
                      },
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('统计'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: bonusState.status == BonusStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : bonusState.status == BonusStatus.error
                      ? Center(child: Text('加载失败: ${bonusState.errorMessage}'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('业务员')),
                              DataColumn(label: Text('日期')),
                              DataColumn(label: Text('奖金')),
                              DataColumn(label: Text('状态')),
                              DataColumn(label: Text('操作')),
                            ],
                            rows: bonusState.bonusList
                                .map((bonus) => DataRow(cells: [
                                      DataCell(Text(bonus.employeeName)),
                                      DataCell(Text(
                                          '${bonus.date.year}-${bonus.date.month.toString().padLeft(2, '0')}')),
                                      DataCell(Text(bonus.amount.toStringAsFixed(2))),
                                      DataCell(Text(bonus.status)),
                                      DataCell(Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              _showBonusDetailDialog(context, bonus);
                                            },
                                            child: const Text('查看'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (bonus.status == '待审批') {
                                                _showDeleteConfirmDialog(context, ref, bonus);
                                              }
                                            },
                                            child: Text(
                                              '删除',
                                              style: TextStyle(
                                                  color: bonus.status == '待审批'
                                                      ? Colors.red
                                                      : Colors.grey),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ]))
                                .toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBonusDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final employeeNameController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController(text: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}');
    final purposeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增奖金'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: employeeNameController,
                    decoration: const InputDecoration(labelText: '业务员'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入业务员姓名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: '奖金金额'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入奖金金额';
                      }
                      if (double.tryParse(value) == null) {
                        return '请输入有效的数字';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: '发放时间'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入发放时间';
                      }
                      // 简单验证日期格式 YYYY-MM
                      final regex = RegExp(r'^\d{4}-\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return '请输入有效的日期格式 (YYYY-MM)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: purposeController,
                    decoration: const InputDecoration(labelText: '奖金事由'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入奖金事由';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final bonus = Bonus(
                    employeeName: employeeNameController.text,
                    amount: double.parse(amountController.text),
                    date: DateTime.parse('${dateController.text}-01'),
                    purpose: purposeController.text,
                  );
                  
                  // 保存当前上下文中需要的对象
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  
                  try {
                    // 使用状态管理保存奖金
                    await ref.read(bonusProvider.notifier).createBonus(bonus);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('奖金申请提交成功')),
                    );
                    navigator.pop();
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('提交失败: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('提交'),
            ),
          ],
        );
      },
    );
  }

  void _showBonusDetailDialog(BuildContext context, Bonus bonus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('奖金详情'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('业务员', bonus.employeeName),
                _buildDetailItem('金额', bonus.amount.toString()),
                _buildDetailItem('发放时间', bonus.date.toString()),
                _buildDetailItem('事由', bonus.purpose),
              ],
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Bonus bonus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除${bonus.employeeName}的奖金申请吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (bonus.id != null) {
                  // 保存当前上下文中需要的对象
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  
                  try {
                    await ref.read(bonusProvider.notifier).deleteBonus(bonus.id!);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('删除成功')),
                    );
                    navigator.pop();
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('删除失败: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  // 奖金统计对话框
  void _showBonusStatisticsDialog(BuildContext context, WidgetRef ref) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('奖金统计'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: startDateController,
                    decoration: const InputDecoration(
                      labelText: '开始时间',
                      hintText: 'YYYY-MM',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入开始时间';
                      }
                      final regex = RegExp(r'^\d{4}-\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return '请输入有效的日期格式 (YYYY-MM)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: endDateController,
                    decoration: const InputDecoration(
                      labelText: '结束时间',
                      hintText: 'YYYY-MM',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入结束时间';
                      }
                      final regex = RegExp(r'^\d{4}-\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return '请输入有效的日期格式 (YYYY-MM)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  // 保存当前上下文中需要的对象
                  final currentContext = context;
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  try {
                    final statistics = await ref
                        .read(bonusProvider.notifier)
                        .getBonusStatistics(
                          startDate: '${startDateController.text}-01',
                          endDate: '${endDateController.text}-28',
                        );
                    
                    // 显示统计结果
                    _showStatisticsResultDialog(currentContext, statistics);
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('统计失败: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('查询'),
            ),
          ],
        );
      },
    );
  }

  // 统计结果对话框
  void _showStatisticsResultDialog(BuildContext context, Map<String, dynamic> statistics) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('统计结果'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('总奖金金额', statistics['totalAmount']?.toString() ?? '0.00'),
                _buildDetailItem('平均奖金', statistics['averageAmount']?.toString() ?? '0.00'),
                _buildDetailItem('最高奖金', statistics['maxAmount']?.toString() ?? '0.00'),
                _buildDetailItem('最低奖金', statistics['minAmount']?.toString() ?? '0.00'),
                _buildDetailItem('奖金额度范围',
                    '${statistics['minAmount']?.toString() ?? '0.00'} - ${statistics['maxAmount']?.toString() ?? '0.00'}'),
                _buildDetailItem('总人数', statistics['totalPeople']?.toString() ?? '0'),
              ],
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
}