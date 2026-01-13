import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/screens/auth/login_screen.dart';
import 'package:erpcrm_client/screens/auth/register_screen.dart';
import 'package:erpcrm_client/screens/dashboard/dashboard_screen.dart';
import 'package:erpcrm_client/screens/products/products_screen.dart';
import 'package:erpcrm_client/screens/products/product_apply_screen.dart';
import 'package:erpcrm_client/screens/orders/orders_screen.dart';
import 'package:erpcrm_client/screens/orders/order_list_screen.dart';
import 'package:erpcrm_client/screens/orders/menu_test_screen.dart';
import 'package:erpcrm_client/screens/customers/customers_screen.dart';
import 'package:erpcrm_client/screens/customers/ai_analysis_screen.dart';
import 'package:erpcrm_client/screens/customers/simple_ai_analysis_screen.dart';
import 'package:erpcrm_client/screens/settings/interactive_settings_screen.dart';
import 'package:erpcrm_client/screens/settings/process_design_screen.dart';
import 'package:erpcrm_client/screens/settings/process_list_screen.dart';
import 'package:erpcrm_client/screens/settings/process_designer_screen.dart';
import 'package:erpcrm_client/screens/settings/new_process_designer_screen.dart';
import 'package:erpcrm_client/screens/settings/process_configuration_screen.dart';
import 'package:erpcrm_client/screens/settings/process_wizard_screen.dart';
import 'package:erpcrm_client/screens/settings/approval_delegate_screen.dart';
import 'package:erpcrm_client/screens/settings/log_management_screen.dart';
import 'package:erpcrm_client/screens/settings/system_parameter_screen.dart';
import 'package:erpcrm_client/screens/settings/data_dictionary_screen.dart';
import 'package:erpcrm_client/screens/settings/settings_screen.dart';
import 'package:erpcrm_client/screens/businesses/businesses_screen.dart';
import 'package:erpcrm_client/screens/approval/approval_screen.dart';
import 'package:erpcrm_client/screens/approval/approval_detail_screen.dart';
import 'package:erpcrm_client/screens/approval/approval_process_screen.dart';
import 'package:erpcrm_client/screens/logistics/logistics_screen.dart';
import 'package:erpcrm_client/screens/procurement/procurement_screen.dart';
import 'package:erpcrm_client/screens/finance/finance_screen.dart';
import 'package:erpcrm_client/screens/warehouse/warehouse_screen.dart';
import 'package:erpcrm_client/screens/warehouse/inventory_screen.dart';
import 'package:erpcrm_client/screens/warehouse/product_search_screen.dart';
import 'package:erpcrm_client/screens/warehouse/warehousing_application_screen.dart';
import 'package:erpcrm_client/screens/warehouse/delivery_application_screen.dart';
import 'package:erpcrm_client/screens/warehouse/scrap_application_screen.dart';
import 'package:erpcrm_client/screens/salary/salary_screen.dart';
import 'package:erpcrm_client/screens/salary/attendance_screen.dart';
import 'package:erpcrm_client/screens/salary/leave_screen.dart';
import 'package:erpcrm_client/screens/salary/business_trip_screen.dart';
import 'package:erpcrm_client/screens/salary/points_screen.dart';
import 'package:erpcrm_client/screens/salary/salary_list_screen.dart';
import 'package:erpcrm_client/screens/salary/bonus_screen.dart';
import 'package:erpcrm_client/screens/basic_info/basic_info_screen.dart';
import 'package:erpcrm_client/screens/basic_info/company_info_screen.dart';
import 'package:erpcrm_client/screens/basic_info/customer/railway_station_screen.dart';
import 'package:erpcrm_client/screens/basic_info/customer/contact_info_screen.dart';
import 'package:erpcrm_client/screens/basic_info/supplier_info_screen.dart';
import 'package:erpcrm_client/screens/basic_info/unit_screen.dart';
import 'package:erpcrm_client/screens/basic_info/category_screen.dart';
import 'package:erpcrm_client/screens/basic_info/tax_category_screen.dart';
import 'package:erpcrm_client/screens/basic_info/template_screen.dart';
import 'package:erpcrm_client/screens/basic_info/employee_info_screen.dart';
import 'package:erpcrm_client/screens/basic_info/department_screen.dart';
import 'package:erpcrm_client/screens/basic_info/position_screen.dart';
import 'package:erpcrm_client/screens/permissions/permissions_screen.dart';
import 'package:erpcrm_client/screens/notification/notification_list_screen.dart';
import 'package:erpcrm_client/screens/notification/notification_settings_screen.dart';
import 'package:erpcrm_client/screens/system_factory_screen.dart';
import 'package:erpcrm_client/screens/demo_form_screen.dart';
import 'package:erpcrm_client/providers/auth_provider.dart';
import 'package:erpcrm_client/providers/auth_listenable.dart';
import 'package:erpcrm_client/widgets/tabbed_main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: ref.watch(authListenableProvider),
    redirect: (context, state) {
      final authState = ref.watch(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      
      // 获取当前路径，如果为null，则使用state.matchedLocation
      final currentPath = state.path ?? state.matchedLocation;
      final isGoingToLogin = currentPath == '/login';
      final isGoingToRegister = currentPath == '/register';
      
      print('GoRouter redirect: isLoggedIn=$isLoggedIn, isGoingToLogin=$isGoingToLogin, isGoingToRegister=$isGoingToRegister, currentPath=$currentPath');
      print('GoRouter redirect: authState详细信息 - isAuthenticated=${authState.isAuthenticated}, user=${authState.user?.username}, token=${authState.token != null ? '存在' : '不存在'}');
      
      if (!isLoggedIn) {
        // 用户未认证，跳转到登录页面
        if (!isGoingToLogin && !isGoingToRegister) {
          print('用户未认证，跳转到登录页面');
          return '/login';
        }
        print('用户未认证，但已在登录或注册页面，不跳转');
        return null; // 已经在登录或注册页面，不跳转
      }
      
      // 用户已认证
      if (isGoingToLogin || isGoingToRegister) {
        // 如果当前在登录或注册页面，跳转到仪表盘
        print('用户已认证，当前在登录或注册页面，跳转到仪表盘页面');
        return '/dashboard';
      }
      
      print('用户已认证，当前在合法页面，不进行跳转，保持当前页面');
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // 主应用布局路由 - 包含标签页管理
      ShellRoute(
        builder: (context, state, child) {
          return TabbedMainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreenComplete(),
          ),
          GoRoute(
            path: '/approval',
            redirect: (context, state) => '/approval/pending',
            builder: (context, state) => const ApprovalScreen(),
            routes: [
              GoRoute(
                path: 'pending',
                builder: (context, state) => ApprovalScreen(),
              ),
              GoRoute(
                path: 'approved',
                builder: (context, state) => ApprovalScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) => ApprovalDetailScreen(
                  approvalId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'process/:id',
                builder: (context, state) => ApprovalProcessScreen(
                  approvalId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/products',

            builder: (context, state) => ProductsScreen(),
            routes: [
              GoRoute(
              path: 'apply',
              builder: (context, state) => ProductsScreen(),
            ),
              GoRoute(
                path: 'listed',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'recycle',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'approved',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'mall/total',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'mall/import',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'mall/pending-delivery',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'collector/total',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'collector/import',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'collector/pending-delivery',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'other/total',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'other/import',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'other/pending-delivery',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'supplement',
                builder: (context, state) => ProductsScreen(),
              ),
              GoRoute(
                path: 'handle',
                builder: (context, state) => ProductsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/orders',
            redirect: (context, state) => '/orders/mall/total',
            builder: (context, state) => OrderListScreen(),
            routes: [
              GoRoute(
                path: 'mall',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'mall/total',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'mall/import',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'mall/pending-delivery',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'collector',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'collector/total',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'collector/import',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'collector/pending-delivery',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'other',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'other/total',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'other/import',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'other/pending-delivery',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'supplement',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'handle',
                builder: (context, state) => OrdersScreen(),
              ),
              GoRoute(
                path: 'external',
                builder: (context, state) => OrdersScreen(),
              ),
              // 测试页面
              GoRoute(
                path: 'menu-test',
                builder: (context, state) => const MenuTestScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            redirect: (context, state) => '/customers/categories',
            builder: (context, state) => const CustomersScreen(),
            routes: [
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CustomersScreen(),
              ),
              GoRoute(
                path: 'tags',
                builder: (context, state) => const CustomersScreen(),
              ),
              GoRoute(
                path: 'contact-logs',
                builder: (context, state) => const CustomersScreen(),
              ),
              GoRoute(
                path: 'sales-opportunities',
                builder: (context, state) => const CustomersScreen(),
              ),
              GoRoute(
                path: 'contacts',
                builder: (context, state) => const CustomersScreen(),
              ),
              GoRoute(
                path: 'ai-analysis',
                builder: (context, state) => const SimpleAIAnalysisScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/businesses',
            redirect: (context, state) => '/businesses/batch-purchase/participable',
            builder: (context, state) => const BusinessesScreen(),
            routes: [
              GoRoute(
                path: 'batch-purchase',
                builder: (context, state) => const BusinessesScreen(),
                routes: [
                  GoRoute(
                    path: 'participable',
                    builder: (context, state) => const BusinessesScreen(),
                  ),
                  GoRoute(
                    path: 'category-match',
                    builder: (context, state) => const BusinessesScreen(),
                  ),
                  GoRoute(
                    path: 'category-not-match',
                    builder: (context, state) => const BusinessesScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'bidding',
                builder: (context, state) => const BusinessesScreen(),
              ),
              GoRoute(
                path: 'auction',
                builder: (context, state) => const BusinessesScreen(),
              ),
              GoRoute(
                path: 'pre-delivery',
                builder: (context, state) => const BusinessesScreen(),
              ),
              GoRoute(
                path: 'pre-plan',
                builder: (context, state) => const BusinessesScreen(),
              ),
              GoRoute(
                path: 'leads',
                builder: (context, state) => const BusinessesScreen(),
              ),
              GoRoute(
                path: 'opportunities',
                builder: (context, state) => const BusinessesScreen(),
              ),
              GoRoute(
                path: 'public-pool',
                builder: (context, state) => const BusinessesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/logistics',
            redirect: (context, state) => '/logistics/pre-delivery',
            builder: (context, state) => const LogisticsScreen(),
            routes: [
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
          GoRoute(
            path: '/procurement',
            redirect: (context, state) => '/procurement/orders',
            builder: (context, state) => ProcurementScreen(),
            routes: [
              GoRoute(
                path: 'orders',
                builder: (context, state) => ProcurementScreen(),
              ),
              GoRoute(
                path: 'applications',
                builder: (context, state) => ProcurementScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/finance',
            redirect: (context, state) => '/finance/receivable/mall',
            builder: (context, state) => FinanceScreen(),
            routes: [
              GoRoute(
                path: 'receivable/mall',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'receivable/collector',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'receivable/other',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'receivable/external',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'payable',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'invoice/incoming',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'invoice/outgoing',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'income/other',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'expense/other',
                builder: (context, state) => FinanceScreen(),
              ),
              GoRoute(
                path: 'reimbursement',
                builder: (context, state) => FinanceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/warehouse',
            redirect: (context, state) => '/warehouse/inventory',
            builder: (context, state) => const WarehouseScreen(),
            routes: [
              GoRoute(
                path: 'inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
              GoRoute(
                path: 'search',
                builder: (context, state) => const ProductSearchScreen(),
              ),
              GoRoute(
                path: 'warehousing',
                builder: (context, state) => const WarehousingApplicationScreen(),
              ),
              GoRoute(
                path: 'delivery',
                builder: (context, state) => const DeliveryApplicationScreen(),
              ),
              GoRoute(
                path: 'scrap',
                builder: (context, state) => const ScrapApplicationScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/basic-info',
            redirect: (context, state) => '/basic-info/company',
            builder: (context, state) => const BasicInfoScreen(),
            routes: [
              GoRoute(
                path: 'company',
                builder: (context, state) => const CompanyInfoScreen(),
              ),
              GoRoute(
                path: 'customer/railway',
                builder: (context, state) => const RailwayStationScreen(),
              ),
              GoRoute(
                path: 'customer/contacts',
                builder: (context, state) => const ContactInfoScreen(),
              ),
              GoRoute(
                path: 'supplier',
                builder: (context, state) => const SupplierInfoScreen(),
              ),
              GoRoute(
                path: 'unit',
                builder: (context, state) => const UnitScreen(),
              ),
              GoRoute(
                path: 'category',
                builder: (context, state) => const CategoryScreen(),
              ),
              GoRoute(
                path: 'tax-category',
                builder: (context, state) => const TaxCategoryScreen(),
              ),
              GoRoute(
                path: 'template',
                builder: (context, state) => const TemplateScreen(),
              ),
              GoRoute(
                path: 'employee',
                builder: (context, state) => const EmployeeInfoScreen(),
              ),
              GoRoute(
                path: 'department',
                builder: (context, state) => const DepartmentScreen(),
              ),
              GoRoute(
                path: 'position',
                builder: (context, state) => const PositionScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/salary',
            redirect: (context, state) => '/salary/attendance',
            builder: (context, state) => const SalaryScreen(),
            routes: [
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
                builder: (context, state) => const SalaryListScreen(),
              ),
              GoRoute(
                path: 'bonus',
                builder: (context, state) => const BonusScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            redirect: (context, state) {
              // 只有当访问/settings根路径时才重定向，子路径不重定向
              if (state.uri.path == '/settings') {
                return '/settings/process-design/list';
              }
              return null;
            },
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'process-design',
                builder: (context, state) => const ProcessDesignScreen(),
                routes: [
                  GoRoute(
                    path: 'list',
                    builder: (context, state) => const ProcessListScreen(),
                  ),
                  GoRoute(
                    path: 'wizard',
                    builder: (context, state) => const ProcessWizardScreen(),
                  ),
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const NewProcessDesignerScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:processId',
                    builder: (context, state) => NewProcessDesignerScreen(
                      processId: state.pathParameters['processId'],
                      processName: '编辑流程',
                    ),
                  ),
                  GoRoute(
                    path: 'configure',
                    builder: (context, state) => const ProcessConfigurationScreen(),
                  ),
                  GoRoute(
                    path: 'configure/:processId',
                    builder: (context, state) => ProcessConfigurationScreen(
                      processId: state.pathParameters['processId'],
                    ),
                  ),
                ],
              ),
              // 替换审批人路由
              GoRoute(
                path: 'approval-delegate',
                builder: (context, state) => const ApprovalDelegateScreen(),
              ),
              // 日志管理路由
              GoRoute(
                path: 'log-management',
                builder: (context, state) => const LogManagementScreen(),
              ),
              // 系统参数路由
              GoRoute(
                path: 'system-parameters',
                builder: (context, state) => const SystemParameterScreen(),
              ),
              // 数据字典路由
              GoRoute(
                path: 'data-dictionary',
                builder: (context, state) => const DataDictionaryScreen(),
              ),
            ],
          ),
          // 系统扩展工厂路由（独立路由，不作为/settings的子路由）
          GoRoute(
            path: '/settings/system-factory',
            builder: (context, state) => const SystemFactoryScreen(),
          ),
          GoRoute(
            path: '/permissions',
            builder: (context, state) => const PermissionsScreen(),
          ),
          // 通知相关路由
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationListScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const NotificationSettingsScreen(),
              ),
            ],
          ),
          // 演示表单路由
          GoRoute(
            path: '/demo-form',
            builder: (context, state) => const DemoFormScreen(),
          ),
        ],
      ),
    ],
  );
});
