import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product/product.dart';
import '../../providers/product_provider.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final int? productId;

  const ProductEditScreen({Key? key, this.productId}) : super(key: key);

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _specificationController;
  late TextEditingController _modelController;
  late TextEditingController _unitController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  late TextEditingController _safetyStockController;
  late TextEditingController _brandController;
  late TextEditingController _manufacturerController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;
  
  String _status = 'ACTIVE';
  int _categoryId = 0;
  int? _supplierId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _specificationController = TextEditingController();
    _modelController = TextEditingController();
    _unitController = TextEditingController();
    _priceController = TextEditingController();
    _costPriceController = TextEditingController();
    _originalPriceController = TextEditingController();
    _stockController = TextEditingController();
    _safetyStockController = TextEditingController();
    _brandController = TextEditingController();
    _manufacturerController = TextEditingController();
    _barcodeController = TextEditingController();
    _descriptionController = TextEditingController();
    
    // 如果有productId，加载商品数据
    if (widget.productId != null) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    if (widget.productId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final productAsync = ref.read(productProvider(widget.productId!).notifier).future;
      final product = await productAsync;
      
      // 填充表单数据
      _nameController.text = product.name;
      _codeController.text = product.code;
      _specificationController.text = product.specification;
      _modelController.text = product.model;
      _unitController.text = product.unit;
      _priceController.text = product.price.toString();
      _costPriceController.text = product.costPrice?.toString() ?? '';
      _originalPriceController.text = product.originalPrice?.toString() ?? '';
      _stockController.text = product.stock.toString();
      _safetyStockController.text = product.safetyStock?.toString() ?? '';
      _brandController.text = product.brand ?? '';
      _manufacturerController.text = product.manufacturer ?? '';
      _barcodeController.text = product.barcode ?? '';
      _descriptionController.text = product.description ?? '';
      
      // 设置选择值
      _status = product.status;
      _categoryId = product.categoryId;
      _supplierId = product.supplierId;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载商品数据失败: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // 释放控制器资源
    _nameController.dispose();
    _codeController.dispose();
    _specificationController.dispose();
    _modelController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _safetyStockController.dispose();
    _brandController.dispose();
    _manufacturerController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? '编辑商品' : '新增商品'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // 基本信息
                Text(
                  '基本信息',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nameController,
                  labelText: '商品名称',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入商品名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _codeController,
                  labelText: '商品编码',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入商品编码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _specificationController,
                  labelText: '规格',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入商品规格';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _modelController,
                  labelText: '型号',
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _unitController,
                  labelText: '单位',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入商品单位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // 价格信息
                const SizedBox(height: 24),
                Text(
                  '价格信息',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _priceController,
                  labelText: '售价',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入售价';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return '请输入有效的售价';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _costPriceController,
                  labelText: '成本价',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final costPrice = double.tryParse(value);
                      if (costPrice == null || costPrice < 0) {
                        return '请输入有效的成本价';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _originalPriceController,
                  labelText: '原价',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final originalPrice = double.tryParse(value);
                      if (originalPrice == null || originalPrice < 0) {
                        return '请输入有效的原价';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // 库存信息
                const SizedBox(height: 24),
                Text(
                  '库存信息',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _stockController,
                  labelText: '库存数量',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入库存数量';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return '请输入有效的库存数量';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _safetyStockController,
                  labelText: '安全库存',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final safetyStock = int.tryParse(value);
                      if (safetyStock == null || safetyStock < 0) {
                        return '请输入有效的安全库存';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // 其他信息
                const SizedBox(height: 24),
                Text(
                  '其他信息',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _brandController,
                  labelText: '品牌',
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _manufacturerController,
                  labelText: '制造商',
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _barcodeController,
                  labelText: '条形码',
                ),
                const SizedBox(height: 12),
                
                // 分类选择
                TextFormField(
                  initialValue: _categoryId.toString(),
                  decoration: const InputDecoration(
                    labelText: '分类ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入分类ID';
                    }
                    final categoryId = int.tryParse(value);
                    if (categoryId == null || categoryId < 0) {
                      return '请输入有效的分类ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      _categoryId = int.parse(value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // 供应商ID
                TextFormField(
                  initialValue: _supplierId?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: '供应商ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final supplierId = int.tryParse(value);
                      if (supplierId == null || supplierId < 0) {
                        return '请输入有效的供应商ID';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      _supplierId = int.parse(value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // 状态选择
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: '商品状态',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('正常')),
                    DropdownMenuItem(value: 'INACTIVE', child: Text('停用')),
                    DropdownMenuItem(value: 'OUT_OF_STOCK', child: Text('缺货')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请选择商品状态';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // 商品描述
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '商品描述',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 24),
                
                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveProduct(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.productId != null ? '保存修改' : '新增商品'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      // 保存表单数据
      _formKey.currentState!.save();
      
      // 构建商品数据
      final productData = {
        'name': _nameController.text,
        'code': _codeController.text,
        'specification': _specificationController.text,
        'model': _modelController.text,
        'unit': _unitController.text,
        'price': double.parse(_priceController.text),
        'costPrice': _costPriceController.text.isNotEmpty ? double.parse(_costPriceController.text) : null,
        'originalPrice': _originalPriceController.text.isNotEmpty ? double.parse(_originalPriceController.text) : null,
        'stock': int.parse(_stockController.text),
        'safetyStock': _safetyStockController.text.isNotEmpty ? int.parse(_safetyStockController.text) : null,
        'categoryId': _categoryId,
        'supplierId': _supplierId,
        'brand': _brandController.text.isNotEmpty ? _brandController.text : null,
        'manufacturer': _manufacturerController.text.isNotEmpty ? _manufacturerController.text : null,
        'barcode': _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        'status': _status,
      };
      
      try {
        if (widget.productId != null) {
          // 编辑商品
          await ref.read(productProvider(widget.productId!).notifier).updateProduct(productData);
        } else {
          // 新增商品
          await ref.read(productsProvider.notifier).createProduct(productData);
        }
        
        // 返回上一页
        Navigator.pop(context, true);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $error')),
        );
      }
    }
  }
}