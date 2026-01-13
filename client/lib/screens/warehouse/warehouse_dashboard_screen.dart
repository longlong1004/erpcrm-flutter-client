import 'package:flutter/material.dart';
import 'package:erpcrm_client/services/warehouse_data_service.dart';
import 'package:erpcrm_client/widgets/common/modern_card.dart';

/// 仓库仪表盘页面
class WarehouseDashboardScreen extends StatefulWidget {
  const WarehouseDashboardScreen({super.key});

  @override
  State<WarehouseDashboardScreen> createState() => _WarehouseDashboardScreenState();
}

class _WarehouseDashboardScreenState extends State<WarehouseDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final metrics = await WarehouseDataService.getWarehouseMetrics();
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
        title: const Text('仓库仪表盘'),
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
                child: Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        ModernCard(
                          title: '库存商品',
                          value: '${_metrics['totalItems'] ?? 0}',
                          unit: '种',
                          icon: Icons.inventory,
                          color: Colors.blue,
                        ),
                        ModernCard(
                          title: '库存总值',
                          value: '¥${((_metrics['totalValue'] ?? 0) / 10000).toStringAsFixed(2)}',
                          unit: '万',
                          icon: Icons.account_balance_wallet,
                          color: Colors.green,
                        ),
                        ModernCard(
                          title: '低库存预警',
                          value: '${_metrics['lowStockCount'] ?? 0}',
                          unit: '种',
                          icon: Icons.warning,
                          color: Colors.orange,
                        ),
                        ModernCard(
                          title: '缺货商品',
                          value: '${_metrics['outOfStockCount'] ?? 0}',
                          unit: '种',
                          icon: Icons.error,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
