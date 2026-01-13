import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class PayablePayScreen extends StatefulWidget {
  final Map<String, dynamic> payableData;

  const PayablePayScreen({super.key, required this.payableData});

  @override
  State<PayablePayScreen> createState() => _PayablePayScreenState();
}

class _PayablePayScreenState extends State<PayablePayScreen> {
  final TextEditingController _actualAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _voucherFilePath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // 初始化为应付金额
    _actualAmountController.text = widget.payableData['应付欠款']?.toString() ?? '0.0';
  }

  @override
  void dispose() {
    _actualAmountController.dispose();
    super.dispose();
  }

  Future<void> _uploadVoucher() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
     
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _voucherFilePath = file.name;
        _isUploading = true;
      });
      
      // 模拟上传文件
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isUploading = false;
      });
      
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('凭证上传成功: ${file.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_voucherFilePath == null) {
        // 提示上传凭证
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('请先上传付款凭证'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // 确认付款逻辑
      final actualAmount = double.tryParse(_actualAmountController.text) ?? 0.0;
      final payableAmount = widget.payableData['应付欠款'] ?? 0.0;

      // 检查金额是否一致
      if (actualAmount != payableAmount) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('金额不一致'),
            content: const Text('实付金额与应付金额不一致，是否继续付款？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  _completePayment();
                  Navigator.pop(context);
                },
                child: const Text('继续'),
              ),
            ],
          ),
        );
      } else {
        _completePayment();
      }
    }
  }

  void _completePayment() {
    // 执行付款逻辑
    print('确认付款: ${widget.payableData['订单编号']}');
    print('实付金额: ${_actualAmountController.text}');
    print('付款凭证: $_voucherFilePath');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('付款成功，状态已更新为已付款'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 返回上一页
    Navigator.pop(context);
  }

  void _rejectPayment() {
    // 执行驳回逻辑
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('驳回确认'),
        content: const Text('确定要驳回该笔付款申请吗？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 执行驳回
              print('驳回付款申请: ${widget.payableData['订单编号']}');
              
              // 显示成功消息
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('付款申请已驳回，状态已更新为已驳回'),
                  backgroundColor: Colors.orange,
                ),
              );
              
              // 返回上一页
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '付款',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '付款',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 付款表单
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
                      _buildInfoRow('订单编号', widget.payableData['订单编号'] ?? ''),
                      _buildInfoRow('应付金额', '¥${widget.payableData['应付欠款'] ?? 0.0}'),
                      _buildInfoRow('收款方', widget.payableData['收款方'] ?? ''),
                      _buildInfoRow('联系人', widget.payableData['联系人'] ?? ''),
                      
                      const SizedBox(height: 24),
                      // 付款信息
                      Text(
                        '付款信息',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // 实付金额
                      TextFormField(
                        controller: _actualAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '实付金额',
                          border: OutlineInputBorder(),
                          prefixText: '¥',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '实付金额不能为空';
                          }
                          if (double.tryParse(value ?? '') == null) {
                            return '实付金额必须是数字';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // 付款凭证
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('付款凭证'),
                                const SizedBox(height: 8),
                                Text(
                                  _voucherFilePath ?? '未上传',
                                  style: TextStyle(
                                    color: _voucherFilePath != null ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : () async => await _uploadVoucher(),
                            icon: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.upload_file),
                            label: const Text('上传凭证'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      // 操作按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _rejectPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                            ),
                            child: const Text('驳回'),
                          ),
                          const SizedBox(width: 16),
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
                          ElevatedButton.icon(
                            onPressed: _submitPayment,
                            icon: const Icon(Icons.payment),
                            label: const Text('确认付款，上传凭证'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF107C10),
                            ),
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
