import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/tax_category.dart';
import 'package:erpcrm_client/providers/basic_info/tax_category_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class TaxCategoryScreen extends ConsumerWidget {
  const TaxCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxCategoryState = ref.watch(taxCategoryProvider);
    final taxCategories = taxCategoryState.taxCategories;
    final isLoading = taxCategoryState.isLoading;
    final error = taxCategoryState.error;

    return MainLayout(
      title: '税收分类',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '税收分类',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showTaxCategoryForm(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('新增'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (error != null)
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('序号')),
                          DataColumn(label: Text('税收分类编码')),
                          DataColumn(label: Text('税收分类编码短码')),
                          DataColumn(label: Text('商品名称')),
                          DataColumn(label: Text('商品和服务分类简称')),
                          DataColumn(label: Text('说明')),
                          DataColumn(label: Text('增值税税率')),
                          DataColumn(label: Text('关键字')),
                          DataColumn(label: Text('是否汇总项')),
                          DataColumn(label: Text('增值税特殊管理')),
                          DataColumn(label: Text('增值税政策依据')),
                          DataColumn(label: Text('消费税政策依据')),
                          DataColumn(label: Text('消费税政策')),
                          DataColumn(label: Text('操作')),
                        ],
                        rows: taxCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final taxCategory = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(taxCategory.taxCode)),
                            DataCell(Text(taxCategory.shortCode)),
                            DataCell(Text(taxCategory.productName)),
                            DataCell(Text(taxCategory.categoryName)),
                            DataCell(Text(taxCategory.description)),
                            DataCell(Text(taxCategory.taxRate)),
                            DataCell(Text(taxCategory.keywords)),
                            DataCell(Text(taxCategory.isSummary ? '是' : '否')),
                            DataCell(Text(taxCategory.specialManagement)),
                            DataCell(Text(taxCategory.taxPolicy)),
                            DataCell(Text(taxCategory.consumptionTaxPolicy)),
                            DataCell(Text(taxCategory.consumptionTaxRule)),
                            DataCell(Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // 查看操作
                                    _showTaxCategoryDetails(context, taxCategory);
                                  },
                                  child: const Text('查看'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 编辑操作
                                    _showTaxCategoryForm(context, ref, taxCategory);
                                  },
                                  child: const Text('编辑'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 删除操作
                                    _showDeleteDialog(context, ref, taxCategory.id);
                                  },
                                  child: const Text('删除'),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaxCategoryDetails(BuildContext context, TaxCategory taxCategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('税收分类详情 - ${taxCategory.productName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('税收分类编码:', taxCategory.taxCode),
              _buildDetailRow('税收分类编码短码:', taxCategory.shortCode),
              _buildDetailRow('商品名称:', taxCategory.productName),
              _buildDetailRow('商品和服务分类简称:', taxCategory.categoryName),
              _buildDetailRow('说明:', taxCategory.description),
              _buildDetailRow('增值税税率:', taxCategory.taxRate),
              _buildDetailRow('关键字:', taxCategory.keywords),
              _buildDetailRow('是否汇总项:', taxCategory.isSummary ? '是' : '否'),
              _buildDetailRow('增值税特殊管理:', taxCategory.specialManagement),
              _buildDetailRow('增值税政策依据:', taxCategory.taxPolicy),
              _buildDetailRow('消费税政策依据:', taxCategory.consumptionTaxPolicy),
              _buildDetailRow('消费税政策:', taxCategory.consumptionTaxRule),
              _buildDetailRow('创建时间:', taxCategory.createdAt.toString().substring(0, 19)),
              _buildDetailRow('更新时间:', taxCategory.updatedAt.toString().substring(0, 19)),
            ],
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

  // 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showTaxCategoryForm(BuildContext context, WidgetRef ref, [TaxCategory? taxCategory]) {
    final taxCodeController = TextEditingController(text: taxCategory?.taxCode ?? '');
    final shortCodeController = TextEditingController(text: taxCategory?.shortCode ?? '');
    final productNameController = TextEditingController(text: taxCategory?.productName ?? '');
    final categoryNameController = TextEditingController(text: taxCategory?.categoryName ?? '');
    final descriptionController = TextEditingController(text: taxCategory?.description ?? '');
    final taxRateController = TextEditingController(text: taxCategory?.taxRate ?? '');
    final keywordsController = TextEditingController(text: taxCategory?.keywords ?? '');
    final isSummaryController = TextEditingController(text: taxCategory != null && taxCategory.isSummary ? '是' : '否');
    final specialManagementController = TextEditingController(text: taxCategory?.specialManagement ?? '');
    final taxPolicyController = TextEditingController(text: taxCategory?.taxPolicy ?? '');
    final consumptionTaxPolicyController = TextEditingController(text: taxCategory?.consumptionTaxPolicy ?? '');
    final consumptionTaxRuleController = TextEditingController(text: taxCategory?.consumptionTaxRule ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(taxCategory == null ? '新增税收分类' : '编辑税收分类'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taxCodeController,
                decoration: const InputDecoration(labelText: '税收分类编码'),
                autofocus: true,
              ),
              TextField(
                controller: shortCodeController,
                decoration: const InputDecoration(labelText: '税收分类编码短码'),
              ),
              TextField(
                controller: productNameController,
                decoration: const InputDecoration(labelText: '商品名称'),
              ),
              TextField(
                controller: categoryNameController,
                decoration: const InputDecoration(labelText: '商品和服务分类简称'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '说明'),
                maxLines: 2,
              ),
              TextField(
                controller: taxRateController,
                decoration: const InputDecoration(labelText: '增值税税率'),
              ),
              TextField(
                controller: keywordsController,
                decoration: const InputDecoration(labelText: '关键字'),
              ),
              TextField(
                controller: isSummaryController,
                decoration: const InputDecoration(labelText: '是否汇总项 (是/否)'),
              ),
              TextField(
                controller: specialManagementController,
                decoration: const InputDecoration(labelText: '增值税特殊管理'),
              ),
              TextField(
                controller: taxPolicyController,
                decoration: const InputDecoration(labelText: '增值税政策依据'),
              ),
              TextField(
                controller: consumptionTaxPolicyController,
                decoration: const InputDecoration(labelText: '消费税政策依据'),
              ),
              TextField(
                controller: consumptionTaxRuleController,
                decoration: const InputDecoration(labelText: '消费税政策'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taxCodeController.text.isEmpty || shortCodeController.text.isEmpty || productNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('税收分类编码、短码和商品名称不能为空'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final isSummary = isSummaryController.text.trim().toLowerCase() == '是';

              final newTaxCategory = TaxCategory(
                id: taxCategory?.id ?? DateTime.now().millisecondsSinceEpoch,
                taxCode: taxCodeController.text.trim(),
                shortCode: shortCodeController.text.trim(),
                productName: productNameController.text.trim(),
                categoryName: categoryNameController.text.trim(),
                description: descriptionController.text.trim(),
                taxRate: taxRateController.text.trim(),
                keywords: keywordsController.text.trim(),
                isSummary: isSummary,
                specialManagement: specialManagementController.text.trim(),
                taxPolicy: taxPolicyController.text.trim(),
                consumptionTaxPolicy: consumptionTaxPolicyController.text.trim(),
                consumptionTaxRule: consumptionTaxRuleController.text.trim(),
                createdAt: taxCategory?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (taxCategory == null) {
                ref.read(taxCategoryProvider.notifier).addTaxCategory(newTaxCategory);
              } else {
                ref.read(taxCategoryProvider.notifier).updateTaxCategory(newTaxCategory);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(taxCategory == null ? '税收分类新增成功' : '税收分类更新成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(taxCategory == null ? '确认' : '确认'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除该税收分类吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(taxCategoryProvider.notifier).deleteTaxCategory(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('税收分类删除成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}