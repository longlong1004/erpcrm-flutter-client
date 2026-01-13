import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class InvoiceInputScreen extends StatefulWidget {
  const InvoiceInputScreen({super.key});

  @override
  State<InvoiceInputScreen> createState() => _InvoiceInputScreenState();
}

class _InvoiceInputScreenState extends State<InvoiceInputScreen> {
  final Map<String, TextEditingController> _controllers = {
    'invoiceCode': TextEditingController(),
    'invoiceNumber': TextEditingController(),
    'invoiceDate': TextEditingController(),
    'buyerName': TextEditingController(),
    'sellerName': TextEditingController(),
    'productAmount': TextEditingController(),
    'amount': TextEditingController(),
    'taxAmount': TextEditingController(),
    'totalAmount': TextEditingController(),
  };
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // 构建发票数据
      final invoiceData = {
        '发票代码': _controllers['invoiceCode']?.text,
        '发票号码': _controllers['invoiceNumber']?.text,
        '开票日期': _controllers['invoiceDate']?.text,
        '购方名称': _controllers['buyerName']?.text,
        '销方名称': _controllers['sellerName']?.text,
        '商品金额': _controllers['productAmount']?.text,
        '金额': _controllers['amount']?.text,
        '税额': _controllers['taxAmount']?.text,
        '价税合计': _controllers['totalAmount']?.text,
      };

      // 提交发票数据
      print('提交发票录入: $invoiceData');

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('发票录入成功，已保存到本地'),
          backgroundColor: Colors.green,
        ),
      );

      // 返回上一页
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '发票录入',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '发票录入',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 录入表单
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 发票代码和发票号码
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('发票代码', 'invoiceCode', validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '发票代码不能为空';
                              }
                              return null;
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('发票号码', 'invoiceNumber', validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '发票号码不能为空';
                              }
                              return null;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 开票日期
                      _buildFormField('开票日期', 'invoiceDate', validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return '开票日期不能为空';
                        }
                        return null;
                      }),
                      const SizedBox(height: 16),
                      // 购方名称和销方名称
                      _buildFormField('购方名称', 'buyerName', validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return '购方名称不能为空';
                        }
                        return null;
                      }),
                      const SizedBox(height: 16),
                      _buildFormField('销方名称', 'sellerName', validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return '销方名称不能为空';
                        }
                        return null;
                      }),
                      const SizedBox(height: 16),
                      // 商品金额、金额和税额
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('商品金额', 'productAmount',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return '商品金额不能为空';
                                }
                                if (double.tryParse(value ?? '') == null) {
                                  return '商品金额必须是数字';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('金额', 'amount',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return '金额不能为空';
                                }
                                if (double.tryParse(value ?? '') == null) {
                                  return '金额必须是数字';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('税额', 'taxAmount',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return '税额不能为空';
                                }
                                if (double.tryParse(value ?? '') == null) {
                                  return '税额必须是数字';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 价税合计
                      _buildFormField('价税合计', 'totalAmount',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '价税合计不能为空';
                          }
                          if (double.tryParse(value ?? '') == null) {
                            return '价税合计必须是数字';
                          }
                          return null;
                        },
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
                            ),
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF107C10),
                            ),
                            child: const Text('保存'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String key, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
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
          controller: _controllers[key],
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
