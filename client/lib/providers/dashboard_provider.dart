import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/services/api_service.dart';

// 仪表盘数据模型
class DashboardData {
  final int totalProducts;
  final int totalOrders;
  final int totalCustomers;
  final int todayOrders;
  // CRM相关字段
  final int? pendingSalesOpportunities;
  final int? newCustomersThisMonth;
  final double? totalRevenueThisMonth;
  final int? pendingFollowups;

  DashboardData({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalCustomers,
    required this.todayOrders,
    // CRM相关字段
    this.pendingSalesOpportunities,
    this.newCustomersThisMonth,
    this.totalRevenueThisMonth,
    this.pendingFollowups,
  });

  // 从JSON创建实例
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalProducts: int.tryParse(json['totalProducts'].toString()) ?? 0,
      totalOrders: int.tryParse(json['totalOrders'].toString()) ?? 0,
      totalCustomers: int.tryParse(json['totalCustomers'].toString()) ?? 0,
      todayOrders: int.tryParse(json['todayOrders'].toString()) ?? 0,
      // CRM相关字段
      pendingSalesOpportunities: int.tryParse(json['pendingSalesOpportunities'].toString()) ?? 0,
      newCustomersThisMonth: int.tryParse(json['newCustomersThisMonth'].toString()) ?? 0,
      totalRevenueThisMonth: double.tryParse(json['totalRevenueThisMonth'].toString()) ?? 0.0,
      pendingFollowups: int.tryParse(json['pendingFollowups'].toString()) ?? 0,
    );
  }

  // 模拟数据
  static DashboardData get mockData {
    return DashboardData(
      totalProducts: 128,
      totalOrders: 456,
      totalCustomers: 789,
      todayOrders: 23,
      // CRM相关模拟数据
      pendingSalesOpportunities: 45,
      newCustomersThisMonth: 67,
      totalRevenueThisMonth: 123456.78,
      pendingFollowups: 28,
    );
  }
}

// 仪表盘状态
class DashboardState {
  final DashboardData? data;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 仪表盘Provider
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  
  try {
    // 尝试从API获取数据
    final response = await apiService.getDashboardData();
    final dashboardData = DashboardData.fromJson(response);
    
    print('使用真实API返回的数据: $dashboardData');
    return dashboardData;
  } catch (e) {
    // 如果API调用失败，使用模拟数据
    print('获取仪表盘数据失败: $e，将使用模拟数据');
    return DashboardData.mockData;
  }
});
