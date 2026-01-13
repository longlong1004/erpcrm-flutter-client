import 'package:riverpod/riverpod.dart';
import '../models/salary/point.dart';
import '../services/salary_service.dart';
import './attendance_provider.dart';

final pointProvider = StateNotifierProvider<PointNotifier, PointState>((ref) {
  return PointNotifier(ref);
});

class PointNotifier extends StateNotifier<PointState> {
  final Ref ref;
  final SalaryService _salaryService;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  PointNotifier(this.ref)
    : _salaryService = ref.read(salaryServiceProvider),
      super(PointState.initial()) {
    // 初始化时加载积分列表
    loadPointList();
  }

  // 加载积分列表
  Future<void> loadPointList({
    String? employeeName,
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
      state = state.copyWith(status: PointStatus.loading);
      
      final response = await _salaryService.getPointList(
        employeeName: employeeName,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: 20,
      );
      
      final List<Point> pointList = (response['data']['content'] as List)
          .map((item) => Point.fromJson(item))
          .toList();
      
      final totalElements = response['data']['totalElements'] as int;
      final totalPages = response['data']['totalPages'] as int;
      
      if (isRefresh) {
        state = state.copyWith(
          pointList: pointList,
          totalElements: totalElements,
          totalPages: totalPages,
          status: PointStatus.success,
        );
      } else {
        state = state.copyWith(
          pointList: [...state.pointList, ...pointList],
          totalElements: totalElements,
          totalPages: totalPages,
          status: PointStatus.success,
        );
      }
      
      _currentPage++;
      _hasMore = _currentPage <= totalPages;
    } catch (e) {
      state = state.copyWith(
        status: PointStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  // 刷新积分列表
  Future<void> refreshPointList({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    await loadPointList(
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      isRefresh: true,
    );
  }

  // 加载更多积分记录
  Future<void> loadMorePoint({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    await loadPointList(
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      isRefresh: false,
    );
  }

  // 创建积分记录
  Future<void> createPoint(Point point) async {
    try {
      final newPoint = await _salaryService.createPoint(point);
      state = state.copyWith(
        pointList: [newPoint, ...state.pointList],
      );
    } catch (e) {
      state = state.copyWith(
        status: PointStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 更新积分记录
  Future<void> updatePoint(int pointId, Point point) async {
    try {
      final updatedPoint = await _salaryService.updatePoint(pointId, point);
      state = state.copyWith(
        pointList: state.pointList.map((item) {
          if (item.id == pointId) {
            return updatedPoint;
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: PointStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 删除积分记录
  Future<void> deletePoint(int pointId) async {
    try {
      await _salaryService.deletePoint(pointId);
      state = state.copyWith(
        pointList: state.pointList
            .where((item) => item.id != pointId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: PointStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 获取积分统计
  Future<Map<String, dynamic>> getPointStatistics({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final statistics = await _salaryService.getPointStatistics(
        employeeName: employeeName,
        startDate: startDate,
        endDate: endDate,
      );
      return statistics;
    } catch (e) {
      state = state.copyWith(
        status: PointStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

// 积分状态枚举
enum PointStatus {
  initial,
  loading,
  success,
  error,
}

// 积分状态类
class PointState {
  final List<Point> pointList;
  final int totalElements;
  final int totalPages;
  final PointStatus status;
  final String? errorMessage;

  PointState({
    required this.pointList,
    required this.totalElements,
    required this.totalPages,
    required this.status,
    this.errorMessage,
  });

  // 初始状态
  factory PointState.initial() {
    return PointState(
      pointList: [],
      totalElements: 0,
      totalPages: 0,
      status: PointStatus.initial,
      errorMessage: null,
    );
  }

  // 复制状态
  PointState copyWith({
    List<Point>? pointList,
    int? totalElements,
    int? totalPages,
    PointStatus? status,
    String? errorMessage,
  }) {
    return PointState(
      pointList: pointList ?? this.pointList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}