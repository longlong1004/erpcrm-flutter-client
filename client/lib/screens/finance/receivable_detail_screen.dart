import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class ReceivableDetailScreen extends StatelessWidget {
  final Map<String, dynamic> receivableData;

  const ReceivableDetailScreen({super.key, required this.receivableData});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '应收详情',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '应收详情',
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
                    _buildInfoRow('业务员', receivableData['业务员'] ?? ''),
                    _buildInfoRow('状态', receivableData['状态'] ?? ''),
                    _buildInfoRow('业务类型', receivableData['业务类型'] ?? ''),
                    _buildInfoRow('订单编号', receivableData['订单编号'] ?? ''),
                    if (receivableData.containsKey('所属路局'))
                      _buildInfoRow('所属路局', receivableData['所属路局'] ?? ''),
                    if (receivableData.containsKey('所属站段'))
                      _buildInfoRow('所属站段', receivableData['所属站段'] ?? ''),
                    if (receivableData.containsKey('客户公司名称'))
                      _buildInfoRow('客户公司名称', receivableData['客户公司名称'] ?? ''),
                    if (receivableData.containsKey('联系人'))
                      _buildInfoRow('联系人', receivableData['联系人'] ?? ''),
                    if (receivableData.containsKey('联系电话'))
                      _buildInfoRow('联系电话', receivableData['联系电话'] ?? ''),
                    
                    const SizedBox(height: 24),
                    // 产品信息
                    Text(
                      '产品信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('国铁名称', receivableData['国铁名称'] ?? ''),
                    _buildInfoRow('国铁型号', receivableData['国铁型号'] ?? ''),
                    _buildInfoRow('国铁单价', '¥${receivableData['国铁单价'] ?? 0.0}'),
                    _buildInfoRow('单位', receivableData['单位'] ?? ''),
                    _buildInfoRow('数量', receivableData['数量'] ?? ''),
                    _buildInfoRow('应收金额', '¥${receivableData['应收金额'] ?? 0.0}'),
                    
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
