import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/unit.dart';
import 'package:erpcrm_client/providers/basic_info/unit_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class UnitScreen extends ConsumerWidget {
  const UnitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitState = ref.watch(unitProvider);
    final units = unitState.units;

    return MainLayout(
      title: '单位',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '单位',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增单位操作
                    _showUnitDialog(context, ref);
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
                    DataColumn(label: Text('单位')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: units.asMap().entries.map((entry) {
                    final index = entry.key;
                    final unit = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(unit.name)),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 查看操作
                              _showUnitDetail(context, unit);
                            },
                            child: const Text('查看'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              _showUnitDialog(context, ref, unit: unit);
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 删除操作
                              _showDeleteConfirm(context, ref, unit);
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

  void _showUnitDetail(BuildContext context, Unit unit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('单位详情'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('单位名称', unit.name),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:')),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showUnitDialog(BuildContext context, WidgetRef ref, {Unit? unit}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: unit?.name ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(unit == null ? '新增单位' : '编辑单位'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '单位'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入单位名称';
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
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newUnit = Unit(
                    id: unit?.id,
                    name: nameController.text,
                  );

                  if (unit == null) {
                    ref.read(unitProvider.notifier).addUnit(newUnit);
                  } else {
                    ref.read(unitProvider.notifier).updateUnit(newUnit);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Unit unit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除确认'),
          content: Text('确定要删除单位 "${unit.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref.read(unitProvider.notifier).deleteUnit(unit.id!);
                Navigator.pop(context);
              },
              child: const Text('删除'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}