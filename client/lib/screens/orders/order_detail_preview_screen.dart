import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/order/order.dart';
import 'package:erpcrm_client/providers/order_provider.dart';

class OrderDetailPreviewScreen extends ConsumerWidget {
  final int orderId;

  const OrderDetailPreviewScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('订单详情预览'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return orderAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('加载失败: $error')),
            data: (order) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 订单基础信息卡片 - 固定高度
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        height: 350, // 固定高度
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '订单基础信息',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003366),
                                ),
                              ),
                              const Divider(thickness: 1, height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoRow('订单编号', order.orderNumber),
                                  _buildInfoRow('状态', order.statusText),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoRow('提交日期', order.formattedCreatedAt),
                                  _buildInfoRow('审批日期', order.formattedUpdatedAt),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoRow('业务员', 'admin'), // 实际应从用户数据获取
                                  _buildInfoRow('总金额', order.formattedTotalAmount),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '收货信息',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF003366),
                                ),
                              ),
                              const Divider(thickness: 1, height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoRow('收货人姓名', '收货人'), // 实际应从订单数据获取
                                  _buildInfoRow('联系电话', '13800138000'), // 实际应从订单数据获取
                                ],
                              ),
                              _buildInfoRow('收货地址', order.shippingAddress ?? ''),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoRow('所属路局', '北京铁路局'), // 实际应从订单数据获取
                                  _buildInfoRow('站段', '北京站'), // 实际应从订单数据获取
                                ],
                              ),
                              _buildInfoRow('公司名称', '公司名称'), // 实际应从订单数据获取
                              const SizedBox(height: 16),
                              const Text(
                                '支付信息',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF003366),
                                ),
                              ),
                              const Divider(thickness: 1, height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoRow('付款方式', order.paymentMethod ?? ''),
                                  _buildInfoRow('付款状态', order.paymentStatusText),
                                ],
                              ),
                              _buildInfoRow('发票类型', '增值税专用发票'), // 实际应从订单数据获取
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 商品明细表格 - 填充剩余空间
                    Expanded(
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '商品明细',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003366),
                                ),
                              ),
                              const Divider(thickness: 1, height: 20),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 16,
                                    horizontalMargin: 12,
                                    dataRowHeight: 48,
                                    columns: const [
                                      DataColumn(
                                        label: Text('品牌'),
                                        numeric: false,
                                        tooltip: '商品品牌',
                                      ),
                                      DataColumn(
                                        label: Text('单品编码'),
                                        numeric: false,
                                        tooltip: '商品单品编码',
                                      ),
                                      DataColumn(
                                        label: Text('国铁名称'),
                                        numeric: false,
                                        tooltip: '商品国铁名称',
                                      ),
                                      DataColumn(
                                        label: Text('国铁型号'),
                                        numeric: false,
                                        tooltip: '商品国铁型号',
                                      ),
                                      DataColumn(
                                        label: Text('单位'),
                                        numeric: false,
                                        tooltip: '商品单位',
                                      ),
                                      DataColumn(
                                        label: Text('数量'),
                                        numeric: true,
                                        tooltip: '商品数量',
                                      ),
                                      DataColumn(
                                        label: Text('单价'),
                                        numeric: true,
                                        tooltip: '商品单价',
                                      ),
                                      DataColumn(
                                        label: Text('金额'),
                                        numeric: true,
                                        tooltip: '商品金额',
                                      ),
                                    ],
                                    rows: order.orderItems.map((item) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(item.productName)), // 品牌
                                          DataCell(Text(item.productSku)), // 单品编码
                                          DataCell(Text(item.productName)), // 国铁名称
                                          DataCell(Text(item.productSku)), // 国铁型号
                                          DataCell(const Text('件')), // 单位
                                          DataCell(Text(item.quantity.toString())), // 数量
                                          DataCell(Text(item.unitPrice.toStringAsFixed(2))), // 单价
                                          DataCell(Text(item.subtotal.toStringAsFixed(2))), // 金额
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color.fromARGB(153, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
