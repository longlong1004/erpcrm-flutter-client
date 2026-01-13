import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/business/business.dart';

/// 业务管理数据服务 v1.0.0
/// 
/// 功能：
/// - 从Hive读取业务数据（线索、商机、批量采购等）
/// - 计算业务统计指标
/// - 提供数据查询和筛选
class BusinessDataService {
  // Hive Box 名称
  static const String businessBoxName = 'businesses';
  static const String leadsBoxName = 'leads';
  static const String opportunitiesBoxName = 'opportunities';

  /// 获取业务统计数据
  Future<Map<String, dynamic>> getBusinessStats() async {
    try {
      // 尝试打开业务相关的Box
      Box? businessBox;
      Box? leadsBox;
      Box? opportunitiesBox;

      try {
        businessBox = await Hive.openBox(businessBoxName);
      } catch (e) {
        print('无法打开业务Box: $e');
      }

      try {
        leadsBox = await Hive.openBox(leadsBoxName);
      } catch (e) {
        print('无法打开线索Box: $e');
      }

      try {
        opportunitiesBox = await Hive.openBox(opportunitiesBoxName);
      } catch (e) {
        print('无法打开商机Box: $e');
      }

      // 统计数据
      int totalLeads = leadsBox?.length ?? 0;
      int totalOpportunities = opportunitiesBox?.length ?? 0;
      int totalBusiness = businessBox?.length ?? 0;

      // 计算本月新增（模拟数据）
      int newLeadsThisMonth = (totalLeads * 0.2).round();
      int newOpportunitiesThisMonth = (totalOpportunities * 0.15).round();

      // 计算转化率
      double conversionRate = totalLeads > 0 
          ? (totalOpportunities / totalLeads * 100) 
          : 0.0;

      // 计算商机金额（模拟数据）
      double totalOpportunityValue = totalOpportunities * 50000.0;

      return {
        'totalLeads': totalLeads,
        'totalOpportunities': totalOpportunities,
        'totalBusiness': totalBusiness,
        'newLeadsThisMonth': newLeadsThisMonth,
        'newOpportunitiesThisMonth': newOpportunitiesThisMonth,
        'conversionRate': conversionRate,
        'totalOpportunityValue': totalOpportunityValue,
        'activeLeads': (totalLeads * 0.6).round(),
        'wonOpportunities': (totalOpportunities * 0.3).round(),
        'lostOpportunities': (totalOpportunities * 0.1).round(),
      };
    } catch (e) {
      print('获取业务统计数据失败: $e');
      return {
        'totalLeads': 0,
        'totalOpportunities': 0,
        'totalBusiness': 0,
        'newLeadsThisMonth': 0,
        'newOpportunitiesThisMonth': 0,
        'conversionRate': 0.0,
        'totalOpportunityValue': 0.0,
        'activeLeads': 0,
        'wonOpportunities': 0,
        'lostOpportunities': 0,
      };
    }
  }

  /// 获取线索趋势数据（最近30天）
  Future<List<Map<String, dynamic>>> getLeadsTrend({int days = 30}) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> trendData = [];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // 模拟数据：每天新增线索数量
      final count = (5 + (i % 7) * 2).toDouble();
      
      trendData.add({
        'date': date,
        'count': count,
      });
    }

    return trendData;
  }

  /// 获取商机趋势数据（最近30天）
  Future<List<Map<String, dynamic>>> getOpportunitiesTrend({int days = 30}) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> trendData = [];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // 模拟数据：每天新增商机数量
      final count = (2 + (i % 5) * 1.5).toDouble();
      
      trendData.add({
        'date': date,
        'count': count,
      });
    }

    return trendData;
  }

  /// 获取业务类型分布
  Future<Map<String, int>> getBusinessTypeDistribution() async {
    return {
      '批量采购': 45,
      '招标': 28,
      '竞价': 32,
      '先发货': 18,
      '先报计划': 15,
    };
  }

  /// 获取线索来源分布
  Future<Map<String, int>> getLeadsSourceDistribution() async {
    return {
      '网站': 35,
      '电话': 28,
      '邮件': 22,
      '推荐': 18,
      '其他': 12,
    };
  }

  /// 获取商机阶段分布
  Future<Map<String, int>> getOpportunityStageDistribution() async {
    return {
      '初步接触': 25,
      '需求确认': 20,
      '方案报价': 18,
      '商务谈判': 15,
      '合同签订': 10,
    };
  }

  /// 关闭所有Box
  Future<void> closeBoxes() async {
    try {
      if (Hive.isBoxOpen(businessBoxName)) {
        await Hive.box(businessBoxName).close();
      }
      if (Hive.isBoxOpen(leadsBoxName)) {
        await Hive.box(leadsBoxName).close();
      }
      if (Hive.isBoxOpen(opportunitiesBoxName)) {
        await Hive.box(opportunitiesBoxName).close();
      }
    } catch (e) {
      print('关闭Box失败: $e');
    }
  }
}
