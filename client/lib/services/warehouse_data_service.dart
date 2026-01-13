import 'package:hive_flutter/hive_flutter.dart';

/// 仓库数据服务类
class WarehouseDataService {
  static const String _inventoryBox = 'inventory';
  
  /// 获取仓库统计指标
  static Future<Map<String, dynamic>> getWarehouseMetrics() async {
    try {
      final inventoryBox = await Hive.openBox(_inventoryBox);
      final inventory = inventoryBox.values.toList();
      
      int totalItems = inventory.length;
      double totalValue = 0;
      int lowStockCount = 0;
      int outOfStockCount = 0;
      
      for (var item in inventory) {
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final price = (item['price'] as num?)?.toDouble() ?? 0;
        final safetyStock = (item['safetyStock'] as num?)?.toInt() ?? 10;
        
        totalValue += quantity * price;
        
        if (quantity == 0) {
          outOfStockCount++;
        } else if (quantity < safetyStock) {
          lowStockCount++;
        }
      }
      
      return {
        'totalItems': totalItems,
        'totalValue': totalValue,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
      };
    } catch (e) {
      return {
        'totalItems': 0,
        'totalValue': 0.0,
        'lowStockCount': 0,
        'outOfStockCount': 0,
      };
    }
  }
  
  /// 获取库存趋势数据
  static Future<List<Map<String, dynamic>>> getInventoryTrend({int days = 30}) async {
    // 简化实现：返回模拟数据
    final now = DateTime.now();
    final List<Map<String, dynamic>> trendData = [];
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      trendData.add({
        'date': '${date.month}/${date.day}',
        'inbound': (100 + i * 5).toDouble(),
        'outbound': (80 + i * 3).toDouble(),
      });
    }
    
    return trendData;
  }
}
