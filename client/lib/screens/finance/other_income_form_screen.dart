import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class OtherIncomeFormScreen extends StatefulWidget {
  final Map<String, dynamic>? incomeData; // 编辑模式下传入数据

  const OtherIncomeFormScreen({super.key, this.incomeData});

  @override
  State<OtherIncomeFormScreen> createState() => _OtherIncomeFormScreenState();
}

class _OtherIncomeFormScreenState extends State<OtherIncomeFormScreen> {
  final Map<String, TextEditingController> _controllers = {
    'salesman': TextEditingController(text: '张三'), // 模拟当前登录业务员
    'number': TextEditingController(),
    'payerUnit': TextEditingController(text: '北京铁路局'),
    'payeeUnit': TextEditingController(text: '本公司'), // 模拟当前公司
    'incomeType': TextEditingController(text: '服务费'),
    'amount': TextEditingController(text: '5000.00'),
    'remark': TextEditingController(text: '2024年第一季度服务费用'),
  };
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    // 编辑模式下填充数据
    if (widget.incomeData != null) {
      setState(() {
        _isEditing = true;
      });
      _controllers['salesman']?.text = widget.incomeData?['业务员'] ?? '';
      _controllers['number']?.text = widget.incomeData?['编号'] ?? '';
      _controllers['payerUnit']?.text = widget.incomeData?['付款单位'] ?? '';
      _controllers['payeeUnit']?.text = widget.incomeData?['收款单位'] ?? '';
      _controllers['incomeType']?.text = widget.incomeData?['收入类型'] ?? '';
      _controllers['amount']?.text = widget.incomeData?['收款金额']?.toString() ?? '';
      _controllers['remark']?.text = widget.incomeData?['备注'] ?? '';
    } else {
      // 新增模式下生成编号
      _controllers['number']?.text = 'INC${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().millisecondsSinceEpoch % 1000}';
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // 构建收入数据
      final incomeData = {
        '业务员': _controllers['salesman']?.text,
        '编号': _controllers['number']?.text,
        '付款单位': _controllers['payerUnit']?.text,
        '收款单位': _controllers['payeeUnit']?.text,
        '收入类型': _controllers['incomeType']?.text,
        '收款金额': double.tryParse(_controllers['amount']?.text ?? '') ?? 0.0,
        '备注': _controllers['remark']?.text,
      };

      // 提交收入数据
      if (_isEditing) {
        print('更新其他收入: $incomeData');
      } else {
        print('新增其他收入: $incomeData');
      }

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? '收入更新成功' : '收入新增成功'),
          backgroundColor: Colors.green,
        ),
      );

      // 返回列表页
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: _isEditing ? '编辑其他收入' : '新增其他收入',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? '编辑其他收入' : '新增其他收入',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 收入表单
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
                      // 业务员和编号
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('业务员', 'salesman', readOnly: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('编号', 'number', readOnly: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 付款单位和收款单位
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('付款单位', 'payerUnit', validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '付款单位不能为空';
                              }
                              return null;
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('收款单位', 'payeeUnit', readOnly: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 收入类型和金额
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('收入类型', 'incomeType', validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '收入类型不能为空';
                              }
                              return null;
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('收款金额', 'amount',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return '收款金额不能为空';
                                }
                                if (double.tryParse(value ?? '') == null) {
                                  return '收款金额必须是数字';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 备注
                      _buildFormField('备注', 'remark', maxLines: 3),
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
                            child: Text(_isEditing ? '保存' : '保存'),
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
    bool readOnly = false,
    int maxLines = 1,
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
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade50 : null,
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
