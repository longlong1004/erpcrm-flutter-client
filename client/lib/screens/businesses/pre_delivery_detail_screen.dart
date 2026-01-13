import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class PreDeliveryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  
  const PreDeliveryDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    // 确保订单数据包含详情列表
    final orderDetails = orderData['details'] ?? [];
    
    return MainLayout(
      title: '先发货订单详情',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '先发货订单详情',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
              const SizedBox(height: 24),
              
              // 基础数据
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
                      Text(
                        '基础数据',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 业务员、所属路局、所属站段
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailField('业务员', orderData['业务员'] ?? ''),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailField('所属路局', orderData['所属路局'] ?? ''),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailField('所属站段', orderData['所属站段'] ?? ''),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 客户、合计金额、发货方式
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailField('客户', orderData['客户'] ?? ''),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailField('合计金额', orderData['金额'] ?? ''),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailField('发货方式', orderData['发货方式'] ?? ''),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 编号、公司名称、状态
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailField('编号', orderData['编号'] ?? ''),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailField('公司名称', orderData['公司名称'] ?? ''),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailField('状态', orderData['状态'] ?? ''),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 订单详细数据
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
                      Text(
                        '订单详细数据',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 订单详情表格
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('单品编码')),
                            DataColumn(label: Text('国铁名称')),
                            DataColumn(label: Text('国铁型号')),
                            DataColumn(label: Text('单位')),
                            DataColumn(label: Text('数量')),
                            DataColumn(label: Text('单价')),
                            DataColumn(label: Text('金额')),
                            DataColumn(label: Text('实发名称')),
                            DataColumn(label: Text('实发型号')),
                            DataColumn(label: Text('实发单位')),
                            DataColumn(label: Text('实发数量')),
                            DataColumn(label: Text('小计')),
                          ],
                          rows: (orderDetails as List).map((detail) => DataRow(cells: [
                            DataCell(Text(detail['单品编码'] ?? '')),
                            DataCell(Text(detail['国铁名称'] ?? '')),
                            DataCell(Text(detail['国铁型号'] ?? '')),
                            DataCell(Text(detail['单位'] ?? '')),
                            DataCell(Text(detail['数量']?.toString() ?? '')),
                            DataCell(Text(detail['单价']?.toString() ?? '')),
                            DataCell(Text(detail['金额']?.toString() ?? '')),
                            DataCell(Text(detail['实发名称'] ?? '')),
                            DataCell(Text(detail['实发型号'] ?? '')),
                            DataCell(Text(detail['实发单位'] ?? '')),
                            DataCell(Text(detail['实发数量']?.toString() ?? '')),
                            DataCell(Text(detail['小计']?.toString() ?? '')),
                          ])).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 底部返回按钮
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
    );
  }
  
  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ],
    );
  }
}
