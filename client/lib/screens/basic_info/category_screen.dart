import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/category.dart';
import 'package:erpcrm_client/providers/basic_info/category_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.categories;
    final isLoading = categoryState.isLoading;
    final error = categoryState.error;

    return MainLayout(
      title: '三级分类',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '三级分类',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCategoryForm(context, ref);
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
                          DataColumn(label: Text('公司名称')),
                          DataColumn(label: Text('分类')),
                          DataColumn(label: Text('上级分类')),
                          DataColumn(label: Text('创建时间')),
                          DataColumn(label: Text('操作')),
                        ],
                        rows: categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(category.companyName)),
                            DataCell(Text(category.name)),
                            DataCell(Text(category.parentId ?? '无')),
                            DataCell(Text(
                              category.createdAt.toString().split(' ')[0],
                            )),
                            DataCell(Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // 查看操作
                                    _showCategoryDetails(context, category);
                                  },
                                  child: const Text('查看'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 编辑操作
                                    _showCategoryForm(context, ref, category);
                                  },
                                  child: const Text('编辑'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 删除操作
                                    _showDeleteDialog(context, ref, category.id);
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

  void _showCategoryDetails(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('分类详情 - ${category.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('分类名称:', category.name),
              _buildDetailRow('公司名称:', category.companyName),
              _buildDetailRow('上级分类:', category.parentId ?? '无'),
              _buildDetailRow('创建时间:', category.createdAt.toString().substring(0, 19)),
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

  void _showCategoryForm(BuildContext context, WidgetRef ref, [Category? category]) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final companyNameController = TextEditingController(text: category?.companyName ?? '');
    final parentIdController = TextEditingController(text: category?.parentId ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? '新增三级分类' : '编辑三级分类'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '分类名称'),
                autofocus: true,
              ),
              TextField(
                controller: companyNameController,
                decoration: const InputDecoration(labelText: '公司名称'),
              ),
              TextField(
                controller: parentIdController,
                decoration: const InputDecoration(labelText: '上级分类ID (可选)'),
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
              if (nameController.text.isEmpty || companyNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('分类名称和公司名称不能为空'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newCategory = Category(
                id: category?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: nameController.text.trim(),
                companyName: companyNameController.text.trim(),
                parentId: parentIdController.text.trim().isEmpty ? null : parentIdController.text.trim(),
                createdAt: category?.createdAt ?? DateTime.now(),
              );

              if (category == null) {
                ref.read(categoryProvider.notifier).addCategory(newCategory);
              } else {
                ref.read(categoryProvider.notifier).updateCategory(newCategory);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(category == null ? '三级分类新增成功' : '三级分类更新成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(category == null ? '新增' : '保存'),
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
        content: const Text('确定要删除该三级分类吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(categoryProvider.notifier).deleteCategory(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('三级分类删除成功'),
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