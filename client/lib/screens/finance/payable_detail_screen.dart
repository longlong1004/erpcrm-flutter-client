import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class PayableDetailScreen extends StatelessWidget {
  final Map<String, dynamic> payableData;

  const PayableDetailScreen({super.key, required this.payableData});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '应付详情',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '应付详情',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 详情卡片
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
                    // 基本信息
                    Text(
                      '基本信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('业务员', payableData['业务员'] ?? ''),
                    _buildInfoRow('状态', payableData['状态'] ?? ''),
                    _buildInfoRow('订单编号', payableData['订单编号'] ?? ''),
                    _buildInfoRow('类型', payableData['类型'] ?? ''),
                    _buildInfoRow('付款方', payableData['付款方'] ?? ''),
                    _buildInfoRow('付款方式', payableData['付款方式'] ?? ''),
                    _buildInfoRow('收款方', payableData['收款方'] ?? ''),
                    _buildInfoRow('联系人', payableData['联系人'] ?? ''),
                    _buildInfoRow('单据类型', payableData['单据类型'] ?? ''),
                    _buildInfoRow('应付欠款', '¥${payableData['应付欠款'] ?? 0.0}'),
                    _buildInfoRow('欠款类型', payableData['欠款类型'] ?? ''),
                    _buildInfoRow('采购凭证', payableData['采购凭证'] ?? ''),
                    _buildInfoRow('国铁凭证', payableData['国铁凭证'] ?? ''),
                    _buildInfoRow('付款日期', payableData['付款日期'] ?? ''),
                    
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
                          child: const Text('返回'),
                        ),
                      ],
                    ),
                  ],
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
