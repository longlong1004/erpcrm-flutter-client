import 'package:hive_flutter/hive_flutter.dart';

/// 商品数据服务类
class ProductDataService {
  static const String _productsBox = 'products';
  
  /// 获取商品统计指标
  static Future<Map<String, dynamic>> getProductMetrics() async {
    try {
      final productsBox = await Hive.openBox(_productsBox);
      final products = productsBox.values.toList();
      
      int totalProducts = products.length;
      int activeProducts = products.where((p) => p['status'] != 'deleted').length;
      int lowStockProducts = products.where((p) {
        final stock = (p['stock'] as num?)?.toInt() ?? 0;
        final safetyStock = (p['safetyStock'] as num?)?.toInt() ?? 10;
        return stock < safetyStock && stock > 0;
      }).length;
      int outOfStockProducts = products.where((p) => (p['stock'] as num?)?.toInt() == 0).length;
      
      return {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
      };
    } catch (e) {
      return {
        'totalProducts': 0,
        'activeProducts': 0,
        'lowStockProducts': 0,
        'outOfStockProducts': 0,
      };
    }
  }
}
