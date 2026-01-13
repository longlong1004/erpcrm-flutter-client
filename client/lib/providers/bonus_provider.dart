import 'package:riverpod/riverpod.dart';
import '../models/salary/bonus.dart';
import '../services/salary_service.dart';
import './attendance_provider.dart';

final bonusProvider = StateNotifierProvider<BonusNotifier, BonusState>((ref) {
  return BonusNotifier(ref);
});

class BonusNotifier extends StateNotifier<BonusState> {
  final Ref ref;
  final SalaryService _salaryService;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  BonusNotifier(this.ref)
    : _salaryService = ref.read(salaryServiceProvider),
      super(BonusState.initial()) {
    // 初始化时加载奖金列表
    loadBonusList();
  }

  // 加载奖金列表
  Future<void> loadBonusList({
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
      state = state.copyWith(status: BonusStatus.loading);
      
      final response = await _salaryService.getBonusList(
        employeeName: employeeName,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: 20,
      );
      
      final List<Bonus> bonusList = (response['data']['content'] as List)
          .map((item) => Bonus.fromJson(item))
          .toList();
      
      final totalElements = response['data']['totalElements'] as int;
      final totalPages = response['data']['totalPages'] as int;
      
      if (isRefresh) {
        state = state.copyWith(
          bonusList: bonusList,
          totalElements: totalElements,
          totalPages: totalPages,
          status: BonusStatus.success,
        );
      } else {
        state = state.copyWith(
          bonusList: [...state.bonusList, ...bonusList],
          totalElements: totalElements,
          totalPages: totalPages,
          status: BonusStatus.success,
        );
      }
      
      _currentPage++;
      _hasMore = _currentPage <= totalPages;
    } catch (e) {
      state = state.copyWith(
        status: BonusStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  // 刷新奖金列表
  Future<void> refreshBonusList({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    await loadBonusList(
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      isRefresh: true,
    );
  }

  // 加载更多奖金记录
  Future<void> loadMoreBonus({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    await loadBonusList(
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      isRefresh: false,
    );
  }

  // 创建奖金记录
  Future<void> createBonus(Bonus bonus) async {
    try {
      final newBonus = await _salaryService.createBonus(bonus);
      state = state.copyWith(
        bonusList: [newBonus, ...state.bonusList],
      );
    } catch (e) {
      state = state.copyWith(
        status: BonusStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 更新奖金记录
  Future<void> updateBonus(int bonusId, Bonus bonus) async {
    try {
      final updatedBonus = await _salaryService.updateBonus(bonusId, bonus);
      state = state.copyWith(
        bonusList: state.bonusList.map((item) {
          if (item.id == bonusId) {
            return updatedBonus;
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: BonusStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 删除奖金记录
  Future<void> deleteBonus(int bonusId) async {
    try {
      await _salaryService.deleteBonus(bonusId);
      state = state.copyWith(
        bonusList: state.bonusList
            .where((item) => item.id != bonusId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: BonusStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 获取奖金统计
  Future<Map<String, dynamic>> getBonusStatistics({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final statistics = await _salaryService.getBonusStatistics(
        employeeName: employeeName,
        startDate: startDate,
        endDate: endDate,
      );
      return statistics;
    } catch (e) {
      state = state.copyWith(
        status: BonusStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

// 奖金状态枚举
enum BonusStatus {
  initial,
  loading,
  success,
  error,
}

// 奖金状态类
class BonusState {
  final List<Bonus> bonusList;
  final int totalElements;
  final int totalPages;
  final BonusStatus status;
  final String? errorMessage;

  BonusState({
    required this.bonusList,
    required this.totalElements,
    required this.totalPages,
    required this.status,
    this.errorMessage,
  });

  // 初始状态
  factory BonusState.initial() {
    return BonusState(
      bonusList: [],
      totalElements: 0,
      totalPages: 0,
      status: BonusStatus.initial,
      errorMessage: null,
    );
  }

  // 复制状态
  BonusState copyWith({
    List<Bonus>? bonusList,
    int? totalElements,
    int? totalPages,
    BonusStatus? status,
    String? errorMessage,
  }) {
    return BonusState(
      bonusList: bonusList ?? this.bonusList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}