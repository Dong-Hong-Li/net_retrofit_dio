import 'package:dio/dio.dart';

import 'http_logger.dart';

/// Logging interceptor: Dio-style `*** Request/Response ***` blocks, optional cURL,
/// and path filtering ([HttpLogger.excludedPathSubstrings]), same idea as
/// `LogInterceptor` + `FilteredLogInterceptor` in app code.
///
/// Per-request switch: [Options.extra]\['enableLogging'\] (see [HttpLogger.shouldLog]).
class HttpLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!HttpLogger.shouldLogRequest(
        options.extra, options.uri, options.path)) {
      handler.next(options);
      return;
    }
    final headers = options.headers.map((k, v) => MapEntry(k, v.toString()));
    HttpLogger.logRequest(
      options.uri.toString(),
      options.method,
      headers,
      options.data,
      options.extra,
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final ro = response.requestOptions;
    if (!HttpLogger.shouldLogRequest(ro.extra, ro.uri, ro.path)) {
      handler.next(response);
      return;
    }
    final extra = ro.extra;
    final startTime = extra['startTime'];
    final timeInMillis = startTime is int
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;
    final headersMap = response.headers.map.entries
        .map((e) => MapEntry(e.key, e.value.join(', ')));
    HttpLogger.logResponse(
      ro.uri.toString(),
      response.statusCode ?? 0,
      Map.fromEntries(headersMap),
      response.data,
      timeInMillis,
      extra,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ro = err.requestOptions;
    if (!HttpLogger.shouldLogRequest(ro.extra, ro.uri, ro.path)) {
      handler.next(err);
      return;
    }
    HttpLogger.logError(
      ro.uri.toString(),
      err,
      err.stackTrace,
      ro.extra,
    );
    handler.next(err);
  }
}
