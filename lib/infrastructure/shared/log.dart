import 'package:logger/logger.dart';

class Log {
  static final Logger _instance = Logger();

  static void info(message, [Object? error, StackTrace? stackTrace]) {
    _instance.i(message, error, stackTrace);
  }

  static void warning(message, [Object? error, StackTrace? stackTrace]) {
    _instance.w(message, error, stackTrace);
  }

  static void error(message, [Object? error, StackTrace? stackTrace]) {
    _instance.e(message, error, stackTrace);
  }
}
