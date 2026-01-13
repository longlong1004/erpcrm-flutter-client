import 'package:flutter/material.dart';

// 菜单项数据结构
class MenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<MenuItem>? children;
  final String? description;
  final List<String>? tableHeaders;
  final List<String>? actionButtons;
  final List<String>? requiredPermissions;

  const MenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.children,
    this.description,
    this.tableHeaders,
    this.actionButtons,
    this.requiredPermissions,
  });
}