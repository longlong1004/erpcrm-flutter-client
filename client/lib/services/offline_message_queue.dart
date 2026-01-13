import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message/message.dart';
import '../services/network_service.dart';
import '../services/websocket_service.dart';
import '../utils/storage.dart';

class OfflineMessageQueue {
  static final OfflineMessageQueue _instance = OfflineMessageQueue._internal();
  factory OfflineMessageQueue() => _instance;
  OfflineMessageQueue._internal();

  late Box<Message> _messageQueue;
  late Box<Message> _sentMessagesBox;
  final NetworkService _networkService = NetworkService();
  final WebSocketService _webSocketService = WebSocketService();
  bool _isProcessing = false;
  StreamController<Message>? _pendingMessagesController;

  Stream<Message> get pendingMessages {
    _pendingMessagesController ??= StreamController<Message>.broadcast();
    return _pendingMessagesController!.stream;
  }

  Future<void> initialize() async {
    Hive.registerAdapter(MessageAdapter());
    _messageQueue = await Hive.openBox<Message>('offline_message_queue');
    _sentMessagesBox = await Hive.openBox<Message>('sent_messages');

    _networkService.connectionStream.listen((isConnected) {
      if (isConnected) {
        processQueue();
      }
    });
  }

  Future<void> enqueueMessage(Message message) async {
    final offlineMessage = message.copyWith(
      status: MessageStatus.SENDING,
      isOffline: true,
      createdAt: DateTime.now(),
    );

    await _messageQueue.add(offlineMessage);
    _pendingMessagesController?.add(offlineMessage);
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;

    final isConnected = await _networkService.isConnected();
    if (!isConnected) return;

    _isProcessing = true;

    try {
      final messages = _messageQueue.values.toList();

      for (final message in messages) {
        try {
          await _webSocketService.sendMessage(message);

          await _messageQueue.delete(message.id);

          final sentMessage = message.copyWith(
            status: MessageStatus.SENT,
            isOffline: false,
          );

          await _sentMessagesBox.put(message.id, sentMessage);
        } catch (e) {
          print('Failed to send message: $e');
        }
      }
    } catch (e) {
      print('Error processing message queue: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> removeMessage(int messageId) async {
    await _messageQueue.delete(messageId);
  }

  Future<void> clearQueue() async {
    await _messageQueue.clear();
  }

  Future<List<Message>> getPendingMessages() async {
    return _messageQueue.values.toList();
  }

  Future<int> getQueueSize() async {
    return _messageQueue.length;
  }

  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    final message = _messageQueue.get(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(status: status);
      await _messageQueue.put(messageId, updatedMessage);
    }
  }
}
