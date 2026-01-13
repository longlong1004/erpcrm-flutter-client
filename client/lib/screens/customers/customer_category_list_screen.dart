import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/crm_provider.dart';

class CustomerCategoryListScreen extends ConsumerWidget {
  const CustomerCategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(customerCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('客户分类管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('加载失败: $error')),
        data: (categoriesList) {
          if (categoriesList.isEmpty) {
            return const Center(child: Text('暂无客户分类'));
          }

          return ListView.builder(
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              final category = categoriesList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    child: Text(category.categoryName.substring(0, 1)),
                  ),
                  title: Text(category.categoryName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('描述: ${category.description}'),
                      Text('状态: ${!category.deleted ? '启用' : '禁用'}'),
                      Text('创建时间: ${category.createTime.toString().substring(0, 19)}'),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showCategoryDialog(context, ref, category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _confirmDelete(context, ref, category.categoryId),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, [dynamic category]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.categoryName ?? '');
    final codeController = TextEditingController(text: category?.categoryCode ?? '');
    final descController = TextEditingController(text: category?.categoryDesc ?? '');
    final statusController = TextEditingController(text: category?.status.toString() ?? '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category != null ? '编辑客户分类' : '添加客户分类'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '分类名称'),
                  validator: (value) => value?.isEmpty ?? true ? '请输入分类名称' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: '分类编码'),
                  validator: (value) => value?.isEmpty ?? true ? '请输入分类编码' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: '分类描述'),
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
            child: Text(category != null ? '保存' : '添加'),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final categoryData = {
                  'categoryName': nameController.text,
                  'categoryCode': codeController.text,
                  'categoryDesc': descController.text,
                  'status': int.parse(statusController.text),
                  'parentId': 0,
                  'level': 1,
                  'sort': 0,
                };

                if (category != null) {
                  await ref.read(customerCategoriesProvider.notifier)
                      .updateCategory(category.customerCategoryId, categoryData);
                } else {
                  await ref.read(customerCategoriesProvider.notifier)
                      .createCategory(categoryData);
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
        content: const Text('确定要删除该客户分类吗？此操作不可恢复。'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await ref.read(customerCategoriesProvider.notifier).deleteCategory(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
