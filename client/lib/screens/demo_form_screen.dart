import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';

// 演示表单状态
class DemoFormState {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String notes;
  final bool agreedToTerms;

  DemoFormState({    this.name = '张三',    this.email = 'zhangsan@example.com',    this.phone = '13800138000',    this.address = '北京市朝阳区建国路88号',    this.notes = '这是一个示例备注，用于演示表单功能。',    this.agreedToTerms = false,  });

  DemoFormState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
    bool? agreedToTerms,
  }) {
    return DemoFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'agreedToTerms': agreedToTerms,
    };
  }

  factory DemoFormState.fromJson(Map<String, dynamic> json) {
    return DemoFormState(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
      agreedToTerms: json['agreedToTerms'] ?? false,
    );
  }
}

// 演示表单页面
class DemoFormScreen extends ConsumerStatefulWidget {
  final String formId;
  final String title;

  const DemoFormScreen({
    Key? key,
    this.formId = 'default',
    this.title = '演示表单',
  }) : super(key: key);

  @override
  ConsumerState<DemoFormScreen> createState() => _DemoFormScreenState();
}

class _DemoFormScreenState extends ConsumerState<DemoFormScreen> {
  late DemoFormState _formState;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    
    // 从标签页状态恢复表单状态
    _loadFormStateFromTab();
    
    // 初始化控制器
    _nameController = TextEditingController(text: _formState.name);
    _emailController = TextEditingController(text: _formState.email);
    _phoneController = TextEditingController(text: _formState.phone);
    _addressController = TextEditingController(text: _formState.address);
    _notesController = TextEditingController(text: _formState.notes);
  }

  @override
  void dispose() {
    // 保存表单状态到标签页
    _saveFormStateToTab();
    
    // 释放控制器
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听路由变化，确保表单状态正确保存
    final currentRoute = GoRouterState.of(context).uri.toString();
    print('DemoFormScreen: 当前路由 $currentRoute');
  }

  // 从标签页状态加载表单状态
  void _loadFormStateFromTab() {
    final tabs = ref.read(tabProvider);
    if (tabs.isEmpty) {
      print('DemoFormScreen: 标签页列表为空，使用默认表单状态');
      setState(() {
        _formState = DemoFormState();
      });
      return;
    }
    
    final activeTab = tabs.firstWhere((tab) => tab.isActive, orElse: () => tabs.first);
    
    // 从当前激活标签页加载表单状态
    final tabState = activeTab.state ?? {};
    final formStateJson = tabState['formState_${widget.formId}'] ?? {};
    
    setState(() {
      _formState = DemoFormState.fromJson(formStateJson);
    });
    
    print('DemoFormScreen: 从标签页 ${activeTab.id} 加载表单状态: $formStateJson');
  }

  // 保存表单状态到标签页
  void _saveFormStateToTab() {
    try {
      final tabs = ref.read(tabProvider);
      if (tabs.isEmpty) {
        print('DemoFormScreen: 标签页列表为空，无法保存表单状态');
        return;
      }
      
      final activeTabIndex = tabs.indexWhere((tab) => tab.isActive);
      
      if (activeTabIndex != -1) {
        final activeTab = tabs[activeTabIndex];
        final tabState = activeTab.state ?? {};
        
        // 更新表单状态
        final updatedTabState = {
          ...tabState,
          'formState_${widget.formId}': _formState.toJson(),
        };
        
        // 更新标签页状态
        ref.read(tabProvider.notifier).updateTabState(
          activeTab.id,
          updatedTabState,
        );
        
        print('DemoFormScreen: 保存表单状态到标签页 ${activeTab.id}: ${_formState.toJson()}');
      }
    } catch (e) {
      print('DemoFormScreen: 保存表单状态失败: $e');
    }
  }

  // 处理表单字段变化
  void _handleFieldChange(String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'name':
          _formState = _formState.copyWith(name: value);
          break;
        case 'email':
          _formState = _formState.copyWith(email: value);
          break;
        case 'phone':
          _formState = _formState.copyWith(phone: value);
          break;
        case 'address':
          _formState = _formState.copyWith(address: value);
          break;
        case 'notes':
          _formState = _formState.copyWith(notes: value);
          break;
        case 'agreedToTerms':
          _formState = _formState.copyWith(agreedToTerms: value);
          break;
      }
    });
    
    // 实时保存到标签页
    _saveFormStateToTab();
  }

  // 提交表单
  void _submitForm() {
    if (_formState.agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('表单提交成功！'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 重置表单
      setState(() {
        _formState = DemoFormState();
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _notesController.clear();
      });
      
      // 保存重置后的状态
      _saveFormStateToTab();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请同意服务条款！'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表单标题
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '这是一个演示表单，展示标签页切换时表单状态的保存和恢复功能',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24.0),
            
            // 表单卡片
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 姓名
                    _buildFormField(
                      label: '姓名',
                      hintText: '请输入您的姓名',
                      controller: _nameController,
                      onChanged: (value) => _handleFieldChange('name', value),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // 邮箱
                    _buildFormField(
                      label: '邮箱',
                      hintText: '请输入您的邮箱',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _handleFieldChange('email', value),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // 电话
                    _buildFormField(
                      label: '电话',
                      hintText: '请输入您的电话',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => _handleFieldChange('phone', value),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // 地址
                    _buildFormField(
                      label: '地址',
                      hintText: '请输入您的地址',
                      controller: _addressController,
                      maxLines: 3,
                      onChanged: (value) => _handleFieldChange('address', value),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // 备注
                    _buildFormField(
                      label: '备注',
                      hintText: '请输入备注信息',
                      controller: _notesController,
                      maxLines: 4,
                      onChanged: (value) => _handleFieldChange('notes', value),
                    ),
                    const SizedBox(height: 24.0),
                    
                    // 同意条款
                    Row(
                      children: [
                        Checkbox(
                          value: _formState.agreedToTerms,
                          onChanged: (value) => _handleFieldChange('agreedToTerms', value ?? false),
                          activeColor: const Color(0xFF007AFF),
                        ),
                        Expanded(
                          child: Text(
                            '我已阅读并同意服务条款和隐私政策',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    
                    // 提交按钮
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('提交表单'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            
            // 操作提示
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: const Color(0xFFE3F2FD),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '操作提示',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      '1. 在表单中输入一些内容',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      '2. 点击顶部"新建标签页"按钮，打开一个新标签页',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      '3. 在新标签页中选择"演示表单"或其他模块',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      '4. 切换回之前的标签页，您会看到表单内容已保存',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: const Color(0xFF1565C0),
                      ),
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

  // 构建表单字段
  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xFF007AFF),
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
