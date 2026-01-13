import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/screens/warehouse/scrap_add_screen.dart';
import 'package:erpcrm_client/screens/warehouse/scrap_detail_screen.dart';

class ScrapApplicationScreen extends ConsumerWidget {
  const ScrapApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      title: '报废商品',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '报废商品',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增报废商品操作
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScrapAddScreen(),
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
                    DataColumn(label: Text('业务员')),
                    DataColumn(label: Text('状态')),
                    DataColumn(label: Text('报废单号')),
                    DataColumn(label: Text('商品名称')),
                    DataColumn(label: Text('商品型号')),
                    DataColumn(label: Text('备注')),
                    DataColumn(label: Text('创建时间')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: [
                    // 示例行
                    DataRow(cells: [
                      const DataCell(Text('张三')),
                      const DataCell(
                        Chip(
                          label: Text('待审核'),
                          backgroundColor: Colors.yellow,
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                      const DataCell(Text('SCRAP001')),
                      const DataCell(Text('测试商品1')),
                      const DataCell(Text('型号1')),
                      const DataCell(Text('备注信息')),
                      const DataCell(Text('2025-12-19 10:00')),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 查看操作
                              final scrapData = {
                                '业务员': '张三',
                                '状态': '待审核',
                                '报废单号': 'SCRAP001',
                                '商品名称': '测试商品1',
                                '商品型号': '型号1',
                                '备注': '备注信息',
                                '创建时间': '2025-12-19 10:00',
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScrapDetailScreen(scrapData: scrapData),
                                ),
                              );
                            },
                            child: const Text('查看'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              final scrapData = {
                                '业务员': '张三',
                                '状态': '待审核',
                                '报废单号': 'SCRAP001',
                                '商品名称': '测试商品1',
                                '商品型号': '型号1',
                                '备注': '备注信息',
                                '创建时间': '2025-12-19 10:00',
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScrapAddScreen(scrapData: scrapData),
                                ),
                              );
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 撤回操作
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('确认撤回'),
                                  content: const Text('确定要撤回该报废申请吗？撤回后状态变更为"已撤销"，数据不再进入审核流程。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('取消'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // 执行撤回操作
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('已撤回，状态变更为"已撤销"'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF003366),
                                      ),
                                      child: const Text('确定'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('撤回'),
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