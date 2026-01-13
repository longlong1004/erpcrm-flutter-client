import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/product/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/two_level_tab_layout.dart';
import './product_apply_screen.dart';
import './product_approved_screen.dart';
import './product_recycle_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 商品管理
      TabConfig(
        title: '商品管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '商品列表',
            content: const _ProductListView(),
          ),
          SecondLevelTabConfig(
            title: '商品申请',
            content: const ProductApplyScreen(),
          ),
          SecondLevelTabConfig(
            title: '已通过商品',
            content: const ProductApprovedScreen(),
          ),
          SecondLevelTabConfig(
            title: '商品回收站',
            content: const ProductRecycleScreen(),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
      moduleName: '商品管理',
    );
  }
}

// 商品列表视图
class _ProductListView extends ConsumerStatefulWidget {
  const _ProductListView();

  @override
  ConsumerState<_ProductListView> createState() => __ProductListViewState();
}

class __ProductListViewState extends ConsumerState<_ProductListView> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final params = <String, dynamic>{};
    if (_searchController.text.isNotEmpty) {
      params['keyword'] = _searchController.text;
    }
    if (_selectedCategory != null) {
      params['categoryId'] = _selectedCategory;
    }
    if (_selectedStatus != null) {
      params['status'] = _selectedStatus;
    }

    ref.read(productsProvider.notifier).fetchProducts(params: params);
  }

  void _resetFilters() {
    _searchController.clear();
    _selectedCategory = null;
    _selectedStatus = null;
    ref.read(productsProvider.notifier).refresh();
  }

  void _showAddEditDialog([Product? product]) {
    // 这里可以实现添加/编辑商品的对话框
    // 目前先显示一个简单的实现，后续可以扩展
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? '添加商品' : '编辑商品'),
        content: const Text('商品编辑功能将在后续版本中实现'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除商品 "${product.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(productsProvider.notifier).deleteProduct(product.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('商品 "${product.name}" 已删除'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('删除失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Column(
      children: [
        // 操作按钮栏
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add),
                label: const Text('添加商品'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),
        
        // 搜索和筛选栏
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索商品名称、编码或型号',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '商品分类',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedCategory,
                      hint: const Text('选择分类'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('全部分类'),
                        ),
                        // 这里可以动态加载商品分类
                        const DropdownMenuItem(
                          value: '1',
                          child: Text('电子产品'),
                        ),
                        const DropdownMenuItem(
                          value: '2',
                          child: Text('办公用品'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '商品状态',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedStatus,
                      hint: const Text('选择状态'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('全部状态'),
                        ),
                        const DropdownMenuItem(
                          value: 'ACTIVE',
                          child: Text('正常'),
                        ),
                        const DropdownMenuItem(
                          value: 'INACTIVE',
                          child: Text('停用'),
                        ),
                        const DropdownMenuItem(
                          value: 'OUT_OF_STOCK',
                          child: Text('缺货'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('筛选'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 商品列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(productsProvider.notifier).refresh(),
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: $error'),
                    ElevatedButton(
                      onPressed: () => ref.read(productsProvider.notifier).refresh(),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('暂无商品数据'),
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        onTap: () => _showAddEditDialog(product),
                        leading: product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(
                                width: 60,
                                height: 60,
                                child: Center(child: Icon(Icons.image)),
                              ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('编码: ${product.code}'),
                            Text('规格: ${product.specification}'),
                            Text('价格: ¥${product.price?.toStringAsFixed(2) ?? '0.00'}'),
                            Text(
                              '库存: ${product.stock ?? 0}',
                              style: TextStyle(
                                color: (product.stock ?? 0) <= 0
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              '创建时间: ${DateFormat('yyyy-MM-dd HH:mm').format(product.createdAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(product.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(product.status),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(product),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: '删除',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.grey;
      case 'OUT_OF_STOCK':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ACTIVE':
        return '正常';
      case 'INACTIVE':
        return '停用';
      case 'OUT_OF_STOCK':
        return '缺货';
      default:
        return '未知';
    }
  }
}
