import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:erpcrm_client/providers/finance_provider.dart';

class OtherExpenseModal extends ConsumerStatefulWidget {
  final Map<String, dynamic>? expenseData; // 编辑/查看模式下传入数据
  final bool isViewMode; // 查看模式标记
  final Function()? onRefresh; // 刷新列表回调

  const OtherExpenseModal({
    super.key,
    this.expenseData,
    this.isViewMode = false,
    this.onRefresh,
  });

  @override
  ConsumerState<OtherExpenseModal> createState() => _OtherExpenseModalState();
}

class _OtherExpenseModalState extends ConsumerState<OtherExpenseModal> {
  final Map<String, TextEditingController> _controllers = {
    'salesman': TextEditingController(text: '张三'), // 模拟当前登录业务员
    'number': TextEditingController(),
    'payerUnit': TextEditingController(text: '本公司'), // 模拟当前公司
    'payeeUnit': TextEditingController(),
    'expenseType': TextEditingController(),
    'amount': TextEditingController(),
    'remark': TextEditingController(),
  };

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isViewMode = false;
  bool _hasChanges = false;

  // 支出类型选项
  final List<String> _expenseTypes = [
    '办公费用',
    '差旅费',
    '招待费',
    '运输费',
    '水电费',
    '房租',
    '其他',
  ];

  // 业务员选项
  final List<String> _salesmen = [
    '张三',
    '李四',
    '王五',
    '赵六',
  ];

  @override
  void initState() {
    super.initState();
    _isViewMode = widget.isViewMode;

    // 编辑或查看模式下填充数据
    if (widget.expenseData != null) {
      _isEditing = true;
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

    // 监听输入变化
    _controllers.forEach((key, controller) {
      controller.addListener(() {
        setState(() {
          _hasChanges = true;
        });
      });
    });
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
        'id': widget.expenseData?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        '业务员': _controllers['salesman']?.text ?? '',
        '编号': _controllers['number']?.text ?? '',
        '付款单位': _controllers['payerUnit']?.text ?? '',
        '收款单位': _controllers['payeeUnit']?.text ?? '',
        '支出类型': _controllers['expenseType']?.text ?? '',
        '支出金额': double.tryParse(_controllers['amount']?.text ?? '') ?? 0.0,
        '备注': _controllers['remark']?.text ?? '',
        'createdAt': widget.expenseData?['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // 保存到本地存储
      _saveToLocalStorage(expenseData);

      // 调用状态管理更新数据
      final financeNotifier = ref.read(financeNotifierProvider.notifier);
      if (_isEditing) {
        financeNotifier.updateFinanceData(
          FinanceDataType.expenseOther,
          expenseData['id'] as String,
          expenseData,
        );
      } else {
        financeNotifier.addFinanceData(
          FinanceDataType.expenseOther,
          expenseData,
        );
      }

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? '支出更新成功' : '支出新增成功'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // 关闭窗口并刷新列表
      widget.onRefresh?.call();
      Navigator.pop(context);
    }
  }

  void _saveToLocalStorage(Map<String, dynamic> expenseData) {
    try {
      // 使用Hive保存数据
      final box = Hive.box('otherExpenses');
      box.put(expenseData['id'], expenseData);
    } catch (e) {
      print('保存到本地失败: $e');
    }
  }

  void _handleCancel() {
    if (_hasChanges && !_isViewMode) {
      // 有未保存修改，二次确认
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认取消'),
          content: const Text('您有未保存的修改，确定要取消吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭确认对话框
              },
              child: const Text('继续编辑'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭确认对话框
                Navigator.pop(context); // 关闭表单窗口
              },
              child: const Text('确定取消'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // 验证金额是否为正数且保留两位小数
  String? _validateAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return '支出金额不能为空';
    }
    final amount = double.tryParse(value ?? '');
    if (amount == null) {
      return '请输入有效的数字';
    }
    if (amount <= 0) {
      return '支出金额必须大于0';
    }
    // 检查小数位数
    final parts = value?.split('.');
    if (parts != null && parts.length > 1 && parts[1].length > 2) {
      return '支出金额最多保留两位小数';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 计算模态窗口的最大高度，确保在不同屏幕尺寸下都能自适应
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final maxWidth = MediaQuery.of(context).size.width * 0.8;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          minWidth: 600,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  _isViewMode ? '查看其他支出记录' : (_isEditing ? '编辑其他支出记录' : '新增其他支出记录'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                const SizedBox(height: 24),
                // 表单
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 业务员和编号
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField('业务员', 'salesman', isDropdown: true),
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
                            child: _buildFormField('付款单位', 'payerUnit', readOnly: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField('收款单位', 'payeeUnit', 
                              validator: (value) {
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
                              isDropdown: true,
                              validator: (value) {
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
                              validator: _validateAmount,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 备注
                      _buildFormField('备注', 'remark', maxLines: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _handleCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C757D),
                        fixedSize: const Size(100, 40),
                      ),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 20),
                    if (!_isViewMode)
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF107C10),
                          fixedSize: const Size(100, 40),
                        ),
                        child: const Text('保存'),
                      ),
                    if (_isViewMode)
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          fixedSize: const Size(100, 40),
                        ),
                        child: const Text('关闭'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String key, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool isDropdown = false,
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
        if (isDropdown)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _isViewMode ? Colors.grey : Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonFormField<String>(
              value: _controllers[key]?.text,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: InputBorder.none,
              ),
              items: label == '业务员'
                  ? _salesmen.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList()
                  : _expenseTypes.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: _isViewMode || readOnly
                  ? null
                  : (value) {
                      _controllers[key]?.text = value ?? '';
                    },
              validator: validator,
            ),
          )
        else
          TextFormField(
            controller: _controllers[key],
            keyboardType: keyboardType,
            readOnly: _isViewMode || readOnly,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: _isViewMode || readOnly,
              fillColor: (_isViewMode || readOnly) ? Colors.grey.shade50 : null,
            ),
            validator: validator,
          ),
      ],
    );
  }
}
