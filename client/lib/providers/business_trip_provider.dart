import 'package:riverpod/riverpod.dart';
import '../models/salary/business_trip.dart';
import '../services/salary_service.dart';

final salaryServiceProvider = Provider((ref) => SalaryService());

final businessTripProvider = StateNotifierProvider<BusinessTripNotifier, BusinessTripState>((ref) {
  return BusinessTripNotifier(ref);
});

enum BusinessTripStatus {
  initial,
  loading,
  success,
  error,
}

class BusinessTripState {
  final List<BusinessTrip> businessTripList;
  final int totalElements;
  final int totalPages;
  final BusinessTripStatus status;
  final String? errorMessage;

  BusinessTripState({
    required this.businessTripList,
    required this.totalElements,
    required this.totalPages,
    required this.status,
    this.errorMessage,
  });

  factory BusinessTripState.initial() {
    return BusinessTripState(
      businessTripList: [],
      totalElements: 0,
      totalPages: 0,
      status: BusinessTripStatus.initial,
      errorMessage: null,
    );
  }

  BusinessTripState copyWith({
    List<BusinessTrip>? businessTripList,
    int? totalElements,
    int? totalPages,
    BusinessTripStatus? status,
    String? errorMessage,
  }) {
    return BusinessTripState(
      businessTripList: businessTripList ?? this.businessTripList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BusinessTripNotifier extends StateNotifier<BusinessTripState> {
  final Ref ref;
  final SalaryService _salaryService;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  BusinessTripNotifier(this.ref)
      : _salaryService = ref.read(salaryServiceProvider),
        super(BusinessTripState.initial()) {
    loadBusinessTripList();
  }

  Future<void> loadBusinessTripList({
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
      state = state.copyWith(status: BusinessTripStatus.loading);
      
      final response = await _salaryService.getBusinessTripList(
        employeeName: employeeName,
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: 20,
      );
      
      final List<BusinessTrip> tripList = (response['data']['content'] as List)
          .map((item) => BusinessTrip.fromJson(item))
          .toList();
      
      final totalElements = response['data']['totalElements'] as int;
      final totalPages = response['data']['totalPages'] as int;
      
      if (isRefresh) {
        state = state.copyWith(
          businessTripList: tripList,
          totalElements: totalElements,
          totalPages: totalPages,
          status: BusinessTripStatus.success,
        );
      } else {
        state = state.copyWith(
          businessTripList: [...state.businessTripList, ...tripList],
          totalElements: totalElements,
          totalPages: totalPages,
          status: BusinessTripStatus.success,
        );
      }
      
      _currentPage++;
      _hasMore = _currentPage <= totalPages;
    } catch (e) {
      state = state.copyWith(
        status: BusinessTripStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshBusinessTripList({
    String? employeeName,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    await loadBusinessTripList(
      employeeName: employeeName,
      status: status,
      startDate: startDate,
      endDate: endDate,
      isRefresh: true,
    );
  }

  Future<void> loadMoreBusinessTrip({
    String? employeeName,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    await loadBusinessTripList(
      employeeName: employeeName,
      status: status,
      startDate: startDate,
      endDate: endDate,
      isRefresh: false,
    );
  }

  Future<void> createBusinessTrip(BusinessTrip trip) async {
    try {
      final newTrip = await _salaryService.createBusinessTrip(trip);
      state = state.copyWith(
        businessTripList: [newTrip, ...state.businessTripList],
      );
    } catch (e) {
      state = state.copyWith(
        status: BusinessTripStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteBusinessTrip(int tripId) async {
    try {
      await _salaryService.deleteBusinessTrip(tripId);
      state = state.copyWith(
        businessTripList: state.businessTripList
            .where((item) => item.id != tripId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: BusinessTripStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> withdrawBusinessTrip(int tripId) async {
    try {
      await _salaryService.withdrawBusinessTrip(tripId);
      state = state.copyWith(
        businessTripList: state.businessTripList.map((item) {
          if (item.id == tripId) {
            return item.copyWith(status: '已撤回');
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: BusinessTripStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}