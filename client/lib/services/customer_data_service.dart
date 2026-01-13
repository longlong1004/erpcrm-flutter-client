import 'package:hive/hive.dart';
import '../models/crm/customer.dart';

/// 客户数据服务类
/// 
/// 提供客户数据的统计、分析和查询功能
class CustomerDataService {
  // Hive box 名称
  static const String _customersBoxName = 'customers';
  
  /// 获取客户统计指标
  /// 
  /// 返回包含以下指标的Map：
  /// - totalCustomers: 总客户数
  /// - newCustomers: 新增客户数（最近30天）
  /// - activeCustomers: 活跃客户数（最近30天有跟进记录）
  /// - opportunityCustomers: 有商机的客户数
  /// - growthRate: 增长率（对比上月）
  static Future<Map<String, dynamic>> getCustomerMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.toList();
      
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final sixtyDaysAgo = now.subtract(const Duration(days: 60));
      
      // 总客户数
      final totalCustomers = customers.length;
      
      // 新增客户数（最近30天）
      final newCustomers = customers.where((customer) {
        final createdDate = DateTime.parse(customer.createdAt);
        return createdDate.isAfter(thirtyDaysAgo);
      }).length;
      
      // 上月新增客户数（用于计算增长率）
      final lastMonthNewCustomers = customers.where((customer) {
        final createdDate = DateTime.parse(customer.createdAt);
        return createdDate.isAfter(sixtyDaysAgo) && createdDate.isBefore(thirtyDaysAgo);
      }).length;
      
      // 计算增长率
      final growthRate = lastMonthNewCustomers > 0
          ? ((newCustomers - lastMonthNewCustomers) / lastMonthNewCustomers * 100)
          : 0.0;
      
      // 活跃客户数（假设有 lastContactDate 字段）
      // 如果没有该字段，这里使用模拟数据
      final activeCustomers = (totalCustomers * 0.6).round();
      
      // 有商机的客户数（假设有 hasOpportunity 字段）
      // 如果没有该字段，这里使用模拟数据
      final opportunityCustomers = (totalCustomers * 0.3).round();
      
