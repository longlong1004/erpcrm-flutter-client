import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/models/order/order.dart';
import 'package:erpcrm_client/providers/order_provider.dart';
import 'package:erpcrm_client/widgets/shortcut_key_handler.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  void onRefresh() {
    ref.read(ordersProvider.notifier).fetchOrders();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('订单数据已刷新'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '订单列表',
      child: Column(
        children: [
          Expanded(
            child: ref.watch(ordersProvider).when(
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
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('暂无订单'));
                }
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('订单号: ${order.orderNumber}'),
                        subtitle: Text('地址: ${order.shippingAddress ?? "未设置"}'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('¥${order.totalAmount.toStringAsFixed(2)}'),
                            Text('状态: ${order.status}'),
                          ],
                        ),
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
