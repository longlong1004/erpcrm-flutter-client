import 'package:flutter/material.dart';
import 'package:erpcrm_client/services/approval_data_service.dart';
import 'package:erpcrm_client/widgets/common/modern_card.dart';

/// 审批仪表盘页面
class ApprovalDashboardScreen extends StatefulWidget {
  const ApprovalDashboardScreen({super.key});

  @override
  State<ApprovalDashboardScreen> createState() => _ApprovalDashboardScreenState();
}

class _ApprovalDashboardScreenState extends State<ApprovalDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final metrics = await ApprovalDataService.getApprovalMetrics();
    setState(() {
      _metrics = metrics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('审批仪表盘'),
        backgroundColor: const Color(0xFF003366),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    ModernCard(
                      title: '待审批',
                      value: '${_metrics['pendingCount'] ?? 0}',
                      unit: '项',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    ModernCard(
                      title: '已通过',
                      value: '${_metrics['approvedCount'] ?? 0}',
                      unit: '项',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    ModernCard(
                      title: '已拒绝',
                      value: '${_metrics['rejectedCount'] ?? 0}',
                      unit: '项',
                      icon: Icons.cancel,
                      color: Colors.red,
                    ),
                    ModernCard(
                      title: '总计',
                      value: '${_metrics['totalCount'] ?? 0}',
                      unit: '项',
                      icon: Icons.list_alt,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
