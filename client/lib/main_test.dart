import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/screens/finance/other_expense_modal.dart';
import 'package:erpcrm_client/providers/finance_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: TestApp(),
      ),
    ),
  );
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试其他支出模块'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const OtherExpenseModal(),
            );
          },
          child: const Text('打开其他支出模态窗口'),
        ),
      ),
    );
  }
}
