import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/message/message.dart';
import '../services/websocket_service.dart';
import '../services/offline_message_queue.dart';
import '../services/network_service.dart';
import '../utils/storage.dart';

class MessageSyncState {
  final List<Message> messages;
  final bool isLoading;
  final String? errorMessage;
  final Map<int, bool> onlineUsers;
  final int unreadCount;

  const MessageSyncState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onlineUsers = const {},
    this.unreadCount = 0,
  });

  MessageSyncState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? errorMessage,
    Map<int, bool>? onlineUsers,
    int? unreadCount,
  }) {
    return MessageSyncState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class MessageSyncNotifier extends StateNotifier<MessageSyncState> {
  final WebSocketService _webSocketService;
  final OfflineMessageQueue _offlineQueue;
  final NetworkService _networkService;
  late Box<Message> _messageBox;
  late Box<Message> _readStatusBox;
  int? _currentChatUserId;
  int? _currentGroupId;

  MessageSyncNotifier(this._webSocketService, this._offlineQueue, this._networkService)
      : super(const MessageSyncState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    Hive.registerAdapter(MessageAdapter());
    _messageBox = await Hive.openBox<Message>('messages');
    _readStatusBox = await Hive.openBox<String>('read_status');

    _loadMessages();
    _setupWebSocketListeners();
    _setupNetworkListeners();
  }

  void _loadMessages() {
    final messages = _messageBox.values.toList();
    state = state.copyWith(messages: messages);
    _updateUnreadCount();
  }

  void _setupWebSocketListeners() {
    _webSocketService.messageStream.listen((messageData) {
      final type = messageData['type'];
      final payload = messageData['payload'];

      switch (type) {
        case 'new_message':
          _handleNewMessage(payload);
          break;
        case 'message_status':
          _handleMessageStatus(payload);
          break;
        case 'user_online':
          _handleUserOnline(payload);
          break;
        case 'user_offline':
          _handleUserOffline(payload);
          break;
      }
    });
  }

  void _setupNetworkListeners() {
    _networkService.connectionStream.listen((isConnected) {
      if (isConnected) {
        _processOfflineQueue();
      }
    });
  }

  Future<void> sendMessage({
    required int receiverId,
    required String content,
    MessageType type = MessageType.TEXT,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    int? groupId,
  }) async {
    final currentUser = await StorageManager.getUserInfo();
    if (currentUser == null) {
      state = state.copyWith(errorMessage: '未登录');
      return;
    }

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUser['id'] as int,
      receiverId: receiverId,
      groupId: groupId,
      type: type,
      content: content,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      status: MessageStatus.SENDING,
      isRecalled: false,
      createdAt: DateTime.now(),
      deviceId: await _getDeviceId(),
      senderName: currentUser['name'] as String?,
      senderAvatar: currentUser['avatarUrl'] as String?,
      isOffline: false,
    );

    final isConnected = await _networkService.isConnected();

    if (isConnected) {
      try {
        await _webSocketService.sendMessage({
          'messageId': message.messageId,
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'groupId': message.groupId,
          'type': message.type.toString(),
          'content': message.content,
          'fileUrl': message.fileUrl,
          'fileName': message.fileName,
          'fileSize': message.fileSize,
          'deviceId': message.deviceId,
        });

        final sentMessage = message.copyWith(status: MessageStatus.SENT);
        await _saveMessage(sentMessage);
      } catch (e) {
        final failedMessage = message.copyWith(status: MessageStatus.SENDING);
        await _saveMessage(failedMessage);
        await _offlineQueue.enqueueMessage(failedMessage);
      }
    } else {
      await _offlineQueue.enqueueMessage(message);
    }
  }

  Future<void> markAsRead(String messageId) async {
    final isConnected = await _networkService.isConnected();

    if (isConnected) {
      await _webSocketService.markAsRead(messageId);
    }

    await _updateMessageStatus(messageId, MessageStatus.READ);
    await _readStatusBox.put(messageId, 'read');
    _updateUnreadCount();
  }

  Future<void> markAsDelivered(String messageId, String deviceId) async {
    await _webSocketService.markAsDelivered(messageId, deviceId);
    await _updateMessageStatus(messageId, MessageStatus.DELIVERED);
  }

  Future<void> recallMessage(String messageId) async {
    final message = _messageBox.values.firstWhere(
      (msg) => msg.messageId == messageId,
      orElse: () => throw Exception('消息不存在'),
    );

    final recalledMessage = message.copyWith(isRecalled: true);
    await _messageBox.put(message.id, recalledMessage);

    final isConnected = await _networkService.isConnected();
    if (isConnected) {
      await _webSocketService.sendMessage({
        'type': 'recall',
        'messageId': messageId,
      });
    }
  }

  Future<void> loadMessages({
    int? userId,
    int? groupId,
    int limit = 50,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      List<Message> filteredMessages = _messageBox.values.toList();

      if (userId != null) {
        filteredMessages = filteredMessages
            .where((msg) => msg.senderId == userId || msg.receiverId == userId)
            .toList();
      }

      if (groupId != null) {
        filteredMessages = filteredMessages
            .where((msg) => msg.groupId == groupId)
            .toList();
      }

      filteredMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final limitedMessages = filteredMessages.take(limit).toList();

      state = state.copyWith(
        messages: limitedMessages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void _handleNewMessage(dynamic payload) {
    try {
      final messageJson = payload as Map<String, dynamic>;
      final message = Message.fromJson(messageJson);

      final existingMessage = _messageBox.values.firstWhere(
        (msg) => msg.messageId == message.messageId,
        orElse: () => null,
      );

      if (existingMessage == null) {
        _saveMessage(message);
      } else {
        final updatedMessage = existingMessage.copyWith(
          status: message.status,
          readAt: message.readAt,
          deliveredAt: message.deliveredAt,
        );
        _messageBox.put(existingMessage.id, updatedMessage);
      }

      _updateUnreadCount();
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  void _handleMessageStatus(dynamic payload) {
    try {
      final messageId = payload['messageId'] as String;
      final statusStr = payload['status'] as String;
      final status = MessageStatus.values.firstWhere(
        (e) => e.toString() == statusStr,
        orElse: () => MessageStatus.SENDING,
      );

      _updateMessageStatus(messageId, status);
    } catch (e) {
      print('Error handling message status: $e');
    }
  }

  void _handleUserOnline(dynamic payload) {
    try {
      final userId = payload['userId'] as int;
      final onlineUsers = Map<int, bool>.from(state.onlineUsers);
      onlineUsers[userId] = true;
      state = state.copyWith(onlineUsers: onlineUsers);
    } catch (e) {
      print('Error handling user online: $e');
    }
  }

  void _handleUserOffline(dynamic payload) {
    try {
      final userId = payload['userId'] as int;
      final onlineUsers = Map<int, bool>.from(state.onlineUsers);
      onlineUsers[userId] = false;
      state = state.copyWith(onlineUsers: onlineUsers);
    } catch (e) {
      print('Error handling user offline: $e');
    }
  }

  Future<void> _saveMessage(Message message) async {
    await _messageBox.put(message.id, message);
    final messages = _messageBox.values.toList();
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(messages: messages);
  }

  Future<void> _updateMessageStatus(String messageId, MessageStatus status) async {
    final message = _messageBox.values.firstWhere(
      (msg) => msg.messageId == messageId,
      orElse: () => null,
    );

    if (message != null) {
      final updatedMessage = message.copyWith(status: status);
      await _messageBox.put(message.id, updatedMessage);

      final messages = _messageBox.values.toList();
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(messages: messages);
    }
  }

  void _updateUnreadCount() {
    final currentUser = StorageManager.getUserInfo();
    if (currentUser == null) return;

    final userId = currentUser['id'] as int;
    final unreadMessages = _messageBox.values.where((msg) {
      return (msg.receiverId == userId || msg.groupId != null) &&
          msg.status != MessageStatus.READ &&
          !msg.isRecalled;
    }).toList();

    state = state.copyWith(unreadCount: unreadMessages.length);
  }

  Future<void> _processOfflineQueue() async {
    await _offlineQueue.processQueue();
    final messages = _messageBox.values.toList();
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(messages: messages);
  }

  Future<String> _getDeviceId() async {
    if (kIsWeb) {
      return 'web_${DateTime.now().millisecondsSinceEpoch}';
    } else if (Platform.isAndroid) {
      return 'android_${DateTime.now().millisecondsSinceEpoch}';
    } else if (Platform.isIOS) {
      return 'ios_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      return 'windows_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
