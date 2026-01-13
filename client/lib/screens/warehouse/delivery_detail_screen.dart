import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class DeliveryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> deliveryData;
  
  const DeliveryDetailScreen({super.key, required this.deliveryData});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '出库申请详情',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '出库申请详情',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                const SizedBox(height: 24),
                
                // 详情字段
                _buildDetailRow('业务员', deliveryData['业务员'] ?? ''),
                _buildDetailRow('状态', deliveryData['状态'] ?? ''),
                _buildDetailRow('出库单号', deliveryData['出库单号'] ?? ''),
                _buildDetailRow('商品名称', deliveryData['商品名称'] ?? ''),
                _buildDetailRow('商品型号', deliveryData['商品型号'] ?? ''),
                _buildDetailRow('备注', deliveryData['备注'] ?? ''),
                _buildDetailRow('创建时间', deliveryData['创建时间'] ?? ''),
                
                const SizedBox(height: 16),
                
                // 出库商品列表
                Text(
                  '出库商品列表',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                const SizedBox(height: 16),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('序号')),
                      DataColumn(label: Text('商品名称')),
                      DataColumn(label: Text('商品型号')),
                      DataColumn(label: Text('单位')),
                      DataColumn(label: Text('出库数量')),
                    ],
                    rows: List.generate(3, (index) {
                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text('测试商品${index + 1}')),
                        DataCell(Text('型号${index + 1}')),
                        DataCell(Text('个')),
                        DataCell(Text('10')),
                      ]);
                    }),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 底部按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
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
  
  // 构建详情行
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.toString(),
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
