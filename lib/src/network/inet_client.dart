import 'package:dio/dio.dart';

import 'http_logging_interceptor.dart';
import 'http_method.dart';
import 'net_content_type.dart';
import 'net_options.dart';

/// HTTP client abstraction, strongly bound to [NetOptions].
///
/// Every client carries its own [options] — the configuration that produced the
/// underlying transport.  Query → [queryParameters], body → [body];
/// [responseType] selects how Dio reads the body (see [ResponseType.json] vs
/// [ResponseType.stream]).  Annotation-driven codegen passes the appropriate
/// [responseType] and parses [Response.data].
abstract class INetClient {
  /// Network configuration this client was built from.
  NetOptions get options;

  /// Single entry for all HTTP calls; [responseType] controls buffering vs stream.
  Future<Response<T>> request<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    ContentType contentType = ContentType.json,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool enableLogging = false,
    CancelToken? cancelToken,
    ResponseType responseType = ResponseType.json,
  });
}

/// [INetClient] backed by a [Dio] instance, created from [NetOptions].
///
/// Register via [NetRequest.plug] or [NetRequest.open]; [NetRequest.cut]
/// removes a lane.
class DioNetClient implements INetClient {
  /// Creates a [DioNetClient] from [options], internally building a [Dio].
  factory DioNetClient(NetOptions options) =>
      DioNetClient._(options, createDio(options));

  /// Creates from an existing [Dio] and [options] — primarily for testing.
  DioNetClient.fromDio(this._options, Dio dio) : _dio = dio;

  DioNetClient._(this._options, this._dio);

  final NetOptions _options;
  final Dio _dio;

  @override
  NetOptions get options => _options;

  /// Underlying [Dio] (e.g. for tests or extra interceptors).
  Dio get dio => _dio;

  /// Builds a [Dio] from [options], adding [HttpLoggingInterceptor] and any
  /// interceptors declared in [NetOptions.interceptors].
  static Dio createDio(NetOptions options) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
        baseUrl: options.baseUrl,
      ),
    );
    dio.interceptors.add(HttpLoggingInterceptor());
    for (final interceptor in options.interceptors ?? <Interceptor>[]) {
      dio.interceptors.add(interceptor);
    }
    return dio;
  }

  static Map<String, dynamic> _extra(
    Map<String, dynamic>? extra,
    bool enableLogging,
  ) =>
      {
        'startTime': DateTime.now().millisecondsSinceEpoch,
        'enableLogging': enableLogging,
        ...?extra,
      };

  static Options _buildRequestOptions({
    required ContentType contentType,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    required bool enableLogging,
    required ResponseType responseType,
  }) {
    return Options(
      responseType: responseType,
      contentType: contentType.toStringType(),
      headers: headers,
      extra: _extra(extra, enableLogging),
    );
  }

  Future<Response<T>> _send<T>({
    required String url,
    required HttpMethod method,
    required Map<String, dynamic> q,
    dynamic body,
    required Options options,
    CancelToken? cancelToken,
  }) {
    switch (method) {
      case HttpMethod.get:
        return _dio.get<T>(
          url,
          queryParameters: q.isNotEmpty ? q : null,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.post:
        return _dio.post<T>(
          url,
          data: body,
          queryParameters: q.isNotEmpty ? q : null,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.put:
        return _dio.put<T>(
          url,
          data: body,
          queryParameters: q.isNotEmpty ? q : null,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.delete:
        return _dio.delete<T>(
          url,
          data: body,
          queryParameters: q.isNotEmpty ? q : null,
          options: options,
          cancelToken: cancelToken,
        );
    }
  }

  @override
  Future<Response<T>> request<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    ContentType contentType = ContentType.json,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool enableLogging = false,
    CancelToken? cancelToken,
    ResponseType responseType = ResponseType.json,
  }) {
    final opts = _buildRequestOptions(
      contentType: contentType,
      headers: headers,
      extra: extra,
      enableLogging: enableLogging,
      responseType: responseType,
    );
    final q = queryParameters ?? <String, dynamic>{};
    return _send<T>(
      url: url,
      method: method,
      q: q,
      body: body,
      options: opts,
      cancelToken: cancelToken,
    );
  }
}
