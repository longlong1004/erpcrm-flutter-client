import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/order/order.dart';

final logger = Logger();

/// 订单数据服务类
/// 负责从 Hive 读取订单数据并进行统计分析
class OrderDataService {
  // Hive Box 名称
  static const String ordersBox = 'orders';

  /// 获取订单统计指标
  Future<Map<String, dynamic>> getOrderMetrics(DateTime start, DateTime end) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      // 筛选时间范围内的订单
      final ordersInRange = box.values.where((order) {
        return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
      }).toList();

      // 今日订单数
      final todayOrders = ordersInRange.where((order) {
        final now = DateTime.now();
        return order.createdAt.year == now.year &&
               order.createdAt.month == now.month &&
               order.createdAt.day == now.day;
      }).length;

      // 本月订单数
      final thisMonthOrders = ordersInRange.where((order) {
        final now = DateTime.now();
        return order.createdAt.year == now.year &&
               order.createdAt.month == now.month;
      }).length;

      // 待处理订单数（status为pending或processing）
      final pendingOrders = box.values.where((order) {
        return order.status == 'pending' || order.status == 'processing';
      }).length;

      // 总订单数
      final totalOrders = ordersInRange.length;

      // 总金额
      final totalAmount = ordersInRange.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      // 平均订单金额
      final averageAmount = totalOrders > 0 ? totalAmount / totalOrders : 0.0;

      // 计算增长率（对比上一时间段）
      final duration = end.difference(start);
      final previousStart = start.subtract(duration);
      final previousEnd = start;

      final previousOrders = box.values.where((order) {
        return order.createdAt.isAfter(previousStart) &&
               order.createdAt.isBefore(previousEnd);
      }).length;

      final growth = previousOrders > 0
          ? ((totalOrders - previousOrders) / previousOrders * 100)
          : 0.0;

      // 按状态统计
      final statusCounts = <String, int>{};
      for (var order in ordersInRange) {
        final status = order.status;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      // 按订单类型统计
      final typeCounts = <String, int>{};
      for (var order in ordersInRange) {
        final type = order.orderType ?? '未分类';
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }

      return {
        'todayOrders': todayOrders,
        'thisMonthOrders': thisMonthOrders,
        'pendingOrders': pendingOrders,
        'totalOrders': totalOrders,
        'totalAmount': totalAmount,
        'averageAmount': averageAmount,
        'growth': growth,
        'statusCounts': statusCounts,
        'typeCounts': typeCounts,
      };
    } catch (e) {
      logger.e('获取订单指标失败: $e');
      return {
        'todayOrders': 0,
        'thisMonthOrders': 0,
        'pendingOrders': 0,
        'totalOrders': 0,
        'totalAmount': 0.0,
        'averageAmount': 0.0,
        'growth': 0.0,
        'statusCounts': {},
        'typeCounts': {},
      };
    }
  }

  /// 获取订单趋势数据（用于图表）
  Future<List<Map<String, dynamic>>> getOrderTrend(DateTime start, DateTime end, String groupBy) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      // 筛选时间范围内的订单
      final ordersInRange = box.values.where((order) {
        return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
      }).toList();

      // 按日期分组
      final Map<String, List<Order>> groupedOrders = {};

      for (var order in ordersInRange) {
        String key;
        if (groupBy == 'day') {
          key = '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}';
        } else if (groupBy == 'week') {
          final weekNumber = _getWeekNumber(order.createdAt);
          key = '${order.createdAt.year}-W$weekNumber';
        } else {
          // month
          key = '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';
        }

        if (!groupedOrders.containsKey(key)) {
          groupedOrders[key] = [];
        }
        groupedOrders[key]!.add(order);
      }

      // 转换为图表数据
      final trendData = <Map<String, dynamic>>[];
      final sortedKeys = groupedOrders.keys.toList()..sort();

      for (var key in sortedKeys) {
        final orders = groupedOrders[key]!;
        final count = orders.length;
        final amount = orders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);

        trendData.add({
          'date': key,
          'count': count,
          'amount': amount,
        });
      }

      return trendData;
    } catch (e) {
      logger.e('获取订单趋势失败: $e');
      return [];
    }
  }

  /// 获取周数
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  /// 搜索订单
  Future<List<Order>> searchOrders(String query) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      if (query.isEmpty) {
        return box.values.toList();
      }

      final lowerQuery = query.toLowerCase();

      return box.values.where((order) {
        return order.orderNumber.toLowerCase().contains(lowerQuery) ||
               order.shippingAddress?.toLowerCase().contains(lowerQuery) == true ||
               order.notes?.toLowerCase().contains(lowerQuery) == true ||
               order.trackingNumber?.toLowerCase().contains(lowerQuery) == true;
      }).toList();
    } catch (e) {
      logger.e('搜索订单失败: $e');
      return [];
    }
  }

  /// 按状态筛选订单
  Future<List<Order>> filterOrdersByStatus(String status) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      return box.values.where((order) => order.status == status).toList();
    } catch (e) {
      logger.e('按状态筛选订单失败: $e');
      return [];
    }
  }

  /// 按日期范围筛选订单
  Future<List<Order>> filterOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      return box.values.where((order) {
        return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
      }).toList();
    } catch (e) {
      logger.e('按日期范围筛选订单失败: $e');
      return [];
    }
  }

  /// 按金额范围筛选订单
  Future<List<Order>> filterOrdersByAmountRange(double minAmount, double maxAmount) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      return box.values.where((order) {
        return order.totalAmount >= minAmount && order.totalAmount <= maxAmount;
      }).toList();
    } catch (e) {
      logger.e('按金额范围筛选订单失败: $e');
      return [];
    }
  }

  /// 获取订单状态分布数据（用于饼图）
  Future<Map<String, int>> getOrderStatusDistribution() async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      final statusCounts = <String, int>{};

      for (var order in box.values) {
        final status = order.status;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return statusCounts;
    } catch (e) {
      logger.e('获取订单状态分布失败: $e');
      return {};
    }
  }

  /// 获取订单类型分布数据（用于饼图）
  Future<Map<String, int>> getOrderTypeDistribution() async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      final typeCounts = <String, int>{};

      for (var order in box.values) {
        final type = order.orderType ?? '未分类';
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }

      return typeCounts;
    } catch (e) {
      logger.e('获取订单类型分布失败: $e');
      return {};
    }
  }
}
