import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/position.dart';
import 'package:erpcrm_client/providers/basic_info/position_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class PositionScreen extends ConsumerWidget {
  const PositionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionState = ref.watch(positionProvider);
    final positions = positionState.positions;
    final isLoading = positionState.isLoading;
    final error = positionState.error;

    return MainLayout(
      title: '岗位管理',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '岗位管理',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showPositionForm(context, ref);
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
                          DataColumn(label: Text('岗位名称')),
                          DataColumn(label: Text('创建时间')),
                          DataColumn(label: Text('操作')),
                        ],
                        rows: positions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final position = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(position.name)),
                            DataCell(Text(
                              position.createdAt.toString().split(' ')[0],
                            )),
                            DataCell(Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // 查看操作
                                    _showPositionDetails(context, position);
                                  },
                                  child: const Text('查看'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 编辑操作
                                    _showPositionForm(context, ref, position);
                                  },
                                  child: const Text('编辑'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 删除操作
                                    _showDeleteDialog(context, ref, position.id);
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

  void _showPositionDetails(BuildContext context, Position position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(position.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('创建时间: ${position.createdAt}'),
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

  void _showPositionForm(BuildContext context, WidgetRef ref, [Position? position]) {
    final nameController = TextEditingController(text: position?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(position == null ? '新增岗位' : '编辑岗位'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '岗位名称'),
                autofocus: true,
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('岗位名称不能为空'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newPosition = Position(
                id: position?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: nameController.text.trim(),
                createdAt: position?.createdAt ?? DateTime.now(),
              );

              if (position == null) {
                ref.read(positionProvider.notifier).addPosition(newPosition);
              } else {
                ref.read(positionProvider.notifier).updatePosition(newPosition);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(position == null ? '岗位新增成功' : '岗位更新成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(position == null ? '新增' : '保存'),
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
        content: const Text('确定要删除该岗位吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(positionProvider.notifier).deletePosition(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('岗位删除成功'),
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