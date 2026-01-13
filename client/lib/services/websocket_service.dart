import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'network_service.dart';
import 'config_service.dart';

/// WebSocket服务，用于处理服务器实时数据推送
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final NetworkService _networkService = NetworkService();
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isReconnecting = false;
  bool _isInitialized = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectInterval = Duration(seconds: 5);

  // 订阅管理器
  final Map<String, List<Function(dynamic)>> _subscribers = {};
  // 连接状态流
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  // 数据变更流
  final StreamController<DataChangeEvent> _dataChangeController = StreamController<DataChangeEvent>.broadcast();
  // 消息流
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();

  /// 初始化WebSocket服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 监听网络状态变化
    _networkService.connectionStream.listen((isConnected) {
      if (isConnected) {
        _connect();
      } else {
        _disconnect();
      }
    });

    _isInitialized = true;
    print('WebSocketService initialized');

    // 如果当前有网络连接，立即连接
    if (await _networkService.isConnected()) {
      _connect();
    }
  }

  /// 连接WebSocket服务器
  void _connect() {
    if (_isConnected || _isReconnecting) return;

    _isReconnecting = true;
    
    try {
      // 使用配置服务获取WebSocket URL，避免硬编码
      final configService = ConfigService();
      final wsUrl = configService.getWebSocketUrl();
      print('Connecting to WebSocket: $wsUrl');
      
      // 创建WebSocket连接
      _channel = IOWebSocketChannel.connect(wsUrl);
      
      // 监听连接状态
      _channel?.ready.then((_) {
        _isConnected = true;
        _isReconnecting = false;
        _reconnectAttempts = 0;
        _connectionStatusController.add(true);
        print('WebSocket connected');
        
        // 启动心跳检测
        _startHeartbeat();
        
        // 监听消息
        _channel?.stream.listen(
          _handleMessage,
          onError: _handleError,
          onDone: _handleDone,
        );
        
        // 发送初始订阅
        _sendInitialSubscriptions();
      });
    } catch (e) {
      print('WebSocket connection failed: $e');
      _handleReconnect();
    }
  }

  /// 断开WebSocket连接
  void _disconnect() {
    _stopHeartbeat();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionStatusController.add(false);
    print('WebSocket disconnected');
  }

  /// 处理WebSocket消息
  void _handleMessage(dynamic message) {
    try {
      print('WebSocket received message: $message');
      
      final Map<String, dynamic> data = json.decode(message);
      final String type = data['type'];
      final dynamic payload = data['payload'];

      // 处理不同类型的消息
      switch (type) {
        case 'heartbeat':
          // 心跳响应，无需处理
          break;
        case 'data_change':
          // 数据变更通知
          _handleDataChange(payload);
          break;
        case 'error':
          // 错误消息
          _handleServerError(payload);
          break;
        default:
          print('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  /// 处理数据变更通知
  void _handleDataChange(dynamic payload) {
    try {
      final String dataType = payload['dataType'];
      final String operation = payload['operation'];
      final dynamic data = payload['data'];

      // 创建数据变更事件
      final event = DataChangeEvent(
        dataType: dataType,
        operation: operation,
        data: data,
        timestamp: DateTime.now(),
      );

      // 发送到数据变更流
      _dataChangeController.add(event);

      // 通知订阅者
      if (_subscribers.containsKey(dataType)) {
        for (final callback in _subscribers[dataType]!) {
          callback(event);
        }
      }

      // 通知所有订阅者
      if (_subscribers.containsKey('all')) {
        for (final callback in _subscribers['all']!) {
          callback(event);
        }
      }
    } catch (e) {
      print('Error handling data change: $e');
    }
  }

  /// 处理服务器错误
  void _handleServerError(dynamic payload) {
    print('WebSocket server error: $payload');
    // 可以添加错误处理逻辑，如显示错误消息
  }

  /// 处理WebSocket错误
  void _handleError(Object error, StackTrace stackTrace) {
    print('WebSocket error: $error');
    _handleReconnect();
  }

  /// 处理WebSocket连接关闭
  void _handleDone() {
    print('WebSocket connection closed');
    _isConnected = false;
    _connectionStatusController.add(false);
    _handleReconnect();
  }

  /// 处理重连
  void _handleReconnect() {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) return;

    _stopHeartbeat();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionStatusController.add(false);

    _reconnectAttempts++;
    print('WebSocket reconnect attempt $_reconnectAttempts of $_maxReconnectAttempts');

    _reconnectTimer = Timer(_reconnectInterval, () {
      _connect();
    });
  }

  /// 启动心跳检测
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _sendHeartbeat();
    });
  }

  /// 停止心跳检测
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 发送心跳消息
  void _sendHeartbeat() {
    if (_isConnected) {
      _channel?.sink.add(json.encode({'type': 'heartbeat'}));
    }
  }

  /// 发送初始订阅
  void _sendInitialSubscriptions() {
    // 订阅所有数据类型的变更
    final subscribeMessage = json.encode({
      'type': 'subscribe',
      'payload': {
        'dataTypes': ['all'],
      },
    });
    _channel?.sink.add(subscribeMessage);
  }

  /// 订阅数据类型
  void subscribe(String dataType, Function(dynamic) callback) {
    if (!_subscribers.containsKey(dataType)) {
      _subscribers[dataType] = [];
    }
    _subscribers[dataType]!.add(callback);
  }

  /// 取消订阅数据类型
  void unsubscribe(String dataType, Function(dynamic) callback) {
    if (_subscribers.containsKey(dataType)) {
      _subscribers[dataType]!.remove(callback);
      if (_subscribers[dataType]!.isEmpty) {
        _subscribers.remove(dataType);
      }
    }
  }

  /// 发布消息到服务器
  void publish(String type, dynamic payload) {
    if (_isConnected) {
      final message = json.encode({'type': type, 'payload': payload});
      _channel?.sink.add(message);
    }
  }

  /// 获取连接状态流
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// 获取数据变更流
  Stream<DataChangeEvent> get dataChangeStream => _dataChangeController.stream;

  /// 获取消息流
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 发送消息
  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final message = json.encode({
      'type': 'message',
      'payload': messageData,
    });

    _channel?.sink.add(message);
    print('Message sent: $message');
  }

  /// 订阅用户消息
  void subscribeToUser(int userId) {
    final subscribeMessage = json.encode({
      'type': 'subscribe_user',
      'payload': {
        'userId': userId,
      },
    });
    _channel?.sink.add(subscribeMessage);
    print('Subscribed to user: $userId');
  }

  /// 订阅群组消息
  void subscribeToGroup(int groupId) {
    final subscribeMessage = json.encode({
      'type': 'subscribe_group',
      'payload': {
        'groupId': groupId,
      },
    });
    _channel?.sink.add(subscribeMessage);
    print('Subscribed to group: $groupId');
  }

  /// 取消订阅用户消息
  void unsubscribeFromUser(int userId) {
    final unsubscribeMessage = json.encode({
      'type': 'unsubscribe_user',
      'payload': {
        'userId': userId,
      },
    });
    _channel?.sink.add(unsubscribeMessage);
    print('Unsubscribed from user: $userId');
  }

  /// 取消订阅群组消息
  void unsubscribeFromGroup(int groupId) {
    final unsubscribeMessage = json.encode({
      'type': 'unsubscribe_group',
      'payload': {
        'groupId': groupId,
      },
    });
    _channel?.sink.add(unsubscribeMessage);
    print('Unsubscribed from group: $groupId');
  }

  /// 标记消息为已读
  Future<void> markAsRead(String messageId) async {
    final message = json.encode({
      'type': 'mark_read',
      'payload': {
        'messageId': messageId,
      },
    });
    _channel?.sink.add(message);
    print('Message marked as read: $messageId');
  }

  /// 标记消息为已送达
  Future<void> markAsDelivered(String messageId, String deviceId) async {
    final message = json.encode({
      'type': 'mark_delivered',
      'payload': {
        'messageId': messageId,
        'deviceId': deviceId,
      },
    });
    _channel?.sink.add(message);
    print('Message marked as delivered: $messageId');
  }

  /// 处理消息相关WebSocket消息
  void _handleMessageMessage(dynamic message) {
    try {
      print('WebSocket received message: $message');

      final Map<String, dynamic> data = json.decode(message);
      final String type = data['type'];
      final dynamic payload = data['payload'];

      // 处理不同类型的消息
      switch (type) {
        case 'heartbeat':
          // 心跳响应，无需处理
          break;
        case 'data_change':
          // 数据变更通知
          _handleDataChange(payload);
          break;
        case 'error':
          // 错误消息
          _handleServerError(payload);
          break;
        case 'new_message':
          // 新消息通知
          _handleNewMessage(payload);
          break;
        case 'message_status':
          // 消息状态变更
          _handleMessageStatus(payload);
          break;
        case 'user_online':
          // 用户上线通知
          _handleUserOnline(payload);
          break;
        case 'user_offline':
          // 用户下线通知
          _handleUserOffline(payload);
          break;
        default:
          print('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  /// 处理新消息
  void _handleNewMessage(dynamic payload) {
    try {
      _messageController.add({
        'type': 'new_message',
        'payload': payload,
      });
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  /// 处理消息状态变更
  void _handleMessageStatus(dynamic payload) {
    try {
      _messageController.add({
        'type': 'message_status',
        'payload': payload,
      });
    } catch (e) {
      print('Error handling message status: $e');
    }
  }

  /// 处理用户上线
  void _handleUserOnline(dynamic payload) {
    try {
      _messageController.add({
        'type': 'user_online',
        'payload': payload,
      });
    } catch (e) {
      print('Error handling user online: $e');
    }
  }

  /// 处理用户下线
  void _handleUserOffline(dynamic payload) {
    try {
      _messageController.add({
        'type': 'user_offline',
        'payload': payload,
      });
    } catch (e) {
      print('Error handling user offline: $e');
    }
  }

  /// 关闭WebSocket服务
  void dispose() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _disconnect();
    _connectionStatusController.close();
    _dataChangeController.close();
    _messageController.close();
    _isInitialized = false;
  }
}

/// 数据变更事件
class DataChangeEvent {
  final String dataType;
  final String operation;
  final dynamic data;
  final DateTime timestamp;

  DataChangeEvent({
    required this.dataType,
    required this.operation,
    required this.data,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'DataChangeEvent{dataType: $dataType, operation: $operation, data: $data, timestamp: $timestamp}';
  }
}

/// WebSocket服务提供者
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final wsService = WebSocketService();
  wsService.initialize();
  return wsService;
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

/// WebSocket数据变更流提供者
final webSocketDataChangeProvider = StreamProvider<DataChangeEvent>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.dataChangeStream;
});
