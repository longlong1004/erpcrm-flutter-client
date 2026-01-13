import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';

class ProcessDesignScreen extends ConsumerWidget {
  const ProcessDesignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流程设计'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 返回系统设置页面
            GoRouter.of(context).go('/settings');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_ind,
              size: 100,
              color: Color(0xFF003366),
            ),
            const SizedBox(height: 20),
            const Text(
              '流程设计功能',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '审批流程可视化设计器',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // 使用标签页系统添加新标签页
                ref.read(tabProvider.notifier).addTab(
                  title: '创建新流程',
                  route: '/settings/process-design/wizard',
                );
                context.go('/settings/process-design/wizard');
              },
              icon: const Icon(Icons.add),
              label: const Text('创建新流程'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                // 使用标签页系统添加新标签页
                ref.read(tabProvider.notifier).addTab(
                  title: '查看已有流程',
                  route: '/settings/process-design/list',
                );
                context.go('/settings/process-design/list');
              },
              icon: const Icon(Icons.list),
              label: const Text('查看已有流程'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF003366),
                side: const BorderSide(color: Color(0xFF003366)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
