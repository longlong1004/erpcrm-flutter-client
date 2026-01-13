import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_database.dart';

/// 数据库实例提供者
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  
  // 当提供者被销毁时关闭数据库连接
  ref.onDispose(() {
    database.close();
  });
  
  return database;
});
