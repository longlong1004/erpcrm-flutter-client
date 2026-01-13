import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product/product.dart';
import '../../../providers/product_provider.dart';

class ProductRecycleScreen extends ConsumerStatefulWidget {
  const ProductRecycleScreen({super.key});

  @override
  ConsumerState<ProductRecycleScreen> createState() => _ProductRecycleScreenState();
}

class _ProductRecycleScreenState extends ConsumerState<ProductRecycleScreen> {
  @override
  Widget build(BuildContext context) {
    // 使用productsProvider获取商品列表
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('回收站'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 表格标题
            _buildTableHeader(),
            const SizedBox(height: 16),
            // 表格内容
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('加载失败: $error'),
                      ElevatedButton(
                        onPressed: () => ref.read(productsProvider.notifier).refresh(),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
                data: (products) {
                  // 筛选出回收站状态的商品
                  final recycleProducts = products.where((product) {
                    // 根据实际业务逻辑调整状态筛选条件
                    return product.status == 'DELETED' || product.status == 'ARCHIVED';
                  }).toList();

                  if (recycleProducts.isEmpty) {
                    return const Center(child: Text('回收站中暂无商品'));
                  }

                  return ListView.builder(
                    itemCount: recycleProducts.length,
                    itemBuilder: (context, index) {
                      final product = recycleProducts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            // 状态
                            _buildTableCell(_getStatusText(product.status), 2),
                            // 业务员
                            _buildTableCell('王五', 2), // 实际业务中应从product或关联表获取
                            // 公司名称
                            _buildTableCell('国铁科技有限公司', 2), // 实际业务中应从product或关联表获取
                            // 品牌
                            _buildTableCell(product.brand ?? '', 2),
                            // 国铁名称
                            _buildTableCell(product.name, 2),
                            // 国铁型号
                            _buildTableCell(product.model, 2),
                            // 单位
                            _buildTableCell(product.unit, 2),
                            // 国铁单价
                            _buildTableCell('¥${product.price}', 2),
                            // 三级分类
                            _buildTableCell('铁路设备 > 传感器 > 压力传感器', 2), // 实际业务中应从category关联表获取
                            // 操作按钮
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () => _handleView(product),
                                      child: const Text('查看'),
                                    ),
                                    TextButton(
                                      onPressed: () => _handleEdit(product),
                                      child: const Text('编辑'),
                                    ),
                                    TextButton(
                                      onPressed: () => _handlePrint(product),
                                      child: const Text('打印合格证'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    final headers = [
      '状态', '业务员', '公司名称', '品牌', '国铁名称', '国铁型号', 
      '单位', '国铁单价', '三级分类', '操作'
    ];

    return Row(
      children: headers.map((header) {
        // 为操作列设置特殊宽度
        final width = header == '操作' ? 200.0 : (header == '状态' || header == '业务员' || header == '单位') ? 100.0 : 120.0;
        return Expanded(
          flex: header == '操作' ? 3 : 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF003366),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              header,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableCell(dynamic content, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          content.toString(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DELETED':
        return '已删除';
      case 'ARCHIVED':
        return '已归档';
      default:
        return status;
    }
  }

  void _handleView(Product product) {
    print('查看商品: ${product.name}');
  }

  void _handleEdit(Product product) {
    print('编辑商品: ${product.name}');
  }

  void _handlePrint(Product product) {
    print('打印合格证: ${product.name}');
  }
}