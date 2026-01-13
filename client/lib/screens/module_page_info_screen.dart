import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/module_page_info.dart';

class ModulePageInfoScreen extends ConsumerWidget {
  const ModulePageInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        child: ModulePageInfo(),
      ),
    );
  }
}
