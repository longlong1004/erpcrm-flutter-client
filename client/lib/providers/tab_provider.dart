import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/tab_item.dart';

// 标签页状态管理提供器
final tabProvider = NotifierProvider<TabNotifier, List<TabItem>>(TabNotifier.new);

class TabNotifier extends Notifier<List<TabItem>> {
  // Hive 盒子名称
  static const String _hiveBoxName = 'tabs';

  // 获取Hive盒子
  Future<Box<TabItem>> _getBox() async {
    if (!Hive.isBoxOpen(_hiveBoxName)) {
      await Hive.openBox<TabItem>(_hiveBoxName);
    }
    return Hive.box<TabItem>(_hiveBoxName);
  }

  @override
  List<TabItem> build() {
    try {
      // 从本地存储恢复标签页状态
      if (!Hive.isBoxOpen(_hiveBoxName)) {
        // 如果盒子未打开，返回默认标签页列表
        final defaultTab = TabItem.create(
          title: '仪表板',
          route: '/dashboard',
        );
        return [defaultTab];
      }
      final box = Hive.box<TabItem>(_hiveBoxName);
      final tabs = box.values.toList();
      
      // 如果没有标签页，添加默认标签页
      if (tabs.isEmpty) {
        final defaultTab = TabItem.create(
          title: '仪表板',
          route: '/dashboard',
        );
        return [defaultTab];
      }
      
      return tabs;
    } catch (e) {
      print('从Hive加载标签页失败: $e');
      // 返回默认标签页列表
      final defaultTab = TabItem.create(
        title: '仪表板',
        route: '/dashboard',
      );
      return [defaultTab];
    }
  }

  // 添加新标签页
  Future<TabItem> addTab({
    required String title,
    required String route,
    String? subtitle,
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
  }) async {
    // 检查是否已存在相同路由的标签页
    int existingTabIndex = -1;
    for (int i = 0; i < state.length; i++) {
      final tab = state[i];
      
      // 精确匹配路由
      if (tab.route != route) {
        continue;
      }
      
      // 匹配params
      bool paramsMatch = false;
      if (tab.params == null && params == null) {
        paramsMatch = true;
      } else if (tab.params != null && params != null) {
        paramsMatch = _mapEquals(tab.params, params);
      }
      
      // 匹配queryParams
      bool queryParamsMatch = false;
      if (tab.queryParams == null && queryParams == null) {
        queryParamsMatch = true;
      } else if (tab.queryParams != null && queryParams != null) {
        queryParamsMatch = _mapEquals(tab.queryParams, queryParams);
      }
      
      if (paramsMatch && queryParamsMatch) {
        existingTabIndex = i;
        break;
      }
    }
    
    if (existingTabIndex != -1) {
      // 如果已存在，激活该标签页
      await setActiveTab(existingTabIndex);
      return state[existingTabIndex];
    }
    
    // 创建新标签页
    final newTab = TabItem.create(
      title: title,
      route: route,
      subtitle: subtitle,
      params: params,
      queryParams: queryParams,
      state: null,
    );
    
    // 更新状态
    final updatedTabs = <TabItem>[];
    for (int i = 0; i < state.length; i++) {
      updatedTabs.add(state[i].copyWith(isActive: false));
    }
    
    // 添加新标签页并设置为激活
    updatedTabs.add(newTab);
    
    // 更新状态
    state = updatedTabs;
    
    // 持久化到本地存储（如果Hive盒子已打开）
    try {
      await _persistTabs(updatedTabs);
    } catch (e) {
      print('持久化标签页失败: $e');
      // 持久化失败不影响标签页的添加，仅打印日志
    }
    
    return newTab;
  }
  
