import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/crm_provider.dart';
import 'package:erpcrm_client/models/crm/customer.dart';
import 'package:erpcrm_client/models/crm/customer_category.dart';

class CustomerEditScreen extends ConsumerStatefulWidget {
  final int? customerId;

  const CustomerEditScreen({super.key, this.customerId});

  @override
  ConsumerState<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends ConsumerState<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _status = 1;
  int _categoryId = 0;
  List<int> _selectedTagIds = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerCategories = ref.watch(customerCategoriesProvider);

    // 如果是编辑模式，加载现有客户数据
    if (widget.customerId != null && !_isEditing) {
      final customerAsync = ref.watch(customerProvider(widget.customerId!));
      return customerAsync.when(
        data: (customer) {
          _isEditing = true;
          _initializeForm(customer);
          return _buildForm(context, customerCategories);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载客户数据失败: $error'),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildForm(context, customerCategories);
  }

  Widget _buildForm(BuildContext context, AsyncValue<List<CustomerCategory>> categoriesAsync) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑客户' : '新建客户'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 客户名称
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '客户名称',
                      hintText: '请输入客户名称',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入客户名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 联系人
                  TextFormField(
                    controller: _contactPersonController,
                    decoration: const InputDecoration(
                      labelText: '联系人',
                      hintText: '请输入联系人姓名',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入联系人姓名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 联系电话
                  TextFormField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: '联系电话',
                      hintText: '请输入联系电话',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入联系电话';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 电子邮箱
                  TextFormField(
                    controller: _contactEmailController,
                    decoration: const InputDecoration(
                      labelText: '电子邮箱',
                      hintText: '请输入电子邮箱',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入电子邮箱';
                      }
                      // 简单的邮箱格式验证
                      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                      if (!emailRegex.hasMatch(value)) {
                        return '请输入有效的电子邮箱';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 地址
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '地址',
                      hintText: '请输入客户地址',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),

                  // 客户分类
                  DropdownButtonFormField<int>(
                    value: _categoryId == 0 ? null : _categoryId,
                    decoration: const InputDecoration(
                      labelText: '客户分类',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.categoryId,
                        child: Text(category.categoryName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoryId = value ?? 0;
                      });
                    },
                    validator: (value) {
                      if (value == null || value == 0) {
                        return '请选择客户分类';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 客户状态
                  DropdownButtonFormField<int>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: '客户状态',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('活跃'),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text('不活跃'),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text('潜在'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value ?? 1;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 描述
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '描述',
                      hintText: '请输入客户描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24.0),

                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isEditing ? '保存修改' : '创建客户'),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // 取消按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载客户分类失败: $error'),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeForm(Customer customer) {
    _nameController.text = customer.name;
    _contactPersonController.text = customer.contactPerson;
    _contactPhoneController.text = customer.contactPhone;
    _contactEmailController.text = customer.contactEmail;
    _addressController.text = customer.address;
    _descriptionController.text = customer.description;
    _status = customer.status;
    _categoryId = customer.categoryId;
    _selectedTagIds = customer.tagIds;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final customerData = {
          'name': _nameController.text,
          'contactPerson': _contactPersonController.text,
          'contactPhone': _contactPhoneController.text,
          'contactEmail': _contactEmailController.text,
          'address': _addressController.text,
          'categoryId': _categoryId,
          'tagIds': _selectedTagIds,
          'description': _descriptionController.text,
          'status': _status,
        };

        if (_isEditing && widget.customerId != null) {
          // 编辑现有客户
          await ref.read(customersProvider.notifier).updateCustomer(
                widget.customerId!, 
                customerData
              );
        } else {
          // 创建新客户
          await ref.read(customersProvider.notifier).createCustomer(customerData);
        }

        // 返回上一页
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('操作失败: $error')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}