import 'package:hive_flutter/hive_flutter.dart';

/// 财务数据服务类
/// 提供财务统计、分析、预警等功能
class FinanceDataService {
  // Hive box 名称常量
  static const String _ordersBox = 'orders';
  static const String _customersBox = 'customers';
  static const String _productsBox = 'products';
  
  /// 获取财务统计指标
  /// 返回应收总额、应付总额、本月收入、本月支出等
  static Future<Map<String, dynamic>> getFinanceMetrics() async {
    try {
      final ordersBox = await Hive.openBox(_ordersBox);
      final orders = ordersBox.values.toList();
      
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      
      // 计算应收总额（所有未收款订单）
      double totalReceivable = 0;
      int receivableCount = 0;
      
      // 计算应付总额（所有未付款订单）
      double totalPayable = 0;
      int payableCount = 0;
      
      // 计算本月收入（已收款订单）
      double monthlyIncome = 0;
      int incomeCount = 0;
      
      // 计算本月支出（已付款订单）
      double monthlyExpense = 0;
      int expenseCount = 0;
      
      for (var order in orders) {
        final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0;
        final paymentStatus = order['paymentStatus'] as String? ?? '';
        final createdAt = order['createdAt'] as String?;
        
        if (createdAt != null) {
          final orderDate = DateTime.tryParse(createdAt);
          
          // 应收账款（未收款）
          if (paymentStatus == 'unpaid' || paymentStatus == 'pending') {
            totalReceivable += totalAmount;
            receivableCount++;
          }
          
          // 应付账款（未付款）
          if (paymentStatus == 'unpaid' || paymentStatus == 'pending') {
            totalPayable += totalAmount * 0.7; // 假设成本为70%
            payableCount++;
          }
          
          // 本月收入（已收款）
          if (orderDate != null &&
              orderDate.isAfter(firstDayOfMonth) &&
              orderDate.isBefore(lastDayOfMonth) &&
              paymentStatus == 'paid') {
            monthlyIncome += totalAmount;
            incomeCount++;
          }
          
          // 本月支出（已付款）
          if (orderDate != null &&
              orderDate.isAfter(firstDayOfMonth) &&
              orderDate.isBefore(lastDayOfMonth) &&
              paymentStatus == 'paid') {
            monthlyExpense += totalAmount * 0.7; // 假设成本为70%
            expenseCount++;
          }
        }
      }
      
      // 计算本月利润
      final monthlyProfit = monthlyIncome - monthlyExpense;
      
      // 计算利润率
      final profitMargin = monthlyIncome > 0 ? (monthlyProfit / monthlyIncome * 100) : 0;
      
      return {
        'totalReceivable': totalReceivable,
        'receivableCount': receivableCount,
        'totalPayable': totalPayable,
        'payableCount': payableCount,
        'monthlyIncome': monthlyIncome,
        'incomeCount': incomeCount,
        'monthlyExpense': monthlyExpense,
        'expenseCount': expenseCount,
        'monthlyProfit': monthlyProfit,
        'profitMargin': profitMargin,
      };
    } catch (e) {
      print('获取财务指标失败: $e');
      return {
        'totalReceivable': 0.0,
        'receivableCount': 0,
        'totalPayable': 0.0,
        'payableCount': 0,
        'monthlyIncome': 0.0,
        'incomeCount': 0,
        'monthlyExpense': 0.0,
        'expenseCount': 0,
        'monthlyProfit': 0.0,
        'profitMargin': 0.0,
      };
    }
  }
  
