import 'package:flutter_riverpod/flutter_riverpod.dart';

// 模块页面模型
class ModulePage {
  final String id;
  final String title;
  final String description;
  final String route;
  final String status;
  final String moduleName;

  ModulePage({
    required this.id,
    required this.title,
    required this.description,
    required this.route,
    required this.status,
    required this.moduleName,
  });
}

// 模块页面状态管理提供器
final modulePagesProvider = NotifierProvider<ModulePagesNotifier, Map<String, List<ModulePage>>>(ModulePagesNotifier.new);

class ModulePagesNotifier extends Notifier<Map<String, List<ModulePage>>> {
  // 模拟模块页面数据
  final Map<String, List<ModulePage>> _mockModulePages = {
    '/dashboard': [
      ModulePage(
        id: '1',
        title: '仪表板',
        description: '系统概览和关键指标',
        route: '/dashboard',
        status: 'active',
        moduleName: '仪表板',
      ),
    ],
    '/orders': [
      ModulePage(
        id: '2',
        title: '订单列表',
        description: '查看和管理所有订单',
        route: '/orders',
        status: 'active',
        moduleName: '订单管理',
      ),
      ModulePage(
        id: '3',
        title: '商城订单',
        description: '查看和管理商城订单',
        route: '/orders/mall',
        status: 'active',
        moduleName: '订单管理',
      ),
      ModulePage(
        id: '4',
        title: '集货商订单',
        description: '查看和管理集货商订单',
        route: '/orders/collector',
        status: 'active',
        moduleName: '订单管理',
      ),
    ],
    '/products': [
      ModulePage(
        id: '5',
        title: '商品列表',
        description: '查看和管理所有商品',
        route: '/products',
        status: 'active',
        moduleName: '商品管理',
      ),
      ModulePage(
        id: '6',
        title: '商品申请',
        description: '申请新商品',
        route: '/products/apply',
        status: 'active',
        moduleName: '商品管理',
      ),
      ModulePage(
        id: '7',
        title: '已审批商品',
        description: '查看已审批的商品',
        route: '/products/approved',
        status: 'active',
        moduleName: '商品管理',
      ),
    ],
    '/customers': [
      ModulePage(
        id: '8',
        title: '客户列表',
        description: '查看和管理所有客户',
        route: '/customers',
        status: 'active',
        moduleName: '客户管理',
      ),
      ModulePage(
        id: '9',
        title: '客户分类',
        description: '管理客户分类',
        route: '/customers/categories',
        status: 'active',
        moduleName: '客户管理',
      ),
      ModulePage(
        id: '10',
        title: '客户标签',
        description: '管理客户标签',
        route: '/customers/tags',
        status: 'active',
        moduleName: '客户管理',
      ),
    ],
    '/businesses': [
      ModulePage(
        id: '11',
        title: '业务管理',
        description: '查看和管理所有业务',
        route: '/businesses',
        status: 'active',
        moduleName: '业务管理',
      ),
    ],
    '/procurement': [
      ModulePage(
        id: '12',
        title: '采购管理',
        description: '查看和管理采购订单',
        route: '/procurement',
        status: 'active',
        moduleName: '采购管理',
      ),
    ],
    '/approvals': [
      ModulePage(
        id: '13',
        title: '审批管理',
        description: '查看和管理审批流程',
        route: '/approvals',
        status: 'active',
        moduleName: '审批管理',
      ),
    ],
    '/warehouse': [
      ModulePage(
        id: '14',
        title: '仓库管理',
        description: '查看和管理仓库库存',
        route: '/warehouse',
        status: 'active',
        moduleName: '仓库管理',
      ),
    ],
    '/logistics': [
      ModulePage(
        id: '15',
        title: '物流管理',
        description: '查看和管理物流信息',
        route: '/logistics',
        status: 'active',
        moduleName: '物流管理',
      ),
    ],
    '/salary': [
      ModulePage(
        id: '16',
        title: '薪酬管理',
        description: '查看和管理薪酬信息',
        route: '/salary',
        status: 'active',
        moduleName: '薪酬管理',
      ),
    ],
    '/settings': [
      ModulePage(
        id: '17',
        title: '系统设置',
        description: '配置系统参数和设置',
        route: '/settings',
        status: 'active',
        moduleName: '系统设置',
      ),
    ],
    '/demo-form': [
      ModulePage(
        id: '18',
        title: '演示表单',
        description: '演示表单功能',
        route: '/demo-form',
        status: 'active',
        moduleName: '演示功能',
      ),
    ],
  };

  @override
  Map<String, List<ModulePage>> build() {
    // 初始化模块页面数据
    return _mockModulePages;
  }

  // 获取指定模块的页面列表
  List<ModulePage> getModulePages(String moduleRoute) {
    // 提取模块的基础路由
    final baseRoute = _extractBaseRoute(moduleRoute);
    return state[baseRoute] ?? [];
  }

  // 提取模块的基础路由
  String _extractBaseRoute(String route) {
    // 对于带参数的路由，提取基础部分
    if (route.contains('/:')) {
      return route.substring(0, route.indexOf('/:'));
    }
    // 对于多级路由，提取第一级子路由
    final parts = route.split('/')..removeWhere((part) => part.isEmpty);
    if (parts.length > 1) {
      return '/${parts[0]}';
    }
    return route;
  }

  // 更新模块页面状态
  void updateModulePageStatus(String moduleRoute, String pageId, String newStatus) {
    final baseRoute = _extractBaseRoute(moduleRoute);
    final updatedPages = state[baseRoute]?.map((page) {
      if (page.id == pageId) {
        return ModulePage(
          id: page.id,
          title: page.title,
          description: page.description,
          route: page.route,
          status: newStatus,
          moduleName: page.moduleName,
        );
      }
      return page;
    }).toList();

    if (updatedPages != null) {
      state = {
        ...state,
        baseRoute: updatedPages,
      };
    }
  }
}

// 获取当前模块的页面列表的提供者
final currentModulePagesProvider = Provider.family<List<ModulePage>, String>((ref, currentRoute) {
  final modulePages = ref.watch(modulePagesProvider);
  final notifier = ref.read(modulePagesProvider.notifier);
  return notifier.getModulePages(currentRoute);
});
