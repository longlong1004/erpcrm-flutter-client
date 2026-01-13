import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:erpcrm_client/models/order/order.dart';
import 'package:erpcrm_client/models/crm/customer.dart';
import 'package:erpcrm_client/models/approval/approval.dart';
import 'package:erpcrm_client/models/product/product.dart';
import 'package:erpcrm_client/models/warehouse/warehouse.dart';
import 'package:erpcrm_client/models/salary/attendance.dart';
import 'package:erpcrm_client/models/crm/sales_opportunity.dart';
import 'package:erpcrm_client/models/crm/contact_record.dart';

final logger = Logger();

/// 仪表盘数据服务
/// 负责从 Hive 读取和计算仪表盘所需的所有业务数据
class DashboardDataService {
  // Hive Box 名称常量
  static const String ordersBox = 'orders';
  static const String customersBox = 'customers';
  static const String approvalsBox = 'approvals';
  static const String productsBox = 'products';
  static const String inventoryBox = 'inventory';
  static const String warehouseBox = 'warehouse';
  static const String attendanceBox = 'attendance';
  static const String opportunitiesBox = 'sales_opportunities';
  static const String contactRecordsBox = 'contact_records';

  /// 获取仪表盘完整数据
  Future<Map<String, dynamic>> getDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 如果没有指定时间范围，默认为今天
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month, now.day);
      final end = endDate ?? DateTime(now.year, now.month, now.day, 23, 59, 59);

      // 并行获取各模块数据
      final results = await Future.wait([
        getOrderMetrics(start, end),
        getCustomerMetrics(start, end),
        getApprovalMetrics(start, end),
        getInventoryMetrics(),
        getPurchaseMetrics(start, end),
        getAttendanceMetrics(start, end),
        getFinanceMetrics(start, end),
        getOpportunityMetrics(start, end),
        getContactMetrics(start, end),
      ]);

      return {
        'orders': results[0],
        'customers': results[1],
        'approvals': results[2],
        'inventory': results[3],
        'purchase': results[4],
        'attendance': results[5],
        'finance': results[6],
        'opportunities': results[7],
        'contacts': results[8],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      logger.e('获取仪表盘数据失败: $e');
      return {
        'orders': {},
        'customers': {},
        'approvals': {},
        'inventory': {},
        'purchase': {},
        'attendance': {},
        'finance': {},
        'opportunities': {},
        'contacts': {},
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 获取订单指标数据
  Future<Map<String, dynamic>> getOrderMetrics(DateTime start, DateTime end) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);

      // 当前时间范围的订单
      final currentOrders = box.values.where((order) {
        return order.orderDate.isAfter(start) && order.orderDate.isBefore(end);
      }).toList();

      // 订单数量
      final orderCount = currentOrders.length;

      // 订单总金额
      final totalAmount = currentOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      // 计算增长率（对比上一个相同时间段）
      final duration = end.difference(start);
      final previousStart = start.subtract(duration);
      final previousEnd = start;

      final previousOrders = box.values.where((order) {
        return order.orderDate.isAfter(previousStart) &&
               order.orderDate.isBefore(previousEnd);
      }).toList();

      final previousCount = previousOrders.length;
      final growth = previousCount > 0
          ? ((orderCount - previousCount) / previousCount * 100)
          : 0.0;

      // 按状态统计
      final statusCounts = <String, int>{};
      for (var order in currentOrders) {
        final status = order.status;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      // 获取趋势数据
      final trendData = await _getOrderTrendData(box, start, end);

      return {
        'count': orderCount,
        'amount': totalAmount,
        'growth': growth,
        'statusCounts': statusCounts,
        'trendData': trendData,
      };
    } catch (e) {
      logger.e('获取订单指标失败: $e');
      return {
        'count': 0,
        'amount': 0.0,
        'growth': 0.0,
        'statusCounts': {},
        'trendData': [],
      };
    }
  }

  /// 获取订单趋势数据
  Future<List<Map<String, dynamic>>> _getOrderTrendData(
    Box<Order> box,
    DateTime start,
    DateTime end,
  ) async {
    final days = end.difference(start).inDays + 1;
    final trendData = <Map<String, dynamic>>[];

    for (var i = 0; i < days; i++) {
      final dayStart = start.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayOrders = box.values.where((order) {
        return order.orderDate.isAfter(dayStart) &&
               order.orderDate.isBefore(dayEnd);
      }).toList();

      final dayCount = dayOrders.length;
      final dayAmount = dayOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      trendData.add({
        'date': dayStart.toIso8601String(),
        'count': dayCount,
        'amount': dayAmount,
      });
    }

    return trendData;
  }

  /// 获取客户指标数据
  Future<Map<String, dynamic>> getCustomerMetrics(DateTime start, DateTime end) async {
    try {
      final box = await Hive.openBox<Customer>(customersBox);

      // 总客户数（未删除的）
      final totalCount = box.values.where((customer) => !customer.deleted).length;

      // 新增客户数
      final newCount = box.values.where((customer) {
        return customer.createTime.isAfter(start) &&
               customer.createTime.isBefore(end) &&
               !customer.deleted;
      }).length;

      // 计算增长率
      final duration = end.difference(start);
      final previousStart = start.subtract(duration);
      final previousEnd = start;

      final previousNewCount = box.values.where((customer) {
        return customer.createTime.isAfter(previousStart) &&
               customer.createTime.isBefore(previousEnd) &&
               !customer.deleted;
      }).length;

      final growth = previousNewCount > 0
          ? ((newCount - previousNewCount) / previousNewCount * 100)
          : 0.0;

      // 按类别统计
      final categoryCounts = <String, int>{};
      for (var customer in box.values.where((c) => !c.deleted)) {
        final category = customer.categoryName;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      // 获取趋势数据
      final trendData = await _getCustomerTrendData(box, start, end);

      return {
        'totalCount': totalCount,
        'newCount': newCount,
        'growth': growth,
        'categoryCounts': categoryCounts,
        'trendData': trendData,
      };
    } catch (e) {
      logger.e('获取客户指标失败: $e');
      return {
        'totalCount': 0,
        'newCount': 0,
        'growth': 0.0,
        'categoryCounts': {},
        'trendData': [],
      };
    }
  }

  /// 获取客户趋势数据
  Future<List<Map<String, dynamic>>> _getCustomerTrendData(
    Box<Customer> box,
    DateTime start,
    DateTime end,
  ) async {
    final days = end.difference(start).inDays + 1;
    final trendData = <Map<String, dynamic>>[];

    for (var i = 0; i < days; i++) {
      final dayStart = start.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayNewCustomers = box.values.where((customer) {
        return customer.createTime.isAfter(dayStart) &&
               customer.createTime.isBefore(dayEnd) &&
               !customer.deleted;
      }).length;

      // 累计客户数
      final cumulativeCount = box.values.where((customer) {
        return customer.createTime.isBefore(dayEnd) && !customer.deleted;
      }).length;

      trendData.add({
        'date': dayStart.toIso8601String(),
        'newCount': dayNewCustomers,
        'cumulativeCount': cumulativeCount,
      });
    }

    return trendData;
  }

  /// 获取审批指标数据
  Future<Map<String, dynamic>> getApprovalMetrics(DateTime start, DateTime end) async {
    try {
      final box = await Hive.openBox<Approval>(approvalsBox);

      // 待审批数量（状态为 pending）
      final pendingCount = box.values.where((approval) {
        return approval.status.toLowerCase() == 'pending' && approval.isSynced;
      }).length;

      // 今日审批数量
      final todayCount = box.values.where((approval) {
        return approval.createdAt.isAfter(start) &&
               approval.createdAt.isBefore(end) &&
               approval.isSynced;
      }).length;

      // 今日已审批数量
      final todayApprovedCount = box.values.where((approval) {
        return approval.updatedAt.isAfter(start) &&
               approval.updatedAt.isBefore(end) &&
               approval.status.toLowerCase() != 'pending' &&
               approval.isSynced;
      }).length;

      // 按类型统计
      final typeCounts = <String, int>{};
      for (var approval in box.values.where((a) => a.isSynced)) {
        final type = approval.type;
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }

      return {
        'pendingCount': pendingCount,
        'todayCount': todayCount,
        'todayApprovedCount': todayApprovedCount,
        'typeCounts': typeCounts,
      };
    } catch (e) {
      logger.e('获取审批指标失败: $e');
      return {
        'pendingCount': 0,
        'todayCount': 0,
        'todayApprovedCount': 0,
        'typeCounts': {},
      };
    }
  }

  /// 获取库存指标数据
  Future<Map<String, dynamic>> getInventoryMetrics() async {
    try {
      final box = await Hive.openBox<Inventory>(inventoryBox);

      // 库存总值
      final totalValue = box.values.fold<double>(
        0.0,
        (sum, inventory) => sum + inventory.totalValue,
      );

      // 预警商品数（库存低于安全库存）
      final warningCount = box.values.where((inventory) {
        return inventory.quantity < inventory.safetyStock;
      }).length;

      // 低库存商品数（库存低于安全库存的50%）
      final lowStockCount = box.values.where((inventory) {
        return inventory.quantity < (inventory.safetyStock * 0.5);
      }).length;

      // 缺货商品数（库存为0）
      final outOfStockCount = box.values.where((inventory) {
        return inventory.quantity == 0;
      }).length;

      // 按仓库统计
      final warehouseCounts = <String, int>{};
      final warehouseValues = <String, double>{};
      for (var inventory in box.values) {
        final warehouse = inventory.warehouseName;
        warehouseCounts[warehouse] = (warehouseCounts[warehouse] ?? 0) + inventory.quantity;
        warehouseValues[warehouse] = (warehouseValues[warehouse] ?? 0.0) + inventory.totalValue;
      }

      return {
        'totalValue': totalValue,
        'warningCount': warningCount,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
        'warehouseCounts': warehouseCounts,
        'warehouseValues': warehouseValues,
      };
    } catch (e) {
      logger.e('获取库存指标失败: $e');
      return {
        'totalValue': 0.0,
        'warningCount': 0,
        'lowStockCount': 0,
        'outOfStockCount': 0,
        'warehouseCounts': {},
        'warehouseValues': {},
      };
    }
  }

  /// 获取采购指标数据
  Future<Map<String, dynamic>> getPurchaseMetrics(DateTime start, DateTime end) async {
    try {
      final orderBox = await Hive.openBox<Order>(ordersBox);

      // 注意：这里假设采购订单也存储在 orders box 中，通过 orderType 字段区分
      // 如果有专门的采购订单表，需要调整
      
      // 待采购订单数（假设状态为 'pending' 或 'to_purchase'）
      final pendingCount = orderBox.values.where((order) {
        // 这里需要根据实际的采购订单标识调整
        return order.status.toLowerCase().contains('pending') ||
               order.status.toLowerCase().contains('purchase');
      }).length;

      // 本月采购金额
      final monthStart = DateTime(end.year, end.month, 1);
      final monthEnd = DateTime(end.year, end.month + 1, 0, 23, 59, 59);

      final monthlyOrders = orderBox.values.where((order) {
        return order.orderDate.isAfter(monthStart) &&
               order.orderDate.isBefore(monthEnd);
      }).toList();

      final monthlyAmount = monthlyOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      // 计算增长率（对比上月）
      final lastMonthStart = DateTime(end.year, end.month - 1, 1);
      final lastMonthEnd = DateTime(end.year, end.month, 0, 23, 59, 59);

      final lastMonthOrders = orderBox.values.where((order) {
        return order.orderDate.isAfter(lastMonthStart) &&
               order.orderDate.isBefore(lastMonthEnd);
      }).toList();

      final lastMonthAmount = lastMonthOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      final growth = lastMonthAmount > 0
          ? ((monthlyAmount - lastMonthAmount) / lastMonthAmount * 100)
          : 0.0;

      return {
        'pendingCount': pendingCount,
        'monthlyAmount': monthlyAmount,
        'growth': growth,
        'lastMonthAmount': lastMonthAmount,
      };
    } catch (e) {
      logger.e('获取采购指标失败: $e');
      return {
        'pendingCount': 0,
        'monthlyAmount': 0.0,
        'growth': 0.0,
        'lastMonthAmount': 0.0,
      };
    }
  }

  /// 获取考勤指标数据
  Future<Map<String, dynamic>> getAttendanceMetrics(DateTime start, DateTime end) async {
    try {
      final box = await Hive.openBox<Attendance>(attendanceBox);

      // 今日考勤记录
      final todayAttendances = box.values.where((attendance) {
        return attendance.date.isAfter(start) &&
               attendance.date.isBefore(end);
      }).toList();

      // 总人数（假设每个员工一天一条记录）
      final totalCount = todayAttendances.length;

      // 正常出勤人数
      final normalCount = todayAttendances.where((attendance) {
        return attendance.status.toLowerCase() == 'normal' ||
               attendance.status.toLowerCase() == 'present';
      }).length;

      // 出勤率
      final attendanceRate = totalCount > 0
          ? (normalCount / totalCount * 100)
          : 0.0;

      // 迟到人数
      final lateCount = todayAttendances.where((attendance) {
        return attendance.status.toLowerCase() == 'late';
      }).length;

      // 缺勤人数
      final absentCount = todayAttendances.where((attendance) {
        return attendance.status.toLowerCase() == 'absent';
      }).length;

      // 异常人数（迟到 + 缺勤 + 其他异常）
      final abnormalCount = todayAttendances.where((attendance) {
        return attendance.status.toLowerCase() != 'normal' &&
               attendance.status.toLowerCase() != 'present';
      }).length;

      // 按状态统计
      final statusCounts = <String, int>{};
      for (var attendance in todayAttendances) {
        final status = attendance.status;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'attendanceRate': attendanceRate,
        'abnormalCount': abnormalCount,
        'lateCount': lateCount,
        'absentCount': absentCount,
        'totalCount': totalCount,
        'normalCount': normalCount,
        'statusCounts': statusCounts,
      };
    } catch (e) {
      logger.e('获取考勤指标失败: $e');
      return {
        'attendanceRate': 0.0,
        'abnormalCount': 0,
        'lateCount': 0,
        'absentCount': 0,
        'totalCount': 0,
        'normalCount': 0,
        'statusCounts': {},
      };
    }
  }

  /// 获取财务指标数据
  Future<Map<String, dynamic>> getFinanceMetrics(DateTime start, DateTime end) async {
    try {
      final orderBox = await Hive.openBox<Order>(ordersBox);

      // 今日收入（今日订单总金额）
      final todayOrders = orderBox.values.where((order) {
        return order.orderDate.isAfter(start) &&
               order.orderDate.isBefore(end);
      }).toList();

      final todayIncome = todayOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      // 本月累计收入
      final monthStart = DateTime(end.year, end.month, 1);
      final monthEnd = DateTime(end.year, end.month + 1, 0, 23, 59, 59);

      final monthlyOrders = orderBox.values.where((order) {
        return order.orderDate.isAfter(monthStart) &&
               order.orderDate.isBefore(monthEnd);
      }).toList();

      final monthlyIncome = monthlyOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      // 计算增长率（对比上月）
      final lastMonthStart = DateTime(end.year, end.month - 1, 1);
      final lastMonthEnd = DateTime(end.year, end.month, 0, 23, 59, 59);

      final lastMonthOrders = orderBox.values.where((order) {
        return order.orderDate.isAfter(lastMonthStart) &&
               order.orderDate.isBefore(lastMonthEnd);
      }).toList();

      final lastMonthIncome = lastMonthOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      final growth = lastMonthIncome > 0
          ? ((monthlyIncome - lastMonthIncome) / lastMonthIncome * 100)
          : 0.0;

      // 获取收入趋势数据
      final trendData = await _getFinanceTrendData(orderBox, start, end);

      return {
        'todayIncome': todayIncome,
        'monthlyIncome': monthlyIncome,
        'growth': growth,
        'lastMonthIncome': lastMonthIncome,
        'trendData': trendData,
      };
    } catch (e) {
      logger.e('获取财务指标失败: $e');
      return {
        'todayIncome': 0.0,
        'monthlyIncome': 0.0,
        'growth': 0.0,
        'lastMonthIncome': 0.0,
        'trendData': [],
      };
    }
  }

  /// 获取财务趋势数据
  Future<List<Map<String, dynamic>>> _getFinanceTrendData(
    Box<Order> orderBox,
    DateTime start,
    DateTime end,
  ) async {
    final days = end.difference(start).inDays + 1;
    final trendData = <Map<String, dynamic>>[];

    for (var i = 0; i < days; i++) {
      final dayStart = start.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayOrders = orderBox.values.where((order) {
        return order.orderDate.isAfter(dayStart) &&
               order.orderDate.isBefore(dayEnd);
      }).toList();

      final dayIncome = dayOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.totalAmount,
      );

      // 支出数据（这里假设为收入的60%，实际应该从财务表读取）
      final dayExpense = dayIncome * 0.6;

      trendData.add({
        'date': dayStart.toIso8601String(),
        'income': dayIncome,
        'expense': dayExpense,
      });
    }

    return trendData;
  }

  /// 搜索功能：全局搜索客户、订单、商品
  Future<Map<String, List<dynamic>>> globalSearch(String keyword) async {
    try {
      if (keyword.isEmpty) {
        return {
          'customers': [],
          'orders': [],
          'products': [],
        };
      }

      final results = await Future.wait([
        _searchCustomers(keyword),
        _searchOrders(keyword),
        _searchProducts(keyword),
      ]);

      return {
        'customers': results[0],
        'orders': results[1],
        'products': results[2],
      };
    } catch (e) {
      logger.e('全局搜索失败: $e');
      return {
        'customers': [],
        'orders': [],
        'products': [],
      };
    }
  }

  /// 搜索客户
  Future<List<Customer>> _searchCustomers(String keyword) async {
    try {
      final box = await Hive.openBox<Customer>(customersBox);
      final lowerKeyword = keyword.toLowerCase();

      return box.values.where((customer) {
        return !customer.deleted &&
               (customer.name.toLowerCase().contains(lowerKeyword) ||
                customer.contactPerson.toLowerCase().contains(lowerKeyword) ||
                customer.contactPhone.contains(keyword) ||
                customer.contactEmail.toLowerCase().contains(lowerKeyword));
      }).toList();
    } catch (e) {
      logger.e('搜索客户失败: $e');
      return [];
    }
  }

  /// 搜索订单
  Future<List<Order>> _searchOrders(String keyword) async {
    try {
      final box = await Hive.openBox<Order>(ordersBox);
      final lowerKeyword = keyword.toLowerCase();

      return box.values.where((order) {
        return order.orderNumber.toLowerCase().contains(lowerKeyword) ||
               (order.notes?.toLowerCase().contains(lowerKeyword) ?? false) ||
               (order.trackingNumber?.toLowerCase().contains(lowerKeyword) ?? false);
      }).toList();
    } catch (e) {
      logger.e('搜索订单失败: $e');
      return [];
    }
  }

  /// 搜索商品
  Future<List<Product>> _searchProducts(String keyword) async {
    try {
      final box = await Hive.openBox<Product>(productsBox);
      final lowerKeyword = keyword.toLowerCase();

      return box.values.where((product) {
        return product.status.toLowerCase() != 'deleted' &&
               (product.name.toLowerCase().contains(lowerKeyword) ||
                product.code.toLowerCase().contains(lowerKeyword) ||
                (product.brand?.toLowerCase().contains(lowerKeyword) ?? false) ||
                (product.categoryName?.toLowerCase().contains(lowerKeyword) ?? false));
      }).toList();
    } catch (e) {
      logger.e('搜索商品失败: $e');
      return [];
    }
  }

  /// 获取待办事项列表
  Future<List<Map<String, dynamic>>> getTodoList() async {
    try {
      final box = await Hive.openBox<Approval>(approvalsBox);
      
      final todos = <Map<String, dynamic>>[];
      
      // 获取待审批事项
      final pendingApprovals = box.values.where((approval) {
        return approval.status.toLowerCase() == 'pending' && approval.isSynced;
      }).toList();

      // 按创建时间倒序排列
      pendingApprovals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 只取前10条
      for (var approval in pendingApprovals.take(10)) {
        todos.add({
          'id': approval.approvalId,
          'title': approval.title,
          'type': approval.type,
          'requester': approval.requesterName,
          'createdAt': approval.createdAt.toIso8601String(),
          'status': approval.status,
        });
      }

      return todos;
    } catch (e) {
      logger.e('获取待办事项失败: $e');
      return [];
    }
  }

  /// 获取业务关注列表
  Future<List<Map<String, dynamic>>> getBusinessFocusList() async {
    try {
      final orderBox = await Hive.openBox<Order>(ordersBox);
      final inventoryBoxData = await Hive.openBox<Inventory>(inventoryBox);

      final focusList = <Map<String, dynamic>>[];

      // 1. 待处理订单
      final pendingOrders = orderBox.values.where((order) {
        return order.status.toLowerCase() == 'pending' ||
               order.status.toLowerCase() == 'processing';
      }).length;

      if (pendingOrders > 0) {
        focusList.add({
          'type': 'order',
          'title': '待处理订单',
          'count': pendingOrders,
          'priority': 'high',
        });
      }

      // 2. 低库存商品
      final lowStockProducts = inventoryBoxData.values.where((inventory) {
        return inventory.quantity < inventory.safetyStock;
      }).length;

      if (lowStockProducts > 0) {
        focusList.add({
          'type': 'inventory',
          'title': '低库存商品',
          'count': lowStockProducts,
          'priority': 'medium',
        });
      }

      // 3. 缺货商品
      final outOfStockProducts = inventoryBoxData.values.where((inventory) {
        return inventory.quantity == 0;
      }).length;

      if (outOfStockProducts > 0) {
        focusList.add({
          'type': 'inventory',
          'title': '缺货商品',
          'count': outOfStockProducts,
          'priority': 'high',
        });
      }

      return focusList;
    } catch (e) {
      logger.e('获取业务关注列表失败: $e');
      return [];
    }
  }
}

  /// 获取商机指标数据
  Future<Map<String, dynamic>> getOpportunityMetrics(DateTime start, DateTime end) async {
    try {
      final opportunitiesBoxData = await Hive.openBox<SalesOpportunity>(DashboardDataService.opportunitiesBox);

      // 新增商机数
      final newOpportunities = opportunitiesBoxData.values.where((opp) {
        return opp.createTime.isAfter(start) &&
               opp.createTime.isBefore(end) &&
               !opp.deleted;
      }).toList();

      final newCount = newOpportunities.length;

      // 预估金额
      final expectedAmount = newOpportunities.fold<double>(
        0.0,
        (sum, opp) => sum + opp.expectedAmount,
      );

      // 赢单数（假设 stage 为 'won' 或 'closed_won'）
      final wonCount = opportunitiesBoxData.values.where((opp) {
        return opp.createTime.isAfter(start) &&
               opp.createTime.isBefore(end) &&
               !opp.deleted &&
               (opp.stage.toLowerCase() == 'won' || 
                opp.stage.toLowerCase() == 'closed_won' ||
                opp.stage.toLowerCase() == '已赢单');
      }).length;

      // 赢单金额
      final wonAmount = opportunitiesBoxData.values.where((opp) {
        return opp.createTime.isAfter(start) &&
               opp.createTime.isBefore(end) &&
               !opp.deleted &&
               (opp.stage.toLowerCase() == 'won' || 
                opp.stage.toLowerCase() == 'closed_won' ||
                opp.stage.toLowerCase() == '已赢单');
      }).fold<double>(0.0, (sum, opp) => sum + opp.expectedAmount);

      // 计算增长率
      final duration = end.difference(start);
      final previousStart = start.subtract(duration);
      final previousEnd = start;

      final previousNewCount = opportunitiesBoxData.values.where((opp) {
        return opp.createTime.isAfter(previousStart) &&
               opp.createTime.isBefore(previousEnd) &&
               !opp.deleted;
      }).length;

      final growth = previousNewCount > 0
          ? ((newCount - previousNewCount) / previousNewCount * 100)
          : 0.0;

      // 按阶段统计
      final stageCounts = <String, int>{};
      for (var opp in opportunitiesBoxData.values.where((o) => !o.deleted)) {
        final stage = opp.stage;
        stageCounts[stage] = (stageCounts[stage] ?? 0) + 1;
      }

      return {
        'newCount': newCount,
        'expectedAmount': expectedAmount,
        'wonCount': wonCount,
        'wonAmount': wonAmount,
        'growth': growth,
        'stageCounts': stageCounts,
      };
    } catch (e) {
      logger.e('获取商机指标失败: $e');
      return {
        'newCount': 0,
        'expectedAmount': 0.0,
        'wonCount': 0,
        'wonAmount': 0.0,
        'growth': 0.0,
        'stageCounts': {},
      };
    }
  }

  /// 获取跟进记录指标数据
  Future<Map<String, dynamic>> getContactMetrics(DateTime start, DateTime end) async {
    try {
      final contactRecordsBoxData = await Hive.openBox<ContactRecord>(DashboardDataService.contactRecordsBox);

      // 新增跟进数
      final newContacts = contactRecordsBoxData.values.where((contact) {
        try {
          final contactDate = DateTime.parse(contact.contactDate);
          return contactDate.isAfter(start) &&
                 contactDate.isBefore(end);
        } catch (e) {
          return false;
        }
      }).toList();

      final newCount = newContacts.length;

      // 计算增长率
      final duration = end.difference(start);
      final previousStart = start.subtract(duration);
      final previousEnd = start;

      final previousNewCount = contactRecordsBoxData.values.where((contact) {
        try {
          final contactDate = DateTime.parse(contact.contactDate);
          return contactDate.isAfter(previousStart) &&
                 contactDate.isBefore(previousEnd);
        } catch (e) {
          return false;
        }
      }).length;

      final growth = previousNewCount > 0
          ? ((newCount - previousNewCount) / previousNewCount * 100)
          : 0.0;

      // 按类型统计
      final typeCounts = <String, int>{};
      for (var contact in newContacts) {
        final type = contact.contactType;
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }

      return {
        'newCount': newCount,
        'growth': growth,
        'typeCounts': typeCounts,
      };
    } catch (e) {
      logger.e('获取跟进记录指标失败: $e');
      return {
        'newCount': 0,
        'growth': 0.0,
        'typeCounts': {},
      };
    }
  }
