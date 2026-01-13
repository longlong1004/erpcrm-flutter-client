import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import './go_router_refresh_stream.dart';
import '../widgets/tabbed_main_layout.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
// import '../screens/auth/forgot_password_screen.dart'; // 文件不存在
import '../screens/home/home_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/products/product_edit_screen.dart';
import '../screens/products/product_apply_screen.dart';
import '../screens/products/product_approved_screen.dart';
import '../screens/products/product_recycle_screen.dart';
import '../screens/products/product_form_screen.dart';
import '../screens/businesses/businesses_screen.dart';// 订单管理模块
import '../screens/orders/order_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/mall_order_total_screen.dart';
import '../screens/orders/mall_order_import_screen.dart';
import '../screens/orders/mall_order_pending_delivery_screen.dart';
import '../screens/orders/collector_order_total_screen.dart';
import '../screens/orders/collector_order_import_screen.dart';
import '../screens/orders/collector_order_pending_delivery_screen.dart';
import '../screens/orders/other_order_total_screen.dart';
import '../screens/orders/other_order_import_screen.dart';
import '../screens/orders/other_order_pending_delivery_screen.dart';
import '../screens/orders/replenishment_order_screen.dart';
import '../screens/orders/handling_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/customers/customer_detail_screen.dart';
import '../screens/customers/customer_category_list_screen.dart';
import '../screens/customers/customer_tag_list_screen.dart';
import '../screens/customers/customer_contact_log_list_screen.dart';
import '../screens/customers/customer_edit_screen.dart';
import '../screens/settings/settings_screen.dart';
// import '../screens/profile/profile_screen.dart'; // 文件不存在
import '../screens/warehouse/inventory_screen.dart';
import '../screens/warehouse/product_search_screen.dart';
import '../screens/warehouse/warehousing_application_screen.dart';
import '../screens/warehouse/delivery_application_screen.dart';
import '../screens/warehouse/scrap_application_screen.dart';
import '../screens/warehouse/inventory_detail_screen.dart';
import '../screens/warehouse/inventory_edit_screen.dart';
import '../screens/warehouse/product_edit_screen.dart';
import '../screens/warehouse/warehousing_add_screen.dart';
import '../screens/warehouse/warehousing_detail_screen.dart';
import '../screens/warehouse/delivery_add_screen.dart';
import '../screens/warehouse/delivery_detail_screen.dart';
import '../screens/warehouse/scrap_add_screen.dart';
import '../screens/warehouse/scrap_detail_screen.dart';
import '../screens/notification/notification_list_screen.dart';
import '../screens/notification/notification_detail_screen.dart';

// 基本信息模块
import '../screens/basic_info/basic_info_screen.dart';
import '../screens/basic_info/department_screen.dart';
import '../screens/basic_info/position_screen.dart';
import '../screens/basic_info/category_screen.dart';
import '../screens/basic_info/tax_category_screen.dart';
import '../screens/basic_info/template_screen.dart';
import '../screens/basic_info/employee_info_screen.dart';
import '../screens/basic_info/employee_form_screen.dart';
import '../screens/basic_info/company_info_screen.dart';
import '../screens/basic_info/unit_screen.dart';

// 采购管理模块
import '../screens/purchases/purchase_list_screen.dart';
import '../screens/purchases/purchase_detail_screen.dart';

// 审批管理模块
import '../screens/approvals/approval_list_screen.dart';
import '../screens/approvals/approval_detail_screen.dart';

// 物流管理模块
import '../screens/logistics/logistics_list_screen.dart';
import '../screens/logistics/logistics_detail_screen.dart';
import '../screens/logistics/logistics_screen.dart';
import '../screens/logistics/logistics_delivery_screen.dart';

// 薪酬管理模块
import '../screens/salary/salary_list_screen.dart';
import '../screens/salary/salary_detail_screen.dart';
import '../screens/salary/attendance_screen.dart';
import '../screens/salary/leave_screen.dart';
import '../screens/salary/business_trip_screen.dart';
import '../screens/salary/points_screen.dart';
import '../screens/salary/bonus_screen.dart';
import '../screens/salary/salary_screen.dart';

