import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/screens/warehouse/inventory_detail_screen.dart';
import 'package:erpcrm_client/screens/warehouse/inventory_edit_screen.dart';
import '../../widgets/two_level_tab_layout.dart';
import './product_search_screen.dart';
import './warehousing_application_screen.dart';
import './delivery_application_screen.dart';
import './scrap_application_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 仓库管理
      TabConfig(
        title: '仓库管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '库存商品',
            content: const _InventoryListView(),
          ),
          SecondLevelTabConfig(
            title: '商品查询',
            content: const ProductSearchScreen(),
          ),
          SecondLevelTabConfig(
            title: '入库申请',
            content: const WarehousingApplicationScreen(),
          ),
          SecondLevelTabConfig(
            title: '出库申请',
            content: const DeliveryApplicationScreen(),
          ),
          SecondLevelTabConfig(
            title: '报废',
            content: const ScrapApplicationScreen(),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
      moduleName: '仓库管理',
    );
  }
}

// 库存商品列表视图
class _InventoryListView extends ConsumerWidget {
  const _InventoryListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '库存商品',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // 新增库存商品操作
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventoryEditScreen(inventoryData: {}),
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
                  DataColumn(label: Text('货架号')),
                  DataColumn(label: Text('关联单品编码')),
                  DataColumn(label: Text('商品名称')),
                  DataColumn(label: Text('商品型号')),
                  DataColumn(label: Text('单位')),
                  DataColumn(label: Text('仓库')),
                  DataColumn(label: Text('库存数量')),
                  DataColumn(label: Text('备注')),
                  DataColumn(label: Text('实物图片')),
                  DataColumn(label: Text('操作')),
                ],
                rows: [
                  // 这里可以添加测试数据，或者从API获取数据后动态生成
                  // 示例行
                  DataRow(cells: [
                    const DataCell(Text('1')),
                    const DataCell(Text('A1')),
                    const DataCell(Text('P001')),
                    const DataCell(Text('测试商品1')),
                    const DataCell(Text('型号1')),
                    const DataCell(Text('个')),
                    const DataCell(Text('主仓库')),
                    const DataCell(Text('100')),
                    const DataCell(Text('备注信息')),
                    const DataCell(Icon(Icons.image)),
                    DataCell(Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            // 查看操作
                            final inventoryData = {
                              '序号': '1',
                              '货架号': 'A1',
                              '关联单品编码': 'P001',
                              '商品名称': '测试商品1',
                              '商品型号': '型号1',
                              '单位': '个',
                              '仓库': '主仓库',
                              '库存数量': '100',
                              '备注': '备注信息',
                              '实物图片': '',
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InventoryDetailScreen(inventoryData: inventoryData),
                              ),
                            );
                          },
                          child: const Text('查看'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 编辑操作
                            final inventoryData = {
                              '序号': '1',
                              '货架号': 'A1',
                              '关联单品编码': 'P001',
                              '商品名称': '测试商品1',
                              '商品型号': '型号1',
                              '单位': '个',
                              '仓库': '主仓库',
                              '库存数量': '100',
                              '备注': '备注信息',
                              '实物图片': '',
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InventoryEditScreen(inventoryData: inventoryData),
                              ),
                            );
                          },
                          child: const Text('编辑'),
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
    );
  }
}