
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

class EnvConfig {
  final String appName;
  final String baseUrl;
  final bool shouldCollectCrashLog;
  late final Logger logger;
  final String baseUrlGooglePlace;

  EnvConfig({
    required this.appName,
    required this.baseUrl,
    this.shouldCollectCrashLog = false,
    required this.baseUrlGooglePlace,
  }) {
    logger = Logger(
      printer: PrettyPrinter(
          methodCount: AppConstants.loggerMethodCount,
          errorMethodCount: AppConstants.loggerErrorMethodCount,
          lineLength: AppConstants.loggerLineLength,
          colors: true,
          printEmojis: true,
          printTime: false // Should each log print contain a timestamp
          ),
      level: Logger.level,

    );
  }
}
