import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';
import 'package:erpcrm_client/screens/approval/approval_detail_screen.dart';
import 'package:erpcrm_client/screens/approval/approval_process_screen.dart';
import 'package:erpcrm_client/providers/approval_provider.dart';

class ApprovalScreen extends ConsumerWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = Router.of(context).routeInformationProvider?.value.uri.path ?? '';
    final isPending = currentPath == '/approval/pending';
    final isApproved = currentPath == '/approval/approved';
    final isRejected = currentPath == '/approval/rejected';

    // 根据当前路径设置标题
    String pageTitle;
    List<String> tableHeaders;
    List<String> actionButtons;

    if (isPending) {
      pageTitle = '待审核';
      tableHeaders = ['序号', '业务员', '审批源', '创建时间', '操作'];
      actionButtons = ['查看', '审批'];
      // 加载待审核数据
      ref.read(approvalProvider.notifier).loadPendingApprovals();
    } else if (isApproved) {
      pageTitle = '已审核';
      tableHeaders = ['序号', '业务员', '审批源', '创建时间', '审批时间', '操作'];
      actionButtons = ['查看'];
      // 加载已审核数据
      ref.read(approvalProvider.notifier).loadApprovedApprovals();
    } else if (isRejected) {
      pageTitle = '已驳回';
      tableHeaders = ['序号', '业务员', '审批源', '创建时间', '审批时间', '操作'];
      actionButtons = ['查看'];
      // 加载已驳回数据
      ref.read(approvalProvider.notifier).loadRejectedApprovals();
    } else {
      // 默认显示所有审批
      pageTitle = '审批管理';
      tableHeaders = ['序号', '业务员', '审批源', '创建时间', '状态', '操作'];
      actionButtons = ['查看'];
      // 加载所有审批数据
      ref.read(approvalProvider.notifier).loadApprovals();
    }

    // 监听审批数据
    final approvals = ref.watch(approvalProvider);

    return MainLayout(
      title: pageTitle,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pageTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 32),
            // 表格容器
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
                child: Column(
                  children: [
                    // 表格标题
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: tableHeaders.map((header) => Expanded(
                          flex: header == '操作' ? 3 : 2,
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F1F1F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )).toList(),
                      ),
                    ),
                    // 表格内容
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 300, // 调整宽度以适应内容
                          child: ListView.builder(
                            itemCount: approvals.length,
                            itemBuilder: (context, index) {
                              final approval = approvals[index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: const Color(0xFFE0E0E0)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // 序号
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text((index + 1).toString()),
                                      ),
                                    ),
                                    // 业务员
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(approval.requesterName),
                                      ),
                                    ),
                                    // 审批源
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(approval.type),
                                      ),
                                    ),
                                    // 创建时间
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(approval.createdAt.toString()),
                                      ),
                                    ),
                                    // 如果是已审核或已驳回，显示审批时间
                                    if (isApproved || isRejected)
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(approval.updatedAt.toString()),
                                        ),
                                      ),
                                    // 如果是默认视图，显示状态
                                    if (!isPending && !isApproved && !isRejected)
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(approval.status),
                                        ),
                                      ),
                                    // 操作按钮
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          alignment: WrapAlignment.center,
                                          children: actionButtons.map((button) => ElevatedButton(
                                            onPressed: () {
                                              // 处理按钮点击事件
                                              if (button == '查看') {
                                                // 查看逻辑
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ApprovalDetailScreen(approvalId: approval.approvalId.toString()),
                                                  ),
                                                );
                                              } else if (button == '审批') {
                                                // 审批逻辑
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ApprovalProcessScreen(approvalId: approval.approvalId.toString()),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: button == '查看' 
                                                  ? const Color(0xFF003366)
                                                  : const Color(0xFF107C10),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              textStyle: const TextStyle(fontSize: 14),
                                            ),
                                            child: Text(button),
                                          )).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // 如果没有数据，显示提示信息
                    if (approvals.isEmpty) 
                      Expanded(
                        child: Center(
                          child: Text(
                            '暂无数据',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}