  // 比较两个Map是否相等
  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }

  // 切换标签页
  Future<void> setActiveTab(int index) async {
    if (index < 0 || index >= state.length) return;
    
    final updatedTabs = [...state];
    
    // 更新所有标签页的激活状态
    for (int i = 0; i < updatedTabs.length; i++) {
      updatedTabs[i] = updatedTabs[i].copyWith(isActive: i == index);
    }
    
    // 更新状态
    state = updatedTabs;
    
    // 持久化到本地存储
    await _persistTabs(updatedTabs);
  }

  // 关闭标签页
  Future<void> closeTab(int index) async {
    if (index < 0 || index >= state.length) return;
    
    final updatedTabs = [...state];
    updatedTabs.removeAt(index);
    
    // 如果关闭的是激活标签页，激活前一个标签页
    if (updatedTabs.isNotEmpty) {
      final newActiveIndex = index == 0 ? 0 : index - 1;
      for (int i = 0; i < updatedTabs.length; i++) {
        updatedTabs[i] = updatedTabs[i].copyWith(isActive: i == newActiveIndex);
      }
    }
    
    // 更新状态
    state = updatedTabs;
    
    // 持久化到本地存储
    await _persistTabs(updatedTabs);
  }

  // 重命名标签页
  Future<void> renameTab(int index, String newTitle) async {
    if (index < 0 || index >= state.length) return;
    
    final updatedTabs = [...state];
    updatedTabs[index] = updatedTabs[index].copyWith(title: newTitle);
    
    // 更新状态
    state = updatedTabs;
    
    // 持久化到本地存储
    await _persistTabs(updatedTabs);
  }

  // 拖拽排序标签页
  Future<void> reorderTabs(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || 
        oldIndex >= state.length || 
        newIndex < 0 || 
        newIndex >= state.length) return;
    
    final updatedTabs = [...state];
    
    // 移除旧位置的标签页
    final item = updatedTabs.removeAt(oldIndex);
    
    // 插入到新位置
    updatedTabs.insert(newIndex, item);
    
    // 更新状态
    state = updatedTabs;
    
    // 持久化到本地存储
    await _persistTabs(updatedTabs);
  }

  // 更新标签页状态
  Future<void> updateTabState(String tabId, Map<String, dynamic> newState) async {
    final updatedTabs = <TabItem>[...state];
    int tabIndex = -1;
    for (int i = 0; i < updatedTabs.length; i++) {
      if (updatedTabs[i].id == tabId) {
        tabIndex = i;
        break;
      }
    }
    
    if (tabIndex != -1) {
      final currentTab = updatedTabs[tabIndex];
      final currentState = currentTab.state ?? {};
      final mergedState = <String, dynamic>{...currentState, ...newState};
      updatedTabs[tabIndex] = currentTab.copyWith(state: mergedState);
      
      // 更新状态
      state = updatedTabs;
      
      // 持久化到本地存储
      await _persistTabs(updatedTabs);
    }
  }
  
  // 更新当前激活标签页的路由
  Future<void> updateActiveTabRoute(String newRoute) async {
    final updatedTabs = <TabItem>[...state];
    final activeIndex = updatedTabs.indexWhere((tab) => tab.isActive);
    
    if (activeIndex != -1) {
      updatedTabs[activeIndex] = updatedTabs[activeIndex].copyWith(route: newRoute);
      
      // 更新状态
      state = updatedTabs;
      
      // 持久化到本地存储
      await _persistTabs(updatedTabs);
    }
  }

  // 更新当前激活标签页的标题
  Future<void> updateActiveTabTitle(String newTitle) async {
    final updatedTabs = <TabItem>[...state];
    final activeIndex = updatedTabs.indexWhere((tab) => tab.isActive);
    
    if (activeIndex != -1) {
      updatedTabs[activeIndex] = updatedTabs[activeIndex].copyWith(title: newTitle);
      
      // 更新状态
      state = updatedTabs;
      
      // 持久化到本地存储
      await _persistTabs(updatedTabs);
    }
  }

  // 持久化标签页状态到本地存储
  Future<void> _persistTabs(List<TabItem> tabs) async {
    final box = await _getBox();
    
    // 清空现有数据
    await box.clear();
    
    // 保存新数据 - 使用putAll方法，避免HiveObject实例key冲突
    final tabMap = <dynamic, TabItem>{};
    for (int i = 0; i < tabs.length; i++) {
      // 创建新的TabItem实例，避免使用已有key的HiveObject实例
      final newTab = TabItem(
        id: tabs[i].id,
        title: tabs[i].title,
        route: tabs[i].route,
        subtitle: tabs[i].subtitle,
        isActive: tabs[i].isActive,
        params: tabs[i].params,
        queryParams: tabs[i].queryParams,
        state: tabs[i].state,
      );
      tabMap[i] = newTab;
    }
    
    // 使用putAll方法一次性存储所有标签页
    await box.putAll(tabMap);
  }

  // 清除所有标签页
  Future<void> clearTabs() async {
    final box = await _getBox();
    await box.clear();
    state = [];
  }

  // 获取当前激活的标签页
  TabItem? getActiveTab() {
    final activeIndex = state.indexWhere((tab) => tab.isActive);
    if (activeIndex != -1) {
      return state[activeIndex];
    }
    return null;
  }

  // 获取标签页索引
  int getTabIndex(String tabId) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].id == tabId) {
        return i;
      }
    }
    return -1;
  }
}
