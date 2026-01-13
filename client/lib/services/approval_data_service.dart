import 'package:hive_flutter/hive_flutter.dart';

/// 审批数据服务类
class ApprovalDataService {
  static const String _approvalsBox = 'approvals';
  
  /// 获取审批统计指标
  static Future<Map<String, dynamic>> getApprovalMetrics() async {
    try {
      final approvalsBox = await Hive.openBox(_approvalsBox);
      final approvals = approvalsBox.values.toList();
      
      int pendingCount = approvals.where((a) => a['status'] == 'pending').length;
      int approvedCount = approvals.where((a) => a['status'] == 'approved').length;
      int rejectedCount = approvals.where((a) => a['status'] == 'rejected').length;
      int totalCount = approvals.length;
      
      return {
        'pendingCount': pendingCount,
        'approvedCount': approvedCount,
        'rejectedCount': rejectedCount,
        'totalCount': totalCount,
      };
    } catch (e) {
      return {
        'pendingCount': 0,
        'approvedCount': 0,
        'rejectedCount': 0,
        'totalCount': 0,
      };
    }
  }
}
