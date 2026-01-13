import 'package:flutter/material.dart';

class OrderDeleteDialog extends StatelessWidget {
  final int count;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const OrderDeleteDialog({
    super.key,
    required this.count,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('确认删除'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '您确定要删除${count > 1 ? '这$count条订单' : '这条订单'}吗？',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '此操作不可恢复，请谨慎处理。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('取消'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('确认删除'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}
