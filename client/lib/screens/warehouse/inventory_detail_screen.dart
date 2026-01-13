import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class InventoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> inventoryData;
  
  const InventoryDetailScreen({super.key, required this.inventoryData});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '库存商品详情',
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
                  '库存商品详情',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                const SizedBox(height: 24),
                
                // 详情字段
                _buildDetailRow('序号', inventoryData['序号'] ?? ''),
                _buildDetailRow('货架号', inventoryData['货架号'] ?? ''),
                _buildDetailRow('关联单品编码', inventoryData['关联单品编码'] ?? ''),
                _buildDetailRow('商品名称', inventoryData['商品名称'] ?? ''),
                _buildDetailRow('商品型号', inventoryData['商品型号'] ?? ''),
                _buildDetailRow('单位', inventoryData['单位'] ?? ''),
                _buildDetailRow('仓库', inventoryData['仓库'] ?? ''),
                _buildDetailRow('库存数量', inventoryData['库存数量'] ?? ''),
                _buildDetailRow('备注', inventoryData['备注'] ?? ''),
                
                // 实物图片
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          '实物图片',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.image, size: 100),
                    ],
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
