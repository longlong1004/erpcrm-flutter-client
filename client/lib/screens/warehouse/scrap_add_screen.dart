import 'package:flutter/material.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class ScrapAddScreen extends StatefulWidget {
  final Map<String, dynamic>? scrapData;
  
  const ScrapAddScreen({super.key, this.scrapData});

  @override
  State<ScrapAddScreen> createState() => _ScrapAddScreenState();
}

class _ScrapAddScreenState extends State<ScrapAddScreen> {
  // 库存商品列表
  List<Map<String, dynamic>> _inventoryProducts = [];
  // 选中的商品列表
  List<Map<String, dynamic>> _selectedProducts = [];
  // 报废数量控制器
  Map<int, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    // 模拟加载库存商品数据
    _loadInventoryProducts();
  }

  @override
  void dispose() {
    _quantityControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _loadInventoryProducts() {
    // 模拟加载库存商品数据
    setState(() {
      _inventoryProducts = List.generate(10, (index) {
        return {
          'id': index + 1,
          '序号': index + 1,
          '货架号': 'A${index + 1}',
          '关联单品编码': 'P${index.toString().padLeft(4, '0')}',
          '商品名称': '测试商品${index + 1}',
          '商品型号': '型号${index + 1}',
          '单位': '个',
          '仓库': '主仓库',
          '库存数量': 100 + index * 10,
        };
      });
      
      // 初始化数量控制器
      _quantityControllers = {
        for (var product in _inventoryProducts)
          product['id']: TextEditingController()
      };
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

  void _submitForm() {
    // 收集选中商品的报废数量
    final formData = _selectedProducts.map((product) {
      final quantity = int.tryParse(_quantityControllers[product['id']]?.text ?? '0') ?? 0;
      return {
        ...product,
        '报废数量': quantity,
      };
    }).toList();
    
    // 提交表单数据
    print('提交报废申请');
    print('表单数据: $formData');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('提交成功，已推送至管理员审核'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 返回上一页
    Navigator.pop(context);
  }

  void _saveForm() {
    // 收集选中商品的报废数量
    final formData = _selectedProducts.map((product) {
      final quantity = int.tryParse(_quantityControllers[product['id']]?.text ?? '0') ?? 0;
      return {
        ...product,
        '报废数量': quantity,
      };
    }).toList();
    
    // 保存表单数据到本地
    print('保存报废申请到本地');
    print('表单数据: $formData');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('保存成功'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 返回上一页
    Navigator.pop(context);
  }

  void _cancel() {
    // 返回上一页
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.scrapData == null ? '新增报废申请' : '编辑报废申请',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.scrapData == null ? '新增报废申请' : '编辑报废申请',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F1F1F),
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 库存商品列表
                  Text(
                    '库存商品列表',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F1F1F),
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('选择')),
                        DataColumn(label: Text('序号')),
                        DataColumn(label: Text('货架号')),
                        DataColumn(label: Text('关联单品编码')),
                        DataColumn(label: Text('商品名称')),
                        DataColumn(label: Text('商品型号')),
                        DataColumn(label: Text('单位')),
                        DataColumn(label: Text('仓库')),
                        DataColumn(label: Text('库存数量')),
                        DataColumn(label: Text('报废数量')),
                      ],
                      rows: _inventoryProducts.map((product) => DataRow(
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
                          DataCell(Text(product['序号'].toString())),
                          DataCell(Text(product['货架号'])),
                          DataCell(Text(product['关联单品编码'])),
                          DataCell(Text(product['商品名称'])),
                          DataCell(Text(product['商品型号'])),
                          DataCell(Text(product['单位'])),
                          DataCell(Text(product['仓库'])),
                          DataCell(Text(product['库存数量'].toString())),
                          DataCell(
                            TextFormField(
                              controller: _quantityControllers[product['id']],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: const OutlineInputBorder(),
                              ),
                              enabled: _selectedProducts.contains(product),
                            ),
                          ),
                        ],
                      )).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 底部按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _cancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C757D),
                        ),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF107C10),
                        ),
                        child: const Text('保存'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                        child: const Text('提交'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
