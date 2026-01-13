import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product/product.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/sync_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../models/product/product_status.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:hive/hive.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  List<File> _mainImages = [];
  List<File> _detailImages = [];
  late Map<String, dynamic> _formData;
  ProductStatus _currentStatus = ProductStatus.draft;
  bool _isDraft = false;

  @override
  void initState() {
    super.initState();
    _formData = {
      'salesperson': '王五',
      'companyName': '北京铁路物资有限公司',
      'brand': '中国铁路',
      'name': '铁路信号设备',
      'model': 'RX-2024',
      'unit': '套',
      'price': 15000.00,
      'category': '铁路设备',
      'weight': 25.5,
      'dimensions': '50cm x 40cm x 30cm',
      'railwayBureau': '北京局',
      'station': '北京站',
      'customer': '北京铁路局',
      'actualName': '铁路信号设备',
      'actualModel': 'RX-2024',
      'purchasePrice': 12000.00,
      'supplier': '北京铁路器材厂',
      'barcode69': '6901234567890',
      'externalLink': 'https://www.example.com/products/rx-2024',
      'note': '这是一个示例产品，用于演示商品表单功能。',
    };

    // 如果是编辑模式，填充现有数据
    if (widget.product != null) {
      _formData = {
        'salesperson': widget.product!.salespersonName ?? '',
        'companyName': widget.product!.companyName ?? '',
        'brand': widget.product!.brand ?? '',
        'name': widget.product!.name,
        'model': widget.product!.model,
        'unit': widget.product!.unit,
        'price': widget.product!.price,
        'category': widget.product!.categoryName ?? '',
        'weight': widget.product!.weight ?? 0.0,
        'dimensions': widget.product!.dimensions ?? '',
        'railwayBureau': widget.product!.railwayBureau ?? '',
        'station': widget.product!.station ?? '',
        'customer': widget.product!.customer ?? '',
        'actualName': widget.product!.actualName ?? '',
        'actualModel': widget.product!.actualModel ?? '',
        'purchasePrice': widget.product!.purchasePrice ?? 0.0,
        'supplier': widget.product!.supplierName ?? '',
        'barcode69': widget.product!.barcode69 ?? '',
        'externalLink': widget.product!.externalLink ?? '',
        'note': widget.product!.note ?? '',
      };
      _currentStatus = ProductStatus.fromString(widget.product!.status);
    }
  }

  Future<void> _pickMainImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      // 验证图片格式
      final validImages = <File>[];
      for (final pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final mimeType = lookupMimeType(file.path);
        if (mimeType?.startsWith('image/jpeg') == true || mimeType?.startsWith('image/png') == true) {
          validImages.add(file);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('只支持JPG/PNG格式的图片')),
            );
          }
        }
      }
      
      // 限制图片数量
      if (validImages.length < 3) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('主图需要3-5张')),
          );
        }
        return;
      }
      
      setState(() {
        _mainImages = validImages.take(5).toList(); // 最多5张
      });
    }
  }

  Future<void> _pickDetailImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final mimeType = lookupMimeType(file.path);
      
      // 验证图片格式
      if (mimeType?.startsWith('image/jpeg') != true && mimeType?.startsWith('image/png') != true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('只支持JPG/PNG格式的图片')),
          );
        }
        return;
      }
      
      setState(() {
        _detailImages = [file];
      });
    }
  }

  Future<void> _saveDraft() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final authState = ref.read(authProvider);
      final now = DateTime.now();
      
      // 保存到本地数据库
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
        name: _formData['name'],
        code: widget.product?.code ?? 'TEMP_${DateTime.now().millisecondsSinceEpoch}',
        specification: '',
        model: _formData['model'],
        unit: _formData['unit'],
        price: _formData['price'],
        costPrice: _formData['purchasePrice'] ?? 0.0,
        originalPrice: _formData['price'],
        stock: 0,
        safetyStock: 0,
        categoryId: 0, // 实际应该从选择的分类获取ID
        brand: _formData['brand'],
        manufacturer: '',
        supplierId: null,
        barcode: _formData['barcode69'],
        imageUrl: null,
        description: '',
        status: ProductStatus.draft.name,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
        salespersonId: authState.user?.id,
        salespersonName: _formData['salesperson'],
        companyName: _formData['companyName'],
        categoryName: _formData['category'],
        weight: _formData['weight'],
        dimensions: _formData['dimensions'],
        railwayBureau: _formData['railwayBureau'],
        station: _formData['station'],
        customer: _formData['customer'],
        actualName: _formData['actualName'],
        actualModel: _formData['actualModel'],
        purchasePrice: _formData['purchasePrice'],
        supplierName: _formData['supplier'],
        imageUrls: [],
        note: _formData['note'],
        mainImageUrls: [],
        detailImageUrl: null,
        barcode69: _formData['barcode69'],
        externalLink: _formData['externalLink'],
        isSynced: false,
      );
      
      // 保存到本地Hive
      await LocalStorageService().saveProduct(product);
      
      // 触发同步
      await SyncService().syncProducts();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('草稿保存成功')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitForm() async {
    // 验证所有必填字段
    if (_mainImages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请上传3-5张主图')),
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final authState = ref.read(authProvider);
      final now = DateTime.now();
      
      // 创建商品对象
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
        name: _formData['name'],
        code: widget.product?.code ?? 'TEMP_${DateTime.now().millisecondsSinceEpoch}',
        specification: '',
        model: _formData['model'],
        unit: _formData['unit'],
        price: _formData['price'],
        costPrice: _formData['purchasePrice'] ?? 0.0,
        originalPrice: _formData['price'],
        stock: 0,
        safetyStock: 0,
        categoryId: 0, // 实际应该从选择的分类获取ID
        brand: _formData['brand'],
        manufacturer: '',
        supplierId: null,
        barcode: _formData['barcode69'],
        imageUrl: null,
        description: '',
        status: ProductStatus.pendingBasicInfoApproval.name,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
        salespersonId: authState.user?.id,
        salespersonName: _formData['salesperson'],
        companyName: _formData['companyName'],
        categoryName: _formData['category'],
        weight: _formData['weight'],
        dimensions: _formData['dimensions'],
        railwayBureau: _formData['railwayBureau'],
        station: _formData['station'],
        customer: _formData['customer'],
        actualName: _formData['actualName'],
        actualModel: _formData['actualModel'],
        purchasePrice: _formData['purchasePrice'],
        supplierName: _formData['supplier'],
        imageUrls: [],
        note: _formData['note'],
        mainImageUrls: [], // 实际应该上传图片后获取URLs
        detailImageUrl: null,
        barcode69: _formData['barcode69'],
        externalLink: _formData['externalLink'],
        isSynced: false,
      );
      
      // 保存到本地Hive
      await LocalStorageService().saveProduct(product);
      
      // 触发同步
      await SyncService().syncProducts();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('商品提交成功，进入待审核状态')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? '编辑商品' : '新增商品'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 基本信息
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '基本信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 业务员（不可编辑）
                        _buildFormField(
                          label: '业务员',
                          value: _formData['salesperson'],
                          readOnly: true,
                        ),
                        
                        // 公司名称（下拉选择）
                        _buildFormField(
                          label: '公司名称',
                          value: _formData['companyName'],
                          hintText: '请从下拉框选择',
                        ),
                        
                        // 品牌（下拉选择）
                        _buildFormField(
                          label: '品牌',
                          value: _formData['brand'],
                          hintText: '请从下拉框选择',
                        ),
                        
                        // 国铁名称
                        _buildFormField(
                          label: '国铁名称',
                          value: _formData['name'],
                          hintText: '请输入国铁名称',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入国铁名称';
                            }
                            return null;
                          },
                        ),
                        
                        // 国铁型号
                        _buildFormField(
                          label: '国铁型号',
                          value: _formData['model'],
                          hintText: '请输入国铁型号',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入国铁型号';
                            }
                            return null;
                          },
                        ),
                        
                        // 单位
                        _buildFormField(
                          label: '单位',
                          value: _formData['unit'],
                          hintText: '请输入单位',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入单位';
                            }
                            return null;
                          },
                        ),
                        
                        // 国铁单价
                        _buildNumberFormField(
                          label: '国铁单价',
                          value: _formData['price'],
                          hintText: '请输入国铁单价',
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return '请输入有效的国铁单价';
                            }
                            return null;
                          },
                        ),
                        
                        // 三级分类（下拉选择）
                        _buildFormField(
                          label: '三级分类',
                          value: _formData['category'],
                          hintText: '请从下拉框选择',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请选择三级分类';
                            }
                            return null;
                          },
                        ),
                        
                        // 重量
                        _buildNumberFormField(
                          label: '重量',
                          value: _formData['weight'],
                          hintText: '请输入重量',
                          validator: (value) {
                            if (value == null || value < 0) {
                              return '请输入有效的重量';
                            }
                            return null;
                          },
                        ),
                        
                        // 尺寸
                        _buildFormField(
                          label: '尺寸',
                          value: _formData['dimensions'],
                          hintText: '请输入尺寸',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入尺寸';
                            }
                            return null;
                          },
                        ),
                        
                        // 所属路局
                        _buildFormField(
                          label: '所属路局',
                          value: _formData['railwayBureau'],
                          hintText: '请输入所属路局',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入所属路局';
                            }
                            return null;
                          },
                        ),
                        
                        // 站段
                        _buildFormField(
                          label: '站段',
                          value: _formData['station'],
                          hintText: '请输入站段',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入站段';
                            }
                            return null;
                          },
                        ),
                        
                        // 客户
                        _buildFormField(
                          label: '客户',
                          value: _formData['customer'],
                          hintText: '请输入客户',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入客户';
                            }
                            return null;
                          },
                        ),
                        
                        // 实发名称
                        _buildFormField(
                          label: '实发名称',
                          value: _formData['actualName'],
                          hintText: '请输入实发名称',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入实发名称';
                            }
                            return null;
                          },
                        ),
                        
                        // 实发型号
                        _buildFormField(
                          label: '实发型号',
                          value: _formData['actualModel'],
                          hintText: '请输入实发型号',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入实发型号';
                            }
                            return null;
                          },
                        ),
                        
                        // 采购单价
                        _buildNumberFormField(
                          label: '采购单价',
                          value: _formData['purchasePrice'],
                          hintText: '请输入采购单价',
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return '请输入有效的采购单价';
                            }
                            return null;
                          },
                        ),
                        
                        // 供应商
                        _buildFormField(
                          label: '供应商',
                          value: _formData['supplier'],
                          hintText: '请输入供应商',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入供应商';
                            }
                            return null;
                          },
                        ),
                        
                        // 条形码69
                        _buildFormField(
                          label: '条形码69',
                          value: _formData['barcode69'],
                          hintText: '请输入条形码69',
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]{13}$').hasMatch(value)) {
                              return '条形码69必须是13位数字';
                            }
                            return null;
                          },
                        ),
                        
                        // 外部链接
                        _buildFormField(
                          label: '外部链接',
                          value: _formData['externalLink'],
                          hintText: '请输入外部链接',
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !RegExp(r'^https?://').hasMatch(value)) {
                              return '请输入有效的外部链接';
                            }
                            return null;
                          },
                        )
                      ],
                    ),
                  ),
                ),

                // 扩展信息
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '扩展信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 重量
                        _buildNumberFormField(
                          label: '重量',
                          value: _formData['weight'],
                          hintText: '请输入重量',
                        ),
                        
                        // 尺寸
                        _buildFormField(
                          label: '尺寸',
                          value: _formData['dimensions'],
                          hintText: '请输入尺寸',
                        ),
                        
                        // 所属路局
                        _buildFormField(
                          label: '所属路局',
                          value: _formData['railwayBureau'],
                          hintText: '请输入所属路局',
                        ),
                        
                        // 站段
                        _buildFormField(
                          label: '站段',
                          value: _formData['station'],
                          hintText: '请输入站段',
                        ),
                        
                        // 客户
                        _buildFormField(
                          label: '客户',
                          value: _formData['customer'],
                          hintText: '请输入客户',
                        ),
                      ],
                    ),
                  ),
                ),

                // 实发信息
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '实发信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 实发名称
                        _buildFormField(
                          label: '实发名称',
                          value: _formData['actualName'],
                          hintText: '请输入实发名称',
                        ),
                        
                        // 实发型号
                        _buildFormField(
                          label: '实发型号',
                          value: _formData['actualModel'],
                          hintText: '请输入实发型号',
                        ),
                        
                        // 采购单价
                        _buildNumberFormField(
                          label: '采购单价',
                          value: _formData['purchasePrice'],
                          hintText: '请输入采购单价',
                        ),
                        
                        // 供应商
                        _buildFormField(
                          label: '供应商',
                          value: _formData['supplier'],
                          hintText: '请输入供应商',
                        ),
                      ],
                    ),
                  ),
                ),

                // 图片上传
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '图片上传',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 实物图片
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('实物图片'),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _pickMainImages,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('上传主图（3-5张）'),
                            ),
                            if (_mainImages.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _mainImages.map((file) => 
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                ).toList(),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('详情图'),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _pickDetailImage,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('上传详情图（1张）'),
                            ),
                            if (_detailImages.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: Image.file(
                                  _detailImages.first,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 备注
                _buildFormField(
                  label: '备注',
                  value: _formData['note'],
                  hintText: '请输入备注',
                  maxLines: 3,
                ),

                // 操作按钮
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
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
    );
  }

  Widget _buildFormField({
    required String label,
    required dynamic value,
    String? hintText,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value?.toString(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        readOnly: readOnly,
        maxLines: maxLines,
        validator: validator,
        onSaved: (newValue) {
          _formData[label.toLowerCase().replaceAll(' ', '_')] = newValue;
        },
      ),
    );
  }

  Widget _buildNumberFormField({
    required String label,
    required dynamic value,
    String? hintText,
    String? Function(double?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value?.toString(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (newValue) {
          if (validator == null) return null;
          double? numValue = double.tryParse(newValue ?? '');
          return validator(numValue);
        },
        onSaved: (newValue) {
          _formData[label.toLowerCase().replaceAll(' ', '_')] = double.tryParse(newValue ?? '0');
        },
      ),
    );
  }
}
