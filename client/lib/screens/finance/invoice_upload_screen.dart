import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class InvoiceUploadScreen extends StatefulWidget {
  final Map<String, dynamic> invoiceData;

  const InvoiceUploadScreen({super.key, required this.invoiceData});

  @override
  State<InvoiceUploadScreen> createState() => _InvoiceUploadScreenState();
}

class _InvoiceUploadScreenState extends State<InvoiceUploadScreen> {
  String? _invoiceFilePath;
  bool _isUploading = false;

  Future<void> _uploadInvoice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xml', 'odf'],
    );
     
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _invoiceFilePath = file.name;
        _isUploading = true;
      });
      
      // 模拟上传文件
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isUploading = false;
      });
      
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发票上传成功: ${file.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitUpload() {
    if (_invoiceFilePath == null) {
      // 提示上传发票
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先上传发票'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // 执行上传逻辑
    print('确认上传发票: ${widget.invoiceData['发票号']}');
    print('上传文件: $_invoiceFilePath');
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('发票上传成功，状态已更新'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 返回上一页
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '上传发票',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '上传发票',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 24),
            // 上传表单
            Container(
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
                  children: [
                    // 发票信息
                    Text(
                      '发票信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('发票号', widget.invoiceData['发票号'] ?? ''),
                    _buildInfoRow('订单编号', widget.invoiceData['订单编号'] ?? ''),
                    _buildInfoRow('供应商', widget.invoiceData['供应商'] ?? ''),
                    _buildInfoRow('发票金额', '¥${widget.invoiceData['发票金额'] ?? 0.0}'),
                    _buildInfoRow('开票日期', widget.invoiceData['开票日期'] ?? ''),
                    
                    const SizedBox(height: 24),
                    // 上传区域
                    Text(
                      '上传发票',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('发票文件'),
                              const SizedBox(height: 8),
                              Text(
                                _invoiceFilePath ?? '未上传',
                                style: TextStyle(
                                  color: _invoiceFilePath != null ? Colors.green : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '支持格式: PDF, XML, ODF',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                            onPressed: _isUploading ? null : () async => await _uploadInvoice(),
                            icon: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.upload_file),
                            label: const Text('上传发票'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    // 操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C757D),
                          ),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _submitUpload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF107C10),
                          ),
                          child: const Text('确认上传'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
