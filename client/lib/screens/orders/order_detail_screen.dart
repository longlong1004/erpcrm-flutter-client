import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/order/order.dart';
import '../../models/order/order_item.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 加载订单详情
    ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId);
  }

  void _updateOrderStatus(Order order, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新订单状态'),
        content: Text('确定要将订单 ${order.orderNumber} 的状态更新为 ${Order.getStatusText(newStatus)} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(orderServiceProvider).updateOrderStatus(order.id, newStatus);
                ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('订单状态已更新'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('更新失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _updatePaymentStatus(Order order, String newPaymentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新支付状态'),
        content: Text('确定要将订单 ${order.orderNumber} 的支付状态更新为 ${Order.getPaymentStatusText(newPaymentStatus)} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(orderServiceProvider).updatePaymentStatus(order.id, newPaymentStatus);
                ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('支付状态已更新'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('更新失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消订单'),
        content: Text('确定要取消订单 ${order.orderNumber} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(orderServiceProvider).cancelOrder(order.id);
                ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('订单已取消'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('取消失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showStatusSelectionDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择新状态'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Order.statusOptions
                .map(
                  (status) => ListTile(
                    title: Text(Order.getStatusText(status)),
                    onTap: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order, status);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showPaymentStatusSelectionDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择新支付状态'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Order.paymentStatusOptions
                .map(
                  (status) => ListTile(
                    title: Text(Order.getPaymentStatusText(status)),
                    onTap: () {
                      Navigator.pop(context);
                      _updatePaymentStatus(order, status);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片占位符
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_cart, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? '未知商品',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (item.productSku != null)
                    Text(
                      'SKU: ${item.productSku}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '数量: ${item.quantity}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '单价: ¥${item.unitPrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              '¥${item.subtotal?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('订单详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId),
            tooltip: '刷新',
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: $error'),
              ElevatedButton(
                onPressed: () => ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('订单不存在'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 订单基本信息
                _buildOrderInfoCard(
                  '订单基本信息',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('订单号:'),
                          Text(
                            order.orderNumber ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('用户ID:'),
                          Text(order.userId.toString()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('创建时间:'),
                          Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('更新时间:'),
                          Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(order.updatedAt)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('订单状态:'),
                          Text(
                            Order.getStatusText(order.status),
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('支付状态:'),
                          Text(
                            Order.getPaymentStatusText(order.paymentStatus),
                            style: TextStyle(
                              color: _getPaymentStatusColor(order.paymentStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('支付方式:'),
                          Text(order.paymentMethod ?? '未指定'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('配送方式:'),
                          Text(order.shippingMethod ?? '未指定'),
                        ],
                      ),
                      if (order.trackingNumber != null)
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('运单号:'),
                            Text(order.trackingNumber!),
                          ],
                        ),
                      if (order.notes != null)
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('备注:'),
                            Expanded(
                              child: Text(
                                order.notes!,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // 配送地址信息
                _buildOrderInfoCard(
                  '配送信息',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '配送地址:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(order.shippingAddress ?? '未填写'),
                      const SizedBox(height: 12),
                      Text(
                        '账单地址:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(order.billingAddress ?? '未填写'),
                    ],
                  ),
                ),

                // 订单商品列表
                _buildOrderInfoCard(
                  '商品列表',
                  Column(
                    children: [
                      ...order.orderItems!.map(_buildOrderItem).toList(),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 96),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('商品总数:'),
                                const SizedBox(width: 8),
                                Text(
                                  '${order.orderItems!.length} 件',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('订单总金额:'),
                                const SizedBox(width: 8),
                                Text(
                                  '¥${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 订单操作
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (order.status != 'COMPLETED' && order.status != 'CANCELED')
                        ElevatedButton(
                          onPressed: () => _showStatusSelectionDialog(order),
                          child: const Text('更新订单状态'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _showPaymentStatusSelectionDialog(order),
                        child: const Text('更新支付状态'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      ),
                      if (order.status == 'PENDING')
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _cancelOrder(order),
                          child: const Text('取消订单'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PAID':
        return Colors.blue;
      case 'SHIPPED':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.redAccent;
      default:
        return Colors.black;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'UNPAID':
        return Colors.red;
      case 'PAID':
        return Colors.green;
      case 'REFUNDED':
        return Colors.redAccent;
      case 'PARTIALLY_REFUNDED':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
