import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/order/order.dart';
import 'package:erpcrm_client/providers/order_provider.dart';

class OrderEditScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderEditScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends ConsumerState<OrderEditScreen> {
  late TextEditingController _orderNumberController;
  late TextEditingController _consigneeNameController;
  late TextEditingController _consigneePhoneController;
  late TextEditingController _shippingAddressController;
  late TextEditingController _railwayBureauController;
  late TextEditingController _stationController;
  late TextEditingController _companyNameController;
  late TextEditingController _supplierController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _invoiceTypeController;
  late TextEditingController _notesController;

  String _status = 'PENDING';
  String _paymentStatus = 'UNPAID';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _orderNumberController = TextEditingController();
    _consigneeNameController = TextEditingController();
    _consigneePhoneController = TextEditingController();
    _shippingAddressController = TextEditingController();
    _railwayBureauController = TextEditingController();
    _stationController = TextEditingController();
    _companyNameController = TextEditingController();
    _supplierController = TextEditingController();
    _paymentMethodController = TextEditingController();
    _invoiceTypeController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _loadOrderData(Order order) {
    _orderNumberController.text = order.orderNumber;
    _consigneeNameController.text = '收货人'; // 实际应从订单数据获取
    _consigneePhoneController.text = '13800138000'; // 实际应从订单数据获取
    _shippingAddressController.text = order.shippingAddress ?? '';
    _railwayBureauController.text = '北京铁路局'; // 实际应从订单数据获取
    _stationController.text = '北京站'; // 实际应从订单数据获取
    _companyNameController.text = '公司名称'; // 实际应从订单数据获取
    _supplierController.text = '供应商'; // 实际应从订单数据获取
    _paymentMethodController.text = order.paymentMethod ?? '';
    _invoiceTypeController.text = '增值税专用发票'; // 实际应从订单数据获取
    _notesController.text = order.notes ?? '';
    _status = order.status;
    _paymentStatus = order.paymentStatus ?? 'UNPAID';
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _consigneeNameController.dispose();
    _consigneePhoneController.dispose();
    _shippingAddressController.dispose();
    _railwayBureauController.dispose();
    _stationController.dispose();
    _companyNameController.dispose();
    _supplierController.dispose();
    _paymentMethodController.dispose();
    _invoiceTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑订单'),
        backgroundColor: const Color(0xFF003366),
        actions: [
          TextButton(
            onPressed: () {
              _saveOrder(ref);
            },
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (order) {
          _loadOrderData(order);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
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
                        _buildTextField('订单编号', _orderNumberController, false),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                '订单状态',
                                _status,
                                ['PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED'],
                                (value) {
                                  setState(() {
                                    _status = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField(
                                '支付状态',
                                _paymentStatus,
                                ['UNPAID', 'PAID', 'REFUNDED', 'PARTIALLY_REFUNDED'],
                                (value) {
                                  setState(() {
                                    _paymentStatus = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '收货信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const Divider(thickness: 1, height: 20),
                        _buildTextField('收货人姓名', _consigneeNameController, true),
                        const SizedBox(height: 12),
                        _buildTextField('收货人电话', _consigneePhoneController, true),
                        const SizedBox(height: 12),
                        _buildTextField('收货地址', _shippingAddressController, true, maxLines: 3),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField('所属路局', _railwayBureauController, true),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField('站段', _stationController, true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField('公司名称', _companyNameController, true),
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '支付和供应商信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const Divider(thickness: 1, height: 20),
                        _buildTextField('供应商', _supplierController, true),
                        const SizedBox(height: 12),
                        _buildTextField('付款方式', _paymentMethodController, true),
                        const SizedBox(height: 12),
                        _buildTextField('发票类型', _invoiceTypeController, true),
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '备注信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const Divider(thickness: 1, height: 20),
                        _buildTextField('备注', _notesController, true, maxLines: 4),
                      ],
                    ),
                  ),
                ),

                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('取消'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _saveOrder(ref);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('保存'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool enabled,
    {int maxLines = 1}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  void _saveOrder(WidgetRef ref) {
    // 构建更新的订单数据
    final orderData = {
      'orderNumber': _orderNumberController.text,
      'status': _status,
      'paymentStatus': _paymentStatus,
      'shippingAddress': _shippingAddressController.text,
      'paymentMethod': _paymentMethodController.text,
      'notes': _notesController.text,
      // 其他字段可以根据需要添加
    };

    // 更新订单
    ref.read(orderProvider(widget.orderId).notifier).updateOrder(orderData);

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('订单保存成功'),
        backgroundColor: Colors.green,
      ),
    );

    // 返回上一页
    Navigator.pop(context);
  }
}
