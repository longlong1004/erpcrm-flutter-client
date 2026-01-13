import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/supplier_info.dart';
import 'package:erpcrm_client/providers/basic_info/supplier_info_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class SupplierInfoScreen extends ConsumerWidget {
  const SupplierInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierState = ref.watch(supplierInfoProvider);
    final suppliers = supplierState.suppliers;

    return MainLayout(
      title: '供应商信息',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '供应商信息',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增供应商信息操作
                    _showSupplierDialog(context, ref);
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
                    DataColumn(label: Text('业务员')),
                    DataColumn(label: Text('供应商名称')),
                    DataColumn(label: Text('联系人')),
                    DataColumn(label: Text('联系电话')),
                    DataColumn(label: Text('备注')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: suppliers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final supplier = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(supplier.salesperson)),
                      DataCell(Text(supplier.supplierName)),
                      DataCell(Text(supplier.contactPerson)),
                      DataCell(Text(supplier.contactPhone)),
                      DataCell(Text(supplier.remarks ?? '')),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 查看操作
                              _showSupplierDetail(context, supplier);
                            },
                            child: const Text('查看'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              _showSupplierDialog(context, ref, supplier: supplier);
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 删除操作
                              _showDeleteConfirm(context, ref, supplier);
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

  void _showSupplierDetail(BuildContext context, SupplierInfo supplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('供应商信息详情'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('业务员', supplier.salesperson),
                _buildDetailRow('供应商名称', supplier.supplierName),
                _buildDetailRow('联系人', supplier.contactPerson),
                _buildDetailRow('联系电话', supplier.contactPhone),
                _buildDetailRow('备注', supplier.remarks ?? '无'),
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

  void _showSupplierDialog(BuildContext context, WidgetRef ref, {SupplierInfo? supplier}) {
    final formKey = GlobalKey<FormState>();
    final salespersonController = TextEditingController(text: supplier?.salesperson ?? '');
    final supplierNameController = TextEditingController(text: supplier?.supplierName ?? '');
    final contactPersonController = TextEditingController(text: supplier?.contactPerson ?? '');
    final contactPhoneController = TextEditingController(text: supplier?.contactPhone ?? '');
    final remarksController = TextEditingController(text: supplier?.remarks ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(supplier == null ? '新增供应商信息' : '编辑供应商信息'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: salespersonController,
                    decoration: const InputDecoration(labelText: '业务员'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入业务员';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: supplierNameController,
                    decoration: const InputDecoration(labelText: '供应商名称'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入供应商名称';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: contactPersonController,
                    decoration: const InputDecoration(labelText: '联系人'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入联系人';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: contactPhoneController,
                    decoration: const InputDecoration(labelText: '联系电话'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入联系电话';
                      }
                      // 简单的电话格式验证
                      final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return '请输入有效的联系电话';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: remarksController,
                    decoration: const InputDecoration(labelText: '备注'),
                    maxLines: 3,
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
                  final newSupplier = SupplierInfo(
                    id: supplier?.id,
                    salesperson: salespersonController.text,
                    supplierName: supplierNameController.text,
                    contactPerson: contactPersonController.text,
                    contactPhone: contactPhoneController.text,
                    remarks: remarksController.text.isEmpty ? null : remarksController.text,
                  );

                  if (supplier == null) {
                    ref.read(supplierInfoProvider.notifier).addSupplier(newSupplier);
                  } else {
                    ref.read(supplierInfoProvider.notifier).updateSupplier(newSupplier);
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

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, SupplierInfo supplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除确认'),
          content: Text('确定要删除供应商 "${supplier.supplierName}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref.read(supplierInfoProvider.notifier).deleteSupplier(supplier.id!);
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