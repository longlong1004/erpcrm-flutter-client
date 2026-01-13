import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class ReceivableCollectScreen extends StatefulWidget {
  final Map<String, dynamic> receivableData;

  const ReceivableCollectScreen({super.key, required this.receivableData});

  @override
  State<ReceivableCollectScreen> createState() => _ReceivableCollectScreenState();
}

class _ReceivableCollectScreenState extends State<ReceivableCollectScreen> {
  final TextEditingController _actualAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 初始化为应收金额
    _actualAmountController.text = widget.receivableData['应收金额']?.toString() ?? '0.0';
  }

  @override
  void dispose() {
    _actualAmountController.dispose();
    super.dispose();
  }

  void _submitCollection() {
    if (_formKey.currentState?.validate() ?? false) {
      // 确认收款逻辑
      final actualAmount = double.tryParse(_actualAmountController.text) ?? 0.0;
      final receivableAmount = widget.receivableData['应收金额'] ?? 0.0;

      // 检查金额是否一致
      if (actualAmount != receivableAmount) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('金额不一致'),
            content: const Text('实收金额与应收金额不一致，是否继续收款？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  _completeCollection();
                  Navigator.pop(context);
                },
                child: const Text('继续'),
              ),
            ],
          ),
        );
      } else {
        _completeCollection();
      }
    }
  }

  void _completeCollection() {
    // 执行收款逻辑
    print('确认收款: ${widget.receivableData['订单编号']}');
    print('实收金额: ${_actualAmountController.text}');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('收款成功，状态已更新为已收款'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 返回上一页
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '收款',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '收款',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 收款表单
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
                      // 订单信息
                      Text(
                        '订单信息',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('订单编号', widget.receivableData['订单编号'] ?? ''),
                      _buildInfoRow('应收金额', '¥${widget.receivableData['应收金额'] ?? 0.0}'),
                      
                      const SizedBox(height: 24),
                      // 收款信息
                      Text(
                        '收款信息',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // 实收金额
                      TextFormField(
                        controller: _actualAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '实收金额',
                          border: OutlineInputBorder(),
                          prefixText: '¥',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '实收金额不能为空';
                          }
                          if (double.tryParse(value ?? '') == null) {
                            return '实收金额必须是数字';
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
                            onPressed: _submitCollection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF107C10),
                            ),
                            child: const Text('确认收款'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
