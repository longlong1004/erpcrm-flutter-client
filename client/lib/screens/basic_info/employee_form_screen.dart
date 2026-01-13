import 'package:flutter/material.dart';
import '../../models/auth/employee.dart';
import '../../services/password_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;
  final Function(Employee) onSave;

  const EmployeeFormScreen({
    Key? key,
    this.employee,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  final PasswordService _passwordService = PasswordService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.employee?.username ?? 'employee_${DateTime.now().millisecondsSinceEpoch % 10000}');
    _passwordController = TextEditingController(text: widget.employee?.password ?? '');
    _nameController = TextEditingController(text: widget.employee?.name ?? '李四');
    _phoneNumberController = TextEditingController(text: widget.employee?.phoneNumber ?? '13900139000');
    _departmentController = TextEditingController(text: widget.employee?.department ?? '销售部');
    _positionController = TextEditingController(text: widget.employee?.position ?? '销售经理');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? '新增员工' : '编辑员工'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 登录账号
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '登录账号',
                  hintText: '请输入登录账号',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入登录账号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 登录密码
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '登录密码',
                  hintText: '请输入登录密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if ((widget.employee == null && (value == null || value.isEmpty)) || 
                      (value != null && value.isNotEmpty && value.length < 6)) {
                    return '密码长度不能少于6位';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 业务员
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '业务员',
                  hintText: '请输入业务员姓名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入业务员姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 联系方式
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: '联系方式',
                  hintText: '请输入联系方式',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入联系方式';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 所属部门
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: '所属部门',
                  hintText: '请输入所属部门',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入所属部门';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 所属岗位
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: '所属岗位',
                  hintText: '请输入所属岗位',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入所属岗位';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 创建时间（只读）
              TextFormField(
                initialValue: widget.employee?.createdAt.toString().substring(0, 19) ?? DateTime.now().toString().substring(0, 19),
                decoration: const InputDecoration(
                  labelText: '创建时间',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 32),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final employee = widget.employee == null
                            ? Employee.create(
                                username: _usernameController.text,
                                password: _passwordController.text,
                                name: _nameController.text,
                                phoneNumber: _phoneNumberController.text,
                                department: _departmentController.text,
                                position: _positionController.text,
                              )
                            : Employee(
                                id: widget.employee!.id,
                                username: _usernameController.text,
                                password: _passwordController.text.isEmpty
                                    ? widget.employee!.password
                                    : _passwordService.hashPassword(_passwordController.text),
                                name: _nameController.text,
                                phoneNumber: _phoneNumberController.text,
                                department: _departmentController.text,
                                position: _positionController.text,
                                createdAt: widget.employee!.createdAt,
                              );
                        widget.onSave(employee);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('确认'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
