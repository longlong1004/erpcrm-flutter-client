import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'employee_form_screen.dart';
import '../../providers/employee_provider.dart';

class EmployeeInfoScreen extends ConsumerWidget {
  const EmployeeInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeeProvider);
    final employeeNotifier = ref.read(employeeProvider.notifier);

    return MainLayout(
      title: '员工信息',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '员工信息',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增员工信息操作
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeFormScreen(
                          onSave: (employee) {
                            employeeNotifier.addEmployee(employee);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('员工信息新增成功'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('新增'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('序号')),
                    DataColumn(label: Text('登录账号')),
                    DataColumn(label: Text('业务员')),
                    DataColumn(label: Text('联系方式')),
                    DataColumn(label: Text('所属部门')),
                    DataColumn(label: Text('所属岗位')),
                    DataColumn(label: Text('创建时间')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: employees.asMap().entries.map((entry) {
                    final index = entry.key;
                    final employee = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(employee.username)),
                      DataCell(Text(employee.name)),
                      DataCell(Text(employee.phoneNumber)),
                      DataCell(Text(employee.department)),
                      DataCell(Text(employee.position)),
                      DataCell(Text(employee.createdAt.toString().substring(0, 19))),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 查看操作
                              _showEmployeeDetails(context, employee);
                            },
                            child: const Text('查看'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeFormScreen(
                                    employee: employee,
                                    onSave: (updatedEmployee) {
                                      employeeNotifier.editEmployee(updatedEmployee);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('员工信息编辑成功'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 删除操作
                              _showDeleteDialog(context, employeeNotifier, employee);
                            },
                            child: const Text('删除'),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示员工详情
  void _showEmployeeDetails(BuildContext context, dynamic employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('员工详情 - ${employee.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('登录账号:', employee.username),
              _buildDetailRow('姓名:', employee.name),
              _buildDetailRow('联系方式:', employee.phoneNumber),
              _buildDetailRow('所属部门:', employee.department),
              _buildDetailRow('所属岗位:', employee.position),
              _buildDetailRow('创建时间:', employee.createdAt.toString().substring(0, 19)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
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

  // 显示删除确认对话框
  void _showDeleteDialog(BuildContext context, dynamic employeeNotifier, dynamic employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除员工 "${employee.name}" 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              employeeNotifier.deleteEmployee(employee.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('员工信息删除成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}