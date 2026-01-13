import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/salary/salary.dart';
import 'package:erpcrm_client/models/salary/attendance.dart';
import 'package:erpcrm_client/models/salary/leave.dart';
import 'package:erpcrm_client/models/salary/business_trip.dart';
import 'package:erpcrm_client/services/api_service.dart';

class SalaryState {
  final bool isLoading;
  final String? errorMessage;
  final List<Salary> salaries;
  final List<SalaryDetail> salaryDetails;
  final List<Attendance> attendances;
  final List<Leave> leaves;
  final List<BusinessTrip> businessTrips;
  final List<SalaryStatistics> statistics;
  final bool hasFetchedSalaries;
  final bool hasFetchedAttendances;
  final bool hasFetchedLeaves;
  final bool hasFetchedBusinessTrips;

  SalaryState({
    this.isLoading = false,
    this.errorMessage,
    this.salaries = const [],
    this.salaryDetails = const [],
    this.attendances = const [],
    this.leaves = const [],
    this.businessTrips = const [],
    this.statistics = const [],
    this.hasFetchedSalaries = false,
    this.hasFetchedAttendances = false,
    this.hasFetchedLeaves = false,
    this.hasFetchedBusinessTrips = false,
  });

  SalaryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Salary>? salaries,
    List<SalaryDetail>? salaryDetails,
    List<Attendance>? attendances,
    List<Leave>? leaves,
    List<BusinessTrip>? businessTrips,
    List<SalaryStatistics>? statistics,
    bool? hasFetchedSalaries,
    bool? hasFetchedAttendances,
    bool? hasFetchedLeaves,
    bool? hasFetchedBusinessTrips,
  }) {
    return SalaryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      salaries: salaries ?? this.salaries,
      salaryDetails: salaryDetails ?? this.salaryDetails,
      attendances: attendances ?? this.attendances,
      leaves: leaves ?? this.leaves,
      businessTrips: businessTrips ?? this.businessTrips,
      statistics: statistics ?? this.statistics,
      hasFetchedSalaries: hasFetchedSalaries ?? this.hasFetchedSalaries,
      hasFetchedAttendances: hasFetchedAttendances ?? this.hasFetchedAttendances,
      hasFetchedLeaves: hasFetchedLeaves ?? this.hasFetchedLeaves,
      hasFetchedBusinessTrips: hasFetchedBusinessTrips ?? this.hasFetchedBusinessTrips,
    );
  }
}

class SalaryNotifier extends StateNotifier<SalaryState> {
  final ApiService _apiService;

  SalaryNotifier(this._apiService) : super(SalaryState());

  Future<void> loadSalaries({String? month}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getSalaries(month: month);

      if (result is List<dynamic>) {
        final salaries = result
            .map((item) => Salary.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          isLoading: false,
          salaries: salaries,
          hasFetchedSalaries: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadSalaryDetails(int salaryId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getSalaryDetails(salaryId);

      if (result is List<dynamic>) {
        final details = result
            .map((item) => SalaryDetail.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          isLoading: false,
          salaryDetails: details,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadAttendances({String? employeeName, int page = 1, int size = 20}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getAttendances(
        employeeName: employeeName,
        page: page,
        size: size,
      );

      if (result is Map<String, dynamic>) {
        final items = result['items'] as List<dynamic>?;
        if (items != null) {
          final attendances = items
              .map((item) => Attendance.fromJson(item as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            isLoading: false,
            attendances: attendances,
            hasFetchedAttendances: true,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadLeaves({String? employeeName, int page = 1, int size = 20}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getLeaves(
        employeeName: employeeName,
        page: page,
        size: size,
      );

      if (result is Map<String, dynamic>) {
        final items = result['items'] as List<dynamic>?;
        if (items != null) {
          final leaves = items
              .map((item) => Leave.fromJson(item as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            isLoading: false,
            leaves: leaves,
            hasFetchedLeaves: true,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadBusinessTrips({String? employeeName, int page = 1, int size = 20}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getBusinessTrips(
        employeeName: employeeName,
        page: page,
        size: size,
      );

      if (result is Map<String, dynamic>) {
        final items = result['items'] as List<dynamic>?;
        if (items != null) {
          final trips = items
              .map((item) => BusinessTrip.fromJson(item as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            isLoading: false,
            businessTrips: trips,
            hasFetchedBusinessTrips: true,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadStatistics(String month) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _apiService.getSalaryStatistics(month);

      if (result is List<dynamic>) {
        final stats = result
            .map((item) => SalaryStatistics.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          isLoading: false,
          statistics: stats,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> approveSalary(int salaryId) async {
    try {
      await _apiService.approveSalary(salaryId);
      final updatedSalaries = state.salaries.map((s) =>
          s.id == salaryId ? Salary(
            id: s.id,
            employeeName: s.employeeName,
            employeeId: s.employeeId,
            month: s.month,
            baseSalary: s.baseSalary,
            attendanceBonus: s.attendanceBonus,
            performanceBonus: s.performanceBonus,
            overtimePay: s.overtimePay,
            leaveDeduction: s.leaveDeduction,
            socialInsurance: s.socialInsurance,
            tax: s.tax,
            totalSalary: s.totalSalary,
            status: 'approved',
            createdAt: s.createdAt,
            updatedAt: DateTime.now(),
          ) : s).toList();
      state = state.copyWith(salaries: updatedSalaries);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> rejectSalary(int salaryId, String reason) async {
    try {
      await _apiService.rejectSalary(salaryId, reason);
      final updatedSalaries = state.salaries.map((s) =>
          s.id == salaryId ? Salary(
            id: s.id,
            employeeName: s.employeeName,
            employeeId: s.employeeId,
            month: s.month,
            baseSalary: s.baseSalary,
            attendanceBonus: s.attendanceBonus,
            performanceBonus: s.performanceBonus,
            overtimePay: s.overtimePay,
            leaveDeduction: s.leaveDeduction,
            socialInsurance: s.socialInsurance,
            tax: s.tax,
            totalSalary: s.totalSalary,
            status: 'rejected',
            createdAt: s.createdAt,
            updatedAt: DateTime.now(),
          ) : s).toList();
      state = state.copyWith(salaries: updatedSalaries);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final salaryNotifierProvider = StateNotifierProvider<SalaryNotifier, SalaryState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SalaryNotifier(apiService);
});
