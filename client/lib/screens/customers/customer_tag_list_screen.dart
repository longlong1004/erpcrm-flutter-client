import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/crm_provider.dart';

class CustomerTagListScreen extends ConsumerWidget {
  const CustomerTagListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(customerTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('客户标签管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTagDialog(context, ref),
          ),
        ],
      ),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('加载失败: $error')),
        data: (tagsList) {
          if (tagsList.isEmpty) {
            return const Center(child: Text('暂无客户标签'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: tagsList.length,
            itemBuilder: (context, index) {
              final tag = tagsList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  tag.tagName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tag.status == 1 ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag.status == 1 ? '启用' : '禁用',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tag.status == 1 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '编码: ${tag.tagCode}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (tag.tagDesc.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                tag.tagDesc,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _showTagDialog(context, ref, tag),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            color: Colors.red,
                            onPressed: () => _confirmDelete(context, ref, tag.tagId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTagDialog(BuildContext context, WidgetRef ref, [dynamic tag]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: tag?.tagName ?? '');
    final codeController = TextEditingController(text: tag?.tagCode ?? '');
    final descController = TextEditingController(text: tag?.tagDesc ?? '');
    final statusController = TextEditingController(text: tag?.status.toString() ?? '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tag != null ? '编辑客户标签' : '添加客户标签'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '标签名称'),
                  validator: (value) => value?.isEmpty ?? true ? '请输入标签名称' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: '标签编码'),
                  validator: (value) => value?.isEmpty ?? true ? '请输入标签编码' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: '标签描述'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: statusController.text,
                  decoration: const InputDecoration(labelText: '状态'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('启用')),
                    DropdownMenuItem(value: '0', child: Text('禁用')),
                  ],
                  onChanged: (value) => statusController.text = value ?? '1',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(tag != null ? '保存' : '添加'),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final tagData = {
                  'tagName': nameController.text,
                  'tagCode': codeController.text,
                  'tagDesc': descController.text,
                  'status': int.parse(statusController.text),
                  'sort': 0,
                };

                if (tag != null) {
                  await ref.read(customerTagsProvider.notifier)
                      .updateTag(tag.customerTagId, tagData);
                } else {
                  await ref.read(customerTagsProvider.notifier)
                      .createTag(tagData);
                }

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除该客户标签吗？此操作不可恢复。'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await ref.read(customerTagsProvider.notifier).deleteTag(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
