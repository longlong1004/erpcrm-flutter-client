import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/product/product.dart';
import '../../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
        actions: [
          IconButton(
            onPressed: () {
              // 编辑商品功能
              _showEditDialog(context, ref, productAsync.value);
            },
            icon: const Icon(Icons.edit),
            tooltip: '编辑商品',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: productAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载商品详情失败: $error'),
                  ElevatedButton(
                    onPressed: () => ref.read(productProvider(productId).notifier).fetchProduct(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
          data: (product) => _buildProductDetail(context, product),
        ),
      ),
    );
  }

  Widget _buildProductDetail(BuildContext context, Product product) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 商品图片
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: product.imageUrl != null
              ? Image.network(
                  product.imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                  ),
                )
              : const Center(
                  child: Icon(Icons.image, size: 100, color: Colors.grey),
                ),
        ),

        // 商品基本信息
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品名称
              Text(
                product.name,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              // 商品编码
              const SizedBox(height: 8),
              Text(
                '编码: ${product.code}',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),

              // 价格信息
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '¥${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  if (product.originalPrice > product.price)
                    Text(
                      '¥${product.originalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),

              // 库存信息
              const SizedBox(height: 8),
              Text(
                '库存: ${product.stock}',
                style: TextStyle(
                  color: product.stock <= 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (product.safetyStock > 0 && product.stock <= product.safetyStock)
                Text(
                  '低于安全库存(${product.safetyStock})',
                  style: TextStyle(color: Colors.orange),
                ),

              // 商品状态
              const SizedBox(height: 8),
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
            ],
          ),
        ),

        // 分割线
        const Divider(thickness: 1),

        // 商品详细信息
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '商品信息',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),
              _buildInfoRow('规格', product.specification),
              _buildInfoRow('型号', product.model),
              _buildInfoRow('单位', product.unit),
              _buildInfoRow('品牌', product.brand ?? '无'),
              _buildInfoRow('制造商', product.manufacturer ?? '无'),
              _buildInfoRow('供应商ID', product.supplierId?.toString() ?? '无'),
              _buildInfoRow('条形码', product.barcode ?? '无'),
              _buildInfoRow('分类ID', product.categoryId.toString()),
            ],
          ),
        ),

        // 分割线
        const Divider(thickness: 1),

        // 商品描述
        if (product.description != null && product.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '商品描述',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(product.description!),
              ],
            ),
          ),

        // 分割线
        const Divider(thickness: 1),

        // 创建和更新时间
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '创建信息',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                '创建时间',
                DateFormat('yyyy-MM-dd HH:mm:ss').format(product.createdAt),
              ),
              _buildInfoRow(
                '更新时间',
                DateFormat('yyyy-MM-dd HH:mm:ss').format(product.updatedAt),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
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

  void _showEditDialog(BuildContext context, WidgetRef ref, Product? product) {
    if (product == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑商品'),
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
}
