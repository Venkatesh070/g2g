import 'package:dio/dio.dart';

class CustomHttpException implements Exception {
  String? response;
  int? code;
  DioException exception;
  String? type;
  CustomHttpException(this.response, this.code, this.exception,this.type);
}