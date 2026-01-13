import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/models/menu_item.dart';

class SalaryMenu extends ConsumerWidget {
  const SalaryMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 构建薪酬管理子菜单
    final salaryMenuItems = [
      const MenuItem(
        title: '考勤', 
        icon: Icons.access_time, 
        route: '/salary/attendance',
        description: '管理员工考勤信息',
      ),
      const MenuItem(
        title: '请假', 
        icon: Icons.request_page, 
        route: '/salary/leave',
        description: '管理员工请假信息',
      ),
      const MenuItem(
        title: '出差', 
        icon: Icons.flight_takeoff, 
        route: '/salary/business-trip',
        description: '管理员工出差信息',
      ),
      const MenuItem(
        title: '积分', 
        icon: Icons.star, 
        route: '/salary/points',
        description: '管理员工积分信息',
      ),
      const MenuItem(
        title: '工资', 
        icon: Icons.payment, 
        route: '/salary/salary',
        description: '管理员工工资信息',
      ),
      const MenuItem(
        title: '其它奖金', 
        icon: Icons.card_giftcard, 
        route: '/salary/bonus',
        description: '管理员工其它奖金信息',
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            '薪酬管理',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF003366),
                ),
          ),
          const SizedBox(height: 12),
          // 子菜单横向滚动列表
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: salaryMenuItems.map((item) {
                // 使用GoRouter.of(context).location替代GoRouterState.of(context)，避免父路由不是页面路由时抛出异常
                final currentRoute = Router.of(context).routeInformationProvider?.value.uri.path ?? '';
                final isSelected = item.route != null && 
                                 currentRoute.startsWith(item.route!);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      if (item.route != null) {
                        // 直接导航到路由，不使用标签页系统
                        context.go(item.route!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF003366) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF003366) : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? Colors.white : const Color(0xFF616161),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF616161),
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}