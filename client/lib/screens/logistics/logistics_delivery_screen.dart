import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/logistics_provider.dart';
import 'package:erpcrm_client/services/local_storage_service.dart';

class LogisticsDeliveryScreen extends ConsumerStatefulWidget {
  final String logisticsType;
  final int? logisticsId;

  const LogisticsDeliveryScreen({
    Key? key,
    required this.logisticsType,
    this.logisticsId,
  }) : super(key: key);

  @override
  ConsumerState<LogisticsDeliveryScreen> createState() => _LogisticsDeliveryScreenState();
}

class _LogisticsDeliveryScreenState extends ConsumerState<LogisticsDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _logisticsCompanyController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _senderPhoneController = TextEditingController();

  bool _isSubmitting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _logisticsCompanyController.dispose();
    _trackingNumberController.dispose();
    _senderPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    if (widget.logisticsId != null) {
      // 从本地存储加载现有数据
      final localStorageService = LocalStorageService();
      final data = await localStorageService
          .getLogisticsDeliveryData(widget.logisticsId!);
      if (data != null) {
        _logisticsCompanyController.text = data['logisticsCompany'] ?? '';
        _trackingNumberController.text = data['trackingNumber'] ?? '';
        _senderPhoneController.text = data['senderPhone'] ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: const Color(0xFF003366),
        actions: [
          TextButton(
            onPressed: () {
              _cancelOperation();
            },
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () {
              if (_formKey.currentState?.validate() ?? false) {
                _submitDelivery();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF003366),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF003366),
                    ),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {
              _hasChanges = true;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '发货信息',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366),
                ),
              ),
              const SizedBox(height: 24),

              // 物流公司
              TextFormField(
                controller: _logisticsCompanyController,
                decoration: const InputDecoration(
                  labelText: '物流公司',
                  border: OutlineInputBorder(),
                  hintText: '请输入物流公司名称',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入物流公司名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 物流单号
              TextFormField(
                controller: _trackingNumberController,
                decoration: const InputDecoration(
                  labelText: '物流单号',
                  border: OutlineInputBorder(),
                  hintText: '请输入物流单号',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入物流单号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 寄件人电话
              TextFormField(
                controller: _senderPhoneController,
                decoration: const InputDecoration(
                  labelText: '寄件人电话',
                  border: OutlineInputBorder(),
                  hintText: '请输入寄件人联系电话',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入寄件人电话';
                  }
                  if (value.length < 11) {
                    return '请输入有效的电话号码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 操作说明
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '操作说明',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. 填写完整的发货信息后点击保存'),
                      const Text('2. 信息会自动保存到本地，支持离线操作'),
                      const Text('3. 有网络时会自动同步到服务器'),
                      const Text('4. 点击取消可放弃当前操作'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (widget.logisticsType) {
      case 'pre-delivery':
        return '先发货物流 - 发货';
      case 'mall':
        return '商城订单物流 - 发货';
      case 'collector':
        return '集货商订单物流 - 发货';
      case 'other':
        return '其它业务物流 - 发货';
      default:
        return '物流发货';
    }
  }

  Future<void> _submitDelivery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 准备发货数据
      final deliveryData = {
        'id': widget.logisticsId ?? DateTime.now().millisecondsSinceEpoch,
        'logisticsType': widget.logisticsType,
        'logisticsCompany': _logisticsCompanyController.text,
        'trackingNumber': _trackingNumberController.text,
        'senderPhone': _senderPhoneController.text,
        'shippingDate': DateTime.now().toIso8601String(),
        'status': '已发货',
        'isSynced': false,
      };

      // 保存到本地存储
      final localStorageService = LocalStorageService();
      await localStorageService.saveLogisticsDeliveryData(deliveryData);

      // 更新物流状态
      ref.refresh(logisticsProvider(widget.logisticsType));

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('发货信息保存成功'),
          backgroundColor: Colors.green,
        ),
      );

      // 返回上一页
      context.pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _cancelOperation() {
    if (_hasChanges) {
      // 显示确认对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认取消'),
          content: const Text('您有未保存的更改，确定要取消吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('继续编辑'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('确定取消'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }
}