import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/salary_menu.dart';
import 'package:erpcrm_client/models/salary/point.dart';
import 'package:erpcrm_client/providers/point_provider.dart';

class PointsScreen extends ConsumerWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointState = ref.watch(pointProvider);
    final pointList = pointState.pointList;
    final isLoading = pointState.status == PointStatus.loading;

    return MainLayout(
      title: '积分',
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
                  '积分',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // 新增积分操作
                        _showAddPointDialog(context, ref);
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
                        // 统计积分
                        _showPointStatistics(context, ref);
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(pointProvider.notifier).refreshPointList();
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('业务员')),
                            DataColumn(label: Text('剩余积分')),
                            DataColumn(label: Text('积分变动')),
                            DataColumn(label: Text('变动事由')),
                            DataColumn(label: Text('变动时间')),
                            DataColumn(label: Text('操作')),
                          ],
                          rows: pointList.map((point) {
                            return DataRow(cells: [
                              DataCell(Text(point.employeeName)),
                              DataCell(Text(point.points.toString())),
                              DataCell(Text(
                                point.changeAmount > 0
                                    ? '+${point.changeAmount}'
                                    : '${point.changeAmount}',
                                style: TextStyle(
                                  color: point.changeAmount > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              )),
                              DataCell(Text(point.reason)),
                              DataCell(Text(point.date.toString().substring(0, 16))),
                              DataCell(Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // 查看操作
                                      _showPointDetailDialog(context, point);
                                    },
                                    child: const Text('查看'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 编辑操作
                                      _showEditPointDialog(context, ref, point);
                                    },
                                    child: const Text('编辑'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 删除操作
                                      _showDeleteConfirmDialog(context, ref, point.id!);
                                    },
                                    child: const Text('删除', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示新增积分对话框
  void _showAddPointDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final employeeNameController = TextEditingController();
    final pointsController = TextEditingController();
    final changeAmountController = TextEditingController();
    final reasonController = TextEditingController();
    final dateController = TextEditingController(
      text: DateTime.now().toString().substring(0, 16),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增积分'),
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
                    controller: pointsController,
                    decoration: const InputDecoration(labelText: '剩余积分'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入剩余积分';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: changeAmountController,
                    decoration: const InputDecoration(labelText: '积分变动'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入积分变动';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(labelText: '变动事由'),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入变动事由';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: '变动时间'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final dateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          dateController.text = dateTime.toString().substring(0, 16);
                        }
                      }
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
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final point = Point(
                    employeeName: employeeNameController.text,
                    points: double.parse(pointsController.text),
                    changeAmount: double.parse(changeAmountController.text),
                    reason: reasonController.text,
                    date: DateTime.parse(dateController.text),
                  );
                  ref.read(pointProvider.notifier).createPoint(point);
                  Navigator.pop(context);
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

  // 显示编辑积分对话框
  void _showEditPointDialog(BuildContext context, WidgetRef ref, Point point) {
    final formKey = GlobalKey<FormState>();
    final employeeNameController = TextEditingController(text: point.employeeName);
    final pointsController = TextEditingController(text: point.points.toString());
    final changeAmountController = TextEditingController(text: point.changeAmount.toString());
    final reasonController = TextEditingController(text: point.reason);
    final dateController = TextEditingController(
      text: point.date.toString().substring(0, 16),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑积分'),
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
                    controller: pointsController,
                    decoration: const InputDecoration(labelText: '剩余积分'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入剩余积分';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: changeAmountController,
                    decoration: const InputDecoration(labelText: '积分变动'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入积分变动';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(labelText: '变动事由'),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入变动事由';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: '变动时间'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: point.date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(point.date),
                        );
                        if (time != null) {
                          final dateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          dateController.text = dateTime.toString().substring(0, 16);
                        }
                      }
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
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final updatedPoint = point.copyWith(
                    employeeName: employeeNameController.text,
                    points: double.parse(pointsController.text),
                    changeAmount: double.parse(changeAmountController.text),
                    reason: reasonController.text,
                    date: DateTime.parse(dateController.text),
                  );
                  ref.read(pointProvider.notifier).updatePoint(point.id!, updatedPoint);
                  Navigator.pop(context);
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

  // 显示积分详情对话框
  void _showPointDetailDialog(BuildContext context, Point point) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('积分详情'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('业务员', point.employeeName),
                _buildDetailItem('剩余积分', point.points.toString()),
                _buildDetailItem(
                  '积分变动',
                  point.changeAmount > 0
                      ? '+${point.changeAmount}'
                      : '${point.changeAmount}',
                ),
                _buildDetailItem('变动事由', point.reason),
                _buildDetailItem('变动时间', point.date.toString()),
                _buildDetailItem('创建时间', point.createdAt.toString()),
                _buildDetailItem('更新时间', point.updatedAt.toString()),
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

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int pointId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这条积分记录吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(pointProvider.notifier).deletePoint(pointId);
                Navigator.pop(context);
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

  // 显示积分统计对话框
  void _showPointStatistics(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('积分统计'),
          content: const Text('积分统计功能开发中...'),
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

  // 构建详情项
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}