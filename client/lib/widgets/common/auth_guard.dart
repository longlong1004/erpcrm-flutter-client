import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/logger_service.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    LoggerService.debug('AuthGuard: isLoading=${authState.isLoading}, isAuthenticated=${authState.isAuthenticated}');

    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authState.isAuthenticated) {
      LoggerService.debug('AuthGuard: 用户已认证，显示子组件');
      return child;
    } else {
      LoggerService.debug('AuthGuard: 用户未认证，跳转到登录页面');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }
  }
}