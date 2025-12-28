import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  AppException handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return AppException(message: 'Timeout', code: 408);
    }

    if (e.type == DioExceptionType.connectionError) {
      return AppException(message: 'No Internet', code: 0);
    }

    if (e.response != null) {
      final data = e.response?.data;
      return AppException(
        message: data?['message'] ?? 'Error',
        code: e.response?.statusCode ?? 500,
      );
    }

    return AppException(message: e.message ?? 'Unknown error', code: 0);
  }
}
