import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class ReimbursementFormScreen extends StatefulWidget {
  final Map<String, dynamic>? reimbursementData;

  const ReimbursementFormScreen({super.key, this.reimbursementData});

  @override
  State<ReimbursementFormScreen> createState() => _ReimbursementFormScreenState();
}

class _ReimbursementFormScreenState extends State<ReimbursementFormScreen> {
  final Map<String, TextEditingController> _controllers = {
    'salesman': TextEditingController(text: '张三'), // 模拟当前登录业务员
    'status': TextEditingController(text: '待审核'),
    'reimbursementType': TextEditingController(),
    'relatedOrderNumber': TextEditingController(),
    'companyName': TextEditingController(text: '本公司'), // 模拟当前公司
    'amount': TextEditingController(),
    'voucher': TextEditingController(),
    'remark': TextEditingController(),
  };
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isViewing = false;

  @override
  void initState() {
    super.initState();
    
    // 编辑或查看模式下填充数据
    if (widget.reimbursementData != null) {
      _controllers['salesman']?.text = widget.reimbursementData?['业务员'] ?? '';
      _controllers['status']?.text = widget.reimbursementData?['状态'] ?? '';
      _controllers['reimbursementType']?.text = widget.reimbursementData?['报销类型'] ?? '';
      _controllers['relatedOrderNumber']?.text = widget.reimbursementData?['关联单号'] ?? '';
      _controllers['companyName']?.text = widget.reimbursementData?['公司名称'] ?? '';
      _controllers['amount']?.text = widget.reimbursementData?['报销金额']?.toString() ?? '';
      _controllers['voucher']?.text = widget.reimbursementData?['报销凭证'] ?? '';
      _controllers['remark']?.text = widget.reimbursementData?['备注'] ?? '';
    }
    
    // 判断是编辑还是查看模式
    if (widget.reimbursementData != null) {
      setState(() {
        _isEditing = widget.reimbursementData?['状态'] == '待审核' || widget.reimbursementData?['状态'] == '已驳回';
        _isViewing = !_isEditing;
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // 构建报销数据
      final reimbursementData = {
        '业务员': _controllers['salesman']?.text,
        '状态': '待审核',
        '报销类型': _controllers['reimbursementType']?.text,
        '关联单号': _controllers['relatedOrderNumber']?.text,
        '公司名称': _controllers['companyName']?.text,
        '报销金额': double.tryParse(_controllers['amount']?.text ?? '') ?? 0.0,
        '报销凭证': _controllers['voucher']?.text,
        '备注': _controllers['remark']?.text,
      };

      // 提交报销数据
      print('提交报销: $reimbursementData');

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('报销提交成功，已提交管理员审核'),
          backgroundColor: Colors.green,
        ),
      );

      // 返回列表页
      Navigator.pop(context);
    }
  }

  void _uploadVoucher() {
    // 模拟上传凭证
    print('上传报销凭证');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('报销凭证上传成功'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 更新凭证状态
    setState(() {
      _controllers['voucher']?.text = '已上传';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.reimbursementData == null ? '报销' : _isViewing ? '报销详情' : '编辑报销',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.reimbursementData == null ? '报销' : _isViewing ? '报销详情' : '编辑报销',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 报销表单
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
                      // 业务员和状态
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('业务员', 'salesman', readOnly: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('状态', 'status', readOnly: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 报销类型和关联单号
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('报销类型', 'reimbursementType', 
                              readOnly: _isViewing,
                              validator: _isViewing ? null : (value) {
                                if (value?.isEmpty ?? true) {
                                  return '报销类型不能为空';
                                }
                                return null;
                              }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('关联单号', 'relatedOrderNumber', 
                              readOnly: _isViewing,
                              validator: _isViewing ? null : (value) {
                                if (value?.isEmpty ?? true) {
                                  return '关联单号不能为空';
                                }
                                return null;
                              }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 公司名称和报销金额
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('公司名称', 'companyName', readOnly: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('报销金额', 'amount',
                              keyboardType: TextInputType.number,
                              readOnly: _isViewing,
                              validator: _isViewing ? null : (value) {
                                if (value?.isEmpty ?? true) {
                                  return '报销金额不能为空';
                                }
                                if (double.tryParse(value ?? '') == null) {
                                  return '报销金额必须是数字';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 报销凭证
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('报销凭证', 'voucher', readOnly: true),
                          ),
                          const SizedBox(width: 16),
                          if (!_isViewing)
                            ElevatedButton.icon(
                              onPressed: _uploadVoucher,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('上传凭证'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003366),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 备注
                      _buildFormField('备注', 'remark', maxLines: 3, readOnly: _isViewing),
                      const SizedBox(height: 24),
                      // 操作按钮
                      if (!_isViewing)
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
                      if (_isViewing)
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
