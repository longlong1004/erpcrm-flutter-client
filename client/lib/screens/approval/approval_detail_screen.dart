import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/providers/approval_provider.dart';
import 'package:erpcrm_client/models/approval/approval.dart';

class ApprovalDetailScreen extends ConsumerWidget {
  final String approvalId;

  const ApprovalDetailScreen({super.key, required this.approvalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 加载审批详情数据
    ref.read(approvalProvider.notifier).getApprovalById(approvalId);
    
    // 获取当前选中的审批
    final approvals = ref.watch(approvalProvider);
    final int? parsedId = int.tryParse(approvalId);
    final approval = approvals.firstWhere(
      (a) => a.approvalId == parsedId,
      orElse: () => Approval(
        approvalId: 0,
        title: '',
        content: '',
        requesterId: 0,
        requesterName: '',
        approverId: 0,
        approverName: '',
        status: '',
        type: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedData: {},
        comment: '',
        isSynced: true,
      ),
    );

    if (approval.approvalId == 0) {
      return MainLayout(
        title: '审批详情',
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final approvalData = {
      '序号': approval.approvalId,
      '业务员': approval.requesterName,
      '审批源': approval.type,
      '创建时间': approval.createdAt,
      '审批状态': approval.status,
      '审批名称': approval.title,
      '审批编号': approval.approvalId,
      '描述': approval.content,
      '审批人': approval.approverName,
      '审批时间': approval.updatedAt,
      '审批意见': approval.comment ?? '-',
    };

    return MainLayout(
      title: '审批详情',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '审批详情',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 32),
            // 审批详情卡片
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 基本信息部分
                      const Text(
                        '基本信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('序号', approvalData['序号'].toString()),
                      _buildDetailRow('业务员', approvalData['业务员'].toString()),
                      _buildDetailRow('审批源', approvalData['审批源'].toString()),
                      _buildDetailRow('审批编号', approvalData['审批编号'].toString()),
                      _buildDetailRow('审批名称', approvalData['审批名称'].toString()),
                      _buildDetailRow('创建时间', approvalData['创建时间'].toString()),
                      _buildDetailRow('审批状态', approvalData['审批状态'].toString()),
                      const SizedBox(height: 24),
                      // 审批内容部分
                      const Text(
                        '审批内容',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('描述', approvalData['描述'].toString()),
                      const SizedBox(height: 24),
                      // 审批信息部分
                      const Text(
                        '审批信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('审批人', approvalData['审批人'].toString()),
                      _buildDetailRow('审批时间', approvalData['审批时间'].toString()),
                      _buildDetailRow('审批意见', approvalData['审批意见'].toString()),
                      const SizedBox(height: 24),
                      // 操作按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C757D),
                            ),
                            child: const Text('返回'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
