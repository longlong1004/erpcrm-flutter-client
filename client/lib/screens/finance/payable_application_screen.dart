import 'package:flutter/material.dart';

class PayableApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> payableData;

  const PayableApplicationScreen({super.key, required this.payableData});

  @override
  State<PayableApplicationScreen> createState() => _PayableApplicationScreenState();
}

class _PayableApplicationScreenState extends State<PayableApplicationScreen> {
  void _generateAndPrintDocument() {
    // 模拟生成并打印Word文档
    print('生成付款申请单: ${widget.payableData['订单编号']}');
    print('使用模板生成可打印的Word文档');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('付款申请单生成成功，已准备好打印'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadDocument() {
    // 模拟下载Word文档
    print('下载付款申请单: ${widget.payableData['订单编号']}');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('付款申请单下载成功'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              '付款申请单',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 申请表信息
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
                    // 申请表标题
                    Center(
                      child: Text(
                        '付款申请单',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 申请表内容
                    _buildInfoRow('申请单号', widget.payableData['订单编号'] ?? ''),
                    _buildInfoRow('申请人', widget.payableData['业务员'] ?? ''),
                    _buildInfoRow('申请日期', DateTime.now().toString().split(' ')[0]),
                    _buildInfoRow('付款方', widget.payableData['付款方'] ?? ''),
                    _buildInfoRow('收款方', widget.payableData['收款方'] ?? ''),
                    _buildInfoRow('付款方式', widget.payableData['付款方式'] ?? ''),
                    _buildInfoRow('付款金额', '¥${widget.payableData['应付欠款'] ?? 0.0}'),
                    _buildInfoRow('付款类型', widget.payableData['类型'] ?? ''),
                    _buildInfoRow('备注', widget.payableData['备注'] ?? ''),
                    
                    const SizedBox(height: 32),
                    // 审批意见区域
                    const Text(
                      '审批意见',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildApprovalRow('部门经理', '', ''),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildApprovalRow('财务主管', '', ''),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildApprovalRow('总经理', '', ''),
                    
                    const SizedBox(height: 24),
                    // 操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _downloadDocument,
                          icon: const Icon(Icons.download),
                          label: const Text('下载'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _generateAndPrintDocument,
                          icon: const Icon(Icons.print),
                          label: const Text('打印'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
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

  Widget _buildApprovalRow(String position, String signature, String date) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$position:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        Expanded(
          child: Text(
            signature.isNotEmpty ? '同意' : '□ 同意 □ 不同意',
            style: TextStyle(
              color: signature.isNotEmpty ? Colors.green : Color(0xFF1F1F1F),
            ),
          ),
        ),
        SizedBox(
          width: 120,
          child: Text(
            date,
            style: const TextStyle(
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }
}
