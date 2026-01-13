import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification/notification.dart' as customNotification;

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends ConsumerState<NotificationListScreen> {
  String? _selectedType;
  bool? _selectedReadStatus;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // 初始化时加载通知
    ref.read(notificationProvider.notifier).loadNotifications();
    // 更新未读数量
    ref.read(notificationProvider.notifier).updateUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '搜索通知...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    notifier.searchNotifications(value);
                  }
                },
              )
            : const Text('消息通知'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  notifier.loadNotifications(isRefresh: true);
                }
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('全部'),
              ),
              const PopupMenuItem(
                value: 'system',
                child: Text('系统通知'),
              ),
              const PopupMenuItem(
                value: 'business',
                child: Text('业务通知'),
              ),
              const PopupMenuItem(
                value: 'approval',
                child: Text('审批通知'),
              ),
            ],
            onSelected: (value) {
              setState(() {
                _selectedType = value == 'all' ? null : value;
              });
              notifier.loadNotifications(
                type: _selectedType,
                isRefresh: true,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment(
                        value: null,
                        label: Text('全部'),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('未读'),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('已读'),
                      ),
                    ],
                    selected: {_selectedReadStatus},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedReadStatus = newSelection.first;
                      });
                      notifier.loadNotifications(
                        type: _selectedType,
                        isRead: _selectedReadStatus,
                        isRefresh: true,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    notifier.loadNotifications(
                      type: _selectedType,
                      isRead: _selectedReadStatus,
                      isRefresh: true,
                    );
                  },
                ),
              ],
            ),
          ),
          // 通知列表
          Expanded(
            child: notificationState.status == NotificationStatus.loading &&
                    notificationState.notifications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : notificationState.status == NotificationStatus.error
                    ? Center(child: Text('加载失败: ${notificationState.errorMessage}'))
                    : notificationState.notifications.isEmpty
                        ? const Center(child: Text('没有通知'))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await notifier.loadNotifications(
                                type: _selectedType,
                                isRead: _selectedReadStatus,
                                isRefresh: true,
                              );
                            },
                            child: ListView.builder(
                              itemCount: notificationState.notifications.length,
                              itemBuilder: (context, index) {
                                final notification = notificationState.notifications[index];
                                return NotificationItem(
                                  notification: notification,
                                  onTap: () {
                                    // 标记为已读
                                    if (!notification.isRead) {
                                      notifier.markAsRead(notification.id!);
                                    }
                                    // 跳转到通知详情
                                    context.push('/notifications/${notification.id}');
                                  },
                                  onLongPress: () {
                                    // 显示操作菜单
                                    _showNotificationMenu(notification);
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  // 显示通知操作菜单
  void _showNotificationMenu(customNotification.Notification notification) {
    final notifier = ref.read(notificationProvider.notifier);
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read),
              title: const Text('标记为已读'),
              onTap: () {
                notifier.markAsRead(notification.id!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(notification.isTop ?? false ? Icons.star_border : Icons.star),
              title: Text(notification.isTop ?? false ? '取消置顶' : '置顶'),
              onTap: () {
                if (notification.isTop ?? false) {
                  notifier.cancelTop(notification.id!);
                } else {
                  notifier.markAsTop(notification.id!);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('归档'),
              onTap: () {
                notifier.archiveNotification(notification.id!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除'),
              textColor: Colors.red,
              onTap: () {
                notifier.deleteNotification(notification.id!);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

// 通知列表项组件
class NotificationItem extends StatelessWidget {
  final customNotification.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          _getNotificationIcon(notification.type),
          color: _getNotificationColor(notification.priority),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            decoration: notification.isRead ? TextDecoration.none : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          notification.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  // 获取通知图标
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'system':
        return Icons.notifications;
      case 'business':
        return Icons.business;
      case 'approval':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  // 获取通知颜色
  Color _getNotificationColor(int priority) {
    switch (priority) {
      case 1: // 高优先级
        return Colors.red;
      case 2: // 中优先级
        return Colors.orange;
      case 3: // 低优先级
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  // 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.year}-${time.month}-${time.day}';
    }
  }
}
