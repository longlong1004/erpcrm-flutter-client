import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import '../../models/notification/notification.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  final int notificationId;

  const NotificationDetailScreen({Key? key, required this.notificationId}) : super(key: key);

  @override
  ConsumerState<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends ConsumerState<NotificationDetailScreen> {
  Notification? _notification;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotificationDetail();
  }

  Future<void> _loadNotificationDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = NotificationService();
      final notification = await service.getNotificationDetail(widget.notificationId);
      setState(() {
        _notification = notification;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知详情'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('标记为已读'),
                onTap: () {
                  if (_notification != null) {
                    notifier.markAsRead(_notification!.id!);
                    setState(() {
                      _notification = _notification!.copyWith(isRead: true);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(_notification?.isTop ?? false ? Icons.star_border : Icons.star),
                title: Text(_notification?.isTop ?? false ? '取消置顶' : '置顶'),
                onTap: () {
                  if (_notification != null) {
                    if (_notification!.isTop ?? false) {
                      notifier.cancelTop(_notification!.id!);
                      setState(() {
                        _notification = _notification!.copyWith(isTop: false);
                      });
                    } else {
                      notifier.markAsTop(_notification!.id!);
                      setState(() {
                        _notification = _notification!.copyWith(isTop: true);
                      });
                    }
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('归档'),
                onTap: () {
                  if (_notification != null) {
                    notifier.archiveNotification(_notification!.id!);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除'),
                textColor: Colors.red,
                onTap: () {
                  if (_notification != null) {
                    notifier.deleteNotification(_notification!.id!);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('加载失败: $_errorMessage'))
              : _notification == null
                  ? const Center(child: Text('通知不存在'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 通知标题
                          Text(
                            _notification!.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 通知发送者和时间
                          Row(
                            children: [
                              Text(
                                _notification!.senderName ?? '系统',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _formatTime(_notification!.createdAt),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 通知内容
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _notification!.content,
                              style: const TextStyle(
                                fontSize: 16,
                                lineHeight: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 通知相关信息
                          if (_notification!.relatedType != null && _notification!.relatedId != null)
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.link),
                                title: Text('相关${_notification!.relatedType}'),
                                subtitle: Text(_notification!.relatedId!),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // 跳转到相关页面
                                  _navigateToRelatedPage();
                                },
                              ),
                            ),
                          if (_notification!.actionUrl != null)
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.open_in_new),
                                title: const Text('查看详情'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // 跳转到指定URL
                                  _navigateToActionUrl();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }

  // 格式化时间
  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  // 跳转到相关页面
  void _navigateToRelatedPage() {
    if (_notification == null || _notification!.relatedType == null || _notification!.relatedId == null) {
      return;
    }

    switch (_notification!.relatedType) {
      case 'order':
        context.push('/orders/${_notification!.relatedId}');
        break;
      case 'product':
        context.push('/products/${_notification!.relatedId}');
        break;
      case 'approval':
        context.push('/approvals/${_notification!.relatedId}');
        break;
      case 'business':
        context.push('/businesses/${_notification!.relatedId}');
        break;
      default:
        // 其他类型的相关页面
        break;
    }
  }

  // 跳转到指定URL
  void _navigateToActionUrl() {
    if (_notification == null || _notification!.actionUrl == null) {
      return;
    }

    // 解析URL并跳转到相应页面
    final url = _notification!.actionUrl!;
    if (url.startsWith('/')) {
      // 内部路由
      context.push(url);
    } else {
      // 外部URL，需要使用url_launcher插件
      // 这里暂时只做简单处理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('跳转到外部链接: $url')),
      );
    }
  }
}
