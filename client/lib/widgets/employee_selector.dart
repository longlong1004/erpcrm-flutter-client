import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth/employee.dart';
import '../providers/employee_provider.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';
import '../utils/logger_service.dart';

// 员工选择器组件
enum SelectionMode {
  single,
  multiple,
}

class EmployeeSelector extends ConsumerStatefulWidget {
  final SelectionMode mode;
  final List<Employee> initialSelected;
  final Function(List<Employee>) onSelectionChanged;
  final bool showRefreshButton;
  final Duration refreshInterval;

  const EmployeeSelector({
    super.key,
    this.mode = SelectionMode.single,
    this.initialSelected = const [],
    required this.onSelectionChanged,
    this.showRefreshButton = true,
    this.refreshInterval = const Duration(minutes: 5),
  });

  @override
  ConsumerState<EmployeeSelector> createState() => _EmployeeSelectorState();
}

class _EmployeeSelectorState extends ConsumerState<EmployeeSelector> {
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  List<Employee> _selectedEmployees = [];
  List<String> _departments = [];
  String _selectedDepartment = '全部';
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // 搜索条件
  String _searchName = '';
  String _searchEmployeeId = '';
  String _searchPosition = '';

  // 自动刷新定时器
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _selectedEmployees = List.from(widget.initialSelected);
    _loadEmployees();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  // 设置自动刷新
  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(widget.refreshInterval, (timer) {
      _loadEmployees();
    });
  }

  // 加载员工数据
  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 先从本地Hive获取员工数据
      final localEmployees = ref.read(employeeProvider);
      setState(() {
        _employees = localEmployees;
      });

      // 然后尝试从API获取最新数据
      final apiService = ref.read(apiServiceProvider);
      final remoteEmployeesJson = await apiService.getEmployees();
      final remoteEmployees = remoteEmployeesJson
          .map((json) => Employee.fromJson(json as Map<String, dynamic>))
          .toList();

      // 更新本地存储
      final employeeNotifier = ref.read(employeeProvider.notifier);
      // 这里需要先清空本地数据，然后添加新数据
      // 实际项目中应该实现更智能的合并逻辑
      for (var employee in remoteEmployees) {
        employeeNotifier.editEmployee(employee);
      }

      setState(() {
        _employees = remoteEmployees;
      });
    } on DioException catch (e) {
      // 网络异常，保留本地数据
      setState(() {
        _errorMessage = '网络连接失败，使用本地数据';
      });
      LoggerService.error('Failed to load employees from API: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败：$e';
      });
      LoggerService.error('Failed to load employees: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _extractDepartments();
        _filterEmployees();
      });
    }
  }

  // 提取所有部门
  void _extractDepartments() {
    final departments = _employees.map((e) => e.department).toSet().toList();
    departments.sort();
    setState(() {
      _departments = ['全部', ...departments];
    });
  }

  // 筛选员工
  void _filterEmployees() {
    var filtered = _employees;

    // 按部门筛选
    if (_selectedDepartment != '全部') {
      filtered = filtered.where((e) => e.department == _selectedDepartment).toList();
    }

    // 按姓名搜索
    if (_searchName.isNotEmpty) {
      filtered = filtered.where((e) => e.name.contains(_searchName)).toList();
    }

    // 按工号搜索
    if (_searchEmployeeId.isNotEmpty) {
      filtered = filtered.where((e) => e.id.toString().contains(_searchEmployeeId)).toList();
    }

    // 按职位搜索
    if (_searchPosition.isNotEmpty) {
      filtered = filtered.where((e) => e.position.contains(_searchPosition)).toList();
    }

    setState(() {
      _filteredEmployees = filtered;
    });
  }

  // 切换员工选择状态
  void _toggleEmployeeSelection(Employee employee) {
    setState(() {
      if (widget.mode == SelectionMode.single) {
        _selectedEmployees = [employee];
      } else {
        if (_selectedEmployees.contains(employee)) {
          _selectedEmployees.remove(employee);
        } else {
          _selectedEmployees.add(employee);
        }
      }
      widget.onSelectionChanged(_selectedEmployees);
    });
  }

  // 清除选择
  void _clearSelection() {
    setState(() {
      _selectedEmployees.clear();
      widget.onSelectionChanged(_selectedEmployees);
    });
  }

  // 显示高级搜索对话框
  void _showAdvancedSearchDialog() {
    // 创建控制器并设置初始值
    final nameController = TextEditingController(text: _searchName);
    final employeeIdController = TextEditingController(text: _searchEmployeeId);
    final positionController = TextEditingController(text: _searchPosition);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('高级搜索'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '姓名'),
                  onChanged: (value) => _searchName = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: employeeIdController,
                  decoration: const InputDecoration(labelText: '工号'),
                  onChanged: (value) => _searchEmployeeId = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: '职位'),
                  onChanged: (value) => _searchPosition = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchName = '';
                  _searchEmployeeId = '';
                  _searchPosition = '';
                });
                Navigator.pop(context);
                _filterEmployees();
              },
              child: const Text('重置'),
            ),
            TextButton(
              onPressed: () {
                // 更新搜索值
                _searchName = nameController.text;
                _searchEmployeeId = employeeIdController.text;
                _searchPosition = positionController.text;
                
                Navigator.pop(context);
                _filterEmployees();
              },
              child: const Text('搜索'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 筛选栏
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // 搜索和刷新
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '搜索员工',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchName = value;
                          _filterEmployees();
                        });
                      },
                    ),
                  ),
                  if (widget.showRefreshButton) ...[
                    IconButton(
                      icon: _isRefreshing
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _isRefreshing = true;
                        });
                        _loadEmployees();
                      },
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showAdvancedSearchDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 部门筛选
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _departments.map((department) {
                    final isSelected = _selectedDepartment == department;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(department),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDepartment = department;
                            _filterEmployees();
                          });
                        },
                        selectedColor: const Color(0xFF003366),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // 错误信息
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
            ],
          ),
        ),
        // 员工列表
        SizedBox(
          height: 300,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredEmployees.isEmpty
                  ? const Center(child: Text('没有找到员工'))
                  : ListView.builder(
                      itemCount: _filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        final isSelected = _selectedEmployees.contains(employee);
                        return ListTile(
                          title: Text(employee.name),
                          subtitle: Text('${employee.position} - ${employee.department}'),
                          trailing: Text(employee.id.toString()),
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              _toggleEmployeeSelection(employee);
                            },
                          ),
                          onTap: () {
                            _toggleEmployeeSelection(employee);
                          },
                          tileColor: isSelected
                              ? const Color(0xFFE0F2F1)
                              : null,
                        );
                      },
                    ),
        ),
        // 已选择员工
        if (_selectedEmployees.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已选择 (${_selectedEmployees.length}):',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _clearSelection,
                      child: const Text('清除'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedEmployees.map((employee) {
                    return Chip(
                      label: Text(employee.name),
                      backgroundColor: const Color(0xFF003366),
                      labelStyle: const TextStyle(color: Colors.white),
                      onDeleted: widget.mode == SelectionMode.multiple
                          ? () {
                              setState(() {
                                _selectedEmployees.remove(employee);
                                widget.onSelectionChanged(_selectedEmployees);
                              });
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
