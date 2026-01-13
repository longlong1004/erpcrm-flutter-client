import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/order/order.dart';
import 'package:erpcrm_client/providers/order_provider.dart';

class OrderDeliveryScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDeliveryScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDeliveryScreen> createState() => _OrderDeliveryScreenState();
}

class _OrderDeliveryScreenState extends ConsumerState<OrderDeliveryScreen> {
  late Order _currentOrder;
  bool _isEditing = false;
  bool _hasChanges = false;

  // 表单控制器
  late TextEditingController _actualNameController;
  late TextEditingController _actualModelController;
  late TextEditingController _actualUnitController;
  late TextEditingController _actualQuantityController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _supplierController;
  late TextEditingController _prepaymentRatioController;
  late TextEditingController _prepaymentAmountController;
  late TextEditingController _invoiceTypeController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _actualNameController = TextEditingController();
    _actualModelController = TextEditingController();
    _actualUnitController = TextEditingController();
    _actualQuantityController = TextEditingController();
    _paymentMethodController = TextEditingController();
    _supplierController = TextEditingController();
    _prepaymentRatioController = TextEditingController();
    _prepaymentAmountController = TextEditingController();
    _invoiceTypeController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _loadOrderData(Order order) {
    _currentOrder = order;
    
    // 初始化表单数据
    final firstItem = order.orderItems.isNotEmpty ? order.orderItems.first : null;
    _actualNameController.text = firstItem?.productName ?? '';
    _actualModelController.text = firstItem?.productSku ?? '';
    _actualUnitController.text = '件';
    _actualQuantityController.text = order.orderItems.length.toString();
    _paymentMethodController.text = order.paymentMethod ?? '在线支付';
    _supplierController.text = '供应商';
    _prepaymentRatioController.text = '0';
    _prepaymentAmountController.text = '0';
    _invoiceTypeController.text = '增值税专用发票';
    _notesController.text = order.notes ?? '';
  }

  @override
  void dispose() {
    _actualNameController.dispose();
    _actualModelController.dispose();
    _actualUnitController.dispose();
    _actualQuantityController.dispose();
    _paymentMethodController.dispose();
    _supplierController.dispose();
    _prepaymentRatioController.dispose();
    _prepaymentAmountController.dispose();
    _invoiceTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('订单发货'),
        backgroundColor: const Color(0xFF003366),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                _cancelEditing();
              },
              child: const Text(
                '取消编辑',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                _saveChanges();
              },
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
                // 订单基础数据卡片
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
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.5,
                          children: [
                            _buildInfoItem('订单编号', order.orderNumber),
                            _buildInfoItem('收货人姓名', '收货人'),
                            _buildInfoItem('联系电话', '13800138000'),
                            _buildInfoItem('收货地址', order.shippingAddress ?? ''),
                            _buildInfoItem('所属路局', '北京铁路局'),
                            _buildInfoItem('站段', '北京站'),
                            _buildInfoItem('公司名称', '公司名称'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 订单详细数据表格
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '订单详细数据',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const Divider(thickness: 1, height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1600, // 设置足够宽的宽度，避免水平滚动
                            child: DataTable(
                              columnSpacing: 16,
                              horizontalMargin: 12,
                              dataRowHeight: 60,
                              columns: const [
                                DataColumn(label: Text('匹配类型')),
                                DataColumn(label: Text('品牌')),
                                DataColumn(label: Text('单品编码')),
                                DataColumn(label: Text('国铁名称')),
                                DataColumn(label: Text('国铁型号')),
                                DataColumn(label: Text('单位')),
                                DataColumn(label: Text('数量')),
                                DataColumn(label: Text('单价')),
                                DataColumn(label: Text('金额')),
                                DataColumn(label: Text('实发名称')),
                                DataColumn(label: Text('实发型号')),
                                DataColumn(label: Text('实发单位')),
                                DataColumn(label: Text('采购单价')),
                                DataColumn(label: Text('库存数量')),
                                DataColumn(label: Text('实发数量')),
                                DataColumn(label: Text('付款方式')),
                                DataColumn(label: Text('供应商')),
                                DataColumn(label: Text('预付比例')),
                                DataColumn(label: Text('预付金额')),
                                DataColumn(label: Text('发票类型')),
                                DataColumn(label: Text('小计')),
                                DataColumn(label: Text('备注')),
                                DataColumn(label: Text('操作')),
                              ],
                              rows: _currentOrder.orderItems.map((item) {
                                return DataRow(cells: [
                                  const DataCell(Text('完全匹配')),
                                  DataCell(Text(item.productName)),
                                  DataCell(Text(item.productSku)),
                                  DataCell(Text(item.productName)),
                                  DataCell(Text(item.productSku)),
                                  const DataCell(Text('件')),
                                  DataCell(Text(item.quantity.toString())),
                                  DataCell(Text(item.unitPrice.toStringAsFixed(2))),
                                  DataCell(Text(item.subtotal.toStringAsFixed(2))),
                                  DataCell(TextField(
                                    controller: _actualNameController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextField(
                                    controller: _actualModelController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextField(
                                    controller: _actualUnitController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  const DataCell(Text('100.00')),
                                  const DataCell(Text('100')),
                                  DataCell(TextField(
                                    controller: _actualQuantityController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextField(
                                    controller: _paymentMethodController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextField(
                                    controller: _supplierController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextField(
                                    controller: _prepaymentRatioController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextField(
                                    controller: _prepaymentAmountController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextField(
                                    controller: _invoiceTypeController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(Text(item.subtotal.toStringAsFixed(2))),
                                  DataCell(TextField(
                                    controller: _notesController,
                                    enabled: _isEditing,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                                  DataCell(TextButton(
                                    onPressed: () {
                                      _requestModify();
                                    },
                                    child: const Text('申请修改'),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
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
                        _cancelDelivery();
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
                        _saveDraft();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('保存'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _submitForApproval();
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('提交'),
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 申请修改
  void _requestModify() {
    setState(() {
      _isEditing = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已进入编辑模式，修改后请点击保存或提交'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 取消编辑
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _hasChanges = false;
    });
    
    // 重置表单数据
    _loadOrderData(_currentOrder);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已取消编辑'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // 保存草稿
  void _saveDraft() {
    setState(() {
      _isEditing = false;
      _hasChanges = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已保存草稿'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 实际项目中应该保存到本地或服务器
    Navigator.pop(context);
  }

  // 提交审批
  void _submitForApproval() {
    // 显示提交确认对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交审批'),
        content: const Text('您确定要提交此订单进行审批吗？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performSubmit();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 执行提交操作
  void _performSubmit() {
    // 实际项目中应该提交到服务器
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已提交审批，等待管理员审核'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }

  // 取消发货
  void _cancelDelivery() {
    if (_hasChanges) {
      // 有未保存的更改，显示确认对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认取消'),
          content: const Text('您有未保存的更改，确定要取消吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('继续编辑'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('确定取消'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // 保存更改
  void _saveChanges() {
    setState(() {
      _isEditing = false;
      _hasChanges = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已保存更改'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
