import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/network_service.dart';

class NetworkStatusIndicator extends ConsumerStatefulWidget {
  const NetworkStatusIndicator({super.key});

  @override
  ConsumerState<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends ConsumerState<NetworkStatusIndicator> {
  bool _isConnected = true;
  late StreamSubscription<bool> _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeNetworkStatus();
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeNetworkStatus() async {
    final networkService = NetworkService();
    // 获取初始网络状态
    _isConnected = await networkService.isConnected();
    setState(() {});

    // 监听网络状态变化
    _connectionSubscription = networkService.connectionStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
      
      // 显示网络状态变化提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected ? '网络已连接' : '网络已断开，当前处于离线模式',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isConnected ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _isConnected ? Icons.wifi : Icons.wifi_off,
          color: _isConnected ? Colors.green : Colors.orange,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          _isConnected ? '在线' : '离线',
          style: TextStyle(
            color: _isConnected ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
