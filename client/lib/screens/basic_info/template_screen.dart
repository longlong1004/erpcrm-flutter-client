import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/template.dart';
import 'package:erpcrm_client/providers/basic_info/template_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class TemplateScreen extends ConsumerWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateState = ref.watch(templateProvider);
    final templates = templateState.templates;
    final isLoading = templateState.isLoading;
    final error = templateState.error;

    return MainLayout(
      title: '模板',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '模板',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showTemplateForm(context, ref);
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
                          DataColumn(label: Text('模版名称')),
                          DataColumn(label: Text('关联对象')),
                          DataColumn(label: Text('创建时间')),
                          DataColumn(label: Text('更新时间')),
                          DataColumn(label: Text('操作')),
                        ],
                        rows: templates.asMap().entries.map((entry) {
                          final index = entry.key;
                          final template = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(template.name)),
                            DataCell(Text(template.associatedObject)),
                            DataCell(Text(
                              template.createdAt.toString().split(' ')[0],
                            )),
                            DataCell(Text(
                              template.updatedAt.toString().split(' ')[0],
                            )),
                            DataCell(Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // 查看操作
                                    _showTemplateDetails(context, template);
                                  },
                                  child: const Text('查看'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 编辑操作
                                    _showTemplateForm(context, ref, template);
                                  },
                                  child: const Text('编辑'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 删除操作
                                    _showDeleteDialog(context, ref, template.id);
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

  void _showTemplateDetails(BuildContext context, Template template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('模板详情 - ${template.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('模板名称:', template.name),
              _buildDetailRow('关联对象:', template.associatedObject),
              const SizedBox(height: 16),
              const Text('模板内容:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey.withOpacity(0.05),
                ),
                child: Text(template.content),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('创建时间:', template.createdAt.toString().substring(0, 19)),
              _buildDetailRow('更新时间:', template.updatedAt.toString().substring(0, 19)),
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
            width: 100,
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

  void _showTemplateForm(BuildContext context, WidgetRef ref, [Template? template]) {
    final nameController = TextEditingController(text: template?.name ?? '');
    final associatedObjectController = TextEditingController(text: template?.associatedObject ?? '');
    final contentController = TextEditingController(text: template?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template == null ? '新增模板' : '编辑模板'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '模板名称'),
                autofocus: true,
              ),
              TextField(
                controller: associatedObjectController,
                decoration: const InputDecoration(labelText: '关联对象'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '模板内容',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
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
              if (nameController.text.isEmpty || associatedObjectController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('模板名称和关联对象不能为空'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newTemplate = Template(
                id: template?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: nameController.text.trim(),
                associatedObject: associatedObjectController.text.trim(),
                content: contentController.text.trim(),
                createdAt: template?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (template == null) {
                ref.read(templateProvider.notifier).addTemplate(newTemplate);
              } else {
                ref.read(templateProvider.notifier).updateTemplate(newTemplate);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(template == null ? '模板新增成功' : '模板更新成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(template == null ? '新增' : '保存'),
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
        content: const Text('确定要删除该模板吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(templateProvider.notifier).deleteTemplate(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('模板删除成功'),
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