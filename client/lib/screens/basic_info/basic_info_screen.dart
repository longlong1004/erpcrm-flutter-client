import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/two_level_tab_layout.dart';
import './company_info_screen.dart';
import './department_screen.dart';
import './position_screen.dart';
import './employee_info_screen.dart';
import './category_screen.dart';
import './tax_category_screen.dart';
import './template_screen.dart';
import './unit_screen.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  @override
  Widget build(BuildContext context) {
    // 配置两级菜单结构
    final firstLevelTabs = [
      // 基本信息
      TabConfig(
        title: '基本信息',
        secondLevelTabs: [
          SecondLevelTabConfig(
            title: '公司信息',
            content: const CompanyInfoScreen(),
          ),
          SecondLevelTabConfig(
            title: '部门管理',
            content: const DepartmentScreen(),
          ),
          SecondLevelTabConfig(
            title: '职位管理',
            content: const PositionScreen(),
          ),
          SecondLevelTabConfig(
            title: '员工信息',
            content: const EmployeeInfoScreen(),
          ),
          SecondLevelTabConfig(
            title: '三级分类',
            content: const CategoryScreen(),
          ),
          SecondLevelTabConfig(
            title: '税收分类',
            content: const TaxCategoryScreen(),
          ),
          SecondLevelTabConfig(
            title: '模板管理',
            content: const TemplateScreen(),
          ),
          SecondLevelTabConfig(
            title: '单位管理',
            content: const UnitScreen(),
          ),
        ],
      ),
    ];

    return TwoLevelTabLayout(
      firstLevelTabs: firstLevelTabs,
      initialFirstLevelIndex: 0,
      initialSecondLevelIndex: 0,
      moduleName: '基本信息',
    );
  }
}