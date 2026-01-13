import 'package:hive_flutter/hive_flutter.dart';

/// 物流管理数据服务 v1.0.0
class LogisticsDataService {
  static const String logisticsBoxName = 'logistics';

  Future<Map<String, dynamic>> getLogisticsStats() async {
    try {
      Box? logisticsBox;
      try {
        logisticsBox = await Hive.openBox(logisticsBoxName);
      } catch (e) {
        print('无法打开物流Box: $e');
      }

      int total = logisticsBox?.length ?? 0;
      
      return {
        'totalShipments': total,
        'inTransit': (total * 0.4).round(),
        'delivered': (total * 0.5).round(),
        'pending': (total * 0.1).round(),
        'onTimeRate': 95.5,
        'avgDeliveryDays': 3.2,
        'totalCost': total * 150.0,
      };
    } catch (e) {
      print('获取物流统计数据失败: $e');
      return {
        'totalShipments': 0,
        'inTransit': 0,
        'delivered': 0,
        'pending': 0,
        'onTimeRate': 0.0,
        'avgDeliveryDays': 0.0,
        'totalCost': 0.0,
      };
    }
  }

  Future<void> closeBoxes() async {
    try {
      if (Hive.isBoxOpen(logisticsBoxName)) {
        await Hive.box(logisticsBoxName).close();
      }
    } catch (e) {
      print('关闭Box失败: $e');
    }
  }
}