// 系统权限模块
import '../screens/permissions/permission_management_screen.dart';

// 系统扩展工厂模块
import '../screens/system_factory_screen.dart';

// API配置
import '../screens/settings/api_config_screen.dart';

// 审批人代理模块
import '../screens/settings/approval_delegate_screen.dart';

// 日志管理模块
import '../screens/settings/log_management_screen.dart';

// 系统参数模块
import '../screens/settings/system_parameter_screen.dart';

// 数据字典模块
import '../screens/settings/data_dictionary_screen.dart';

// 多级菜单示例
import '../screens/example/multi_level_menu_example_screen.dart';

import '../providers/auth_provider.dart';
import '../widgets/common/auth_guard.dart';

class AppRouter {
  final Ref ref;

  AppRouter(this.ref);

  GoRouter get router => GoRouter(
        initialLocation: '/',
        redirect: (context, state) {
          final authState = ref.watch(authProvider);
          final isAuthenticated = authState.isAuthenticated;
          final currentPath = state.uri.toString();

          // 未登录用户只能访问登录页面
          if (!isAuthenticated) {
            if (currentPath != '/login') {
              return '/login';
            }
          }

          // 已登录用户默认跳转到首页
          if (isAuthenticated && currentPath == '/login') {
            return '/';
          }

          return null;
        },
        routes: [
          // 认证相关路由
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),

          // 主应用路由 - 使用ShellRoute实现共享布局
          ShellRoute(
            builder: (context, state, child) {
              // 直接使用TabbedMainLayout，将子路由作为内容传入
              return TabbedMainLayout(child: child);
            },
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ProductDetailScreen(
                      productId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ProductEditScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => ProductEditScreen(
                      productId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  // 新增商品管理子路由
                  GoRoute(
                    path: 'apply',
                    builder: (context, state) => const ProductApplyScreen(),
                  ),
                  GoRoute(
                    path: 'listed',
                    builder: (context, state) => const ProductListScreen(),
                  ),
                  GoRoute(
                    path: 'approved',
                    builder: (context, state) => const ProductApprovedScreen(),
                  ),
                  GoRoute(
                    path: 'recycle',
                    builder: (context, state) => const ProductRecycleScreen(),
                  ),
                  // 商品表单路由
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => ProductFormScreen(
                      productId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => OrderDetailScreen(
                      orderId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomersScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => CustomerDetailScreen(
                      customerId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const CustomerEditScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => CustomerEditScreen(
                      customerId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => const CustomerCategoryListScreen(),
                  ),
                  GoRoute(
                    path: 'tags',
                    builder: (context, state) => const CustomerTagListScreen(),
                  ),
                  GoRoute(
                    path: 'contact-logs',
                    builder: (context, state) => CustomerContactLogListScreen(
                      customerId: int.parse(state.uri.queryParameters['customerId']!),
                      customerName: state.uri.queryParameters['customerName']!, 
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'api-config',
                    builder: (context, state) => const ApiConfigScreen(),
                  ),
                  GoRoute(
                    path: 'approval-delegate',
                    builder: (context, state) => const ApprovalDelegateScreen(),
                  ),
                  GoRoute(
                    path: 'log-management',
                    builder: (context, state) => const LogManagementScreen(),
                  ),
                  GoRoute(
                    path: 'system-parameters',
                    builder: (context, state) => const SystemParameterScreen(),
                  ),
                  GoRoute(
                    path: 'data-dictionary',
                    builder: (context, state) => const DataDictionaryScreen(),
                  ),
                  // 系统扩展工厂路由
                  GoRoute(
                    path: 'system-factory',
                    builder: (context, state) => const SystemFactoryScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              // 业务管理路由
              GoRoute(
                path: '/businesses',
                builder: (context, state) => const BusinessesScreen(),
              ),
              // 仓库管理路由
              GoRoute(
                path: '/warehouse',
                builder: (context, state) => const InventoryScreen(),
              ),
              // 通知管理路由
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => NotificationDetailScreen(
                      notificationId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
              // 采购管理路由
              GoRoute(
                path: '/purchases',
                builder: (context, state) => const PurchaseListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => PurchaseDetailScreen(
                      purchaseId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
              // 审批管理路由
              GoRoute(
                path: '/approvals',
                builder: (context, state) => const ApprovalListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ApprovalDetailScreen(
                      approvalId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
              // 物流管理路由
              GoRoute(
                path: '/logistics',
                builder: (context, state) => const LogisticsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => LogisticsDetailScreen(
                      logisticsId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'delivery',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>? ?? {};
                      return LogisticsDeliveryScreen(
                        logisticsType: extra['logisticsType'] as String? ?? 'pre-delivery',
                        logisticsId: extra['logisticsId'] as int?,
                      );
                    },
                  ),
                  // 物流类型子路由
                  GoRoute(
                    path: 'pre-delivery',
                    builder: (context, state) => const LogisticsScreen(),
                  ),
                  GoRoute(
                    path: 'mall',
                    builder: (context, state) => const LogisticsScreen(),
                  ),
                  GoRoute(
                    path: 'collector',
                    builder: (context, state) => const LogisticsScreen(),
                  ),
                  GoRoute(
                    path: 'other',
                    builder: (context, state) => const LogisticsScreen(),
                  ),
                ],
              ),
              // 薪酬管理路由
              GoRoute(
                path: '/salary',
                builder: (context, state) => const SalaryListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => SalaryDetailScreen(
                      salaryId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  // 薪酬管理子路由
                  GoRoute(
                    path: 'attendance',
                    builder: (context, state) => const AttendanceScreen(),
                  ),
                  GoRoute(
                    path: 'leave',
                    builder: (context, state) => const LeaveScreen(),
                  ),
                  GoRoute(
                    path: 'business-trip',
                    builder: (context, state) => const BusinessTripScreen(),
                  ),
                  GoRoute(
                    path: 'points',
                    builder: (context, state) => const PointsScreen(),
                  ),
                  GoRoute(
                    path: 'salary',
                    builder: (context, state) => const SalaryScreen(),
                  ),
                  GoRoute(
                    path: 'bonus',
                    builder: (context, state) => const BonusScreen(),
                  ),
                ],
              ),
              // 系统权限路由
              GoRoute(
                path: '/permissions',
                builder: (context, state) => const PermissionManagementScreen(),
              ),
              // 基本信息模块路由
              GoRoute(
                path: '/basic-info',
                builder: (context, state) => const BasicInfoScreen(),
                routes: [
                  // 公司信息
                  GoRoute(
                    path: 'company',
                    builder: (context, state) => const CompanyInfoScreen(),
                  ),
                  // 部门管理
                  GoRoute(
                    path: 'department',
                    builder: (context, state) => const DepartmentScreen(),
                  ),
                  // 职位管理
                  GoRoute(
                    path: 'position',
                    builder: (context, state) => const PositionScreen(),
                  ),
                  // 三级分类
                  GoRoute(
                    path: 'category',
                    builder: (context, state) => const CategoryScreen(),
                  ),
                  // 税收分类
                  GoRoute(
                    path: 'tax-category',
                    builder: (context, state) => const TaxCategoryScreen(),
                  ),
                  // 模板
                  GoRoute(
                    path: 'template',
                    builder: (context, state) => const TemplateScreen(),
                  ),
                  // 员工信息
                  GoRoute(
                    path: 'employee',
                    builder: (context, state) => const EmployeeInfoScreen(),
                  ),
                  // 单位
                  GoRoute(
                    path: 'unit',
                    builder: (context, state) => const UnitScreen(),
                  ),
                ],
              ),
              // 多级菜单示例路由
              GoRoute(
                path: '/multi-level-menu-example',
                builder: (context, state) => const MultiLevelMenuExampleScreen(),
              ),
            ],
          ),
        ],
      );
}
