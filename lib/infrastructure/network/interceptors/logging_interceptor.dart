import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    logger.e('Error: ${err.error}, Message: ${err.message}');
    logger.e(
        'Error data : ${null != err.response!.data ? err.response!.data.toString() : ''}');
    return super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} Request => $requestPath');

    logger.i('Request Headers:', jsonEncode(options.headers));

    logger.i('Request Data : ${options.queryParameters.toString()}');
    logger.i('Request Data : ${options.data.toString()}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('StatusCode: ${response.statusCode}, Data: ${response.data}');
    return super.onResponse(response, handler);
  }
}
