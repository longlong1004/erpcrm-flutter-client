import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoiceData;
  final bool isIncomingInvoice; // true 为进项发票，false 为销项发票

  const InvoiceDetailScreen({super.key, required this.invoiceData, required this.isIncomingInvoice});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: isIncomingInvoice ? '进项发票详情' : '销项发票详情',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isIncomingInvoice ? '进项发票详情' : '销项发票详情',
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
                    if (isIncomingInvoice) ...[
                      // 进项发票字段
                      _buildInfoRow('业务员', invoiceData['业务员'] ?? ''),
                      _buildInfoRow('状态', invoiceData['状态'] ?? ''),
                      _buildInfoRow('类型', invoiceData['类型'] ?? ''),
                      _buildInfoRow('订单编号', invoiceData['订单编号'] ?? ''),
                      _buildInfoRow('供应商', invoiceData['供应商'] ?? ''),
                      _buildInfoRow('付款金额', '¥${invoiceData['付款金额'] ?? 0.0}'),
                      _buildInfoRow('付款日期', invoiceData['付款日期'] ?? ''),
                      _buildInfoRow('发票号', invoiceData['发票号'] ?? ''),
                      _buildInfoRow('发票金额', '¥${invoiceData['发票金额'] ?? 0.0}'),
                      _buildInfoRow('开票日期', invoiceData['开票日期'] ?? ''),
                    ] else ...[
                      // 销项发票字段
                      _buildInfoRow('录入时间', invoiceData['录入时间'] ?? ''),
                      _buildInfoRow('公司名称', invoiceData['公司名称'] ?? ''),
                      _buildInfoRow('申请单号', invoiceData['申请单号'] ?? ''),
                      _buildInfoRow('申请时间', invoiceData['申请时间'] ?? ''),
                      _buildInfoRow('账单编号', invoiceData['账单编号'] ?? ''),
                      _buildInfoRow('发票类型', invoiceData['发票类型'] ?? ''),
                      _buildInfoRow('发票抬头', invoiceData['发票抬头'] ?? ''),
                      _buildInfoRow('纳税人识别码', invoiceData['纳税人识别码'] ?? ''),
                      _buildInfoRow('总金额', '¥${invoiceData['总金额'] ?? 0.0}'),
                      _buildInfoRow('结果', invoiceData['结果'] ?? ''),
                      _buildInfoRow('发票状态', invoiceData['发票状态'] ?? ''),
                      _buildInfoRow('开票状态', invoiceData['开票状态'] ?? ''),
                    ],
                    
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
