import 'package:dio/dio.dart';
import '../models/notification/notification.dart';
import '../utils/http_client.dart';

class NotificationService {
  final Dio _dio = HttpClient.instance;

  // 获取用户通知列表
  Future<Map<String, dynamic>> getUserNotifications({
    String? type,
    int? priority,
    bool? isRead,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {
          if (type != null) 'type': type,
          if (priority != null) 'priority': priority,
          if (isRead != null) 'isRead': isRead,
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('获取通知列表失败: $e');
    }
  }

  // 获取未读通知数量
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return response.data['data'];
    } catch (e) {
      throw Exception('获取未读通知数量失败: $e');
    }
  }

  // 标记通知为已读
  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } catch (e) {
      throw Exception('标记通知为已读失败: $e');
    }
  }

  // 批量标记所有通知为已读
  Future<void> markAllAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } catch (e) {
      throw Exception('批量标记通知为已读失败: $e');
    }
  }

  // 置顶通知
  Future<void> markAsTop(int notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/top');
    } catch (e) {
      throw Exception('置顶通知失败: $e');
    }
  }

  // 取消置顶通知
  Future<void> cancelTop(int notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/cancel-top');
    } catch (e) {
      throw Exception('取消置顶通知失败: $e');
    }
  }

  // 归档通知
  Future<void> archiveNotification(int notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/archive');
    } catch (e) {
      throw Exception('归档通知失败: $e');
    }
  }

  // 删除通知
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _dio.delete('/notifications/$notificationId');
    } catch (e) {
      throw Exception('删除通知失败: $e');
    }
  }

  // 获取通知详情
  Future<Notification> getNotificationDetail(int notificationId) async {
    try {
      final response = await _dio.get('/notifications/$notificationId');
      return Notification.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取通知详情失败: $e');
    }
  }

  // 搜索通知
  Future<Map<String, dynamic>> searchNotifications({
    required String keyword,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications/search',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('搜索通知失败: $e');
    }
  }
}
