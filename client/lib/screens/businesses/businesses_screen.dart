import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/two_level_tab_layout.dart';
import 'package:erpcrm_client/screens/businesses/pre_delivery_add_screen.dart';
import 'package:erpcrm_client/screens/businesses/pre_delivery_detail_screen.dart';

class BusinessesScreen extends ConsumerWidget {
  const BusinessesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 批量采购
      TabConfig(
        title: '批量采购',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '可参与',
            content: _buildBatchPurchaseParticipable(context),
          ),
          SecondLevelTabConfig(
            title: '类目符合',
            content: _buildBatchPurchaseCategoryMatch(context),
          ),
          SecondLevelTabConfig(
            title: '类目不符合',
            content: _buildBatchPurchaseCategoryNotMatch(context),
          ),
        ],
      ),
      // 招标信息
      TabConfig(
        title: '招标信息',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '招标信息',
            content: _buildBiddingScreen(context),
          ),
        ],
      ),
      // 竞价信息
      TabConfig(
        title: '竞价信息',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '竞价信息',
            content: _buildAuctionScreen(context),
          ),
        ],
      ),
      // 先发货管理
      TabConfig(
        title: '先发货管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '先发货管理',
            content: _buildPreDeliveryScreen(context),
          ),
        ],
      ),
      // 先报计划管理
      TabConfig(
        title: '先报计划管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '先报计划管理',
            content: _buildPrePlanScreen(context),
          ),
        ],
      ),
      // 线索
      TabConfig(
        title: '线索',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '线索',
            content: _buildLeadsScreen(context),
          ),
        ],
      ),
      // 商机
      TabConfig(
        title: '商机',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '商机',
            content: _buildOpportunitiesScreen(context),
          ),
        ],
      ),
      // 公海池
      TabConfig(
        title: '公海池',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '公海池',
            content: _buildPublicPoolScreen(context),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
      moduleName: '业务管理',
    );
  }
  
  // 构建详情行
  Widget _buildDetailRow(String label, String value) {
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
  
  // 批量采购 - 可参与
  Widget _buildBatchPurchaseParticipable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '可参与批量采购',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('发布时间')),
                DataColumn(label: Text('品牌')),
                DataColumn(label: Text('商品类别')),
                DataColumn(label: Text('参与起止时间')),
                DataColumn(label: Text('业务员')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('查看时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('公告名称$index')),
                  DataCell(Text('2025-12-19')),
                  DataCell(Text('品牌$index')),
                  DataCell(Text('商品类别$index')),
                  DataCell(Text('2025-12-19 至 2025-12-26')),
                  DataCell(Text('admin')),
                  DataCell(const Text('可参与')),
                  DataCell(Text('2025-12-19 10:00')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                        },
                        child: const Text('查看'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 报备功能
                        },
                        child: const Text('报备'),
                      ),
                    ],
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 批量采购 - 类目符合
  Widget _buildBatchPurchaseCategoryMatch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '类目符合批量采购',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('发布时间')),
                DataColumn(label: Text('品牌')),
                DataColumn(label: Text('商品类别')),
                DataColumn(label: Text('参与起止时间')),
                DataColumn(label: Text('查看时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('公告名称$index')),
                  DataCell(Text('2025-12-19')),
                  DataCell(Text('品牌$index')),
                  DataCell(Text('商品类别$index')),
                  DataCell(Text('2025-12-19 至 2025-12-26')),
                  DataCell(Text('2025-12-19 10:00')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                        },
                        child: const Text('查看'),
                      ),
                    ],
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 批量采购 - 类目不符合
  Widget _buildBatchPurchaseCategoryNotMatch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '类目不符合批量采购',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('发布时间')),
                DataColumn(label: Text('品牌')),
                DataColumn(label: Text('商品类别')),
                DataColumn(label: Text('参与起止时间')),
                DataColumn(label: Text('查看时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('公告名称$index')),
                  DataCell(Text('2025-12-19')),
                  DataCell(Text('品牌$index')),
                  DataCell(Text('商品类别$index')),
                  DataCell(Text('2025-12-19 至 2025-12-26')),
                  DataCell(Text('2025-12-19 10:00')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                        },
                        child: const Text('查看'),
                      ),
                    ],
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 招标信息
  Widget _buildBiddingScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '招标信息',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('发布时间')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('招标公告$index')),
                  DataCell(Text('2025-12-19')),
                  DataCell(const Text('进行中')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                        },
                        child: const Text('查看'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 报备功能
                        },
                        child: const Text('报备'),
                      ),
                    ],
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 竞价信息
  Widget _buildAuctionScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '竞价信息',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('发布时间')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('竞价公告$index')),
                  DataCell(Text('2025-12-19')),
                  DataCell(const Text('进行中')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                        },
                        child: const Text('查看'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 报备功能
                        },
                        child: const Text('报备'),
                      ),
                    ],
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 先发货管理
  Widget _buildPreDeliveryScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '先发货管理',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // 新增功能
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreDeliveryAddScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('新增'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('业务员')),
                DataColumn(label: Text('编号')),
                DataColumn(label: Text('公司名称')),
                DataColumn(label: Text('所属路局')),
                DataColumn(label: Text('所属站段')),
                DataColumn(label: Text('客户')),
                DataColumn(label: Text('未匹配数量')),
                DataColumn(label: Text('品牌')),
                DataColumn(label: Text('单品编码')),
                DataColumn(label: Text('国铁名称')),
                DataColumn(label: Text('国铁型号')),
                DataColumn(label: Text('单位')),
                DataColumn(label: Text('国铁单价')),
                DataColumn(label: Text('实发数量')),
                DataColumn(label: Text('金额')),
                DataColumn(label: Text('付款情况')),
                DataColumn(label: Text('发货情况')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(const Text('已发货')),
                  DataCell(Text('admin')),
                  DataCell(Text('FD$index')),
                  DataCell(Text('公司名称$index')),
                  DataCell(Text('北京铁路局')),
                  DataCell(Text('北京站')),
                  DataCell(Text('客户$index')),
                  DataCell(Text('0')),
                  DataCell(Text('品牌$index')),
                  DataCell(Text('P$index')),
                  DataCell(Text('国铁名称$index')),
                  DataCell(Text('型号$index')),
                  DataCell(Text('件')),
                  DataCell(Text('¥100.00')),
                  DataCell(Text('10')),
                  DataCell(Text('¥1000.00')),
                  DataCell(const Text('已付款')),
                  DataCell(const Text('已发货')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                          final orderData = {
                            '状态': '已发货',
                            '业务员': 'admin',
                            '编号': 'FD$index',
                            '公司名称': '公司名称$index',
                            '所属路局': '北京铁路局',
                            '所属站段': '北京站',
                            '客户': '客户$index',
                            '合计金额': '¥1000.00',
                            '发货方式': '铁路运输',
                            'details': [
                              {
                                '单品编码': 'P$index',
                                '国铁名称': '国铁名称$index',
                                '国铁型号': '型号$index',
                                '单位': '件',
                                '数量': 10,
                                '单价': 100.0,
                                '金额': 1000.0,
                                '实发名称': '国铁名称$index',
                                '实发型号': '型号$index',
                                '实发单位': '件',
                                '实发数量': 10,
                                '小计': 1000.0,
                              },
                            ],
                          };
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreDeliveryDetailScreen(orderData: orderData),
                            ),
                          );
                        },
                        child: const Text('查看'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 编辑功能
                          // 跳转到新增页面，但带有现有数据进行编辑
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PreDeliveryAddScreen(),
                            ),
                          );
                        },
                        child: const Text('编辑'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 删除功能
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认删除'),
                              content: Text('确定要删除该先发货订单吗？'),
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

                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 先报计划管理
  Widget _buildPrePlanScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '先报计划管理',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // 新增功能
                },
                icon: const Icon(Icons.add),
                label: const Text('新增'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('业务员')),
                DataColumn(label: Text('编号')),
                DataColumn(label: Text('公司名称')),
                DataColumn(label: Text('所属路局')),
                DataColumn(label: Text('所属站段')),
                DataColumn(label: Text('客户')),
                DataColumn(label: Text('未匹配数量')),
                DataColumn(label: Text('品牌')),
                DataColumn(label: Text('单品编码')),
                DataColumn(label: Text('国铁名称')),
                DataColumn(label: Text('国铁型号')),
                DataColumn(label: Text('单位')),
                DataColumn(label: Text('国铁单价')),
                DataColumn(label: Text('金额')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(const Text('已审批')),
                  DataCell(Text('admin')),
                  DataCell(Text('PP$index')),
                  DataCell(Text('公司名称$index')),
                  DataCell(Text('北京铁路局')),
                  DataCell(Text('北京站')),
                  DataCell(Text('客户$index')),
                  DataCell(Text('0')),
                  DataCell(Text('品牌$index')),
                  DataCell(Text('P$index')),
                  DataCell(Text('国铁名称$index')),
                  DataCell(Text('型号$index')),
                  DataCell(Text('件')),
                  DataCell(Text('¥100.00')),
                  DataCell(Text('¥1000.00')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                        },
                        child: const Text('查看'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 编辑功能
                        },
                        child: const Text('编辑'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 删除功能
                        },
                        child: const Text('删除'),
                      ),
                    ],
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 线索
  Widget _buildLeadsScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '线索',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('线索来源')),
                DataColumn(label: Text('业务员')),
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('客户单位')),
                DataColumn(label: Text('联系人')),
                DataColumn(label: Text('联系电话')),
                DataColumn(label: Text('创建时间')),
                DataColumn(label: Text('报名截止时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('网站$index')),
                  DataCell(Text('admin')),
                  DataCell(Text('公告名称$index')),
                  DataCell(Text('客户单位$index')),
                  DataCell(Text('联系人$index')),
                  DataCell(Text('1380013800$index')),
                  DataCell(Text('2025-12-19 10:00')),
                  DataCell(Text('2025-12-26 18:00')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 我想联系功能
                          // 将数据流转到商机页面，并从线索列表移除
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认操作'),
                              content: const Text('确定要将该线索转为商机吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('取消'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // 执行流转操作
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已转为商机'),
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
                        child: const Text('我想联系'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 暂不联系功能
                          // 将数据流转到公海池页面，并从线索列表移除
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认操作'),
                              content: const Text('确定要将该线索转入公海池吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('取消'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // 执行流转操作
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已转入公海池'),
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
                        child: const Text('暂不联系'),
                      ),
                    ],
                  )),

                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 商机
  Widget _buildOpportunitiesScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '商机',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('商机来源')),
                DataColumn(label: Text('业务员')),
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('客户单位')),
                DataColumn(label: Text('联系人')),
                DataColumn(label: Text('联系电话')),
                DataColumn(label: Text('创建时间')),
                DataColumn(label: Text('最后跟进时间')),
                DataColumn(label: Text('下次跟进时间')),
                DataColumn(label: Text('最新跟进内容')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('线索转化$index')),
                  DataCell(Text('admin')),
                  DataCell(Text('公告名称$index')),
                  DataCell(Text('客户单位$index')),
                  DataCell(Text('联系人$index')),
                  DataCell(Text('1380013800$index')),
                  DataCell(Text('2025-12-19 10:00')),
                  DataCell(Text('2025-12-20 14:00')),
                  DataCell(Text('2025-12-21 10:00')),
                  DataCell(Text('跟进内容$index')),
                  DataCell(DropdownButton<String>(
                    value: '待成交',
                    items: ['已成交', '待成交'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      // 状态更新
                    },
                  )),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                          // 弹出详情页面，展示商机来源的完整信息
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              insetPadding: const EdgeInsets.all(24.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 详情页面内容
                                    Container(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '商机详情',
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF1F1F1F),
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // 详情字段
                                          _buildDetailRow('商机来源', '线索转化$index'),
                                          _buildDetailRow('业务员', 'admin'),
                                          _buildDetailRow('公告名称', '公告名称$index'),
                                          _buildDetailRow('客户单位', '客户单位$index'),
                                          _buildDetailRow('联系人', '联系人$index'),
                                          _buildDetailRow('联系电话', '1380013800$index'),
                                          _buildDetailRow('创建时间', '2025-12-19 10:00'),
                                          _buildDetailRow('最后跟进时间', '2025-12-20 14:00'),
                                          _buildDetailRow('下次跟进时间', '2025-12-21 10:00'),
                                          _buildDetailRow('最新跟进内容', '跟进内容$index'),
                                          _buildDetailRow('状态', '待成交'),
                                        ],
                                      ),
                                    ),
                                    
                                    // 底部按钮
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF003366),
                                            ),
                                            child: const Text('关闭'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('查看'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 暂不联系功能
                          // 将数据流转到公海池页面，并从商机列表移除
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认操作'),
                              content: const Text('确定要将该商机转入公海池吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('取消'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // 执行流转操作
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已转入公海池'),
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
                        child: const Text('暂不联系'),
                      ),
                    ],
                  )),

                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  // 公海池
  Widget _buildPublicPoolScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '公海池',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('商机来源')),
                DataColumn(label: Text('业务员')),
                DataColumn(label: Text('公告名称')),
                DataColumn(label: Text('客户单位')),
                DataColumn(label: Text('联系人')),
                DataColumn(label: Text('联系电话')),
                DataColumn(label: Text('创建时间')),
                DataColumn(label: Text('进入公海池时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: List.generate(5, (index) {
                return DataRow(cells: [
                  DataCell(Text('网站$index')),
                  DataCell(Text('admin')),
                  DataCell(Text('公告名称$index')),
                  DataCell(Text('客户单位$index')),
                  DataCell(Text('联系人$index')),
                  DataCell(Text('1380013800$index')),
                  DataCell(Text('2025-12-19 10:00')),
                  DataCell(Text('2025-12-20 14:00')),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // 查看功能
                          // 弹出详情页面，展示商机来源的完整信息
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              insetPadding: const EdgeInsets.all(24.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 详情页面内容
                                    Container(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '公海池详情',
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF1F1F1F),
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // 详情字段
                                          _buildDetailRow('商机来源', '网站$index'),
                                          _buildDetailRow('业务员', 'admin'),
                                          _buildDetailRow('公告名称', '公告名称$index'),
                                          _buildDetailRow('客户单位', '客户单位$index'),
                                          _buildDetailRow('联系人', '联系人$index'),
                                          _buildDetailRow('联系电话', '1380013800$index'),
                                          _buildDetailRow('创建时间', '2025-12-19 10:00'),
                                          _buildDetailRow('进入公海池时间', '2025-12-20 14:00'),
                                        ],
                                      ),
                                    ),
                                    
                                    // 底部按钮
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF003366),
                                            ),
                                            child: const Text('关闭'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('查看'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 我想联系功能
                          // 将数据流转到商机页面，并从公海池列表移除
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认操作'),
                              content: const Text('确定要将该公海池线索转为商机吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('取消'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // 执行流转操作
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已转为商机'),
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
                        child: const Text('我想联系'),
                      ),
                    ],
                  )),

                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}