import 'package:flutter/material.dart';
import 'package:erpcrm_client/services/product_data_service.dart';
import 'package:erpcrm_client/widgets/common/modern_card.dart';

/// 商品仪表盘页面
class ProductDashboardScreen extends StatefulWidget {
  const ProductDashboardScreen({super.key});

  @override
  State<ProductDashboardScreen> createState() => _ProductDashboardScreenState();
}

class _ProductDashboardScreenState extends State<ProductDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final metrics = await ProductDataService.getProductMetrics();
    setState(() {
      _metrics = metrics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('商品仪表盘'),
        backgroundColor: const Color(0xFF003366),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    ModernCard(
                      title: '商品总数',
                      value: '${_metrics['totalProducts'] ?? 0}',
                      unit: '种',
                      icon: Icons.shopping_bag,
                      color: Colors.blue,
                    ),
                    ModernCard(
                      title: '在售商品',
                      value: '${_metrics['activeProducts'] ?? 0}',
                      unit: '种',
                      icon: Icons.store,
                      color: Colors.green,
                    ),
                    ModernCard(
                      title: '低库存',
                      value: '${_metrics['lowStockProducts'] ?? 0}',
                      unit: '种',
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                    ModernCard(
                      title: '缺货',
                      value: '${_metrics['outOfStockProducts'] ?? 0}',
                      unit: '种',
                      icon: Icons.error,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
