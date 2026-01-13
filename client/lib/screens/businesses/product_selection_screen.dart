import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductSelectionScreen extends StatefulWidget {
  final String productType; // 'existing' 表示现有国铁编码，'unfinished' 表示未完成新增商品
  
  const ProductSelectionScreen({super.key, required this.productType});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _selectedProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    setState(() {
      _isLoading = true;
    });

    // 模拟加载商品数据
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _products = List.generate(20, (index) {
          return {
            'id': index + 1,
            '单品编码': 'P${index.toString().padLeft(4, '0')}',
            '国铁名称': '铁路配件${index + 1}',
            '国铁型号': 'TP-${index.toString().padLeft(3, '0')}',
            '单位': '件',
            '数量': 10,
            '单价': 100.0 + index * 10,
            '金额': (100.0 + index * 10) * 10,
            '实发名称': '铁路配件${index + 1}',
            '实发型号': 'TP-${index.toString().padLeft(3, '0')}',
            '实发单位': '件',
            '采购单价': 90.0 + index * 9,
            '库存数量': 50 + index * 5,
            '实发数量': 10,
            '付款方式': '银行转账',
            '供应商': '供应商${(index % 3) + 1}',
            '预付比例': 0.3,
            '预付金额': ((100.0 + index * 10) * 10) * 0.3,
            '发票类型': '增值税专用发票',
            '小计': (100.0 + index * 10) * 10,
            '备注': '',
            // 新增字段，用于先报计划管理
            '品牌': '品牌${(index % 3) + 1}',
            '国铁单价': 100.0 + index * 10,
            '采购金额': (90.0 + index * 9) * 10,
          };
        });
        _isLoading = false;
      });
    });
  }

  void _toggleProductSelection(Map<String, dynamic> product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedProducts);
  }

  void _cancelSelection() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productType == 'existing' ? '已上架商品' : '申请上架商品'),
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索商品...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) {
                // 这里可以添加搜索逻辑
                // 目前先不实现，保持简单
              },
            ),
          ),

          // 商品列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: SizedBox(width: 40, child: Text('选择')),
                          numeric: false,
                        ),
                        DataColumn(label: Text('单品编码')),
                        DataColumn(label: Text('国铁名称')),
                        DataColumn(label: Text('国铁型号')),
                        DataColumn(label: Text('单位')),
                        DataColumn(label: Text('库存数量')),
                        DataColumn(label: Text('国铁单价')),
                        DataColumn(label: Text('品牌')),
                      ],
                      rows: _products.map((product) => DataRow(
                        selected: _selectedProducts.contains(product),
                        onSelectChanged: (selected) {
                          if (selected != null) {
                            _toggleProductSelection(product);
                          }
                        },
                        cells: [
                          DataCell(Center(
                            child: Checkbox(
                              value: _selectedProducts.contains(product),
                              onChanged: (value) {
                                _toggleProductSelection(product);
                              },
                            ),
                          )),
                          DataCell(Text(product['单品编码'])),
                          DataCell(Text(product['国铁名称'])),
                          DataCell(Text(product['国铁型号'])),
                          DataCell(Text(product['单位'])),
                          DataCell(Text(product['库存数量'].toString())),
                          DataCell(Text('¥${product['国铁单价'].toStringAsFixed(2)}')),
                          DataCell(Text(product['品牌'])),
                        ],
                      )).toList(),
                    ),
                  ),
          ),

          // 底部操作按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelSelection,
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
