import 'package:riverpod/riverpod.dart';
import '../models/salary/leave.dart';
import '../services/salary_service.dart';
import './attendance_provider.dart';

final leaveProvider = StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  return LeaveNotifier(ref);
});

class LeaveNotifier extends StateNotifier<LeaveState> {
  final Ref ref;
  final SalaryService _salaryService;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  LeaveNotifier(this.ref)
    : _salaryService = ref.read(salaryServiceProvider),
      super(LeaveState.initial()) {
    // 初始化时加载请假列表
    loadLeaveList();
  }

  // 加载请假列表
  Future<void> loadLeaveList({
    String? employeeName,
    String? status,
    String? leaveType,
    String? startDate,
    String? endDate,
    bool isRefresh = false,
  }) async {
    if (_isLoading) return;
    
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    
    try {
      state = state.copyWith(status: LeaveStatus.loading);
      
      final response = await _salaryService.getLeaveList(
        employeeName: employeeName,
        status: status,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: 20,
      );
      
      final List<Leave> leaveList = (response['data']['content'] as List)
          .map((item) => Leave.fromJson(item))
          .toList();
      
      final totalElements = response['data']['totalElements'] as int;
      final totalPages = response['data']['totalPages'] as int;
      
      if (isRefresh) {
        state = state.copyWith(
          leaveList: leaveList,
          totalElements: totalElements,
          totalPages: totalPages,
          status: LeaveStatus.success,
        );
      } else {
        state = state.copyWith(
          leaveList: [...state.leaveList, ...leaveList],
          totalElements: totalElements,
          totalPages: totalPages,
          status: LeaveStatus.success,
        );
      }
      
      _currentPage++;
      _hasMore = _currentPage <= totalPages;
    } catch (e) {
      state = state.copyWith(
        status: LeaveStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  // 刷新请假列表
  Future<void> refreshLeaveList({
    String? employeeName,
    String? status,
    String? leaveType,
    String? startDate,
    String? endDate,
  }) async {
    await loadLeaveList(
      employeeName: employeeName,
      status: status,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      isRefresh: true,
    );
  }

  // 加载更多请假记录
  Future<void> loadMoreLeave({
    String? employeeName,
    String? status,
    String? leaveType,
    String? startDate,
    String? endDate,
  }) async {
    await loadLeaveList(
      employeeName: employeeName,
      status: status,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      isRefresh: false,
    );
  }

  // 创建请假申请
  Future<void> createLeave(Leave leave) async {
    try {
      final newLeave = await _salaryService.createLeave(leave);
      state = state.copyWith(
        leaveList: [newLeave, ...state.leaveList],
      );
    } catch (e) {
      state = state.copyWith(
        status: LeaveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 更新请假申请
  Future<void> updateLeave(int leaveId, Leave leave) async {
    try {
      final updatedLeave = await _salaryService.updateLeave(leaveId, leave);
      state = state.copyWith(
        leaveList: state.leaveList.map((item) {
          if (item.id == leaveId) {
            return updatedLeave;
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: LeaveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 删除请假申请
  Future<void> deleteLeave(int leaveId) async {
    try {
      await _salaryService.deleteLeave(leaveId);
      state = state.copyWith(
        leaveList: state.leaveList
            .where((item) => item.id != leaveId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: LeaveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 撤回请假申请
  Future<void> withdrawLeave(int leaveId) async {
    try {
      await _salaryService.withdrawLeave(leaveId);
      state = state.copyWith(
        leaveList: state.leaveList.map((item) {
          if (item.id == leaveId) {
            return item.copyWith(status: '已撤回');
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: LeaveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 审批请假申请
  Future<void> approveLeave(int leaveId, bool approved, String? comment) async {
    try {
      await _salaryService.approveLeave(leaveId, approved, comment);
      state = state.copyWith(
        leaveList: state.leaveList.map((item) {
          if (item.id == leaveId) {
            return item.copyWith(
              status: approved ? '已通过' : '已拒绝',
              approvalComment: comment,
            );
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: LeaveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// 请假状态枚举
enum LeaveStatus {
  initial,
  loading,
  success,
  error,
}

// 请假状态类
class LeaveState {
  final List<Leave> leaveList;
  final int totalElements;
  final int totalPages;
  final LeaveStatus status;
  final String? errorMessage;

  LeaveState({
    required this.leaveList,
    required this.totalElements,
    required this.totalPages,
    required this.status,
    this.errorMessage,
  });

  // 初始状态
  factory LeaveState.initial() {
    return LeaveState(
      leaveList: [],
      totalElements: 0,
      totalPages: 0,
      status: LeaveStatus.initial,
      errorMessage: null,
    );
  }

  // 复制状态
  LeaveState copyWith({
    List<Leave>? leaveList,
    int? totalElements,
    int? totalPages,
    LeaveStatus? status,
    String? errorMessage,
  }) {
    return LeaveState(
      leaveList: leaveList ?? this.leaveList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
