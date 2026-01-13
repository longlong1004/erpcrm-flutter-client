import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/services/api_service.dart';
import 'package:erpcrm_client/services/local_storage_service.dart';
import 'package:erpcrm_client/services/sync_service.dart';
import 'package:erpcrm_client/models/sync/sync_operation.dart';
import 'package:erpcrm_client/models/approval/approval.dart';

class ApprovalNotifier extends StateNotifier<List<Approval>> {
  final Ref ref;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;

  ApprovalNotifier(this.ref, this._localStorageService, this._syncService)
      : super([]);

  // 加载审批列表
  Future<void> loadApprovals({String? status, String? type}) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      List<dynamic> approvals;

      if (status != null) {
        approvals = await apiService.getApprovalsByStatus(status);
      } else if (type != null) {
        approvals = await apiService.getApprovalsByType(type);
      } else {
        approvals = await apiService.getApprovals();
      }

      // 转换为Approval对象列表
      final approvalList = approvals.map((item) => Approval.fromJson(item as Map<String, dynamic>)).toList();
      state = approvalList;

      // 保存到本地存储
      await _localStorageService.saveApprovals(approvalList);
    } catch (e) {
      // 如果API请求失败，尝试从本地存储加载
      final localApprovals = await _localStorageService.getApprovals();
      state = localApprovals;
      rethrow;
    }
  }

  // 加载待审批列表
  Future<void> loadPendingApprovals() async {
    await loadApprovals(status: 'pending');
  }

  // 加载已审批列表
  Future<void> loadApprovedApprovals() async {
    await loadApprovals(status: 'approved');
  }

  // 加载已拒绝列表
  Future<void> loadRejectedApprovals() async {
    await loadApprovals(status: 'rejected');
  }

  // 加载我的申请
  Future<void> loadMyApplications(String userId) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final approvals = await apiService.getApprovalsByApplicant(userId);
      final approvalList = approvals.map((item) => Approval.fromJson(item as Map<String, dynamic>)).toList();
      state = approvalList;
      await _localStorageService.saveApprovals(approvalList);
    } catch (e) {
      final localApprovals = await _localStorageService.getApprovals();
      state = localApprovals.where((approval) => approval.requesterId.toString() == userId).toList();
      rethrow;
    }
  }

  // 加载我的审批
  Future<void> loadMyApprovals(String userId) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final approvals = await apiService.getApprovalsByApprover(userId);
      final approvalList = approvals.map((item) => Approval.fromJson(item as Map<String, dynamic>)).toList();
      state = approvalList;
      await _localStorageService.saveApprovals(approvalList);
    } catch (e) {
      final localApprovals = await _localStorageService.getApprovals();
      state = localApprovals.where((approval) => approval.approverId.toString() == userId).toList();
      rethrow;
    }
  }

  // 获取单个审批详情
  Future<Approval?> getApprovalById(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final approvalMap = await apiService.getApprovalById(id);
      if (approvalMap != null) {
        return Approval.fromJson(approvalMap);
      }
      return null;
    } catch (e) {
      // 如果API请求失败，尝试从本地存储加载
      final localApprovals = await _localStorageService.getApprovals();
      final int? parsedId = int.tryParse(id);
      final foundApproval = localApprovals.where((approval) => approval.approvalId == parsedId).toList();
      return foundApproval.isNotEmpty ? foundApproval.first : null;
    }
  }

  // 创建审批
  Future<Approval> createApproval(Map<String, dynamic> approvalData) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final createdApprovalMap = await apiService.createApproval(approvalData);
      final createdApproval = Approval.fromJson(createdApprovalMap);
      
      // 更新状态
      state = [...state, createdApproval];
      
      // 保存到本地存储
      await _localStorageService.saveApprovals(state);
      
      return createdApproval;
    } catch (e) {
      // 如果API请求失败，保存到本地并标记为待同步
      final tempId = DateTime.now().millisecondsSinceEpoch;
      final approvalWithSyncStatus = Approval(
        approvalId: tempId,
        title: approvalData['title'] ?? '',
        content: approvalData['content'] ?? '',
        requesterId: approvalData['requesterId'] ?? 0,
        requesterName: approvalData['requesterName'] ?? '',
        approverId: approvalData['approverId'] ?? 0,
        approverName: approvalData['approverName'] ?? '',
        status: approvalData['status'] ?? 'pending',
        type: approvalData['type'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedData: approvalData['relatedData'],
        comment: approvalData['comment'],
        isSynced: false,
      );
      
      state = [...state, approvalWithSyncStatus];
      await _localStorageService.saveApprovals(state);
      final syncOperation = SyncOperation(
        id: DateTime.now().millisecondsSinceEpoch,
        dataType: 'approval',
        operationType: SyncOperationType.create,
        data: approvalWithSyncStatus.toJson(),
        timestamp: DateTime.now(),
        tempId: tempId,
      );
      await _syncService.addSyncOperation(syncOperation);
      
      rethrow;
    }
  }

  // 审批通过
  Future<Approval> approveApproval(String id, Map<String, dynamic> approveData) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final approvedApprovalMap = await apiService.approveApproval(id, approveData);
      final approvedApproval = Approval.fromJson(approvedApprovalMap);
      
      // 更新状态
      state = state.map((approval) {
        if (approval.approvalId.toString() == id) {
          return approvedApproval;
        }
        return approval;
      }).toList();
      
      // 保存到本地存储
      await _localStorageService.saveApprovals(state);
      
      return approvedApproval;
    } catch (e) {
      // 如果API请求失败，更新本地状态并标记为待同步
      final updatedApproval = state.firstWhere((approval) => approval.approvalId.toString() == id);
      final approvalWithSyncStatus = Approval(
        approvalId: updatedApproval.approvalId,
        title: updatedApproval.title,
        content: updatedApproval.content,
        requesterId: updatedApproval.requesterId,
        requesterName: updatedApproval.requesterName,
        approverId: approveData['approverId'] ?? updatedApproval.approverId,
        approverName: updatedApproval.approverName,
        status: 'approved',
        type: updatedApproval.type,
        createdAt: updatedApproval.createdAt,
        updatedAt: DateTime.now(),
        relatedData: updatedApproval.relatedData,
        comment: updatedApproval.comment,
        isSynced: false,
      );
      
      List<Approval> updatedApprovals = [];
      for (var approval in state) {
        if (approval.approvalId.toString() == id) {
          updatedApprovals.add(approvalWithSyncStatus);
        } else {
          updatedApprovals.add(approval);
        }
      }
      state = updatedApprovals;
      
      await _localStorageService.saveApprovals(state);
      final syncOperation = SyncOperation(
        id: DateTime.now().millisecondsSinceEpoch,
        dataType: 'approval',
        operationType: SyncOperationType.update,
        data: approvalWithSyncStatus.toJson(),
        timestamp: DateTime.now(),
        tempId: approvalWithSyncStatus.approvalId,
      );
      await _syncService.addSyncOperation(syncOperation);
      
      rethrow;
    }
  }

  // 审批拒绝
  Future<Approval> rejectApproval(String id, Map<String, dynamic> rejectData) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final rejectedApprovalMap = await apiService.rejectApproval(id, rejectData);
      final rejectedApproval = Approval.fromJson(rejectedApprovalMap);
      
      // 更新状态
      List<Approval> updatedApprovals = [];
      for (var approval in state) {
        if (approval.approvalId.toString() == id) {
          updatedApprovals.add(rejectedApproval);
        } else {
          updatedApprovals.add(approval);
        }
      }
      state = updatedApprovals;
      
      // 保存到本地存储
      await _localStorageService.saveApprovals(state);
      
      return rejectedApproval;
    } catch (e) {
      // 如果API请求失败，更新本地状态并标记为待同步
      final updatedApproval = state.firstWhere((approval) => approval.approvalId.toString() == id);
      final approvalWithSyncStatus = Approval(
        approvalId: updatedApproval.approvalId,
        title: updatedApproval.title,
        content: updatedApproval.content,
        requesterId: updatedApproval.requesterId,
        requesterName: updatedApproval.requesterName,
        approverId: rejectData['approverId'] ?? updatedApproval.approverId,
        approverName: updatedApproval.approverName,
        status: 'rejected',
        type: updatedApproval.type,
        createdAt: updatedApproval.createdAt,
        updatedAt: DateTime.now(),
        relatedData: updatedApproval.relatedData,
        comment: updatedApproval.comment,
        isSynced: false,
      );
      
      List<Approval> updatedApprovals = [];
      for (var approval in state) {
        if (approval.approvalId.toString() == id) {
          updatedApprovals.add(approvalWithSyncStatus);
        } else {
          updatedApprovals.add(approval);
        }
      }
      state = updatedApprovals;
      
      await _localStorageService.saveApprovals(state);
      final syncOperation = SyncOperation(
        id: DateTime.now().millisecondsSinceEpoch,
        dataType: 'approval',
        operationType: SyncOperationType.update,
        data: approvalWithSyncStatus.toJson(),
        timestamp: DateTime.now(),
        tempId: approvalWithSyncStatus.approvalId,
      );
      await _syncService.addSyncOperation(syncOperation);
      
      rethrow;
    }
  }
}

// 创建Provider
final approvalProvider = StateNotifierProvider<ApprovalNotifier, List<Approval>>((ref) {
  final localStorageService = ref.read(localStorageServiceProvider);
  final syncService = ref.read(syncServiceProvider);
  return ApprovalNotifier(ref, localStorageService, syncService);
});

// 审批详情Provider
final approvalDetailProvider = FutureProvider.family<Approval?, String>((ref, id) async {
  final approvalNotifier = ref.read(approvalProvider.notifier);
  return await approvalNotifier.getApprovalById(id);
});
