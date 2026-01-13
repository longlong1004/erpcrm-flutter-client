import 'package:logger/logger.dart';

/// 单例日志服务
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  late Logger _logger;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal() {
    // 配置日志格式
    _logger = Logger(
      filter: DevelopmentFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: null,
    );
  }

  /// 单例实例
  static Logger get logger {
    return _instance._logger;
  }

  /// 调试日志
  static void debug(dynamic message) {
    logger.d(message);
  }

  /// 信息日志
  static void info(dynamic message) {
    logger.i(message);
  }

  /// 警告日志
  static void warning(dynamic message) {
    logger.w(message);
  }

  /// 错误日志
  static void error(dynamic message) {
    logger.e(message);
  }

  /// 详细日志
  static void verbose(dynamic message) {
    logger.t(message);
  }
}
