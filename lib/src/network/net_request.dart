import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'http_method.dart';
import 'inet_client.dart';
import 'net_content_type.dart';
import 'net_options.dart';

/// HTTP entry: [prime] sets the global root [INetClient]; each lane [id] is
/// resolved **at runtime** from a single registry [_clients] keyed by string.
///
/// Every [INetClient] carries its own [NetOptions], so there is no separate
/// "blueprint" map — configuration and transport are always bound together.
///
/// - [plug] / [open] / [cut] are the only mutators.
/// - Non-[defaultLaneId]: first write only; change ⇒ [cut] first.
/// - [defaultLaneId]: [plug] / [open] may be replaced in place.
///
/// **Tests**: [injectDio] wraps a raw [Dio] in [DioNetClient] for the root.
class NetRequest {
  static INetClient? _root;

  /// `@NetApi(client: …)` string for the overridable default lane.
  static const String defaultLaneId = 'default';

  /// Lane id → [INetClient] (which already embeds [NetOptions]).
  static final Map<String, INetClient> _clients = {};

  static bool _isDefaultLane(String id) => id == defaultLaneId;

  // ─── Root ─────────────────────────────────────────

  /// Initialises the global root client from [options].
  static void prime(NetOptions options) {
    _root = DioNetClient(options);
  }

  /// Registers [client] for [id]. [client.options] is used for
  /// [resolveBaseUrl] and any other configuration queries.
  static void plug(String id, INetClient client) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (_isDefaultLane(id)) {
      _clients[id] = client;
      return;
    }
    if (_clients.containsKey(id)) {
      throw StateError(
        'Lane "$id" exists. NetRequest.cut("$id") first.',
      );
    }
    _clients[id] = client;
  }

  /// Sugar: creates a [DioNetClient] from [spec] and registers it for [id].
  static void open(String id, NetOptions spec) {
    plug(id, DioNetClient(spec));
  }

  /// Removes [id] from the registry.
  static void cut(String id) {
    _clients.remove(id);
  }

  // ─── Query ─────────────────────────────────────────

  /// The root [INetClient]; throws if [prime] has not been called.
  static INetClient get rootClient {
    final r = _root;
    if (r != null) return r;
    throw StateError('Call NetRequest.prime(NetOptions) first.');
  }

  /// Shorthand for `rootClient.options`.
  static NetOptions get rootSpec => rootClient.options;

  /// Returns the [NetOptions] for [id], or `null` if not registered.
  static NetOptions? optionsOf(String? id) {
    final k = _normalizeLaneId(id);
    return k != null ? _clients[k]?.options : null;
  }

  /// Returns the [INetClient] registered for [id], or `null`.
  static INetClient? transport(String? id) {
    final k = _normalizeLaneId(id);
    return k != null ? _clients[k] : null;
  }

  // ─── Request / URL (runtime match by [clientKey]) ─────────────────────────

  static String? _normalizeLaneId(String? clientKey) {
    if (clientKey != null && clientKey.isNotEmpty) return clientKey;
    return null;
  }

  static String resolveBaseUrl([String? clientKey]) {
    final k = _normalizeLaneId(clientKey);
    if (k != null) {
      final client = _clients[k];
      if (client != null) return client.options.baseUrl;
    }
    final root = _root;
    if (root != null) return root.options.baseUrl;
    if (k != null) {
      throw StateError(
        'Lane "$k": no client registered — '
        'NetRequest.open("$k", …) or plug("$k", …), or prime root.',
      );
    }
    throw StateError('NetRequest.prime(NetOptions) first.');
  }

  static INetClient _transportFor(String? clientKey) {
    final k = _normalizeLaneId(clientKey);

    if (k != null) {
      final c = _clients[k];
      if (c != null) return c;
      final root = _root;
      if (root != null) return root;
      throw StateError(
        'Lane "$k" has no client and root missing — prime or plug("$k", …).',
      );
    }

    final root = _root;
    if (root != null) return root;
    throw StateError('NetRequest.prime(NetOptions) first.');
  }

  static void addInterceptor(Interceptor interceptor) {
    _rootDio.interceptors.add(interceptor);
  }

  static void addInterceptors(List<Interceptor> interceptors) {
    _rootDio.interceptors.addAll(interceptors);
  }

  @visibleForTesting
  static void injectDio(Dio dio) {
    _root = DioNetClient.fromDio(
      NetOptions(baseUrl: dio.options.baseUrl),
      dio,
    );
  }

  @visibleForTesting
  static set dioInstance(Dio dio) => injectDio(dio);

  static Dio get _rootDio {
    final root = _root;
    if (root is DioNetClient) return root.dio;
    throw StateError(
      'Root client is not a DioNetClient. Cannot access underlying Dio.',
    );
  }

  static Dio get dio => _rootDio;

  static Future<Response<T>> request<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    ContentType contentType = ContentType.json,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool enableLogging = false,
    String? clientKey,
    CancelToken? cancelToken,
    ResponseType responseType = ResponseType.json,
  }) {
    final c = _transportFor(clientKey);
    return c.request<T>(
      url: url,
      method: method,
      queryParameters: queryParameters,
      body: body,
      contentType: contentType,
      headers: headers,
      extra: extra,
      enableLogging: enableLogging,
      cancelToken: cancelToken,
      responseType: responseType,
    );
  }
}
