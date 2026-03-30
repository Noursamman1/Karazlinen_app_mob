import 'package:dio/dio.dart';

import 'package:karaz_linen_app/core/config/app_config.dart';
import 'package:karaz_linen_app/core/logging/app_logger.dart';
import 'package:karaz_linen_app/core/network/api_result.dart';

class AppHttpClient {
  AppHttpClient({
    required AppConfig config,
    required AppLogger logger,
    Dio? dio,
  })  : _logger = logger,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: config.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              headers: <String, Object?>{
                'Accept': 'application/json',
              },
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          _logger.info('http_request', context: <String, Object?>{
            'method': options.method,
            'path': options.path,
          });
          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          _logger.error(
            'http_error',
            error: error,
            context: <String, Object?>{
              'path': error.requestOptions.path,
              'statusCode': error.response?.statusCode,
            },
          );
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final AppLogger _logger;

  Dio get raw => _dio;

  Future<ApiResult<Map<String, dynamic>>> getJson(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return ApiSuccess<Map<String, dynamic>>(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      return ApiError<Map<String, dynamic>>(
        ApiFailure(
          code: error.response?.data is Map<String, dynamic> ? (error.response?.data['code']?.toString() ?? 'HTTP_ERROR') : 'HTTP_ERROR',
          message: error.message ?? 'Unexpected network error',
          statusCode: error.response?.statusCode,
          retryable: error.type == DioExceptionType.connectionError || error.type == DioExceptionType.receiveTimeout,
        ),
      );
    }
  }
}
