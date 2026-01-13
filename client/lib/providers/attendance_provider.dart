import 'package:riverpod/riverpod.dart';
import '../models/salary/attendance.dart';
import '../services/salary_service.dart';

final salaryServiceProvider = Provider((ref) => SalaryService());

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref);
});

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref ref;
  final SalaryService _salaryService;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  AttendanceNotifier(this.ref)
    : _salaryService = ref.read(salaryServiceProvider),
      super(AttendanceState.initial()) {
    // 初始化时加载考勤列表
    loadAttendanceList();
  }

  // 加载考勤列表
  Future<void> loadAttendanceList({
    String? employeeName,
    String? status,
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
      state = state.copyWith(status: AttendanceStatus.loading);
      
      final response = await _salaryService.getAttendanceList(
        employeeName: employeeName,
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: 20,
      );
      
      final List<Attendance> attendanceList = (response['data']['content'] as List)
          .map((item) => Attendance.fromJson(item))
          .toList();
      
      final totalElements = response['data']['totalElements'] as int;
      final totalPages = response['data']['totalPages'] as int;
      
      if (isRefresh) {
        state = state.copyWith(
          attendanceList: attendanceList,
          totalElements: totalElements,
          totalPages: totalPages,
          status: AttendanceStatus.success,
        );
      } else {
        state = state.copyWith(
          attendanceList: [...state.attendanceList, ...attendanceList],
          totalElements: totalElements,
          totalPages: totalPages,
          status: AttendanceStatus.success,
        );
      }
      
      _currentPage++;
      _hasMore = _currentPage <= totalPages;
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  // 刷新考勤列表
  Future<void> refreshAttendanceList({
    String? employeeName,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    await loadAttendanceList(
      employeeName: employeeName,
      status: status,
      startDate: startDate,
      endDate: endDate,
      isRefresh: true,
    );
  }

  // 加载更多考勤记录
  Future<void> loadMoreAttendance({
    String? employeeName,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    await loadAttendanceList(
      employeeName: employeeName,
      status: status,
      startDate: startDate,
      endDate: endDate,
      isRefresh: false,
    );
  }

  // 新增考勤记录
  Future<void> createAttendance(Attendance attendance) async {
    try {
      final newAttendance = await _salaryService.createAttendance(attendance);
      state = state.copyWith(
        attendanceList: [newAttendance, ...state.attendanceList],
      );
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 更新考勤记录
  Future<void> updateAttendance(int attendanceId, Attendance attendance) async {
    try {
      final updatedAttendance = await _salaryService.updateAttendance(attendanceId, attendance);
      state = state.copyWith(
        attendanceList: state.attendanceList.map((item) {
          if (item.id == attendanceId) {
            return updatedAttendance;
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 删除考勤记录
  Future<void> deleteAttendance(int attendanceId) async {
    try {
      await _salaryService.deleteAttendance(attendanceId);
      state = state.copyWith(
        attendanceList: state.attendanceList
            .where((item) => item.id != attendanceId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 获取考勤统计
  Future<Map<String, dynamic>> getAttendanceStatistics({
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _salaryService.getAttendanceStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

// 考勤状态枚举
enum AttendanceStatus {
  initial,
  loading,
  success,
  error,
}

// 考勤状态类
class AttendanceState {
  final List<Attendance> attendanceList;
  final int totalElements;
  final int totalPages;
  final AttendanceStatus status;
  final String? errorMessage;

  AttendanceState({
    required this.attendanceList,
    required this.totalElements,
    required this.totalPages,
    required this.status,
    this.errorMessage,
  });

  // 初始状态
  factory AttendanceState.initial() {
    return AttendanceState(
      attendanceList: [],
      totalElements: 0,
      totalPages: 0,
      status: AttendanceStatus.initial,
      errorMessage: null,
    );
  }

  // 复制状态
  AttendanceState copyWith({
    List<Attendance>? attendanceList,
    int? totalElements,
    int? totalPages,
    AttendanceStatus? status,
    String? errorMessage,
  }) {
    return AttendanceState(
      attendanceList: attendanceList ?? this.attendanceList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
