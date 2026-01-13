import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tab_provider.dart';

/// 三级台阶式菜单布局组件
/// 用于实现与订单管理标签页一致的布局结构
class TwoLevelTabLayout extends ConsumerStatefulWidget {
  // 一级菜单配置
  final List<TabConfig> firstLevelTabs;
  // 初始选中的一级菜单索引
  final int initialFirstLevelIndex;
  // 初始选中的二级菜单索引
  final int initialSecondLevelIndex;
  // 模块名称，用于标签页标题
  final String moduleName;

  const TwoLevelTabLayout({
    super.key,
    required this.firstLevelTabs,
    this.initialFirstLevelIndex = 0,
    this.initialSecondLevelIndex = 0,
    required this.moduleName,
  });

  @override
  ConsumerState<TwoLevelTabLayout> createState() => _TwoLevelTabLayoutState();
}

class _TwoLevelTabLayoutState extends ConsumerState<TwoLevelTabLayout> {
  int _currentFirstLevelIndex = 0;
  int _currentSecondLevelIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFirstLevelIndex = widget.initialFirstLevelIndex;
    _currentSecondLevelIndex = widget.initialSecondLevelIndex;
    
    // 初始化时更新标签页标题
    _updateTabTitle();
  }

  // 更新当前标签页的标题
  void _updateTabTitle() {
    final currentFirstTab = widget.firstLevelTabs[_currentFirstLevelIndex];
    final currentSecondTab = currentFirstTab.secondLevelTabs[_currentSecondLevelIndex];
    
    // 只使用当前表单的标题，不包含层级结构
    final newTitle = currentSecondTab.title;
    
    // 更新当前激活标签页的标题
    ref.read(tabProvider.notifier).updateActiveTabTitle(newTitle);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TwoLevelTabLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检查是否需要更新状态
    bool needUpdate = false;
    
    // 如果firstLevelTabs变化，重新初始化当前索引
    if (oldWidget.firstLevelTabs != widget.firstLevelTabs) {
      _currentFirstLevelIndex = widget.initialFirstLevelIndex;
      _currentSecondLevelIndex = widget.initialSecondLevelIndex;
      needUpdate = true;
    }
    
    // 检查initialFirstLevelIndex是否变化
    if (oldWidget.initialFirstLevelIndex != widget.initialFirstLevelIndex) {
      _currentFirstLevelIndex = widget.initialFirstLevelIndex;
      _currentSecondLevelIndex = widget.initialSecondLevelIndex;
      needUpdate = true;
    }
    
    // 检查initialSecondLevelIndex是否变化
    if (oldWidget.initialSecondLevelIndex != widget.initialSecondLevelIndex) {
      _currentSecondLevelIndex = widget.initialSecondLevelIndex;
      needUpdate = true;
    }
    
    // 确保索引不越界
    if (_currentFirstLevelIndex >= widget.firstLevelTabs.length) {
      _currentFirstLevelIndex = widget.firstLevelTabs.isNotEmpty ? widget.firstLevelTabs.length - 1 : 0;
      _currentSecondLevelIndex = 0;
      needUpdate = true;
    }
    
    final currentFirstTab = widget.firstLevelTabs[_currentFirstLevelIndex];
    if (_currentSecondLevelIndex >= currentFirstTab.secondLevelTabs.length) {
      _currentSecondLevelIndex = currentFirstTab.secondLevelTabs.isNotEmpty ? currentFirstTab.secondLevelTabs.length - 1 : 0;
      needUpdate = true;
    }
    
    // 如果需要更新，调用setState并更新标题
    if (needUpdate) {
      setState(() {
        _updateTabTitle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前选中的表单内容
    final currentFirstTab = widget.firstLevelTabs[_currentFirstLevelIndex];
    final currentSecondTab = currentFirstTab.secondLevelTabs[_currentSecondLevelIndex];
    
    return Column(
      children: [
        // 三级台阶式菜单布局
        _buildThreeLevelMenu(),
        
        // 内容区域 - 显示当前表单信息
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: currentSecondTab.content,
          ),
        ),
      ],
    );
  }
  
  // 构建三级台阶式菜单
  Widget _buildThreeLevelMenu() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          // 第一级菜单 - 台阶1
          _buildFirstLevelMenu(),
          
          // 第二级菜单 - 台阶2
          _buildSecondLevelMenu(),
        ],
      ),
    );
  }
  
  // 构建第一级菜单
  Widget _buildFirstLevelMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E9F0),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
        ),
        border: Border(
          right: BorderSide(color: Colors.grey.withOpacity(0.2)),
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: List.generate(widget.firstLevelTabs.length, (index) {
          final tab = widget.firstLevelTabs[index];
          final isSelected = index == _currentFirstLevelIndex;
          
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentFirstLevelIndex = index;
                  _currentSecondLevelIndex = 0;
                  _updateTabTitle();
                });
              },
              child: Text(
                tab.title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF003366) : const Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  // 构建第二级菜单
  Widget _buildSecondLevelMenu() {
    final currentFirstTab = widget.firstLevelTabs[_currentFirstLevelIndex];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        border: Border(
          right: BorderSide(color: Colors.grey.withOpacity(0.2)),
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: List.generate(currentFirstTab.secondLevelTabs.length, (index) {
          final tab = currentFirstTab.secondLevelTabs[index];
          final isSelected = index == _currentSecondLevelIndex;
          
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentSecondLevelIndex = index;
                  _updateTabTitle();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF003366) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tab.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : const Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 标签页配置类
class TabConfig {
  // 标签标题
  final String title;
  // 二级菜单配置
  final List<SecondLevelTabConfig> secondLevelTabs;

  const TabConfig({
    required this.title,
    required this.secondLevelTabs,
  });
}

/// 二级标签页配置类
class SecondLevelTabConfig {
  // 标签标题
  final String title;
  // 标签内容
  final Widget content;

  const SecondLevelTabConfig({
    required this.title,
    required this.content,
  });
}
