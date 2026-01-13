import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/widgets/salary_menu.dart';
import 'package:erpcrm_client/providers/salary_provider.dart';
import 'package:erpcrm_client/models/salary/salary.dart';
import 'package:erpcrm_client/models/salary/attendance.dart';
import 'package:erpcrm_client/models/salary/leave.dart';
import 'package:erpcrm_client/models/salary/business_trip.dart';

class SalaryScreen extends ConsumerStatefulWidget {
  const SalaryScreen({super.key});

  @override
  ConsumerState<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends ConsumerState<SalaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchKeyword = '';
  String _selectedMonth = DateTime.now().toString().substring(0, 7);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salaryNotifierProvider.notifier).loadSalaries(month: _selectedMonth);
      ref.read(salaryNotifierProvider.notifier).loadAttendances();
      ref.read(salaryNotifierProvider.notifier).loadLeaves();
      ref.read(salaryNotifierProvider.notifier).loadBusinessTrips();
      ref.read(salaryNotifierProvider.notifier).loadStatistics(_selectedMonth);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case '已通过':
      case 'approved':
        return const Color(0xFF4CAF50);
      case '已拒绝':
      case 'rejected':
        return const Color(0xFFF44336);
      case '待审批':
      case 'pending':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _showSalaryDetailDialog(Salary salary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${salary.employeeName} - ${salary.month} 薪资详情'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSalaryItem('基本工资', '¥${salary.baseSalary.toStringAsFixed(2)}'),
                _buildSalaryItem('考勤奖金', '¥${salary.attendanceBonus.toStringAsFixed(2)}'),
                _buildSalaryItem('绩效奖金', '¥${salary.performanceBonus.toStringAsFixed(2)}'),
                _buildSalaryItem('加班费', '¥${salary.overtimePay.toStringAsFixed(2)}'),
                _buildSalaryItem('请假扣款', '-¥${salary.leaveDeduction.toStringAsFixed(2)}', isDeduction: true),
                _buildSalaryItem('社保', '-¥${salary.socialInsurance.toStringAsFixed(2)}', isDeduction: true),
                _buildSalaryItem('个税', '-¥${salary.tax.toStringAsFixed(2)}', isDeduction: true),
                const Divider(),
                _buildSalaryItem('实发工资', '¥${salary.totalSalary.toStringAsFixed(2)}', isTotal: true),
              ],
            ),
          ),
        ),
        actions: [
          if (salary.status == 'pending') ...[
            TextButton(
              onPressed: () async {
                final reasonController = TextEditingController();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('拒绝薪资'),
                    content: TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: '拒绝原因',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('确认拒绝'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && reasonController.text.isNotEmpty) {
                  final success = await ref.read(salaryNotifierProvider.notifier).rejectSalary(salary.id, reasonController.text);
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已拒绝')),
                    );
                  }
                }
              },
              child: const Text('拒绝', style: TextStyle(color: Color(0xFFF44336))),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref.read(salaryNotifierProvider.notifier).approveSalary(salary.id);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已通过')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('通过'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryItem(String label, String value, {bool isDeduction = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black : const Color(0xFF616161),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDeduction ? const Color(0xFFF44336) : (isTotal ? const Color(0xFF1976D2) : const Color(0xFF212121)),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '薪酬管理',
      showBackButton: true,
      topContent: const SalaryMenu(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '薪酬管理',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1976D2),
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1976D2),
                    unselectedLabelColor: const Color(0xFF616161),
                    indicatorColor: const Color(0xFF1976D2),
                    tabs: const [
                      Tab(text: '薪资概览'),
                      Tab(text: '考勤记录'),
                      Tab(text: '请假记录'),
                      Tab(text: '出差记录'),
                    ],
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSalaryOverviewTab(),
                        _buildAttendanceTab(),
                        _buildLeaveTab(),
                        _buildBusinessTripTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryOverviewTab() {
    final state = ref.watch(salaryNotifierProvider);
    final salaries = state.salaries.where((s) =>
      s.employeeName.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 操作栏
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索员工姓名',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedMonth,
                items: List.generate(12, (index) {
                  final date = DateTime.now().subtract(Duration(days: index * 30));
                  final month = date.toString().substring(0, 7);
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                    });
                    ref.read(salaryNotifierProvider.notifier).loadSalaries(month: value);
                    ref.read(salaryNotifierProvider.notifier).loadStatistics(value);
                  }
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // 添加导出功能
                  _exportSalaries(salaries);
                },
                icon: const Icon(Icons.download),
                label: const Text('导出'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 统计卡片
          if (state.statistics.isNotEmpty) ...[
            _buildStatisticsCard(state.statistics.first),
            const SizedBox(height: 16),
          ],
          
          // 薪资分布图表占位
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '薪资分布',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        '薪资分布图表',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 薪资列表
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : salaries.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无薪资数据',
                          style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: salaries.length,
                        itemBuilder: (context, index) {
                          final salary = salaries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                salary.employeeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('月份: ${salary.month}'),
                                  const SizedBox(height: 4),
                                  Text('实发工资: ¥${salary.totalSalary.toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(salary.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      salary.status == 'pending' ? '待审批' : (salary.status == 'approved' ? '已通过' : '已拒绝'),
                                      style: TextStyle(
                                        color: _getStatusColor(salary.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      _showSalaryActions(context, salary);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () => _showSalaryDetailDialog(salary),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(SalaryStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1976D2).withOpacity(0.1), const Color(0xFF42A5F5).withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stats.month} 薪资统计',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('总员工数', '${stats.totalEmployees}', Icons.people),
              ),
              Expanded(
                child: _buildStatItem('总发放', '¥${stats.totalSalaryPaid.toStringAsFixed(0)}', Icons.account_balance_wallet),
              ),
              Expanded(
                child: _buildStatItem('平均工资', '¥${stats.averageSalary.toStringAsFixed(0)}', Icons.trending_up),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('最高工资', '¥${stats.maxSalary.toStringAsFixed(0)}', Icons.arrow_upward, color: const Color(0xFF4CAF50)),
              ),
              Expanded(
                child: _buildStatItem('最低工资', '¥${stats.minSalary.toStringAsFixed(0)}', Icons.arrow_downward, color: const Color(0xFFF44336)),
              ),
              Expanded(
                child: _buildStatItem('待审批', '${stats.pendingCount}', Icons.pending, color: const Color(0xFFFF9800)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color ?? const Color(0xFF1976D2)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF616161),
            ),
          ),
        ],
      ),
    );
  }

  void _exportSalaries(List<Salary> salaries) {
    // 实现导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能开发中')),
    );
  }

  void _showSalaryActions(BuildContext context, Salary salary) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'detail',
          child: Text('查看详情'),
        ),
        if (salary.status == 'pending') ...[
          const PopupMenuItem(
            value: 'approve',
            child: Text('审批通过', style: TextStyle(color: Color(0xFF4CAF50))),
          ),
          const PopupMenuItem(
            value: 'reject',
            child: Text('拒绝审批', style: TextStyle(color: Color(0xFFF44336))),
          ),
        ],
        const PopupMenuItem(
          value: 'print',
          child: Text('打印'),
        ),
      ],
    ).then((value) async {
      if (value == 'detail') {
        _showSalaryDetailDialog(salary);
      } else if (value == 'approve' && salary.status == 'pending') {
        final success = await ref.read(salaryNotifierProvider.notifier).approveSalary(salary.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已通过')),
          );
        }
      } else if (value == 'reject' && salary.status == 'pending') {
        final reasonController = TextEditingController();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('拒绝薪资'),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '拒绝原因',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                ),
                child: const Text('确认拒绝'),
              ),
            ],
          ),
        );

        if (confirmed == true && reasonController.text.isNotEmpty) {
          final success = await ref.read(salaryNotifierProvider.notifier).rejectSalary(salary.id, reasonController.text);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已拒绝')),
            );
          }
        }
      } else if (value == 'print') {
        // 实现打印功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打印功能开发中')),
        );
      }
    });
  }

  void _batchOperateAttendances(List<Attendance> attendances) {
    // 实现批量操作功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('批量操作 ${attendances.length} 条记录')),
    );
  }

  void _editAttendance(Attendance attendance) {
    // 实现编辑考勤记录功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑考勤记录功能开发中')),
    );
  }

  void _deleteAttendance(int attendanceId) {
    // 实现删除考勤记录功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条考勤记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 这里添加实际的删除逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('删除考勤记录功能开发中')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    final state = ref.watch(salaryNotifierProvider);
    final attendances = state.attendances.where((a) =>
      a.employeeName.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索员工姓名',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // 添加批量操作功能
                  _batchOperateAttendances(attendances);
                },
                icon: const Icon(Icons.select_all),
                label: const Text('批量操作'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendances.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无考勤数据',
                          style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: attendances.length,
                        itemBuilder: (context, index) {
                          final attendance = attendances[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          attendance.employeeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(attendance.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          attendance.status,
                                          style: TextStyle(
                                            color: _getStatusColor(attendance.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '日期: ${attendance.date.toString().substring(0, 10)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  if (attendance.checkInTime != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '签到时间: ${attendance.checkInTime}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  if (attendance.checkOutTime != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '签退时间: ${attendance.checkOutTime}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  if (attendance.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '备注: ${attendance.description}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          // 添加编辑考勤记录功能
                                          _editAttendance(attendance);
                                        },
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('编辑', style: TextStyle(color: Color(0xFF1976D2))),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // 添加删除考勤记录功能
                                          if (attendance.id != null) {
                                            _deleteAttendance(attendance.id!);
                                          }
                                        },
                                        icon: const Icon(Icons.delete, size: 16),
                                        label: const Text('删除', style: TextStyle(color: Color(0xFFF44336))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTab() {
    final state = ref.watch(salaryNotifierProvider);
    final leaves = state.leaves.where((l) =>
      l.employeeName.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: '搜索员工姓名',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchKeyword = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : leaves.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无请假数据',
                          style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: leaves.length,
                        itemBuilder: (context, index) {
                          final leave = leaves[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          leave.employeeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(leave.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          leave.status,
                                          style: TextStyle(
                                            color: _getStatusColor(leave.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '请假类型: ${leave.leaveType}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '开始时间: ${leave.startTime.toString().substring(0, 16)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '结束时间: ${leave.endTime.toString().substring(0, 16)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '请假时长: ${leave.getDuration().toStringAsFixed(1)} 小时',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '请假原因: ${leave.reason}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  if (leave.approvalComment != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '审批意见: ${leave.approvalComment}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTripTab() {
    final state = ref.watch(salaryNotifierProvider);
    final trips = state.businessTrips.where((t) =>
      t.employeeName.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: '搜索员工姓名',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchKeyword = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : trips.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无出差数据',
                          style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: trips.length,
                        itemBuilder: (context, index) {
                          final trip = trips[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          trip.employeeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(trip.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          trip.status,
                                          style: TextStyle(
                                            color: _getStatusColor(trip.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '火车站: ${trip.railwayStation}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '地点: ${trip.location}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '开始时间: ${trip.startTime.toString().substring(0, 16)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '结束时间: ${trip.endTime.toString().substring(0, 16)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '出差时长: ${trip.getDurationDays().toStringAsFixed(1)} 天',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '出差目的: ${trip.purpose}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF616161),
                                    ),
                                  ),
                                  if (trip.approvalComment != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '审批意见: ${trip.approvalComment}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF616161),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