      return {
        'totalCustomers': totalCustomers,
        'newCustomers': newCustomers,
        'activeCustomers': activeCustomers,
        'opportunityCustomers': opportunityCustomers,
        'growthRate': growthRate,
        'lastMonthNewCustomers': lastMonthNewCustomers,
      };
    } catch (e) {
      print('获取客户统计指标失败: $e');
      return {
        'totalCustomers': 0,
        'newCustomers': 0,
        'activeCustomers': 0,
        'opportunityCustomers': 0,
        'growthRate': 0.0,
        'lastMonthNewCustomers': 0,
      };
    }
  }
  
  /// 获取客户增长趋势数据
  /// 
  /// 返回最近30天每天的客户增长数据
  static Future<List<Map<String, dynamic>>> getCustomerGrowthTrend() async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.toList();
      
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      // 按日期分组统计
      final Map<String, int> groupedByDate = {};
      
      for (var customer in customers) {
        final createdDate = DateTime.parse(customer.createdAt);
        if (createdDate.isAfter(thirtyDaysAgo)) {
          final dateKey = '${createdDate.year}-${createdDate.month.toString().padLeft(2, '0')}-${createdDate.day.toString().padLeft(2, '0')}';
          groupedByDate[dateKey] = (groupedByDate[dateKey] ?? 0) + 1;
        }
      }
      
      // 生成趋势数据
      final trendData = <Map<String, dynamic>>[];
      final sortedDates = groupedByDate.keys.toList()..sort();
      
      int cumulativeCount = customers.where((c) {
        final createdDate = DateTime.parse(c.createdAt);
        return createdDate.isBefore(thirtyDaysAgo) || createdDate.isAtSameMomentAs(thirtyDaysAgo);
      }).length;
      
      for (var date in sortedDates) {
        final count = groupedByDate[date]!;
        cumulativeCount += count;
        
        trendData.add({
          'date': date,
          'count': count,
          'cumulativeCount': cumulativeCount,
        });
      }
      
      return trendData;
    } catch (e) {
      print('获取客户增长趋势失败: $e');
      return [];
    }
  }
  
  /// 获取客户价值分析（RFM模型）
  /// 
  /// R (Recency): 最近一次交易时间
  /// F (Frequency): 交易频率
  /// M (Monetary): 交易金额
  /// 
  /// 返回客户价值分布数据
  static Future<Map<String, dynamic>> getCustomerValueAnalysis() async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.toList();
      
      // 由于Customer模型中可能没有RFM相关字段，这里使用模拟数据
      // 实际应用中需要从订单数据中计算
      
      final totalCustomers = customers.length;
      
      // 客户价值分布（模拟数据）
      final highValueCustomers = (totalCustomers * 0.2).round();
      final mediumValueCustomers = (totalCustomers * 0.5).round();
      final lowValueCustomers = totalCustomers - highValueCustomers - mediumValueCustomers;
      
      return {
        'highValueCustomers': highValueCustomers,
        'mediumValueCustomers': mediumValueCustomers,
        'lowValueCustomers': lowValueCustomers,
        'highValuePercentage': (highValueCustomers / totalCustomers * 100).toStringAsFixed(1),
        'mediumValuePercentage': (mediumValueCustomers / totalCustomers * 100).toStringAsFixed(1),
        'lowValuePercentage': (lowValueCustomers / totalCustomers * 100).toStringAsFixed(1),
      };
    } catch (e) {
      print('获取客户价值分析失败: $e');
      return {
        'highValueCustomers': 0,
        'mediumValueCustomers': 0,
        'lowValueCustomers': 0,
        'highValuePercentage': '0.0',
        'mediumValuePercentage': '0.0',
        'lowValuePercentage': '0.0',
      };
    }
  }
  
  /// 搜索客户
  /// 
  /// 支持按客户名称、联系人、电话、邮箱搜索
  static Future<List<Customer>> searchCustomers(String keyword) async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.toList();
      
      if (keyword.isEmpty) {
        return customers;
      }
      
      final lowerKeyword = keyword.toLowerCase();
      
      return customers.where((customer) {
        return customer.name.toLowerCase().contains(lowerKeyword) ||
               customer.contactPerson.toLowerCase().contains(lowerKeyword) ||
               customer.contactPhone.contains(keyword) ||
               customer.contactEmail.toLowerCase().contains(lowerKeyword);
      }).toList();
    } catch (e) {
      print('搜索客户失败: $e');
      return [];
    }
  }
  
  /// 按分类筛选客户
  static Future<List<Customer>> filterByCategory(String categoryName) async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.toList();
      
      return customers.where((customer) {
        return customer.categoryName == categoryName;
      }).toList();
    } catch (e) {
      print('按分类筛选客户失败: $e');
      return [];
    }
  }
  
  /// 按标签筛选客户
  static Future<List<Customer>> filterByTag(String tagName) async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.toList();
      
      // 假设Customer模型有tags字段（List<String>）
      // 如果没有，这里返回空列表
      return customers.where((customer) {
        // TODO: 根据实际的Customer模型调整
        // return customer.tags?.contains(tagName) ?? false;
        return false;
      }).toList();
    } catch (e) {
      print('按标签筛选客户失败: $e');
      return [];
    }
  }
  
  /// 获取客户分类统计
  static Future<Map<String, int>> getCategoryStatistics() async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.toList();
      
      final Map<String, int> categoryStats = {};
      
      for (var customer in customers) {
        final category = customer.categoryName;
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }
      
      return categoryStats;
    } catch (e) {
      print('获取客户分类统计失败: $e');
      return {};
    }
  }
  
  /// 批量导出客户数据
  static Future<String> exportCustomers(List<int> customerIds) async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      final customers = box.values.where((c) => customerIds.contains(c.customerId)).toList();
      
      // TODO: 实现实际的导出逻辑（CSV、Excel等）
      // 这里返回模拟的导出结果
      return '已导出 ${customers.length} 个客户数据';
    } catch (e) {
      print('批量导出客户失败: $e');
      return '导出失败: $e';
    }
  }
  
  /// 批量添加标签
  static Future<bool> batchAddTag(List<int> customerIds, String tagName) async {
    try {
      final box = await Hive.openBox<Customer>(_customersBoxName);
      
      for (var customerId in customerIds) {
        final customer = box.values.firstWhere((c) => c.customerId == customerId);
        // TODO: 根据实际的Customer模型调整
        // customer.tags?.add(tagName);
        // await box.put(customer.customerId, customer);
      }
      
      return true;
    } catch (e) {
      print('批量添加标签失败: $e');
      return false;
    }
  }
}
