import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class Approval {
  final String id;
  final String title;
  final String type;
  final String applicant;
  final String status;
  final DateTime createTime;
  final DateTime? approvalTime;

  Approval({
    required this.id,
    required this.title,
    required this.type,
    required this.applicant,
    required this.status,
    required this.createTime,
    this.approvalTime,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      applicant: json['applicant'] as String,
      status: json['status'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      approvalTime: json['approvalTime'] != null 
          ? DateTime.parse(json['approvalTime'] as String) 
          : null,
    );
  }
}

class ApprovalListScreen extends ConsumerStatefulWidget {
  const ApprovalListScreen({super.key});

  @override
  ConsumerState<ApprovalListScreen> createState() => _ApprovalListScreenState();
}

class _ApprovalListScreenState extends ConsumerState<ApprovalListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchKeyword = '';
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '审批管理',
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
                    Tab(text: '待审批'),
                    Tab(text: '已通过'),
                    Tab(text: '已拒绝'),
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
                      _buildPendingTab(constraints),
                      _buildApprovedTab(constraints),
                      _buildRejectedTab(constraints),
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

  Widget _buildPendingTab(BoxConstraints constraints) {
    final approvals = _getMockApprovals().where((a) => a.status == '待审批').toList();
    final filteredApprovals = approvals.where((a) =>
      a.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      a.applicant.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();
    final isMobile = constraints.maxWidth <= 768;

    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索待审批...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredApprovals.length,
            itemBuilder: (context, index) {
              final approval = filteredApprovals[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(approval.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('类型: ${approval.type}'),
                      Text('申请人: ${approval.applicant}'),
                      Text('创建时间: ${approval.createTime.toString().substring(0, 19)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(approval.status),
                        backgroundColor: Colors.orange[50],
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showApprovalDialog(approval);
                        },
                        icon: const Icon(Icons.approval),
                        label: const Text('审批'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8.0 : 16.0,
                            vertical: isMobile ? 4.0 : 8.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedTab(BoxConstraints constraints) {
    final approvals = _getMockApprovals().where((a) => a.status == '已通过').toList();
    final filteredApprovals = approvals.where((a) =>
      a.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      a.applicant.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();
    final isMobile = constraints.maxWidth <= 768;

    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索已通过...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredApprovals.length,
            itemBuilder: (context, index) {
              final approval = filteredApprovals[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(approval.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('类型: ${approval.type}'),
                      Text('申请人: ${approval.applicant}'),
                      Text('审批时间: ${approval.approvalTime?.toString().substring(0, 19) ?? ''}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(approval.status),
                    backgroundColor: Colors.green[50],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedTab(BoxConstraints constraints) {
    final approvals = _getMockApprovals().where((a) => a.status == '已拒绝').toList();
    final filteredApprovals = approvals.where((a) =>
      a.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      a.applicant.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();
    final isMobile = constraints.maxWidth <= 768;

    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          decoration: InputDecoration(
            hintText: '搜索已拒绝...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredApprovals.length,
            itemBuilder: (context, index) {
              final approval = filteredApprovals[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(approval.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('类型: ${approval.type}'),
                      Text('申请人: ${approval.applicant}'),
                      Text('拒绝时间: ${approval.approvalTime?.toString().substring(0, 19) ?? ''}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(approval.status),
                    backgroundColor: Colors.red[50],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showApprovalDialog(Approval approval) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('审批'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('标题: ${approval.title}'),
            const SizedBox(height: 8),
            Text('类型: ${approval.type}'),
            const SizedBox(height: 8),
            Text('申请人: ${approval.applicant}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('审批通过')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('通过'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已拒绝')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('拒绝'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Approval> _getMockApprovals() {
    return [
      Approval(
        id: '1',
        title: '采购申请-办公用品',
        type: '采购',
        applicant: '张三',
        status: '待审批',
        createTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Approval(
        id: '2',
        title: '采购申请-设备',
        type: '采购',
        applicant: '李四',
        status: '待审批',
        createTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Approval(
        id: '3',
        title: '采购申请-材料',
        type: '采购',
        applicant: '王五',
        status: '已通过',
        createTime: DateTime.now().subtract(const Duration(days: 3)),
        approvalTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Approval(
        id: '4',
        title: '采购申请-服务',
        type: '采购',
        applicant: '赵六',
        status: '已拒绝',
        createTime: DateTime.now().subtract(const Duration(days: 4)),
        approvalTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Approval(
        id: '5',
        title: '请假申请-年假',
        type: '请假',
        applicant: '钱七',
        status: '待审批',
        createTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Approval(
        id: '6',
        title: '请假申请-事假',
        type: '请假',
        applicant: '孙八',
        status: '已通过',
        createTime: DateTime.now().subtract(const Duration(days: 2)),
        approvalTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}