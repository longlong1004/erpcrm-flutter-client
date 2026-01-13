import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/screens/businesses/product_selection_screen.dart';

class PreDeliveryAddScreen extends StatefulWidget {
  const PreDeliveryAddScreen({super.key});

  @override
  State<PreDeliveryAddScreen> createState() => _PreDeliveryAddScreenState();
}

class _PreDeliveryAddScreenState extends State<PreDeliveryAddScreen> {
  // 基础数据控制器
  final Map<String, TextEditingController> _basicControllers = {
    'salesman': TextEditingController(text: '张三'), // 模拟当前登录业务员
    'railwayBureau': TextEditingController(),
    'stationSection': TextEditingController(),
    'customer': TextEditingController(),
    'totalAmount': TextEditingController(text: '0.0'),
    'deliveryMethod': TextEditingController(),
  };
  
  // 订单详情列表
  List<Map<String, dynamic>> _orderDetails = [];
  
  @override
  void dispose() {
    _basicControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _selectProduct(String productType) async {
    // 跳转到商品选择页面
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(productType: productType),
      ),
    );
    
    // 处理返回的选中商品
    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        _orderDetails.addAll(result);
        // 更新合计金额
        final total = _orderDetails.fold(0.0, (sum, item) => sum + (item['金额'] ?? 0.0));
        _basicControllers['totalAmount']?.text = total.toString();
      });
    }
  }

  void _submitForm() {
    // 提交审核
    print('提交审核');
    print('基础数据: ${_basicControllers.map((key, value) => MapEntry(key, value.text))}');
    print('订单详情: $_orderDetails');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('提交成功，已推送至管理员审核'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 返回上一页
    Navigator.pop(context);
  }

  void _saveForm() {
    // 保存到本地
    print('保存到本地');
    print('基础数据: ${_basicControllers.map((key, value) => MapEntry(key, value.text))}');
    print('订单详情: $_orderDetails');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('保存成功'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 返回上一页
    Navigator.pop(context);
  }

  void _cancel() {
    // 返回上一页
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '新增先发货订单',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '新增先发货订单',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 左上角按钮
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectProduct('existing'),
                  icon: const Icon(Icons.search),
                  label: const Text('现有国铁编码'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _selectProduct('unfinished'),
                  icon: const Icon(Icons.add),
                  label: const Text('未完成新增商品'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 基础数据
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基础数据',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // 业务员、所属路局、所属站段
                    Row(
                      children: [
                        Expanded(
                          child: _buildBasicField('业务员', 'salesman', readOnly: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBasicField('所属路局', 'railwayBureau'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBasicField('所属站段', 'stationSection'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 客户、合计金额、发货方式
                    Row(
                      children: [
                        Expanded(
                          child: _buildBasicField('客户', 'customer'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBasicField('合计金额', 'totalAmount', readOnly: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBasicField('发货方式', 'deliveryMethod'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 订单详细数据
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '订单详细数据',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // 订单详情表格
                    SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
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
                          rows: _orderDetails.map((detail) => DataRow(cells: [
                            DataCell(Text(detail['单品编码'] ?? '')),
                            DataCell(Text(detail['国铁名称'] ?? '')),
                            DataCell(Text(detail['国铁型号'] ?? '')),
                            DataCell(Text(detail['单位'] ?? '')),
                            DataCell(Text(detail['数量']?.toString() ?? '')),
                            DataCell(Text(detail['单价']?.toString() ?? '')),
                            DataCell(Text(detail['金额']?.toString() ?? '')),
                            DataCell(Text(detail['实发名称'] ?? '')),
                            DataCell(Text(detail['实发型号'] ?? '')),
                            DataCell(Text(detail['实发单位'] ?? '')),
                            DataCell(Text(detail['采购单价']?.toString() ?? '')),
                            DataCell(Text(detail['库存数量']?.toString() ?? '')),
                            DataCell(Text(detail['实发数量']?.toString() ?? '')),
                            DataCell(Text(detail['付款方式'] ?? '')),
                            DataCell(Text(detail['供应商'] ?? '')),
                            DataCell(Text(detail['预付比例']?.toString() ?? '')),
                            DataCell(Text(detail['预付金额']?.toString() ?? '')),
                            DataCell(Text(detail['发票类型'] ?? '')),
                            DataCell(Text(detail['小计']?.toString() ?? '')),
                            DataCell(Text(detail['备注'] ?? '')),
                            DataCell(IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _orderDetails.remove(detail);
                                  // 更新合计金额
                                  final total = _orderDetails.fold(0.0, (sum, item) => sum + (item['金额'] ?? 0.0));
                                  _basicControllers['totalAmount']?.text = total.toString();
                                });
                              },
                            )),
                          ])).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 底部操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _cancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C757D),
                  ),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107C10),
                  ),
                  child: const Text('保存'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                  child: const Text('提交'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicField(String label, String key, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _basicControllers[key],
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade50 : null,
          ),
        ),
      ],
    );
  }
}
