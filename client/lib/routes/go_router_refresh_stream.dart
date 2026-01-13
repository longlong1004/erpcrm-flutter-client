import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// 用于让GoRouter监听Riverpod的StreamProvider变化
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}