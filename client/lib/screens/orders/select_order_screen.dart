import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/providers/order_provider.dart';
import 'package:erpcrm_client/models/order/order.dart';

class SelectOrderScreen extends ConsumerStatefulWidget {
  const SelectOrderScreen({super.key});

  @override
  ConsumerState<SelectOrderScreen> createState() => _SelectOrderScreenState();
}

class _SelectOrderScreenState extends ConsumerState<SelectOrderScreen> {
  final Set<int> _selectedOrderIds = {};

  void _toggleOrderSelection(int orderId) {
    setState(() {
      if (_selectedOrderIds.contains(orderId)) {
        _selectedOrderIds.remove(orderId);
      } else {
        _selectedOrderIds.add(orderId);
      }
    });
  }

  void _selectAllOrders(List<Order> orders) {
    setState(() {
      if (_selectedOrderIds.length == orders.length && orders.isNotEmpty) {
        _selectedOrderIds.clear();
      } else {
        _selectedOrderIds.clear();
        _selectedOrderIds.addAll(orders.map((order) => order.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择订单'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请选择需要关联的国铁订单',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 表格
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('加载失败: $error')),
                data: (orders) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Checkbox(
                            value: _selectedOrderIds.length == orders.length && orders.isNotEmpty,
                            onChanged: (bool? value) {
                              _selectAllOrders(orders);
                            },
                          ),
                        ),
                        const DataColumn(label: Text('订单编号')),
                        const DataColumn(label: Text('公司名称')),
                        const DataColumn(label: Text('所属路局')),
                        const DataColumn(label: Text('站段')),
                        const DataColumn(label: Text('收货人姓名')),
                        const DataColumn(label: Text('收货人电话')),
                      ],
                      rows: orders.map((order) {
                        return DataRow(cells: [
                          DataCell(Checkbox(
                            value: _selectedOrderIds.contains(order.id),
                            onChanged: (bool? value) {
                              _toggleOrderSelection(order.id);
                            },
                          )),
                          DataCell(Text(order.orderNumber)),
                          DataCell(Text('公司名称')), // 模拟数据
                          DataCell(Text('北京铁路局')), // 模拟数据
                          DataCell(Text('北京站')), // 模拟数据
                          DataCell(Text('收货人')), // 模拟数据
                          DataCell(Text('13800138000')), // 模拟数据
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedOrderIds.isEmpty
                      ? null
                      : () {
                          // 返回选中的订单ID
                          Navigator.pop(context, _selectedOrderIds.toList());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
