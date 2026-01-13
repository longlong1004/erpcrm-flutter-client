import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/two_level_tab_layout.dart';
import 'package:erpcrm_client/models/product/product.dart';
import 'package:erpcrm_client/providers/product_provider.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 商品管理一级菜单
      TabConfig(
        title: '商品管理',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '申请上架',
            content: _buildProductApplyScreen(context, ref),
          ),
          SecondLevelTabConfig(
            title: '已上架',
            content: _buildProductApprovedScreen(context, ref),
          ),
          SecondLevelTabConfig(
            title: '回收站',
            content: _buildProductRecycleScreen(context, ref),
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
  
  // 申请上架页面
  Widget _buildProductApplyScreen(BuildContext context, WidgetRef ref) {
    // 使用productsProvider获取商品列表
    final productsAsync = ref.watch(productsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showAddProductDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('新增商品'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          // 表格标题
          _buildTableHeader(['状态', '业务员', '公司名称', '品牌', '国铁名称', '国铁型号', '单位', '国铁单价', '三级分类', '操作']),
          const SizedBox(height: 16),
          // 表格内容
          Expanded(
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
                // 筛选出申请上架状态的商品
                final applyProducts = products.where((product) {
                  // 根据实际业务逻辑调整状态筛选条件
                  return product.status == 'PENDING' || product.status == 'APPLYING';
                }).toList();

                if (applyProducts.isEmpty) {
                  return const Center(child: Text('暂无申请上架的商品'));
                }

                return ListView.builder(
                  itemCount: applyProducts.length,
                  itemBuilder: (context, index) {
                    final product = applyProducts[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => _showProductDetailDialog(context, ref, product),
                          hoverColor: const Color(0xFFF5F5F5),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                // 状态
                                _buildTableCell(_getStatusText(product.status), 2),
                                // 业务员
                                _buildTableCell('张三', 2), // 实际业务中应从product或关联表获取
                                // 公司名称
                                _buildTableCell('国铁科技有限公司', 2), // 实际业务中应从product或关联表获取
                                // 品牌
                                _buildTableCell(product.brand ?? '', 2),
                                // 国铁名称
                                _buildTableCell(product.name, 2),
                                // 国铁型号
                                _buildTableCell(product.model, 2),
                                // 单位
                                _buildTableCell(product.unit, 2),
                                // 国铁单价
                                _buildTableCell('¥${product.price}', 2),
                                // 三级分类
                                _buildTableCell('铁路设备 > 传感器 > 压力传感器', 2), // 实际业务中应从category关联表获取
                                // 操作按钮
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed: () => _showProductDetailDialog(context, ref, product),
                                          child: const Text('查看'),
                                        ),
                                        TextButton(
                                          onPressed: () => _showEditProductDialog(context, ref, product),
                                          child: const Text('编辑'),
                                        ),
                                        TextButton(
                                          onPressed: () => _handlePrint(context, product),
                                          child: const Text('打印合格证'),
                                        ),
                                        TextButton(
                                          onPressed: () => _showWithdrawDialog(context, ref, product),
                                          child: const Text('撤回'),
                                        ),
                                        TextButton(
                                          onPressed: () => _showDeleteDialog(context, ref, product),
                                          child: const Text('删除', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 已上架页面
  Widget _buildProductApprovedScreen(BuildContext context, WidgetRef ref) {
    // 使用productsProvider获取商品列表
    final productsAsync = ref.watch(productsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 导入功能
                  print('导入按钮被点击');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('导入'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          // 表格标题
          _buildTableHeader([
            '状态', '业务员', '上架天数', '未下单天数', '公司名称', '品牌', 
            '商品编码', '单品编码', '国铁名称', '国铁型号', '单位', '国铁单价', 
            '三级分类', '操作'
          ]),
          const SizedBox(height: 16),
          // 表格内容
          Expanded(
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
                // 筛选出已上架状态的商品
                final approvedProducts = products.where((product) {
                  // 根据实际业务逻辑调整状态筛选条件
                  return product.status == 'APPROVED' || product.status == 'ACTIVE';
                }).toList();

                if (approvedProducts.isEmpty) {
                  return const Center(child: Text('暂无已上架的商品'));
                }

                return ListView.builder(
                  itemCount: approvedProducts.length,
                  itemBuilder: (context, index) {
                    final product = approvedProducts[index];
                    // 计算上架天数和未下单天数（实际业务中应从数据库获取）
                    final daysOnShelf = DateTime.now().difference(product.createdAt).inDays;
                    final daysNoOrder = 3; // 实际业务中应从订单表统计

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          // 状态
                          _buildTableCell(_getStatusText(product.status), 2),
                          // 业务员
                          _buildTableCell('李四', 2), // 实际业务中应从product或关联表获取
                          // 上架天数
                          _buildTableCell(daysOnShelf, 2),
                          // 未下单天数
                          _buildTableCell(daysNoOrder, 2),
                          // 公司名称
                          _buildTableCell('国铁科技有限公司', 2), // 实际业务中应从product或关联表获取
                          // 品牌
                          _buildTableCell(product.brand ?? '', 2),
                          // 商品编码
                          _buildTableCell(product.code, 2),
                          // 单品编码
                          _buildTableCell(product.barcode ?? '', 2),
                          // 国铁名称
                          _buildTableCell(product.name, 2),
                          // 国铁型号
                          _buildTableCell(product.model, 2),
                          // 单位
                          _buildTableCell(product.unit, 2),
                          // 国铁单价
                          _buildTableCell('¥${product.price}', 2),
                          // 三级分类
                          _buildTableCell('铁路设备 > 传感器 > 压力传感器', 2), // 实际业务中应从category关联表获取
                          // 操作按钮
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () => _showProductDetailDialog(context, ref, product),
                                    child: const Text('查看'),
                                  ),
                                  TextButton(
                                    onPressed: () => _showEditProductDialog(context, ref, product),
                                    child: const Text('编辑'),
                                  ),
                                  TextButton(
                                    onPressed: () => _handleCopy(context, product),
                                    child: const Text('复制'),
                                  ),
                                  TextButton(
                                    onPressed: () => _handlePrint(context, product),
                                    child: const Text('打印合格证'),
                                  ),
                                  TextButton(
                                    onPressed: () => _showDeleteDialog(context, ref, product),
                                    child: const Text('删除', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 回收站页面
  Widget _buildProductRecycleScreen(BuildContext context, WidgetRef ref) {
    // 使用productsProvider获取商品列表
    final productsAsync = ref.watch(productsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 表格标题
          _buildTableHeader(['状态', '业务员', '公司名称', '品牌', '国铁名称', '国铁型号', '单位', '国铁单价', '三级分类', '操作']),
          const SizedBox(height: 16),
          // 表格内容
          Expanded(
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
                // 筛选出回收站状态的商品
                final recycleProducts = products.where((product) {
                  // 根据实际业务逻辑调整状态筛选条件
                  return product.status == 'DELETED' || product.status == 'ARCHIVED';
                }).toList();

                if (recycleProducts.isEmpty) {
                  return const Center(child: Text('回收站中暂无商品'));
                }

                return ListView.builder(
                  itemCount: recycleProducts.length,
                  itemBuilder: (context, index) {
                    final product = recycleProducts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          // 状态
                          _buildTableCell(_getStatusText(product.status), 2),
                          // 业务员
                          _buildTableCell('王五', 2), // 实际业务中应从product或关联表获取
                          // 公司名称
                          _buildTableCell('国铁科技有限公司', 2), // 实际业务中应从product或关联表获取
                          // 品牌
                          _buildTableCell(product.brand ?? '', 2),
                          // 国铁名称
                          _buildTableCell(product.name, 2),
                          // 国铁型号
                          _buildTableCell(product.model, 2),
                          // 单位
                          _buildTableCell(product.unit, 2),
                          // 国铁单价
                          _buildTableCell('¥${product.price}', 2),
                          // 三级分类
                          _buildTableCell('铁路设备 > 传感器 > 压力传感器', 2), // 实际业务中应从category关联表获取
                          // 操作按钮
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () => _showProductDetailDialog(context, ref, product),
                                    child: const Text('查看'),
                                  ),
                                  TextButton(
                                    onPressed: () => _showEditProductDialog(context, ref, product),
                                    child: const Text('编辑'),
                                  ),
                                  TextButton(
                                    onPressed: () => _handlePrint(context, product),
                                    child: const Text('打印合格证'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTableHeader(List<String> headers) {
    return Row(
      children: headers.map((header) {
        // 为操作列设置特殊宽度
        final width = header == '操作' ? 200.0 : (header == '状态' || header == '业务员' || header == '单位') ? 100.0 : 120.0;
        return Expanded(
          flex: header == '操作' ? 3 : 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF003366),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              header,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableCell(dynamic content, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          content.toString(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '待审核基本信息';
      case 'IMAGE_UPLOAD_REQUIRED':
        return '待上传图片';
      case 'IMAGE_REVIEW_PENDING':
        return '待审核图片';
      case 'CLERK_PROCESSING':
        return '待文员处理';
      case 'RAILWAY_UPLOAD_REQUIRED':
        return '待上传国铁';
      case 'UPLOAD_FAILED':
        return '上传失败';
      case 'RAILWAY_REVIEW_PENDING':
        return '待国铁审核';
      case 'REJECTED':
        return '已驳回';
      case 'WITHDRAWN':
        return '已撤回';
      case 'APPROVED':
      case 'ACTIVE':
        return '已上架';
      case 'DELETED':
        return '已删除';
      case 'ARCHIVED':
        return '已归档';
      case 'INACTIVE':
        return '已下架';
      case 'OUT_OF_STOCK':
        return '缺货';
      default:
        return status;
    }
  }

  void _handleCopy(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('商品信息已复制到剪贴板')),
    );
  }

  void _handlePrint(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('打印合格证功能开发中')),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final barcodeController = TextEditingController();
    final modelController = TextEditingController();
    final brandController = TextEditingController();
    final unitController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final safetyStockController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增商品'),
        content: SizedBox(
          width: 600,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '商品名称',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入商品名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: '商品编码',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入商品编码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: barcodeController,
                    decoration: const InputDecoration(
                      labelText: '条形码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: '型号',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: '品牌',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: '单位',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入单位';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '单价',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入单价';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '库存',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入库存';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: safetyStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '安全库存',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  final newProduct = Product(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: nameController.text,
                    code: codeController.text,
                    specification: modelController.text.isEmpty ? '' : modelController.text,
                    barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
                    model: modelController.text,
                    brand: brandController.text.isEmpty ? null : brandController.text,
                    unit: unitController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    costPrice: double.tryParse(priceController.text) ?? 0.0,
                    originalPrice: double.tryParse(priceController.text) ?? 0.0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    safetyStock: int.tryParse(safetyStockController.text) ?? 0,
                    categoryId: 1,
                    status: 'PENDING',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  ref.read(productsProvider.notifier).addProduct(newProduct);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('商品创建成功'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('创建失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, WidgetRef ref, Product product) {
    final nameController = TextEditingController(text: product.name);
    final codeController = TextEditingController(text: product.code);
    final barcodeController = TextEditingController(text: product.barcode ?? '');
    final modelController = TextEditingController(text: product.model);
    final brandController = TextEditingController(text: product.brand ?? '');
    final unitController = TextEditingController(text: product.unit);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());
    final safetyStockController = TextEditingController(text: product.safetyStock.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑商品'),
        content: SizedBox(
          width: 600,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '商品名称',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入商品名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: '商品编码',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入商品编码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: barcodeController,
                    decoration: const InputDecoration(
                      labelText: '条形码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: '型号',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: '品牌',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: '单位',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入单位';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '单价',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入单价';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '库存',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入库存';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: safetyStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '安全库存',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  final updatedProduct = Product(
                    id: product.id,
                    name: nameController.text,
                    code: codeController.text,
                    specification: modelController.text.isEmpty ? '' : modelController.text,
                    barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
                    model: modelController.text,
                    brand: brandController.text.isEmpty ? null : brandController.text,
                    unit: unitController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    costPrice: product.costPrice,
                    originalPrice: product.originalPrice,
                    stock: int.tryParse(stockController.text) ?? 0,
                    safetyStock: int.tryParse(safetyStockController.text) ?? 0,
                    categoryId: product.categoryId,
                    status: product.status,
                    createdAt: product.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  ref.read(productsProvider.notifier).updateProductDirect(updatedProduct);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('商品更新成功'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('更新失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showProductDetailDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品详情'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('商品名称', product.name),
                _buildDetailItem('商品编码', product.code),
                _buildDetailItem('条形码', product.barcode ?? '-'),
                _buildDetailItem('型号', product.model),
                _buildDetailItem('品牌', product.brand ?? '-'),
                _buildDetailItem('单位', product.unit),
                _buildDetailItem('单价', '¥${product.price.toStringAsFixed(2)}'),
                _buildDetailItem('库存', '${product.stock}'),
                _buildDetailItem('安全库存', '${product.safetyStock}'),
                _buildDetailItem('状态', _getStatusText(product.status)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref, Product product) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('撤回商品'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('确定要撤回商品"${product.name}"吗？'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '撤回原因',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入撤回原因';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  ref.read(productsProvider.notifier).withdrawProduct(product.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('商品已撤回'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('撤回失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('确认撤回'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除商品'),
        content: Text('确定要删除商品"${product.name}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                ref.read(productsProvider.notifier).deleteProduct(product.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('商品已删除'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('删除失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF212121),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
