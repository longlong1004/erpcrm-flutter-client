import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';
import 'package:erpcrm_client/models/menu_item.dart';

// 可折叠菜单项组件
class CollapsibleMenuItem extends ConsumerStatefulWidget {
  final MenuItem item;

  const CollapsibleMenuItem({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<CollapsibleMenuItem> createState() => _CollapsibleMenuItemState();
}

class _CollapsibleMenuItemState extends ConsumerState<CollapsibleMenuItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentRoute = Router.of(context).routeInformationProvider?.value.uri.path ?? '';
    final isSelected = widget.item.route != null && 
                     currentRoute.startsWith(widget.item.route!);
    
    // 有子菜单的情况
    if (widget.item.children != null && widget.item.children!.isNotEmpty) {
      return SizedBox(
        height: 48,
        child: ListTile(
          leading: Icon(
            widget.item.icon,
            color: isSelected ? Colors.white : const Color(0xFF90CAF9),
            size: 24,
          ),
          title: Text(
            widget.item.title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFBBDEFB),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedTileColor: const Color(0xFF004488),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          trailing: Icon(
            _isExpanded ? Icons.arrow_left : Icons.arrow_right,
            color: const Color(0xFF90CAF9),
            size: 20,
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      );
    } else {
      // 无子菜单的情况
      return SizedBox(
        height: 48,
        child: ListTile(
          leading: Icon(
            widget.item.icon,
            color: isSelected ? Colors.white : const Color(0xFF90CAF9),
            size: 24,
          ),
          title: Text(
            widget.item.title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFBBDEFB),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedTileColor: const Color(0xFF004488),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: () {
            if (widget.item.route != null) {
              // 使用标签页系统添加新标签页
              ref.read(tabProvider.notifier).addTab(
                title: widget.item.title!,
                route: widget.item.route!,
              );
              // 导航到路由
              context.go(widget.item.route!);
            }
          },
        ),
      );
    }
  }
}