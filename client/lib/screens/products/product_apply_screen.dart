import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/models/product/product.dart';
import 'package:erpcrm_client/providers/product_provider.dart';

class ProductApplyScreen extends ConsumerWidget {
  const ProductApplyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      title: '产品申请',
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('申请新产品'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ref.watch(productsProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('加载失败: $error'),
                  ],
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('暂无产品'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text('状态: ${product.status}'),
                        trailing: Text('¥${product.price.toStringAsFixed(2)}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
