import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/multi_level_menu_layout.dart';

/// 多级菜单示例页面
class MultiLevelMenuExampleScreen extends ConsumerStatefulWidget {
  const MultiLevelMenuExampleScreen({super.key});

  @override
  ConsumerState<MultiLevelMenuExampleScreen> createState() => _MultiLevelMenuExampleScreenState();
}

class _MultiLevelMenuExampleScreenState extends ConsumerState<MultiLevelMenuExampleScreen> {
  // 示例菜单配置
  List<MenuItem> _buildExampleMenu() {
    return [
      MenuItem(
        id: 'dashboard',
        title: '仪表盘',
        icon: Icons.dashboard,
        content: const Center(child: Text('仪表盘内容')),
      ),
      MenuItem(
        id: 'orders',
        title: '订单管理',
        icon: Icons.shopping_cart,
        children: [
          MenuItem(
            id: 'order_list',
            title: '订单列表',
            content: const Center(child: Text('订单列表内容')),
          ),
          MenuItem(
            id: 'order_create',
            title: '创建订单',
            content: const Center(child: Text('创建订单内容')),
          ),
          MenuItem(
            id: 'order_statistics',
            title: '订单统计',
            children: [
              MenuItem(
                id: 'daily_statistics',
                title: '日统计',
                content: const Center(child: Text('日统计内容')),
              ),
              MenuItem(
                id: 'monthly_statistics',
                title: '月统计',
                content: const Center(child: Text('月统计内容')),
              ),
              MenuItem(
                id: 'yearly_statistics',
                title: '年统计',
                content: const Center(child: Text('年统计内容')),
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        id: 'products',
        title: '商品管理',
        icon: Icons.shopping_bag,
        children: [
          MenuItem(
            id: 'product_list',
            title: '商品列表',
            content: const Center(child: Text('商品列表内容')),
          ),
          MenuItem(
            id: 'product_category',
            title: '商品分类',
            children: [
              MenuItem(
                id: 'category_list',
                title: '分类列表',
                content: const Center(child: Text('分类列表内容')),
              ),
              MenuItem(
                id: 'category_create',
                title: '创建分类',
                content: const Center(child: Text('创建分类内容')),
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        id: 'customers',
        title: '客户管理',
        icon: Icons.people,
        children: [
          MenuItem(
            id: 'customer_list',
            title: '客户列表',
            content: const Center(child: Text('客户列表内容')),
          ),
          MenuItem(
            id: 'customer_groups',
            title: '客户分组',
            content: const Center(child: Text('客户分组内容')),
          ),
        ],
      ),
      MenuItem(
        id: 'reports',
        title: '报表中心',
        icon: Icons.bar_chart,
        children: [
          MenuItem(
            id: 'sales_report',
            title: '销售报表',
            content: const Center(child: Text('销售报表内容')),
          ),
          MenuItem(
            id: 'inventory_report',
            title: '库存报表',
            content: const Center(child: Text('库存报表内容')),
          ),
          MenuItem(
            id: 'financial_report',
            title: '财务报表',
            content: const Center(child: Text('财务报表内容')),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('多级菜单示例'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: MultiLevelMenuLayout(
        menuItems: _buildExampleMenu(),
        initialSelectedPath: '/dashboard',
      ),
    );
  }
}
