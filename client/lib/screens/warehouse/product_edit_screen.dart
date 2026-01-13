import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/main_layout.dart';

class ProductEditScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;
  
  const ProductEditScreen({super.key, this.productData});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  // 表单控制器
  final Map<String, TextEditingController> _controllers = {
    '序号': TextEditingController(),
    '商品名称': TextEditingController(),
    '商品型号': TextEditingController(),
    '单位': TextEditingController(),
    '备注': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    // 如果有数据，初始化控制器
    if (widget.productData != null) {
      _controllers.forEach((key, controller) {
        controller.text = widget.productData![key]?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    // 提交表单数据
    print('提交商品编辑');
    print('表单数据: ${_controllers.map((key, value) => MapEntry(key, value.text))}');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('编辑成功'),
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
      title: widget.productData == null ? '新增商品' : '编辑商品',
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
                    widget.productData == null ? '新增商品' : '编辑商品',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F1F1F),
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 表单字段
                  _buildFormField('序号', '序号'),
                  const SizedBox(height: 16),
                  _buildFormField('商品名称', '商品名称'),
                  const SizedBox(height: 16),
                  _buildFormField('商品型号', '商品型号'),
                  const SizedBox(height: 16),
                  _buildFormField('单位', '单位'),
                  const SizedBox(height: 16),
                  _buildFormField('备注', '备注', maxLines: 3),
                  const SizedBox(height: 16),
                  
                  // 实物图片
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '实物图片',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image, size: 50, color: Color(0xFF9E9E9E)),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () async {
                                  // 上传图片
                                  try {
                                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                      allowMultiple: false,
                                    );
                                    if (result != null) {
                                      PlatformFile file = result.files.first;
                                      print('选择的图片文件: ${file.name}, 大小: ${file.size} bytes');
                                      // 这里可以添加图片上传逻辑
                                    }
                                  } catch (e) {
                                    print('选择图片时出错: $e');
                                  }
                                },
                                child: const Text('上传图片'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                        child: const Text('保存'),
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
  
  // 构建表单字段
  Widget _buildFormField(String label, String key, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[key],
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
