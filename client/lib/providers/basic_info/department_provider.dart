import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/department.dart';
import 'package:erpcrm_client/services/api_service.dart';

class DepartmentState {
  final List<Department> departments;
  final bool isLoading;
  final String? error;

  const DepartmentState({
    this.departments = const [],
    this.isLoading = false,
    this.error,
  });

  DepartmentState copyWith({
    List<Department>? departments,
    bool? isLoading,
    String? error,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DepartmentNotifier extends StateNotifier<DepartmentState> {
  final Box departmentBox;
  final ApiService apiService;

  DepartmentNotifier(this.departmentBox, this.apiService) : super(const DepartmentState()) {
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    state = state.copyWith(isLoading: true);
    try {
      // 尝试从API获取数据
      final departmentsData = await apiService.getDepartments();
      final departments = departmentsData.map((data) => Department.fromJson(data as Map<String, dynamic>)).toList();
      
      // 将数据同步到本地Hive
      await departmentBox.put('departments', departments.map((d) => d.toJson()).toList());
      
      state = state.copyWith(
        departments: departments,
        isLoading: false,
      );
    } catch (e) {
      // API调用失败，从本地Hive读取数据
      print('从API获取部门信息失败，尝试从本地读取: $e');
      try {
        final departmentsJson = departmentBox.get('departments', defaultValue: <Map<String, dynamic>>[]);
        final departments = (departmentsJson as List).map((json) => Department.fromJson(json as Map<String, dynamic>)).toList();
        state = state.copyWith(
          departments: departments,
          isLoading: false,
        );
      } catch (hiveError) {
        state = state.copyWith(
          isLoading: false,
          error: '加载部门信息失败: $hiveError',
        );
      }
    }
  }

  Future<void> addDepartment(Department department) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API创建部门
      final createdDepartmentData = await apiService.createDepartment(department.toJson());
      final createdDepartment = Department.fromJson(createdDepartmentData);
      
      // 更新本地Hive数据
      final updatedDepartments = <Department>[...state.departments, createdDepartment];
      await departmentBox.put('departments', updatedDepartments.map((d) => d.toJson()).toList());
      
      state = state.copyWith(
        departments: updatedDepartments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加部门信息失败: $e',
      );
    }
  }

  Future<void> updateDepartment(Department department) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API更新部门
      final updatedDepartmentData = await apiService.updateDepartment(department.id.toString(), department.toJson());
      final updatedDepartment = Department.fromJson(updatedDepartmentData);
      
      // 更新本地Hive数据
      final updatedDepartments = <Department>[];
      for (var d in state.departments) {
        if (d.id == department.id) {
          updatedDepartments.add(updatedDepartment);
        } else {
          updatedDepartments.add(d);
        }
      }
      await departmentBox.put('departments', updatedDepartments.map((d) => d.toJson()).toList());
      
      state = state.copyWith(
        departments: updatedDepartments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新部门信息失败: $e',
      );
    }
  }

  Future<void> deleteDepartment(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      // 调用API删除部门
      await apiService.deleteDepartment(id.toString());
      
      // 更新本地Hive数据
      final updatedDepartments = <Department>[];
      for (var d in state.departments) {
        if (d.id != id) {
          updatedDepartments.add(d);
        }
      }
      await departmentBox.put('departments', updatedDepartments.map((d) => d.toJson()).toList());
      
      state = state.copyWith(
        departments: updatedDepartments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除部门信息失败: $e',
      );
    }
  }
}

final departmentBoxProvider = Provider<Box>((ref) {
  return Hive.box('department_box');
});

final departmentProvider = StateNotifierProvider<DepartmentNotifier, DepartmentState>((ref) {
  final box = ref.watch(departmentBoxProvider);
  final apiService = ref.watch(apiServiceProvider);
  return DepartmentNotifier(box, apiService);
});
