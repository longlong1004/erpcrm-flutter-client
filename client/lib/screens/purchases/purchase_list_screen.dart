import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class Purchase {
  final String id;
  final String title;
  final String type;
  final String applicant;
  final String status;
  final double amount;
  final DateTime createTime;

  Purchase({
    required this.id,
    required this.title,
    required this.type,
    required this.applicant,
    required this.status,
    required this.amount,
    required this.createTime,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      applicant: json['applicant'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      createTime: DateTime.parse(json['createTime'] as String),
    );
  }
}

class PurchaseListScreen extends ConsumerStatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  ConsumerState<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends ConsumerState<PurchaseListScreen> with SingleTickerProviderStateMixin {
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
      title: '采购管理',
      showBackButton: true,
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
    final purchases = _getMockPurchases().where((p) => p.status == '待审批').toList();
    final filteredPurchases = purchases.where((p) =>
      p.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      p.applicant.toLowerCase().contains(_searchKeyword.toLowerCase())
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
            itemCount: filteredPurchases.length,
            itemBuilder: (context, index) {
              final purchase = filteredPurchases[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(purchase.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('类型: ${purchase.type}'),
                      Text('申请人: ${purchase.applicant}'),
                      Text('金额: ¥${purchase.amount.toStringAsFixed(2)}'),
                      Text('创建时间: ${purchase.createTime.toString().substring(0, 19)}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(purchase.status),
                    backgroundColor: Colors.orange[50],
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
    final purchases = _getMockPurchases().where((p) => p.status == '已通过').toList();
    final filteredPurchases = purchases.where((p) =>
      p.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      p.applicant.toLowerCase().contains(_searchKeyword.toLowerCase())
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
            itemCount: filteredPurchases.length,
            itemBuilder: (context, index) {
              final purchase = filteredPurchases[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(purchase.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('类型: ${purchase.type}'),
                      Text('申请人: ${purchase.applicant}'),
                      Text('金额: ¥${purchase.amount.toStringAsFixed(2)}'),
                      Text('创建时间: ${purchase.createTime.toString().substring(0, 19)}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(purchase.status),
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
    final purchases = _getMockPurchases().where((p) => p.status == '已拒绝').toList();
    final filteredPurchases = purchases.where((p) =>
      p.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
      p.applicant.toLowerCase().contains(_searchKeyword.toLowerCase())
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
            itemCount: filteredPurchases.length,
            itemBuilder: (context, index) {
              final purchase = filteredPurchases[index];
              return Card(
                margin: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                child: ListTile(
                  title: Text(purchase.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('类型: ${purchase.type}'),
                      Text('申请人: ${purchase.applicant}'),
                      Text('金额: ¥${purchase.amount.toStringAsFixed(2)}'),
                      Text('创建时间: ${purchase.createTime.toString().substring(0, 19)}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(purchase.status),
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

  List<Purchase> _getMockPurchases() {
    return [
      Purchase(
        id: '1',
        title: '办公用品采购',
        type: '办公用品',
        applicant: '张三',
        status: '待审批',
        amount: 1500.00,
        createTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Purchase(
        id: '2',
        title: '设备采购',
        type: '设备',
        applicant: '李四',
        status: '待审批',
        amount: 5000.00,
        createTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Purchase(
        id: '3',
        title: '材料采购',
        type: '材料',
        applicant: '王五',
        status: '已通过',
        amount: 8000.00,
        createTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Purchase(
        id: '4',
        title: '服务采购',
        type: '服务',
        applicant: '赵六',
        status: '已拒绝',
        amount: 3000.00,
        createTime: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Purchase(
        id: '5',
        title: '设备采购',
        type: '设备',
        applicant: '钱七',
        status: '已通过',
        amount: 12000.00,
        createTime: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Purchase(
        id: '6',
        title: '办公用品采购',
        type: '办公用品',
        applicant: '孙八',
        status: '待审批',
        amount: 2500.00,
        createTime: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }
}