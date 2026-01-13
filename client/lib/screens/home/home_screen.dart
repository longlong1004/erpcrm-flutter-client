import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../screens/dashboard/dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: '首页',
      child: DashboardScreen(),
    );
  }
}