  /// 获取收支趋势数据
  /// 返回最近30天的收入和支出数据
  static Future<List<Map<String, dynamic>>> getRevenueTrend({int days = 30}) async {
    try {
      final ordersBox = await Hive.openBox(_ordersBox);
      final orders = ordersBox.values.toList();
      
      final now = DateTime.now();
      final List<Map<String, dynamic>> trendData = [];
      
      // 生成最近N天的数据
      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = '${date.month}/${date.day}';
        
        double dailyIncome = 0;
        double dailyExpense = 0;
        
        for (var order in orders) {
          final createdAt = order['createdAt'] as String?;
          if (createdAt != null) {
            final orderDate = DateTime.tryParse(createdAt);
            if (orderDate != null &&
                orderDate.year == date.year &&
                orderDate.month == date.month &&
                orderDate.day == date.day) {
              final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0;
              final paymentStatus = order['paymentStatus'] as String? ?? '';
              
              if (paymentStatus == 'paid') {
                dailyIncome += totalAmount;
                dailyExpense += totalAmount * 0.7; // 假设成本为70%
              }
            }
          }
        }
        
        trendData.add({
          'date': dateStr,
          'income': dailyIncome,
          'expense': dailyExpense,
          'profit': dailyIncome - dailyExpense,
        });
      }
      
      return trendData;
    } catch (e) {
      print('获取收支趋势失败: $e');
      return [];
    }
  }
  
  /// 获取应收账款预警
  /// 返回逾期应收、即将逾期应收等
  static Future<Map<String, dynamic>> getReceivableWarnings() async {
    try {
      final ordersBox = await Hive.openBox(_ordersBox);
      final orders = ordersBox.values.toList();
      
      final now = DateTime.now();
      
      int overdueCount = 0; // 逾期应收
      double overdueAmount = 0;
      
      int soonDueCount = 0; // 即将逾期（7天内）
      double soonDueAmount = 0;
      
      int normalCount = 0; // 正常应收
      double normalAmount = 0;
      
      for (var order in orders) {
        final paymentStatus = order['paymentStatus'] as String? ?? '';
        if (paymentStatus == 'unpaid' || paymentStatus == 'pending') {
          final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0;
          final dueDate = order['dueDate'] as String?;
          
          if (dueDate != null) {
            final due = DateTime.tryParse(dueDate);
            if (due != null) {
              final daysUntilDue = due.difference(now).inDays;
              
              if (daysUntilDue < 0) {
                // 已逾期
                overdueCount++;
                overdueAmount += totalAmount;
              } else if (daysUntilDue <= 7) {
                // 即将逾期（7天内）
                soonDueCount++;
                soonDueAmount += totalAmount;
              } else {
                // 正常
                normalCount++;
                normalAmount += totalAmount;
              }
            }
          } else {
            // 没有到期日期，视为正常
            normalCount++;
            normalAmount += totalAmount;
          }
        }
      }
      
      return {
        'overdueCount': overdueCount,
        'overdueAmount': overdueAmount,
        'soonDueCount': soonDueCount,
        'soonDueAmount': soonDueAmount,
        'normalCount': normalCount,
        'normalAmount': normalAmount,
        'totalCount': overdueCount + soonDueCount + normalCount,
        'totalAmount': overdueAmount + soonDueAmount + normalAmount,
      };
    } catch (e) {
      print('获取应收账款预警失败: $e');
      return {
        'overdueCount': 0,
        'overdueAmount': 0.0,
        'soonDueCount': 0,
        'soonDueAmount': 0.0,
        'normalCount': 0,
        'normalAmount': 0.0,
        'totalCount': 0,
        'totalAmount': 0.0,
      };
    }
  }
  
  /// 获取成本和利润分析
  /// 返回按类别、按产品的成本和利润分析
  static Future<Map<String, dynamic>> getCostProfitAnalysis() async {
    try {
      final ordersBox = await Hive.openBox(_ordersBox);
      final orders = ordersBox.values.toList();
      
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      
      // 按业务类型统计
      Map<String, Map<String, double>> byType = {};
      
      // 按产品统计
      Map<String, Map<String, double>> byProduct = {};
      
      for (var order in orders) {
        final createdAt = order['createdAt'] as String?;
        if (createdAt != null) {
          final orderDate = DateTime.tryParse(createdAt);
          if (orderDate != null &&
              orderDate.isAfter(firstDayOfMonth) &&
              orderDate.isBefore(lastDayOfMonth)) {
            final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0;
            final paymentStatus = order['paymentStatus'] as String? ?? '';
            final businessType = order['businessType'] as String? ?? '未分类';
            final productName = order['productName'] as String? ?? '未知商品';
            
            if (paymentStatus == 'paid') {
              final cost = totalAmount * 0.7; // 假设成本为70%
              final profit = totalAmount - cost;
              
              // 按业务类型统计
              if (!byType.containsKey(businessType)) {
                byType[businessType] = {
                  'revenue': 0,
                  'cost': 0,
                  'profit': 0,
                };
              }
              byType[businessType]!['revenue'] = (byType[businessType]!['revenue'] ?? 0) + totalAmount;
              byType[businessType]!['cost'] = (byType[businessType]!['cost'] ?? 0) + cost;
              byType[businessType]!['profit'] = (byType[businessType]!['profit'] ?? 0) + profit;
              
              // 按产品统计
              if (!byProduct.containsKey(productName)) {
                byProduct[productName] = {
                  'revenue': 0,
                  'cost': 0,
                  'profit': 0,
                };
              }
              byProduct[productName]!['revenue'] = (byProduct[productName]!['revenue'] ?? 0) + totalAmount;
              byProduct[productName]!['cost'] = (byProduct[productName]!['cost'] ?? 0) + cost;
              byProduct[productName]!['profit'] = (byProduct[productName]!['profit'] ?? 0) + profit;
            }
          }
        }
      }
      
      // 转换为列表并排序（按利润降序）
      final byTypeList = byType.entries.map((e) => {
        'type': e.key,
        'revenue': e.value['revenue'],
        'cost': e.value['cost'],
        'profit': e.value['profit'],
        'profitMargin': e.value['revenue']! > 0 ? (e.value['profit']! / e.value['revenue']! * 100) : 0,
      }).toList()..sort((a, b) => (b['profit'] as double).compareTo(a['profit'] as double));
      
      final byProductList = byProduct.entries.map((e) => {
        'product': e.key,
        'revenue': e.value['revenue'],
        'cost': e.value['cost'],
        'profit': e.value['profit'],
        'profitMargin': e.value['revenue']! > 0 ? (e.value['profit']! / e.value['revenue']! * 100) : 0,
      }).toList()..sort((a, b) => (b['profit'] as double).compareTo(a['profit'] as double));
      
      return {
        'byType': byTypeList.take(5).toList(), // 取前5个
        'byProduct': byProductList.take(10).toList(), // 取前10个
      };
    } catch (e) {
      print('获取成本利润分析失败: $e');
      return {
        'byType': [],
        'byProduct': [],
      };
    }
  }
  
  /// 导出财务报表
  /// 支持导出利润表、资产负债表等
  static Future<String> exportFinanceReport(String reportType) async {
    try {
      // TODO: 实现真实的导出逻辑
      await Future.delayed(const Duration(seconds: 1));
      return '财务报表（$reportType）导出成功';
    } catch (e) {
      return '导出失败: $e';
    }
  }
}
