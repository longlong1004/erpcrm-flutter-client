import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/salary_menu.dart';
import 'package:erpcrm_client/models/salary/attendance.dart';
import 'package:erpcrm_client/models/salary/leave.dart';
import 'package:erpcrm_client/models/salary/business_trip.dart';
import 'package:erpcrm_client/models/salary/bonus.dart';
import 'package:erpcrm_client/services/salary_service.dart';

class SalaryListScreen extends ConsumerStatefulWidget {
  const SalaryListScreen({super.key});

  @override
  ConsumerState<SalaryListScreen> createState() => _SalaryListScreenState();
}

class _SalaryListScreenState extends ConsumerState<SalaryListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchKeyword = '';
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '薪酬管理',
      topContent: const SalaryMenu(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth > 768 ? 24.0 : 16.0;
          final isMobile = constraints.maxWidth <= 768;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '考勤管理'),
                    Tab(text: '请假管理'),
                    Tab(text: '出差管理'),
                    Tab(text: '奖金管理'),
                  ],
                  labelColor: const Color(0xFF1E88E5),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1E88E5),
                  indicatorWeight: 2,
                  isScrollable: isMobile,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAttendanceTab(constraints),
                      _buildLeaveTab(constraints),
                      _buildBusinessTripTab(constraints),
                      _buildBonusTab(constraints),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceTab(BoxConstraints constraints) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索考勤记录...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder(
            future: SalaryService().getAttendanceList(
              employeeName: _searchKeyword.isEmpty ? null : _searchKeyword,
              page: _currentPage,
              size: _pageSize,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('加载失败: ${snapshot.error}'),
                );
              }
              final data = snapshot.data ?? {};
              final items = data['items'] as List? ?? [];
              
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final attendance = Attendance.fromJson(items[index] as Map<String, dynamic>);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(attendance.employeeName ?? '未知员工'),
                          subtitle: Text('${attendance.date} ${attendance.checkInTime} - ${attendance.checkOutTime}'),
                          trailing: Chip(
                            label: Text(attendance.status),
                            backgroundColor: _getStatusColor(attendance.status),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildPagination(data),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveTab(BoxConstraints constraints) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索请假记录...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder(
            future: SalaryService().getLeaveList(
              employeeName: _searchKeyword.isEmpty ? null : _searchKeyword,
              page: _currentPage,
              size: _pageSize,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('加载失败: ${snapshot.error}'),
                );
              }
              final data = snapshot.data ?? {};
              final items = data['items'] as List? ?? [];
              
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final leave = Leave.fromJson(items[index] as Map<String, dynamic>);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(leave.employeeName ?? '未知员工'),
                          subtitle: Text('${leave.leaveType} ${leave.startTime.toString().substring(0, 10)} 至 ${leave.endTime.toString().substring(0, 10)}'),
                          trailing: Chip(
                            label: Text(leave.status),
                            backgroundColor: _getStatusColor(leave.status),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildPagination(data),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessTripTab(BoxConstraints constraints) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索出差记录...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder(
            future: SalaryService().getBusinessTripList(
              employeeName: _searchKeyword.isEmpty ? null : _searchKeyword,
              page: _currentPage,
              size: _pageSize,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('加载失败: ${snapshot.error}'),
                );
              }
              final data = snapshot.data ?? {};
              final items = data['items'] as List? ?? [];
              
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final trip = BusinessTrip.fromJson(items[index] as Map<String, dynamic>);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(trip.employeeName ?? '未知员工'),
                          subtitle: Text('${trip.location} ${trip.startTime.toString().substring(0, 10)} 至 ${trip.endTime.toString().substring(0, 10)}'),
                          trailing: Chip(
                            label: Text(trip.status),
                            backgroundColor: _getStatusColor(trip.status),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildPagination(data),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBonusTab(BoxConstraints constraints) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索奖金记录...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder(
            future: SalaryService().getBonusList(
              employeeName: _searchKeyword.isEmpty ? null : _searchKeyword,
              page: _currentPage,
              size: _pageSize,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('加载失败: ${snapshot.error}'),
                );
              }
              final data = snapshot.data ?? {};
              final items = data['items'] as List? ?? [];
              
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final bonus = Bonus.fromJson(items[index] as Map<String, dynamic>);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(bonus.employeeName ?? '未知员工'),
                          subtitle: Text('${bonus.amount}元 ${bonus.purpose}'),
                          trailing: Chip(
                            label: Text(bonus.status),
                            backgroundColor: _getStatusColor(bonus.status),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildPagination(data),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(Map<String, dynamic> data) {
    final total = data['total'] as int? ?? 0;
    final totalPages = (total / _pageSize).ceil();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text('第 $_currentPage / $totalPages 页'),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case '已通过':
      case 'approved':
        return Colors.green[50] ?? Colors.green;
      case '已拒绝':
      case 'rejected':
        return Colors.red[50] ?? Colors.red;
      case '待审批':
      case 'pending':
        return Colors.orange[50] ?? Colors.orange;
      default:
        return Colors.grey[300] ?? Colors.grey;
    }
  }
}