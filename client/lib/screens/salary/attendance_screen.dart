import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/salary_menu.dart';
import 'package:erpcrm_client/providers/attendance_provider.dart';
import 'package:erpcrm_client/models/salary/attendance.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);
    final attendanceList = attendanceState.attendanceList;
    final status = attendanceState.status;
    final isLoading = status == AttendanceStatus.loading;

    return MainLayout(
      title: '考勤',
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
                  '考勤',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // 新增考勤操作
                        _showAddAttendanceDialog(context, ref);
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
                        // 统计考勤操作
                        _showAttendanceStatistics(context, ref);
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
                        await ref.refresh(attendanceProvider.notifier).loadAttendanceList(isRefresh: true);
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('业务员')),
                            DataColumn(label: Text('状态')),
                            DataColumn(label: Text('日期')),
                            DataColumn(label: Text('上班时间')),
                            DataColumn(label: Text('下班时间')),
                            DataColumn(label: Text('描述')),
                            DataColumn(label: Text('操作')),
                          ],
                          rows: attendanceList.map((attendance) {
                            return DataRow(cells: [
                              DataCell(Text(attendance.employeeName)),
                              DataCell(
                                Chip(
                                  label: Text(_getStatusLabel(attendance.status)),
                                  backgroundColor: _getStatusColor(attendance.status),
                                  labelStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(Text(attendance.date.toString().substring(0, 10))),
                              DataCell(Text(attendance.checkInTime ?? '-')),
                              DataCell(Text(attendance.checkOutTime ?? '-')),
                              DataCell(Text(attendance.description ?? '-')),
                              DataCell(Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // 查看操作
                                      _showAttendanceDetailDialog(context, attendance);
                                    },
                                    child: const Text('查看'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 编辑操作
                                      _showEditAttendanceDialog(context, ref, attendance);
                                    },
                                    child: const Text('编辑'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 删除操作
                                      _showDeleteConfirmDialog(context, ref, attendance.id!);
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

  // 显示新增考勤对话框
  void _showAddAttendanceDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final employeeNameController = TextEditingController();
    final statusController = TextEditingController(text: '正常');
    final dateController = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final checkInController = TextEditingController();
    final checkOutController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增考勤'),
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
                    value: '正常',
                    decoration: const InputDecoration(labelText: '状态'),
                    items: const [
                      DropdownMenuItem(value: '正常', child: Text('正常')),
                      DropdownMenuItem(value: '迟到', child: Text('迟到')),
                      DropdownMenuItem(value: '早退', child: Text('早退')),
                      DropdownMenuItem(value: '旷工', child: Text('旷工')),
                      DropdownMenuItem(value: '请假', child: Text('请假')),
                      DropdownMenuItem(value: '加班', child: Text('加班')),
                    ],
                    onChanged: (value) {
                      statusController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: '日期'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        dateController.text = date.toString().substring(0, 10);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: checkInController,
                    decoration: const InputDecoration(
                      labelText: '上班时间',
                      hintText: 'HH:mm',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: checkOutController,
                    decoration: const InputDecoration(
                      labelText: '下班时间',
                      hintText: 'HH:mm',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '描述'),
                    maxLines: 2,
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
                  final attendance = Attendance(
                    employeeName: employeeNameController.text,
                    status: statusController.text,
                    date: DateTime.parse(dateController.text),
                    checkInTime: checkInController.text.isEmpty ? null : checkInController.text,
                    checkOutTime: checkOutController.text.isEmpty ? null : checkOutController.text,
                    description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  );
                  ref.read(attendanceProvider.notifier).createAttendance(attendance);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  // 显示编辑考勤对话框
  void _showEditAttendanceDialog(BuildContext context, WidgetRef ref, Attendance attendance) {
    final formKey = GlobalKey<FormState>();
    final employeeNameController = TextEditingController(text: attendance.employeeName);
    final statusController = TextEditingController(text: attendance.status);
    final dateController = TextEditingController(text: attendance.date.toString().substring(0, 10));
    final checkInController = TextEditingController(text: attendance.checkInTime ?? '');
    final checkOutController = TextEditingController(text: attendance.checkOutTime ?? '');
    final descriptionController = TextEditingController(text: attendance.description ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑考勤'),
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
                    value: attendance.status,
                    decoration: const InputDecoration(labelText: '状态'),
                    items: const [
                      DropdownMenuItem(value: '正常', child: Text('正常')),
                      DropdownMenuItem(value: '迟到', child: Text('迟到')),
                      DropdownMenuItem(value: '早退', child: Text('早退')),
                      DropdownMenuItem(value: '旷工', child: Text('旷工')),
                      DropdownMenuItem(value: '请假', child: Text('请假')),
                      DropdownMenuItem(value: '加班', child: Text('加班')),
                    ],
                    onChanged: (value) {
                      statusController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: '日期'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: attendance.date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        dateController.text = date.toString().substring(0, 10);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: checkInController,
                    decoration: const InputDecoration(
                      labelText: '上班时间',
                      hintText: 'HH:mm',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: checkOutController,
                    decoration: const InputDecoration(
                      labelText: '下班时间',
                      hintText: 'HH:mm',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '描述'),
                    maxLines: 2,
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
                  final updatedAttendance = attendance.copyWith(
                    employeeName: employeeNameController.text,
                    status: statusController.text,
                    date: DateTime.parse(dateController.text),
                    checkInTime: checkInController.text.isEmpty ? null : checkInController.text,
                    checkOutTime: checkOutController.text.isEmpty ? null : checkOutController.text,
                    description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  );
                  ref.read(attendanceProvider.notifier).updateAttendance(attendance.id!, updatedAttendance);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  // 显示考勤详情对话框
  void _showAttendanceDetailDialog(BuildContext context, Attendance attendance) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('考勤详情'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('业务员', attendance.employeeName),
                _buildDetailItem('状态', _getStatusLabel(attendance.status)),
                _buildDetailItem('日期', attendance.date.toString().substring(0, 10)),
                _buildDetailItem('上班时间', attendance.checkInTime ?? '-'),
                _buildDetailItem('下班时间', attendance.checkOutTime ?? '-'),
                _buildDetailItem('描述', attendance.description ?? '-'),
                _buildDetailItem('创建时间', attendance.createdAt.toString()),
                _buildDetailItem('更新时间', attendance.updatedAt.toString()),
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
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int attendanceId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这条考勤记录吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(attendanceProvider.notifier).deleteAttendance(attendanceId);
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

  // 显示考勤统计对话框
  void _showAttendanceStatistics(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('考勤统计'),
          content: const Text('考勤统计功能开发中...'),
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
      case 'normal':
        return '正常';
      case 'late':
        return '迟到';
      case 'early_leave':
        return '早退';
      case 'absent':
        return '旷工';
      case 'leave':
        return '请假';
      case 'overtime':
        return '加班';
      default:
        return status;
    }
  }

  // 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'early_leave':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'leave':
        return Colors.blue;
      case 'overtime':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
