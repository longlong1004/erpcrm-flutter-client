import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/providers/approval_provider.dart';

class ApprovalProcessScreen extends ConsumerStatefulWidget {
  final String approvalId;

  const ApprovalProcessScreen({super.key, required this.approvalId});

  @override
  ConsumerState<ApprovalProcessScreen> createState() => _ApprovalProcessScreenState();
}

class _ApprovalProcessScreenState extends ConsumerState<ApprovalProcessScreen> {
  final TextEditingController _approvalCommentController = TextEditingController();

  @override
  void dispose() {
    _approvalCommentController.dispose();
    super.dispose();
  }

  void _handleApproval(bool isApproved) async {
    try {
      // 调用真实的审批API
      await ref.read(approvalProvider.notifier).approveApproval(
        widget.approvalId.toString(),
        {
          'approverId': '当前用户ID', // 这里应该从登录状态获取当前用户ID
          'result': isApproved ? 'APPROVED' : 'REJECTED',
          'comments': _approvalCommentController.text,
        },
      );

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved ? '审批通过' : '审批驳回',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: isApproved ? const Color(0xFF107C10) : const Color(0xFFD93025),
          ),
        );

        // 返回上一页
        Navigator.pop(context);
      }
    } catch (error) {
      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '审批失败: $error',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD93025),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '审批操作',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '审批操作',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 32),
            // 审批表单卡片
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
                      // 审批ID
                      Text(
                        '审批ID: ${widget.approvalId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 审批意见
                      const Text(
                        '审批意见',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _approvalCommentController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          hintText: '请输入审批意见...',
                          contentPadding: const EdgeInsets.all(16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 32),
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
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              _handleApproval(false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD93025),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('驳回'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              _handleApproval(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF107C10),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('同意'),
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
}
