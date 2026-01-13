import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/department.dart';
import 'package:erpcrm_client/providers/basic_info/department_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class DepartmentScreen extends ConsumerWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentState = ref.watch(departmentProvider);
    final departments = departmentState.departments;
    final isLoading = departmentState.isLoading;
    final error = departmentState.error;

    return MainLayout(
      title: '部门管理',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '部门管理',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showDepartmentForm(context, ref);
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
            if (error != null)
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('序号')),
                          DataColumn(label: Text('部门名称')),
                          DataColumn(label: Text('负责人')),
                          DataColumn(label: Text('联系电话')),
                          DataColumn(label: Text('创建时间')),
                          DataColumn(label: Text('操作')),
                        ],
                        rows: departments.asMap().entries.map((entry) {
                          final index = entry.key;
                          final department = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(department.name)),
                            DataCell(Text(department.manager)),
                            DataCell(Text(department.phoneNumber)),
                            DataCell(Text(
                              department.createdAt.toString().split(' ')[0],
                            )),
                            DataCell(Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // 查看操作
                                    _showDepartmentDetails(context, department);
                                  },
                                  child: const Text('查看'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 编辑操作
                                    _showDepartmentForm(context, ref, department);
                                  },
                                  child: const Text('编辑'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 删除操作
                                    _showDeleteDialog(context, ref, department.id);
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

  void _showDepartmentDetails(BuildContext context, Department department) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(department.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('负责人: ${department.manager}'),
            Text('联系电话: ${department.phoneNumber}'),
            Text('创建时间: ${department.createdAt}'),
          ],
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

  void _showDepartmentForm(BuildContext context, WidgetRef ref, [Department? department]) {
    final nameController = TextEditingController(text: department?.name ?? '');
    final managerController = TextEditingController(text: department?.manager ?? '');
    final phoneController = TextEditingController(text: department?.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(department == null ? '新增部门' : '编辑部门'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '部门名称'),
                autofocus: true,
              ),
              TextField(
                controller: managerController,
                decoration: const InputDecoration(labelText: '负责人'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: '联系电话'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || managerController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('部门名称和负责人不能为空'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newDepartment = Department(
                id: department?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: nameController.text.trim(),
                manager: managerController.text.trim(),
                phoneNumber: phoneController.text.trim(),
                createdAt: department?.createdAt ?? DateTime.now(),
              );

              if (department == null) {
                ref.read(departmentProvider.notifier).addDepartment(newDepartment);
              } else {
                ref.read(departmentProvider.notifier).updateDepartment(newDepartment);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(department == null ? '部门新增成功' : '部门更新成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(department == null ? '新增' : '保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除该部门吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(departmentProvider.notifier).deleteDepartment(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('部门删除成功'),
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