import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/crm/contact_record.dart';
import '../../providers/crm_provider.dart';

class CustomerContactLogListScreen extends ConsumerStatefulWidget {
  final int customerId;
  final String customerName;

  const CustomerContactLogListScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  ConsumerState<CustomerContactLogListScreen> createState() =>
      _CustomerContactLogListScreenState();
}

class _CustomerContactLogListScreenState
    extends ConsumerState<CustomerContactLogListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactPersonController = TextEditingController();
  final _contactTypeController = TextEditingController();
  final _contactContentController = TextEditingController();

  ContactRecord? _editingLog;

  @override
  void initState() {
    super.initState();
    // 初始化时加载客户的联系记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(contactRecordsProvider.notifier)
          .getContactRecordsByCustomer(widget.customerId);
    });
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    _contactTypeController.dispose();
    _contactContentController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _contactPersonController.clear();
    _contactTypeController.clear();
    _contactContentController.clear();
    _editingLog = null;
  }

  void _openAddEditDialog([ContactRecord? log]) {
    _clearForm();
    _editingLog = log;

    if (log != null) {
      _contactPersonController.text = log.contactPerson;
      _contactTypeController.text = log.contactType;
      _contactContentController.text = log.contactContent;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log == null ? '添加联系记录' : '编辑联系记录'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(labelText: '联系人'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? '请输入联系人' : null,
                ),
                TextFormField(
                  controller: _contactTypeController,
                  decoration: const InputDecoration(labelText: '联系类型'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? '请输入联系类型' : null,
                ),
                TextFormField(
                  controller: _contactContentController,
                  decoration: const InputDecoration(labelText: '联系内容'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? '请输入联系内容' : null,
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
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final logData = {
                  'customerId': widget.customerId,
                  'contactPerson': _contactPersonController.text,
                  'contactType': _contactTypeController.text,
                  'contactContent': _contactContentController.text,
                };

                try {
                  if (_editingLog != null) {
                    await ref
                        .read(contactRecordsProvider.notifier)
                        .updateContactRecord(
                          _editingLog!.recordId,
                          logData,
                        );
                  } else {
                    await ref
                        .read(contactRecordsProvider.notifier)
                        .createContactRecord(logData);
                  }
                  Navigator.pop(context);
                  _clearForm();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('操作失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ContactRecord log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这条联系记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(contactRecordsProvider.notifier)
                    .deleteContactRecord(log.recordId);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('删除失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(contactRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.customerName} - 联系记录',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003366),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        iconTheme: const IconThemeData(color: Color(0xFF003366)),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _openAddEditDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加记录'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003366),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(contactRecordsProvider.notifier)
            .getContactRecordsByCustomer(widget.customerId),
        color: const Color(0xFF003366),
        backgroundColor: Colors.white,
        child: logsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(
                color: Color(0xFF003366),
              ),
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败: $error',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(contactRecordsProvider.notifier)
                      .getContactRecordsByCustomer(widget.customerId),
                  child: const Text('重试'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        size: 64,
                        color: Color(0xFFE0E0E0),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '暂无联系记录',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF999999),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '点击右上角"添加记录"按钮开始记录客户联系情况',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () => _openAddEditDialog(log),
                            hoverColor: const Color(0xFFF5F5F5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        log.contactPerson,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF003366),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _confirmDelete(log),
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        tooltip: '删除',
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6F2FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          log.contactType,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF003366),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '联系时间: ${log.contactDate}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    log.contactContent,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF333333),
                                      lineHeight: 1.5,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  if (log.nextContactPlan.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '下次联系计划: ${log.nextContactPlan}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (index < logs.length - 1)
                            const Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Color(0xFFE0E0E0),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
