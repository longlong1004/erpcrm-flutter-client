import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/crm_provider.dart';
import 'package:erpcrm_client/models/crm/customer.dart';
import '../../widgets/two_level_tab_layout.dart';
import './customer_category_list_screen.dart';
import './customer_tag_list_screen.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 客户管理
      TabConfig(
        title: '客户管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '客户列表',
            content: const _CustomerListView(),
          ),
          SecondLevelTabConfig(
            title: '客户分类',
            content: const CustomerCategoryListScreen(),
          ),
          SecondLevelTabConfig(
            title: '客户标签',
            content: const CustomerTagListScreen(),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
      moduleName: '客户管理',
    );
  }
}

// 客户列表视图
class _CustomerListView extends ConsumerWidget {
  const _CustomerListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    final searchController = TextEditingController();

    return Column(
      children: [
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '客户列表',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/customers/new');
                },
                icon: const Icon(Icons.add),
                label: const Text('添加客户'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
        // 搜索框
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索客户名称或联系人',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  searchController.clear();
                  ref.refresh(customersProvider);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF003366)),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (keyword) {
              if (keyword.isNotEmpty) {
                ref.read(customersProvider.notifier).searchCustomers(keyword);
              } else {
                ref.refresh(customersProvider);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        // 客户列表
        Expanded(
          child: customers.when(
            data: (customerList) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    itemCount: customerList.length,
                    itemBuilder: (context, index) {
                      final customer = customerList[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              context.push('/customers/${customer.customerId}');
                            },
                            hoverColor: const Color(0xFFF5F5F5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF003366),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '联系人: ${customer.contactPerson}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '电话: ${customer.contactPhone}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '邮箱: ${customer.contactEmail}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(Icons.category_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              '分类: ${customer.categoryName}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF003366),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < customerList.length - 1)
                            const Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Color(0xFFE0E0E0),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF003366),
                ),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败: $error',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(customersProvider),
                    child: const Text('重试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}