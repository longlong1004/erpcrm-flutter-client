import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 多级菜单布局组件
/// 支持任意层级的菜单结构，具有展开/折叠功能
class MultiLevelMenuLayout extends ConsumerStatefulWidget {
  // 菜单配置
  final List<MenuItem> menuItems;
  // 初始选中的菜单项路径
  final String initialSelectedPath;
  // 菜单展开状态
  final Map<String, bool> initialExpandedState;

  const MultiLevelMenuLayout({
    super.key,
    required this.menuItems,
    this.initialSelectedPath = '',
    this.initialExpandedState = const {},
  });

  @override
  ConsumerState<MultiLevelMenuLayout> createState() => _MultiLevelMenuLayoutState();
}

class _MultiLevelMenuLayoutState extends ConsumerState<MultiLevelMenuLayout> {
  // 当前选中的菜单项路径
  String _selectedPath = '';
  // 菜单展开状态
  final Map<String, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    _selectedPath = widget.initialSelectedPath;
    _expandedState.addAll(widget.initialExpandedState);
    // 默认展开包含当前选中项的所有父菜单
    _expandParentMenus(_selectedPath);
  }

  // 展开包含指定路径的所有父菜单
  void _expandParentMenus(String path) {
    if (path.isEmpty) return;
    
    final pathParts = path.split('/').where((part) => part.isNotEmpty).toList();
    String currentPath = '';
    
    for (final part in pathParts) {
      currentPath += '/$part';
      _expandedState[currentPath] = true;
    }
  }

  // 切换菜单展开状态
  void _toggleExpand(String path) {
    setState(() {
      _expandedState[path] = !(_expandedState[path] ?? false);
    });
  }

  // 处理菜单项点击
  void _handleMenuItemTap(MenuItem item, String path) {
    setState(() {
      _selectedPath = path;
    });
  }

  // 递归构建菜单树
  Widget _buildMenuTree(List<MenuItem> items, String parentPath) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final path = parentPath.isEmpty ? '/${item.id}' : '$parentPath/${item.id}';
        final isSelected = _selectedPath == path;
        final isExpanded = _expandedState[path] ?? false;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 菜单项
            InkWell(
              onTap: () {
                if (item.children.isNotEmpty) {
                  _toggleExpand(path);
                } else {
                  _handleMenuItemTap(item, path);
                }
              },
              child: Container(
                padding: EdgeInsets.only(
                  left: 16.0 + (parentPath.split('/').length - 1) * 16.0,
                  top: 12.0,
                  bottom: 12.0,
                  right: 16.0,
                ),
                color: isSelected ? const Color(0xFFE6F2FF) : Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 菜单图标
                        if (item.icon != null) ...[
                          Icon(item.icon, size: 16, color: isSelected ? const Color(0xFF003366) : Colors.grey),
                          const SizedBox(width: 8),
                        ],
                        // 菜单文本
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF003366) : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // 展开/折叠指示器
                    if (item.children.isNotEmpty) ...[
                      Icon(
                        isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // 子菜单
            if (item.children.isNotEmpty) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: isExpanded ? 0 : 0,
                    maxHeight: isExpanded ? double.infinity : 0,
                  ),
                  child: AnimatedOpacity(
                    opacity: isExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      color: const Color(0xFFF5F7FA),
                      child: _buildMenuTree(item.children, path),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧菜单
        Container(
          width: 250,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: SingleChildScrollView(
            child: _buildMenuTree(widget.menuItems, ''),
          ),
        ),
        // 右侧内容区域
        Expanded(
          child: _buildContentArea(),
        ),
      ],
    );
  }

  // 构建内容区域
  Widget _buildContentArea() {
    // 查找当前选中的菜单项
    MenuItem? findSelectedItem(List<MenuItem> items, String path) {
      for (final item in items) {
        final itemPath = '/${item.id}';
        if (itemPath == path) {
          return item;
        }
        if (item.children.isNotEmpty) {
          final found = findSelectedItem(item.children, path);
          if (found != null) {
            return found;
          }
        }
      }
      return null;
    }

    final selectedItem = findSelectedItem(widget.menuItems, _selectedPath);
    
    if (selectedItem == null || selectedItem.content == null) {
      return Center(
        child: Text(
          '请选择一个菜单项',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        ),
      );
    }

    return selectedItem.content!;
  }
}

/// 菜单项配置类
class MenuItem {
  // 菜单项ID
  final String id;
  // 菜单项标题
  final String title;
  // 菜单项图标
  final IconData? icon;
  // 子菜单项
  final List<MenuItem> children;
  // 菜单项对应的内容
  final Widget? content;

  const MenuItem({
    required this.id,
    required this.title,
    this.icon,
    this.children = const [],
    this.content,
  });
}
