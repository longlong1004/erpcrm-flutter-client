import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/storage.dart';
import '../providers/auth_provider.dart';
import './logger_service.dart';

class HttpClient {
  static Dio? _dio;
  static dynamic _ref;

  /// 确保HTTP客户端已初始化
  static void _ensureInitialized() {
    if (_dio == null) {
      _ref = ProviderContainer();
      // 创建Dio实例
      _dio = Dio(BaseOptions(
        baseUrl: 'http://${const String.fromEnvironment('API_BASE_URL', defaultValue: 'localhost:8082')}', // 从环境变量获取或使用默认值，后端已配置/api上下文路径
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        contentType: 'application/json; charset=utf-8',
        responseType: ResponseType.json,
      ));

      // 添加请求拦截器
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加认证令牌
          final token = await StorageManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // 打印请求日志
          LoggerService.info('''
📤 Request:
  URL: ${options.uri}
  Method: ${options.method}
  Headers: ${options.headers}
  Data: ${options.data}
''');

          return handler.next(options);
        },
      ));

      // 添加响应拦截器
      _dio!.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) {
          // 打印响应日志
          LoggerService.info('''
📥 Response:
  URL: ${response.requestOptions.uri}
  Status: ${response.statusCode}
  Data: ${response.data}
''');

          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // 打印错误日志
          LoggerService.error('''
❌ Error:
  URL: ${error.requestOptions.uri}
  Status: ${error.response?.statusCode}
  Message: ${error.message}
  Data: ${error.response?.data}
''');

          // 处理401未授权错误，尝试刷新令牌
          if (error.response?.statusCode == 401) {
            try {
              // 调用刷新令牌接口
              final authNotifier = _ref.read(authProvider.notifier);
              await authNotifier.refreshToken();

              // 重新发起请求
              final token = await StorageManager.getToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio!.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (refreshError) {
              // 刷新令牌失败，清除认证信息并跳转到登录页
              await StorageManager.clearAuthInfo();
              // 这里可以通过事件总线或其他方式通知UI跳转到登录页
            }
          }

          return handler.next(error);
        },
      ));
    }
  }

  /// 初始化HTTP客户端
  static Future<void> init([Ref? ref]) async {
    _ref = ref ?? ProviderContainer();
    _ensureInitialized();
  }

  /// GET请求
  static Future<Response> get(
    String path,
    {Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    return await _dio!.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST请求
  static Future<Response> post(
    String path,
    {dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    return await _dio!.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT请求
  static Future<Response> put(
    String path,
    {dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    return await _dio!.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE请求
  static Future<Response> delete(
    String path,
    {dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    return await _dio!.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH请求
  static Future<Response> patch(
    String path,
    {dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    return await _dio!.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 上传文件
  static Future<Response> upload(
    String path,
    FormData data,
    {Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    return await _dio!.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(
        contentType: 'multipart/form-data',
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 下载文件
  static Future<Response> download(
    String urlPath,
    String savePath,
    {Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _ensureInitialized();
    return await _dio!.download(
      urlPath,
      savePath,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 获取Dio实例
  static Dio get instance {
    _ensureInitialized();
    return _dio!;
  }
}
