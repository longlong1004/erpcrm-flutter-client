import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController(text: 'admin');
  final passwordController = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    print('LoginScreen构建 - authState: isAuthenticated=${authState.isAuthenticated}, isLoading=$isLoading');
    
    // 添加一个测试按钮，用于清除本地存储的token，方便测试
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('测试提示'),
            content: const Text('已检测到本地存储中有token，是否清除token以测试登录流程？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  print('清除token按钮被点击');
                  await ref.read(authProvider.notifier).logout();
                  Navigator.pop(context);
                },
                child: const Text('清除token'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ERP+CRM国铁商城',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF003366),
                        ),
                  ),
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: '用户名',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                          validator: (value) {
                            print('用户名验证: $value');
                            if (value == null || value.isEmpty) {
                              return '请输入用户名';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: '密码',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          obscureText: true,
                          style: Theme.of(context).textTheme.bodyLarge,
                          validator: (value) {
                            print('密码验证: $value');
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (value.length < 6) {
                              return '密码长度不能少于6位';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    print('登录按钮onPressed被调用，isLoading: $isLoading');
                                    print('表单验证状态: ${_formKey.currentState?.validate() ?? false}');
                                    if (_formKey.currentState?.validate() ?? false) {
                                      print('登录按钮被点击');
                                      print('用户名: ${usernameController.text}');
                                      print('密码: ${passwordController.text}');
                                      try {
                                        print('开始调用authProvider.notifier.login');
                                        await ref.read(authProvider.notifier).login(
                                            usernameController.text,
                                            passwordController.text,
                                          );
                                        print('登录成功，等待GoRouter重定向');
                                        // 登录成功后，GoRouter的redirect机制会自动跳转
                                      } catch (e) {
                                        print('登录失败: $e');
                                        if (mounted) {
                                          // 显示更友好的错误信息
                                          String errorMessage = '登录失败，请检查用户名和密码';
                                          if (e.toString().contains('timeout') || e.toString().contains('连接')) {
                                            errorMessage = '网络连接超时，请检查网络设置';
                                          } else if (e.toString().contains('用户名或密码错误')) {
                                            errorMessage = '用户名或密码错误';
                                          }
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(errorMessage),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: const Color(0xFF003366),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('登录'),
                          ),
                        ),
                      ],
                    ),
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