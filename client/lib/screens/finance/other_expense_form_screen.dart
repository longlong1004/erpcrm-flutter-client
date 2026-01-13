import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class OtherExpenseFormScreen extends StatefulWidget {
  final Map<String, dynamic>? expenseData; // 编辑模式下传入数据
  final bool isViewMode; // 查看模式标记

  const OtherExpenseFormScreen({super.key, this.expenseData, this.isViewMode = false});

  @override
  State<OtherExpenseFormScreen> createState() => _OtherExpenseFormScreenState();
}

class _OtherExpenseFormScreenState extends State<OtherExpenseFormScreen> {
  final Map<String, TextEditingController> _controllers = {
    'salesman': TextEditingController(text: '张三'), // 模拟当前登录业务员
    'number': TextEditingController(),
    'payerUnit': TextEditingController(text: '本公司'), // 模拟当前公司
    'payeeUnit': TextEditingController(text: '北京铁路运输有限公司'),
    'expenseType': TextEditingController(text: '运输费'),
    'amount': TextEditingController(text: '3000.00'),
    'remark': TextEditingController(text: '2024年2月设备运输费用'),
  };
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isViewMode = false;

  @override
  void initState() {
    super.initState();
    
    _isViewMode = widget.isViewMode;
    
    // 编辑或查看模式下填充数据
    if (widget.expenseData != null) {
      setState(() {
        _isEditing = true;
      });
      _controllers['salesman']?.text = widget.expenseData?['业务员'] ?? '';
      _controllers['number']?.text = widget.expenseData?['编号'] ?? '';
      _controllers['payerUnit']?.text = widget.expenseData?['付款单位'] ?? '';
      _controllers['payeeUnit']?.text = widget.expenseData?['收款单位'] ?? '';
      _controllers['expenseType']?.text = widget.expenseData?['支出类型'] ?? '';
      _controllers['amount']?.text = widget.expenseData?['支出金额']?.toString() ?? '';
      _controllers['remark']?.text = widget.expenseData?['备注'] ?? '';
    } else {
      // 新增模式下生成编号
      _controllers['number']?.text = 'EXP${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().millisecondsSinceEpoch % 1000}';
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // 构建支出数据
      final expenseData = {
        '业务员': _controllers['salesman']?.text,
        '编号': _controllers['number']?.text,
        '付款单位': _controllers['payerUnit']?.text,
        '收款单位': _controllers['payeeUnit']?.text,
        '支出类型': _controllers['expenseType']?.text,
        '支出金额': double.tryParse(_controllers['amount']?.text ?? '') ?? 0.0,
        '备注': _controllers['remark']?.text,
      };

      // 提交支出数据
      if (_isEditing) {
        print('更新其他支出: $expenseData');
      } else {
        print('新增其他支出: $expenseData');
      }

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? '支出更新成功' : '支出新增成功'),
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
      title: _isViewMode ? '查看其他支出' : (_isEditing ? '编辑其他支出' : '新增其他支出'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isViewMode ? '查看其他支出' : (_isEditing ? '编辑其他支出' : '新增其他支出'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 支出表单
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
                            child: _buildFormField('业务员', 'salesman', readOnly: true || _isViewMode),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('编号', 'number', readOnly: true || _isViewMode),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 付款单位和收款单位
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('付款单位', 'payerUnit', readOnly: true || _isViewMode),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('收款单位', 'payeeUnit', 
                              readOnly: _isViewMode,
                              validator: _isViewMode ? null : (value) {
                                if (value?.isEmpty ?? true) {
                                  return '收款单位不能为空';
                                }
                                return null;
                              }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 支出类型和金额
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('支出类型', 'expenseType', 
                              readOnly: _isViewMode,
                              validator: _isViewMode ? null : (value) {
                                if (value?.isEmpty ?? true) {
                                  return '支出类型不能为空';
                                }
                                return null;
                              }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('支出金额', 'amount',
                              keyboardType: TextInputType.number,
                              readOnly: _isViewMode,
                              validator: _isViewMode ? null : (value) {
                                if (value?.isEmpty ?? true) {
                                  return '支出金额不能为空';
                                }
                                if (double.tryParse(value ?? '') == null) {
                                  return '支出金额必须是数字';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 备注
                      _buildFormField('备注', 'remark', maxLines: 3, readOnly: _isViewMode),
                      const SizedBox(height: 24),
                      // 操作按钮 - 查看模式下不显示
                      if (!_isViewMode)
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
                      // 查看模式下添加返回按钮
                      if (_isViewMode)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003366),
                              ),
                              child: const Text('返回'),
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