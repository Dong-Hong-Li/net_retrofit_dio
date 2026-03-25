import 'package:dio/dio.dart';

/// Network-layer configuration bound to every [INetClient].
///
/// Pass to [NetRequest.prime] or [NetRequest.open]; every [INetClient] exposes
/// its own [NetOptions] via [INetClient.options].  Same [id] in
/// `@NetApi(client: id)` is matched at runtime.
///
/// [interceptors] are appended in [DioNetClient.createDio] after
/// [HttpLoggingInterceptor].
class NetOptions {
  const NetOptions({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
    this.sendTimeout = const Duration(seconds: 60),
    this.interceptors,
  });

  /// Base URL.
  final String baseUrl;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  /// Send timeout.
  final Duration sendTimeout;

  /// Interceptor list compatible with Dio [Interceptor], appended in order
  /// after the default logging interceptor.
  final List<Interceptor>? interceptors;
}
