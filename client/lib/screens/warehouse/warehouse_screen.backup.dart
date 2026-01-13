import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/providers/warehouse_provider.dart';
import 'package:erpcrm_client/models/warehouse/warehouse.dart';

class WarehouseScreen extends ConsumerStatefulWidget {
  const WarehouseScreen({super.key});

  @override
  ConsumerState<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends ConsumerState<WarehouseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchKeyword = '';
  int? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(warehouseNotifierProvider.notifier).loadWarehouses();
      ref.read(warehouseNotifierProvider.notifier).loadInventories();
      ref.read(warehouseNotifierProvider.notifier).loadStockRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddWarehouseDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final addressController = TextEditingController();
    final managerController = TextEditingController();
    final phoneController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建仓库'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '仓库名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: '仓库编码',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: '仓库地址',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: managerController,
                  decoration: const InputDecoration(
                    labelText: '负责人',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: '联系电话',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
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
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写仓库名称和编码')),
                );
                return;
              }

              final warehouse = Warehouse(
                id: DateTime.now().millisecondsSinceEpoch,
                name: nameController.text,
                code: codeController.text,
                address: addressController.text.isEmpty ? null : addressController.text,
                manager: managerController.text.isEmpty ? null : managerController.text,
                phone: phoneController.text.isEmpty ? null : phoneController.text,
                description: descriptionController.text.isEmpty ? null : descriptionController.text,
                status: 'active',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isSynced: false,
              );

              final success = await ref.read(warehouseNotifierProvider.notifier).createWarehouse(warehouse);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('仓库创建成功')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showStockInDialog() {
    final productController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final supplierController = TextEditingController();
    final remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('入库操作'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(
                    labelText: '产品名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '入库数量',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '单价',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: supplierController,
                  decoration: const InputDecoration(
                    labelText: '供应商',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarkController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
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
              if (productController.text.isEmpty || quantityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写产品名称和入库数量')),
                );
                return;
              }

              final quantity = int.tryParse(quantityController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0.0;

              final record = StockRecord(
                id: DateTime.now().millisecondsSinceEpoch,
                recordNo: 'IN${DateTime.now().millisecondsSinceEpoch}',
                type: 'in',
                productId: DateTime.now().millisecondsSinceEpoch,
                productName: productController.text,
                warehouseId: _selectedWarehouseId ?? 1,
                warehouseName: '主仓库',
                quantity: quantity,
                unitPrice: price,
                totalAmount: quantity * price,
                supplierName: supplierController.text.isEmpty ? null : supplierController.text,
                remark: remarkController.text.isEmpty ? null : remarkController.text,
                status: 'completed',
                operationTime: DateTime.now(),
                createdAt: DateTime.now(),
                operatorName: '当前用户',
                isSynced: false,
              );

              final success = await ref.read(warehouseNotifierProvider.notifier).createStockRecord(record);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('入库操作成功')),
                );
              }
            },
            child: const Text('确认入库'),
          ),
        ],
      ),
    );
  }

  void _showStockOutDialog() {
    final productController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final customerController = TextEditingController();
    final remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('出库操作'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(
                    labelText: '产品名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '出库数量',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '单价',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: customerController,
                  decoration: const InputDecoration(
                    labelText: '客户',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarkController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
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
              if (productController.text.isEmpty || quantityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写产品名称和出库数量')),
                );
                return;
              }

              final quantity = int.tryParse(quantityController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0.0;

              final record = StockRecord(
                id: DateTime.now().millisecondsSinceEpoch,
                recordNo: 'OUT${DateTime.now().millisecondsSinceEpoch}',
                type: 'out',
                productId: DateTime.now().millisecondsSinceEpoch,
                productName: productController.text,
                warehouseId: _selectedWarehouseId ?? 1,
                warehouseName: '主仓库',
                quantity: quantity,
                unitPrice: price,
                totalAmount: quantity * price,
                customerName: customerController.text.isEmpty ? null : customerController.text,
                remark: remarkController.text.isEmpty ? null : remarkController.text,
                status: 'completed',
                operationTime: DateTime.now(),
                createdAt: DateTime.now(),
                operatorName: '当前用户',
                isSynced: false,
              );

              final success = await ref.read(warehouseNotifierProvider.notifier).createStockRecord(record);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('出库操作成功')),
                );
              }
            },
            child: const Text('确认出库'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '仓库管理',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '仓库管理',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1976D2),
                    unselectedLabelColor: const Color(0xFF616161),
                    indicatorColor: const Color(0xFF1976D2),
                    tabs: const [
                      Tab(text: '库存列表'),
                      Tab(text: '出入库记录'),
                      Tab(text: '仓库设置'),
                    ],
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInventoryTab(),
                        _buildStockRecordsTab(),
                        _buildWarehouseSettingsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    final state = ref.watch(warehouseNotifierProvider);
    final inventories = state.inventories.where((inv) =>
      inv.productName.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      inv.productCode.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();

    final lowStockItems = ref.read(warehouseNotifierProvider.notifier).getLowStockInventories();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索产品名称或编码',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchKeyword = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showStockInDialog,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('入库'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showStockOutDialog,
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('出库'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (lowStockItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFB74D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Color(0xFFFF9800)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '有 ${lowStockItems.length} 个产品库存不足安全库存',
                          style: const TextStyle(
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : inventories.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无库存数据',
                              style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: inventories.length,
                            itemBuilder: (context, index) {
                              final inventory = inventories[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              inventory.productName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (inventory.isLowStock)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3E0),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: const Color(0xFFFFB74D)),
                                              ),
                                              child: const Text(
                                                '库存不足',
                                                style: TextStyle(
                                                  color: Color(0xFFE65100),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '编码: ${inventory.productCode}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF616161),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              '仓库',
                                              inventory.warehouseName,
                                              Icons.warehouse,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildInfoItem(
                                              '库存',
                                              '${inventory.quantity}',
                                              Icons.inventory_2,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildInfoItem(
                                              '安全库存',
                                              '${inventory.safetyStock}',
                                              Icons.security,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              '单价',
                                              '¥${inventory.unitPrice.toStringAsFixed(2)}',
                                              Icons.attach_money,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildInfoItem(
                                              '总价值',
                                              '¥${inventory.totalValue.toStringAsFixed(2)}',
                                              Icons.account_balance_wallet,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockRecordsTab() {
    final state = ref.watch(warehouseNotifierProvider);
    final records = state.stockRecords.where((r) =>
      r.productName.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      r.recordNo.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: '搜索记录编号或产品名称',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchKeyword = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : records.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无出入库记录',
                          style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: record.type == 'in'
                                              ? const Color(0xFFE8F5E9)
                                              : const Color(0xFFFFEBEE),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          record.type == 'in' ? '入库' : '出库',
                                          style: TextStyle(
                                            color: record.type == 'in'
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFFC62828),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          record.recordNo,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF616161),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    record.productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoItem(
                                          '数量',
                                          '${record.quantity}',
                                          Icons.inventory,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildInfoItem(
                                          '单价',
                                          '¥${record.unitPrice.toStringAsFixed(2)}',
                                          Icons.attach_money,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildInfoItem(
                                          '总金额',
                                          '¥${record.totalAmount.toStringAsFixed(2)}',
                                          Icons.account_balance_wallet,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoItem(
                                          '仓库',
                                          record.warehouseName,
                                          Icons.warehouse,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildInfoItem(
                                          '操作人',
                                          record.operatorName ?? '-',
                                          Icons.person,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (record.supplierName != null || record.customerName != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      record.supplierName != null
                                          ? '供应商: ${record.supplierName}'
                                          : '客户: ${record.customerName}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  if (record.remark != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '备注: ${record.remark}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    '操作时间: ${record.operationTime.toString().substring(0, 19)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSettingsTab() {
    final state = ref.watch(warehouseNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '仓库列表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddWarehouseDialog,
                icon: const Icon(Icons.add),
                label: const Text('新建仓库'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.warehouses.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无仓库数据',
                          style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.warehouses.length,
                        itemBuilder: (context, index) {
                          final warehouse = state.warehouses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          warehouse.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: warehouse.status == 'active'
                                              ? const Color(0xFFE8F5E9)
                                              : const Color(0xFFFFEBEE),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          warehouse.status == 'active' ? '启用' : '禁用',
                                          style: TextStyle(
                                            color: warehouse.status == 'active'
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFFC62828),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '编码: ${warehouse.code}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  if (warehouse.address != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '地址: ${warehouse.address}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  if (warehouse.manager != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '负责人: ${warehouse.manager}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  if (warehouse.phone != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '联系电话: ${warehouse.phone}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  if (warehouse.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '备注: ${warehouse.description}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF757575)),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF616161),
          ),
        ),
      ],
    );
  }
}
