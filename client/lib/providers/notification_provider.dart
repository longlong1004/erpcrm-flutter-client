import 'package:riverpod/riverpod.dart';
import '../models/notification/notification.dart' as customNotification;
import '../services/notification_service.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref ref;
  final NotificationService _notificationService;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  NotificationNotifier(this.ref) 
    : _notificationService = ref.read(notificationServiceProvider),
      super(NotificationState.initial()) {
    // 初始化时加载通知列表
    loadNotifications();
  }

  // 加载通知列表
  Future<void> loadNotifications({
    String? type,
    int? priority,
    bool? isRead,
    bool isRefresh = false,
  }) async {
    if (_isLoading) return;
    
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    
    try {
      state = state.copyWith(status: NotificationStatus.loading);
      
      final response = await _notificationService.getUserNotifications(
        type: type,
        priority: priority,
        isRead: isRead,
        page: _currentPage,
        size: 20,
      );
      
      final List<customNotification.Notification> notifications = (response['data']['content'] as List)
          .map((item) => customNotification.Notification.fromJson(item))
          .toList();
      
      final totalElements = response['data']['totalElements'] as int;
      final totalPages = response['data']['totalPages'] as int;
      
      if (isRefresh) {
        state = state.copyWith(
          notifications: notifications,
          totalElements: totalElements,
          totalPages: totalPages,
          status: NotificationStatus.success,
        );
      } else {
        state = state.copyWith(
          notifications: [...state.notifications, ...notifications],
          totalElements: totalElements,
          totalPages: totalPages,
          status: NotificationStatus.success,
        );
      }
      
      _currentPage++;
      _hasMore = _currentPage <= totalPages;
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  // 刷新通知列表
  Future<void> refreshNotifications({
    String? type,
    int? priority,
    bool? isRead,
  }) async {
    await loadNotifications(
      type: type,
      priority: priority,
      isRead: isRead,
      isRefresh: true,
    );
  }

  // 加载更多通知
  Future<void> loadMoreNotifications({
    String? type,
    int? priority,
    bool? isRead,
  }) async {
    await loadNotifications(
      type: type,
      priority: priority,
      isRead: isRead,
      isRefresh: false,
    );
  }

  // 获取未读通知数量
  Future<void> updateUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadNotificationCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // 忽略获取未读数量的错误，不影响主功能
    }
  }

  // 标记通知为已读
  Future<void> markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // 更新本地状态
      state = state.copyWith(
        notifications: state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(
              isRead: true,
              readTime: DateTime.now(),
            );
          }
          return notification;
        }).toList(),
      );
      
      // 更新未读数量
      if (state.unreadCount > 0) {
        state = state.copyWith(unreadCount: state.unreadCount - 1);
      }
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 批量标记所有通知为已读
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // 更新本地状态
      state = state.copyWith(
        notifications: state.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList(),
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 置顶通知
  Future<void> markAsTop(int notificationId) async {
    try {
      await _notificationService.markAsTop(notificationId);
      
      // 更新本地状态
      state = state.copyWith(
        notifications: state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isTop: true);
          }
          return notification;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 取消置顶通知
  Future<void> cancelTop(int notificationId) async {
    try {
      await _notificationService.cancelTop(notificationId);
      
      // 更新本地状态
      state = state.copyWith(
        notifications: state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isTop: false);
          }
          return notification;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 归档通知
  Future<void> archiveNotification(int notificationId) async {
    try {
      await _notificationService.archiveNotification(notificationId);
      
      // 从列表中移除归档的通知
      state = state.copyWith(
        notifications: state.notifications
            .where((notification) => notification.id != notificationId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 删除通知
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // 从列表中移除删除的通知
      state = state.copyWith(
        notifications: state.notifications
            .where((notification) => notification.id != notificationId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 搜索通知
  Future<void> searchNotifications(String keyword) async {
    if (_isLoading) return;
    
    _isLoading = true;
    
    try {
      state = state.copyWith(status: NotificationStatus.loading);
      
      final response = await _notificationService.searchNotifications(
        keyword: keyword,
        page: 1,
        size: 20,
      );
      
      final List<customNotification.Notification> notifications = (response['data']['content'] as List)
          .map((item) => customNotification.Notification.fromJson(item))
          .toList();
      
      final totalElements = response['data']['totalElements'] as int;
      final totalPages = response['data']['totalPages'] as int;
      
      state = state.copyWith(
        notifications: notifications,
        totalElements: totalElements,
        totalPages: totalPages,
        status: NotificationStatus.success,
      );
      
      _currentPage = 2;
      _hasMore = _currentPage <= totalPages;
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }
}

// 通知状态枚举
enum NotificationStatus {
  initial,
  loading,
  success,
  error,
}

// 通知状态类
class NotificationState {
  final List<customNotification.Notification> notifications;
  final int unreadCount;
  final int totalElements;
  final int totalPages;
  final NotificationStatus status;
  final String? errorMessage;

  NotificationState({
    required this.notifications,
    required this.unreadCount,
    required this.totalElements,
    required this.totalPages,
    required this.status,
    this.errorMessage,
  });

  // 初始状态
  factory NotificationState.initial() {
    return NotificationState(
      notifications: [],
      unreadCount: 0,
      totalElements: 0,
      totalPages: 0,
      status: NotificationStatus.initial,
      errorMessage: null,
    );
  }

  // 复制状态
  NotificationState copyWith({
    List<customNotification.Notification>? notifications,
    int? unreadCount,
    int? totalElements,
    int? totalPages,
    NotificationStatus? status,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
