import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/models/procurement/procurement_application.dart';
import 'package:erpcrm_client/providers/procurement_application_provider.dart';

class ProcurementApplicationScreen extends ConsumerWidget {
  const ProcurementApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    final Map<String, TextEditingController> _controllers = {
      'salesman': TextEditingController(text: '张三'), // 模拟当前登录业务员
      'company': TextEditingController(text: '国铁科技有限公司'), // 模拟当前公司
      'materialName': TextEditingController(),
      'model': TextEditingController(),
      'quantity': TextEditingController(),
      'unitPrice': TextEditingController(),
      'unit': TextEditingController(),
    };
    double _totalAmount = 0.0;

    void _calculateTotal() {
      final quantity = double.tryParse(_controllers['quantity']?.text ?? '') ?? 0.0;
      final unitPrice = double.tryParse(_controllers['unitPrice']?.text ?? '') ?? 0.0;
      _totalAmount = quantity * unitPrice;
    }

    void _submitForm() {
      if (_formKey.currentState?.validate() ?? false) {
        _calculateTotal(); // 确保金额计算正确
        
        // 构建并保存采购申请数据
        final application = ProcurementApplication.create(
          salesman: _controllers['salesman']?.text ?? '',
          company: _controllers['company']?.text ?? '',
          materialName: _controllers['materialName']?.text ?? '',
          model: _controllers['model']?.text ?? '',
          quantity: double.tryParse(_controllers['quantity']?.text ?? '') ?? 0.0,
          unitPrice: double.tryParse(_controllers['unitPrice']?.text ?? '') ?? 0.0,
          unit: _controllers['unit']?.text ?? '',
        );

        // 保存到状态管理
        ref.read(procurementApplicationProvider.notifier).addApplication(application);

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('采购申请已提交，状态变更为待审核'),
            backgroundColor: Colors.green,
          ),
        );

        // 返回采购申请列表页
        Navigator.pop(context);
      }
    }

    return MainLayout(
      title: '新增采购申请',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '新增采购申请',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 32),
            // 表单
            Expanded(
              child: Container(
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
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 业务员
                        _buildFormField(context, _controllers, '业务员', 'salesman', 
                          readOnly: true,
                          onChanged: (_) => _calculateTotal(),
                        ),
                        const SizedBox(height: 16),
                        // 公司
                        _buildFormField(context, _controllers, '公司', 'company', 
                          readOnly: true,
                          onChanged: (_) => _calculateTotal(),
                        ),
                        const SizedBox(height: 16),
                        // 采购物资名称
                        _buildFormField(context, _controllers, '采购物资名称', 'materialName', 
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return '采购物资名称不能为空';
                            }
                            return null;
                          },
                          onChanged: (_) => _calculateTotal(),
                        ),
                        const SizedBox(height: 16),
                        // 型号
                        _buildFormField(context, _controllers, '型号', 'model', 
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return '型号不能为空';
                            }
                            return null;
                          },
                          onChanged: (_) => _calculateTotal(),
                        ),
                        const SizedBox(height: 16),
                        // 数量和单价
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(context, _controllers, '数量', 'quantity', 
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '数量不能为空';
                                  }
                                  if (double.tryParse(value ?? '') == null) {
                                    return '数量必须是数字';
                                  }
                                  return null;
                                },
                                onChanged: (_) => _calculateTotal(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(context, _controllers, '单价', 'unitPrice', 
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return '单价不能为空';
                                  }
                                  if (double.tryParse(value ?? '') == null) {
                                    return '单价必须是数字';
                                  }
                                  return null;
                                },
                                onChanged: (_) => _calculateTotal(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 单位
                        _buildFormField(context, _controllers, '单位', 'unit', 
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return '单位不能为空';
                            }
                            return null;
                          },
                          onChanged: (_) => _calculateTotal(),
                        ),
                        const SizedBox(height: 16),
                        // 金额
                        _buildFormField(context, _controllers, '金额', 'amount', 
                          readOnly: true,
                          onChanged: (_) => _calculateTotal(),
                          showAmount: true,
                          totalAmount: _totalAmount,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C757D),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  Widget _buildFormField(BuildContext context, Map<String, TextEditingController> controllers, 
    String label, String key, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool showAmount = false,
    double totalAmount = 0.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controllers[key],
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: readOnly ? '' : '请输入$label',
          ),
          validator: validator,
          onChanged: onChanged,
        ),
        // 金额字段显示计算结果
        if (showAmount)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '¥${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
          ),
      ],
    );
  }
}
