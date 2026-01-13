import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/salary_menu.dart';
import 'package:erpcrm_client/providers/leave_provider.dart';
import 'package:erpcrm_client/models/salary/leave.dart';

class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveState = ref.watch(leaveProvider);
    final leaveList = leaveState.leaveList;
    final status = leaveState.status;
    final isLoading = status == LeaveStatus.loading;

    return MainLayout(
      title: '请假',
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
                  '请假',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 申请请假操作
                    _showApplyLeaveDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('申请'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.refresh(leaveProvider.notifier).loadLeaveList(isRefresh: true);
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('业务员')),
                            DataColumn(label: Text('状态')),
                            DataColumn(label: Text('请假类型')),
                            DataColumn(label: Text('开始时间')),
                            DataColumn(label: Text('结束时间')),
                            DataColumn(label: Text('请假理由')),
                            DataColumn(label: Text('操作')),
                          ],
                          rows: leaveList.map((leave) {
                            return DataRow(cells: [
                              DataCell(Text(leave.employeeName)),
                              DataCell(
                                Chip(
                                  label: Text(_getStatusLabel(leave.status)),
                                  backgroundColor: _getStatusColor(leave.status),
                                  labelStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(Text(leave.leaveType)),
                              DataCell(Text(leave.startTime.toString().substring(0, 16))),
                              DataCell(Text(leave.endTime.toString().substring(0, 16))),
                              DataCell(Text(leave.reason, maxLines: 2, overflow: TextOverflow.ellipsis)),
                              DataCell(Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // 查看操作
                                      _showLeaveDetailDialog(context, leave);
                                    },
                                    child: const Text('查看'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 撤回操作
                                      _showWithdrawConfirmDialog(context, ref, leave.id!);
                                    },
                                    child: const Text('撤回'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 删除操作
                                      _showDeleteConfirmDialog(context, ref, leave.id!);
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

  // 显示申请请假对话框
  void _showApplyLeaveDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final employeeNameController = TextEditingController();
    final leaveTypeController = TextEditingController(text: '事假');
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final reasonController = TextEditingController();

    // 设置默认时间
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    startTimeController.text = now.toString().substring(0, 16);
    endTimeController.text = tomorrow.toString().substring(0, 16);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('申请请假'),
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
                  DropdownButtonFormField<String>(
                    value: '事假',
                    decoration: const InputDecoration(labelText: '请假类型'),
                    items: const [
                      DropdownMenuItem(value: '事假', child: Text('事假')),
                      DropdownMenuItem(value: '病假', child: Text('病假')),
                      DropdownMenuItem(value: '年假', child: Text('年假')),
                      DropdownMenuItem(value: '婚假', child: Text('婚假')),
                      DropdownMenuItem(value: '产假', child: Text('产假')),
                      DropdownMenuItem(value: '丧假', child: Text('丧假')),
                      DropdownMenuItem(value: '调休', child: Text('调休')),
                    ],
                    onChanged: (value) {
                      leaveTypeController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: startTimeController,
                    decoration: const InputDecoration(labelText: '开始时间'),
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
                          final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          startTimeController.text = dateTime.toString().substring(0, 16);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: endTimeController,
                    decoration: const InputDecoration(labelText: '结束时间'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          endTimeController.text = dateTime.toString().substring(0, 16);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(labelText: '请假理由'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入请假理由';
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
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final leave = Leave(
                    employeeName: employeeNameController.text,
                    status: '待审核',
                    leaveType: leaveTypeController.text,
                    startTime: DateTime.parse(startTimeController.text),
                    endTime: DateTime.parse(endTimeController.text),
                    reason: reasonController.text,
                  );
                  ref.read(leaveProvider.notifier).createLeave(leave);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('提交申请'),
            ),
          ],
        );
      },
    );
  }

  // 显示请假详情对话框
  void _showLeaveDetailDialog(BuildContext context, Leave leave) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('请假详情'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('业务员', leave.employeeName),
                _buildDetailItem('状态', _getStatusLabel(leave.status)),
                _buildDetailItem('请假类型', leave.leaveType),
                _buildDetailItem('开始时间', leave.startTime.toString()),
                _buildDetailItem('结束时间', leave.endTime.toString()),
                _buildDetailItem('请假理由', leave.reason),
                _buildDetailItem('审批意见', leave.approvalComment ?? '-'),
                _buildDetailItem('创建时间', leave.createdAt.toString()),
                _buildDetailItem('更新时间', leave.updatedAt.toString()),
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

  // 显示撤回确认对话框
  void _showWithdrawConfirmDialog(BuildContext context, WidgetRef ref, int leaveId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认撤回'),
          content: const Text('确定要撤回这条请假申请吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(leaveProvider.notifier).withdrawLeave(leaveId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('撤回'),
            ),
          ],
        );
      },
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int leaveId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这条请假申请吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(leaveProvider.notifier).deleteLeave(leaveId);
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // 获取状态标签
  String _getStatusLabel(String status) {
    switch (status) {
      case '待审核':
        return '待审核';
      case '已通过':
        return '已通过';
      case '已拒绝':
        return '已拒绝';
      case '已撤回':
        return '已撤回';
      default:
        return status;
    }
  }

  // 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '待审核':
        return Colors.yellow;
      case '已通过':
        return Colors.green;
      case '已拒绝':
        return Colors.red;
      case '已撤回':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
