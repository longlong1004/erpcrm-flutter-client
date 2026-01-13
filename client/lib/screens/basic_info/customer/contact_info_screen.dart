import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/contact_info.dart';
import 'package:erpcrm_client/providers/basic_info/contact_info_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class ContactInfoScreen extends ConsumerWidget {
  const ContactInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(contactInfoProvider);
    final contacts = contactState.contacts;

    return MainLayout(
      title: '客户联系方式',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '客户联系方式',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增客户联系方式操作
                    _showContactDialog(context, ref);
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
                    DataColumn(label: Text('路局')),
                    DataColumn(label: Text('站段')),
                    DataColumn(label: Text('联系人')),
                    DataColumn(label: Text('联系电话')),
                    DataColumn(label: Text('科室')),
                    DataColumn(label: Text('职位')),
                    DataColumn(label: Text('备注')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: contacts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final contact = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(contact.salesperson)),
                      DataCell(Text(contact.railwayBureau)),
                      DataCell(Text(contact.station)),
                      DataCell(Text(contact.contactPerson)),
                      DataCell(Text(contact.contactPhone)),
                      DataCell(Text(contact.department)),
                      DataCell(Text(contact.position)),
                      DataCell(Text(contact.remarks ?? '')),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 查看操作
                              _showContactDetail(context, contact);
                            },
                            child: const Text('查看'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              _showContactDialog(context, ref, contact: contact);
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 删除操作
                              _showDeleteConfirm(context, ref, contact);
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

  void _showContactDetail(BuildContext context, ContactInfo contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('客户联系方式详情'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('业务员', contact.salesperson),
                _buildDetailRow('路局', contact.railwayBureau),
                _buildDetailRow('站段', contact.station),
                _buildDetailRow('联系人', contact.contactPerson),
                _buildDetailRow('联系电话', contact.contactPhone),
                _buildDetailRow('科室', contact.department),
                _buildDetailRow('职位', contact.position),
                _buildDetailRow('备注', contact.remarks ?? '无'),
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

  void _showContactDialog(BuildContext context, WidgetRef ref, {ContactInfo? contact}) {
    final formKey = GlobalKey<FormState>();
    final salespersonController = TextEditingController(text: contact?.salesperson ?? '');
    final railwayBureauController = TextEditingController(text: contact?.railwayBureau ?? '');
    final stationController = TextEditingController(text: contact?.station ?? '');
    final contactPersonController = TextEditingController(text: contact?.contactPerson ?? '');
    final contactPhoneController = TextEditingController(text: contact?.contactPhone ?? '');
    final departmentController = TextEditingController(text: contact?.department ?? '');
    final positionController = TextEditingController(text: contact?.position ?? '');
    final remarksController = TextEditingController(text: contact?.remarks ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contact == null ? '新增客户联系方式' : '编辑客户联系方式'),
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
                    controller: railwayBureauController,
                    decoration: const InputDecoration(labelText: '路局'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入路局';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: stationController,
                    decoration: const InputDecoration(labelText: '站段'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入站段';
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
                    controller: departmentController,
                    decoration: const InputDecoration(labelText: '科室'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入科室';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: positionController,
                    decoration: const InputDecoration(labelText: '职位'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入职位';
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
                  final newContact = ContactInfo(
                    id: contact?.id,
                    salesperson: salespersonController.text,
                    railwayBureau: railwayBureauController.text,
                    station: stationController.text,
                    contactPerson: contactPersonController.text,
                    contactPhone: contactPhoneController.text,
                    department: departmentController.text,
                    position: positionController.text,
                    remarks: remarksController.text.isEmpty ? null : remarksController.text,
                  );

                  if (contact == null) {
                    ref.read(contactInfoProvider.notifier).addContact(newContact);
                  } else {
                    ref.read(contactInfoProvider.notifier).updateContact(newContact);
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

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, ContactInfo contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除确认'),
          content: Text('确定要删除客户联系方式 "${contact.contactPerson} - ${contact.contactPhone}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref.read(contactInfoProvider.notifier).deleteContact(contact.id!);
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