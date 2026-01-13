import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';
import '../services/offline_message_queue.dart';
import '../providers/message_sync_provider.dart';

/// WebSocket服务提供者
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final wsService = WebSocketService();
  wsService.initialize();
  return wsService;
});

/// 离线消息队列服务提供者
final offlineMessageQueueProvider = Provider<OfflineMessageQueue>((ref) {
  final queue = OfflineMessageQueue();
  queue.initialize();
  return queue;
});

/// 消息同步状态提供者
final messageSyncProvider = StateNotifierProvider<MessageSyncNotifier, MessageSyncState>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  final offlineQueue = ref.watch(offlineMessageQueueProvider);
  return MessageSyncNotifier(wsService, offlineQueue);
});

/// WebSocket连接状态提供者
final webSocketConnectionProvider = StreamProvider<bool>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.connectionStatusStream;
});

/// WebSocket消息流提供者
final webSocketMessageProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.messageStream;
});
