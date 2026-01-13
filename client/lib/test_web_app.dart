import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP+CRM 国铁商城系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF003366),
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP+CRM 国铁商城系统'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 100, color: Color(0xFF003366)),
            SizedBox(height: 20),
            Text(
              '系统启动成功!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '后端服务正在 http://localhost:8080/api 运行',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '前端Web服务正在此页面运行',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('系统功能正在开发中')),
          );
        },
        backgroundColor: const Color(0xFF003366),
        child: const Icon(Icons.info, color: Colors.white),
      ),
    );
  }
}