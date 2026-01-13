import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class ScrapDetailScreen extends StatelessWidget {
  final Map<String, dynamic> scrapData;
  
  const ScrapDetailScreen({super.key, required this.scrapData});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '报废商品详情',
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
                  '报废商品详情',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                const SizedBox(height: 24),
                
                // 详情字段
                _buildDetailRow('业务员', scrapData['业务员'] ?? ''),
                _buildDetailRow('状态', scrapData['状态'] ?? ''),
                _buildDetailRow('报废单号', scrapData['报废单号'] ?? ''),
                _buildDetailRow('商品名称', scrapData['商品名称'] ?? ''),
                _buildDetailRow('商品型号', scrapData['商品型号'] ?? ''),
                _buildDetailRow('备注', scrapData['备注'] ?? ''),
                _buildDetailRow('创建时间', scrapData['创建时间'] ?? ''),
                
                const SizedBox(height: 16),
                
                // 报废商品列表
                Text(
                  '报废商品列表',
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
                      DataColumn(label: Text('报废数量')),
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
