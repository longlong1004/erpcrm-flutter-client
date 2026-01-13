import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/screens/warehouse/product_edit_screen.dart';

class ProductSearchScreen extends ConsumerWidget {
  const ProductSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      title: '商品查询',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '商品查询',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增商品操作
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductEditScreen(productData: {}),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('新增'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('序号')),
                    DataColumn(label: Text('商品名称')),
                    DataColumn(label: Text('商品型号')),
                    DataColumn(label: Text('单位')),
                    DataColumn(label: Text('实物图片')),
                    DataColumn(label: Text('备注')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: [
                    // 示例行
                    DataRow(cells: [
                      const DataCell(Text('1')),
                      const DataCell(Text('测试商品1')),
                      const DataCell(Text('型号1')),
                      const DataCell(Text('个')),
                      const DataCell(Icon(Icons.image)),
                      const DataCell(Text('备注信息')),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              final productData = {
                                '序号': '1',
                                '商品名称': '测试商品1',
                                '商品型号': '型号1',
                                '单位': '个',
                                '备注': '备注信息',
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductEditScreen(productData: productData),
                                ),
                              );
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 删除操作
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('确认删除'),
                                  content: const Text('确定要删除该商品吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('取消'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // 执行删除操作
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('删除成功'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('删除'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('删除'),
                          ),
                        ],
                      )),

                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}