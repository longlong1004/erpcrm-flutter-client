import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/providers/auth_provider.dart';

/// 用于监听AuthNotifier状态变化的Listenable实现
class AuthListenable extends ChangeNotifier {
  final Ref ref;
  
  AuthListenable(this.ref) {
    // 监听authProvider的状态变化
    ref.listen(authProvider, (previous, next) {
      print('AuthListenable检测到authProvider状态变化: previous=${previous?.isAuthenticated}, next=${next.isAuthenticated}');
      // 当认证状态变化时，通知监听器
      notifyListeners();
    });
  }
}

/// 提供AuthListenable实例的Provider
final authListenableProvider = Provider<AuthListenable>((ref) {
  return AuthListenable(ref);
});
