import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/auth/employee.dart';
import '../services/password_service.dart';

class EmployeeNotifier extends StateNotifier<List<Employee>> {
  final Box employeeBox;
  final PasswordService passwordService;

  EmployeeNotifier(this.employeeBox, this.passwordService) : super([]) {
    _loadEmployees();
  }

  void _loadEmployees() {
    final employeesJson = employeeBox.get('employees') as List?;
    if (employeesJson != null) {
      final employees = employeesJson.map((json) {
        final stringDynamicMap = json.cast<String, dynamic>();
        return Employee.fromJson(stringDynamicMap);
      }).toList();
      state = employees;
    } else {
      final hashedPassword = passwordService.hashPassword('123456');
      final adminEmployee = Employee(
        id: 1,
        username: 'admin',
        password: hashedPassword,
        name: '管理员',
        phoneNumber: '13800138000',
        department: '管理部门',
        position: '管理员',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      state = [adminEmployee];
      _saveEmployees([adminEmployee]);
    }
  }

  void _saveEmployees(List<Employee> employees) {
    final employeesJson = employees.map((employee) => employee.toJson()).toList();
    employeeBox.put('employees', employeesJson);
    state = employees;
  }

  void addEmployee(Employee employee) {
    final updatedEmployees = [...state, employee];
    _saveEmployees(updatedEmployees);
  }

  void editEmployee(Employee updatedEmployee) {
    final updatedEmployees = state.map((employee) {
      if (employee.id == updatedEmployee.id) {
        return updatedEmployee;
      }
      return employee;
    }).toList();
    _saveEmployees(updatedEmployees);
  }

  void deleteEmployee(int id) {
    final updatedEmployees = state.where((employee) => employee.id != id).toList();
    _saveEmployees(updatedEmployees);
  }

  Employee? getEmployeeByUsernamePassword(String username, String password) {
    try {
      final employee = state.firstWhere(
        (emp) => emp.username == username,
      );
      if (employee.verifyPassword(password)) {
        return employee;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final employeeProvider = StateNotifierProvider<EmployeeNotifier, List<Employee>>((ref) {
  final employeeBox = Hive.box('employee_box');
  final passwordService = PasswordService();
  return EmployeeNotifier(employeeBox, passwordService);
});
