import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../services/order_service.dart';

// 补发货类型枚举
enum SupplementOrderType {
  supplementGoods, // 补发货
  supplementFreight, // 补运费
  other // 其它
}

class AddSupplementOrderScreen extends StatefulWidget {
  final List<int> selectedOrderIds;

  const AddSupplementOrderScreen({super.key, required this.selectedOrderIds});

  @override
  State<AddSupplementOrderScreen> createState() => _AddSupplementOrderScreenState();
}

class _AddSupplementOrderScreenState extends State<AddSupplementOrderScreen> {
  SupplementOrderType _selectedType = SupplementOrderType.supplementGoods;
  final Map<String, TextEditingController> _controllers = {};
  html.File? _voucherFile;
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _initControllers();
  }

  void _initControllers() {
    // 补发货控制器
    _controllers['supplementName'] = TextEditingController();
    _controllers['supplementModel'] = TextEditingController();
    _controllers['supplementQuantity'] = TextEditingController();
    _controllers['unitPrice'] = TextEditingController();
    _controllers['totalPrice'] = TextEditingController();
    _controllers['paymentMethod'] = TextEditingController();
    _controllers['supplier'] = TextEditingController();
    _controllers['invoiceType'] = TextEditingController();
    _controllers['warehouse'] = TextEditingController();
    _controllers['notes'] = TextEditingController();

    // 补运费控制器
    _controllers['freightPaymentMethod'] = TextEditingController();
    _controllers['freightSupplier'] = TextEditingController();
    _controllers['freightCost'] = TextEditingController();
    _controllers['freightNotes'] = TextEditingController();

    // 其它控制器
    _controllers['otherPaymentMethod'] = TextEditingController();
    _controllers['otherSupplier'] = TextEditingController();
    _controllers['otherAmount'] = TextEditingController();
    _controllers['otherDescription'] = TextEditingController();
  }

  @override
  void dispose() {
    // 释放控制器
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _uploadVoucher() {
    final input = html.FileUploadInputElement()
      ..accept = '.pdf,.png,.jpg,.jpeg' // 限制文件类型
      ..multiple = false; // 仅允许上传单个文件

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          _voucherFile = files.first;
        });
      }
    });

    input.click();
  }

  Future<void> _submitForm() async {
    // 验证表单
    if (_validateForm()) {
      // 构建补发货订单数据
      final Map<String, dynamic> orderData = {
        'orderIds': widget.selectedOrderIds,
        'type': _selectedType.toString(),
        'status': 'PENDING', // 待审核状态
      };

      // 根据类型添加具体数据
      switch (_selectedType) {
        case SupplementOrderType.supplementGoods:
          orderData.addAll({
            'supplementName': _controllers['supplementName']?.text,
            'supplementModel': _controllers['supplementModel']?.text,
            'supplementQuantity': _controllers['supplementQuantity']?.text,
            'unitPrice': _controllers['unitPrice']?.text,
            'totalPrice': _controllers['totalPrice']?.text,
            'paymentMethod': _controllers['paymentMethod']?.text,
            'supplier': _controllers['supplier']?.text,
            'invoiceType': _controllers['invoiceType']?.text,
            'warehouse': _controllers['warehouse']?.text,
            'notes': _controllers['notes']?.text,
          });
          break;
        case SupplementOrderType.supplementFreight:
          orderData.addAll({
            'paymentMethod': _controllers['freightPaymentMethod']?.text,
            'supplier': _controllers['freightSupplier']?.text,
            'freightCost': _controllers['freightCost']?.text,
            'notes': _controllers['freightNotes']?.text,
            'voucherFile': _voucherFile,
          });
          break;
        case SupplementOrderType.other:
          orderData.addAll({
            'paymentMethod': _controllers['otherPaymentMethod']?.text,
            'supplier': _controllers['otherSupplier']?.text,
            'amount': _controllers['otherAmount']?.text,
            'description': _controllers['otherDescription']?.text,
            'voucherFile': _voucherFile,
          });
          break;
      }

      // 提交到服务器
      final orderService = OrderService();
      await orderService.createOrder(orderData);

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已提交至管理员审核'),
          backgroundColor: Colors.green,
        ),
      );

      // 关闭当前页面
      Navigator.pop(context);
    }
  }

  bool _validateForm() {
    // 清除之前的错误
    _errors.clear();
    bool isValid = true;

    // 根据不同类型验证表单
    switch (_selectedType) {
      case SupplementOrderType.supplementGoods:
        if (_controllers['supplementName']?.text.isEmpty == true) {
          _errors['supplementName'] = '补发名称不能为空';
          isValid = false;
        }
        if (_controllers['supplementModel']?.text.isEmpty == true) {
          _errors['supplementModel'] = '补发型号不能为空';
          isValid = false;
        }
        if (_controllers['supplementQuantity']?.text.isEmpty == true) {
          _errors['supplementQuantity'] = '补发数量不能为空';
          isValid = false;
        } else if (double.tryParse(_controllers['supplementQuantity']?.text ?? '') == null) {
          _errors['supplementQuantity'] = '补发数量必须是数字';
          isValid = false;
        }
        if (_controllers['unitPrice']?.text.isEmpty == true) {
          _errors['unitPrice'] = '单价不能为空';
          isValid = false;
        } else if (double.tryParse(_controllers['unitPrice']?.text ?? '') == null) {
          _errors['unitPrice'] = '单价必须是数字';
          isValid = false;
        }
        if (_controllers['totalPrice']?.text.isEmpty == true) {
          _errors['totalPrice'] = '总价不能为空';
          isValid = false;
        } else if (double.tryParse(_controllers['totalPrice']?.text ?? '') == null) {
          _errors['totalPrice'] = '总价必须是数字';
          isValid = false;
        }
        if (_controllers['paymentMethod']?.text.isEmpty == true) {
          _errors['paymentMethod'] = '付款方式不能为空';
          isValid = false;
        }
        if (_controllers['supplier']?.text.isEmpty == true) {
          _errors['supplier'] = '供应商不能为空';
          isValid = false;
        }
        if (_controllers['invoiceType']?.text.isEmpty == true) {
          _errors['invoiceType'] = '发票类型不能为空';
          isValid = false;
        }
        if (_controllers['warehouse']?.text.isEmpty == true) {
          _errors['warehouse'] = '发货仓库不能为空';
          isValid = false;
        }
        break;
      case SupplementOrderType.supplementFreight:
        if (_controllers['freightPaymentMethod']?.text.isEmpty == true) {
          _errors['freightPaymentMethod'] = '付款方式不能为空';
          isValid = false;
        }
        if (_controllers['freightSupplier']?.text.isEmpty == true) {
          _errors['freightSupplier'] = '供应商不能为空';
          isValid = false;
        }
        if (_controllers['freightCost']?.text.isEmpty == true) {
          _errors['freightCost'] = '运费不能为空';
          isValid = false;
        } else if (double.tryParse(_controllers['freightCost']?.text ?? '') == null) {
          _errors['freightCost'] = '运费必须是数字';
          isValid = false;
        }
        if (_voucherFile == null) {
          _errors['voucher'] = '请上传凭证';
          isValid = false;
        }
        break;
      case SupplementOrderType.other:
        if (_controllers['otherPaymentMethod']?.text.isEmpty == true) {
          _errors['otherPaymentMethod'] = '付款方式不能为空';
          isValid = false;
        }
        if (_controllers['otherSupplier']?.text.isEmpty == true) {
          _errors['otherSupplier'] = '供应商不能为空';
          isValid = false;
        }
        if (_controllers['otherAmount']?.text.isEmpty == true) {
          _errors['otherAmount'] = '金额不能为空';
          isValid = false;
        } else if (double.tryParse(_controllers['otherAmount']?.text ?? '') == null) {
          _errors['otherAmount'] = '金额必须是数字';
          isValid = false;
        }
        if (_controllers['otherDescription']?.text.isEmpty == true) {
          _errors['otherDescription'] = '付款说明不能为空';
          isValid = false;
        }
        if (_voucherFile == null) {
          _errors['voucher'] = '请上传凭证';
          isValid = false;
        }
        break;
      default:
        isValid = false;
    }

    setState(() {}); // 触发重新渲染以显示错误信息
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增补发货订单'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择补发货类型',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 补发货类型选项
            Row(
              children: [
                Expanded(
                  child: RadioListTile<SupplementOrderType>(
                    title: const Text('补发货'),
                    value: SupplementOrderType.supplementGoods,
                    groupValue: _selectedType,
                    onChanged: (SupplementOrderType? value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    activeColor: const Color(0xFF003366),
                  ),
                ),
                Expanded(
                  child: RadioListTile<SupplementOrderType>(
                    title: const Text('补运费'),
                    value: SupplementOrderType.supplementFreight,
                    groupValue: _selectedType,
                    onChanged: (SupplementOrderType? value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    activeColor: const Color(0xFF003366),
                  ),
                ),
                Expanded(
                  child: RadioListTile<SupplementOrderType>(
                    title: const Text('其它'),
                    value: SupplementOrderType.other,
                    groupValue: _selectedType,
                    onChanged: (SupplementOrderType? value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    activeColor: const Color(0xFF003366),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 动态表单
            Expanded(
              child: SingleChildScrollView(
                child: _buildForm(),
              ),
            ),
            const SizedBox(height: 24),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
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
    );
  }

  Widget _buildForm() {
    switch (_selectedType) {
      case SupplementOrderType.supplementGoods:
        return _buildSupplementGoodsForm();
      case SupplementOrderType.supplementFreight:
        return _buildSupplementFreightForm();
      case SupplementOrderType.other:
        return _buildOtherForm();
      default:
        return Container();
    }
  }

  Widget _buildSupplementGoodsForm() {
    return Column(
      children: [
        _buildTextField('补发名称', 'supplementName'),
        const SizedBox(height: 16),
        _buildTextField('补发型号', 'supplementModel'),
        const SizedBox(height: 16),
        _buildTextField('补发数量', 'supplementQuantity', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField('单价', 'unitPrice', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField('总价', 'totalPrice', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField('付款方式', 'paymentMethod'),
        const SizedBox(height: 16),
        _buildTextField('供应商', 'supplier'),
        const SizedBox(height: 16),
        _buildTextField('发票类型', 'invoiceType'),
        const SizedBox(height: 16),
        _buildTextField('发货仓库', 'warehouse'),
        const SizedBox(height: 16),
        _buildTextField('备注', 'notes', maxLines: 3),
      ],
    );
  }

  Widget _buildSupplementFreightForm() {
    return Column(
      children: [
        _buildTextField('付款方式', 'freightPaymentMethod'),
        const SizedBox(height: 16),
        _buildTextField('供应商', 'freightSupplier'),
        const SizedBox(height: 16),
        _buildTextField('运费', 'freightCost', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField('备注', 'freightNotes', maxLines: 3),
        const SizedBox(height: 16),
        _buildFileUpload(),
      ],
    );
  }

  Widget _buildOtherForm() {
    return Column(
      children: [
        _buildTextField('付款方式', 'otherPaymentMethod'),
        const SizedBox(height: 16),
        _buildTextField('供应商', 'otherSupplier'),
        const SizedBox(height: 16),
        _buildTextField('金额', 'otherAmount', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField('付款说明', 'otherDescription', maxLines: 3),
        const SizedBox(height: 16),
        _buildFileUpload(),
      ],
    );
  }

  Widget _buildTextField(String label, String key, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controllers[key],
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: _errors.containsKey(key) ? Colors.red : Colors.grey,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            errorText: _errors[key],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('凭证'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _errors.containsKey('voucher') ? Colors.red : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _voucherFile != null ? _voucherFile!.name : '未选择文件',
                  style: TextStyle(
                    color: _voucherFile != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _uploadVoucher,
              icon: const Icon(Icons.upload_file),
              label: const Text('上传'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_errors.containsKey('voucher'))
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              _errors['voucher']!, // 使用非空断言，因为我们已经检查了键是否存在
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          '支持PDF, PNG, JPG, JPEG格式',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
