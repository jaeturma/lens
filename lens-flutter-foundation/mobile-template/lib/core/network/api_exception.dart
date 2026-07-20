import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException exception) {
    final response = exception.response;
    final data = response?.data;

    String message = 'Unable to complete the request.';
    if (data is Map<String, dynamic> && data['message'] is String) {
      message = data['message'] as String;
    } else if (exception.message != null && exception.message!.isNotEmpty) {
      message = exception.message!;
    }

    return ApiException(message: message, statusCode: response?.statusCode);
  }

  @override
  String toString() => message;
}
