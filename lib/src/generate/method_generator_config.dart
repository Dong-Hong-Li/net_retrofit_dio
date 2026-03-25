// Generated according to lib/src/generate/annotations.dart and
// the INetClient.request contract.
// For each abstract method annotated with @Get/@Post/@Put/@Delete,
// the generator builds implementation code from this config.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import '../network/http_method.dart';
import '../network/net_content_type.dart';
import 'package:source_gen/source_gen.dart';

/// Per-method generation config that maps directly to [annotations.dart]
/// and [NetRequest.request].
///
/// The generator builds [url] from [path], [pathParams], and baseUrl;
/// maps [method] to [HttpMethod];
/// [queryParam]/[queryKeyParams] -> queryParameters;
/// [bodyParam]/[partParams] -> body;
/// [headerParams] -> headers;
/// [contentType], [clientKey], [parserConfig], and [stream] map to the
/// remaining [NetRequest.request] arguments.
class MethodGeneratorConfig {
  const MethodGeneratorConfig({
    required this.path,
    required this.method,
    this.contentType,
    this.clientKey,
    required this.stream,
    this.queryParam,
    this.queryKeyParams = const {},
    this.bodyParam,
    this.partParams = const {},
    this.headerParams = const {},
    this.pathParams = const {},
    required this.parserConfig,
  });

  // ========================== From @Get/@Post/@Put/@Delete ==========================

  /// Relative path used to build [url] with baseUrl.
  /// Supports placeholders like `/user/{id}` replaced by [pathParams].
  final String path;

  /// Request method, mapped to [HttpMethod].
  final HttpMethod method;

  /// Request content type from [HttpMethodAnnotation.contentType].
  /// Null means default [ContentType.json].
  final ContentType? contentType;

  // ========================== From @NetApi ==========================

  /// Maps from [NetApi.client], i.e. [NetRequest.request] [clientKey].
  /// Null: omit [clientKey] (default [_dio] stack; [NetRequest.resolveBaseUrl]\(\)).
  final String? clientKey;

  // ========================== From @StreamResponse ==========================

  /// Whether this is a stream request.
  /// If true, generator passes `responseType: ResponseType.stream` to [NetRequest.request].
  final bool stream;

  // ========================== From @Query / @QueryKey ==========================

  /// Parameter name of full query map ([Query]).
  /// When present, [NetRequest.request] queryParameters is assigned directly to it.
  final String? queryParam;

  /// Mapping from query key to method parameter name
  /// ([QueryKey(name)] -> parameter name), merged into queryParameters.
  final Map<String, String> queryKeyParams;

  // ========================== From @Body / @Part ==========================

  /// Parameter name used as request body ([Body]).
  /// With formData, composition with [partParams] follows generator rules.
  final String? bodyParam;

  /// Mapping from part name to parameter name
  /// ([Part(name)] -> parameter name), used for multipart/form-data.
  final Map<String, String> partParams;

  // ========================== From @Header / @Path ==========================

  /// Mapping from header name to parameter name
  /// ([Header(name)] -> parameter name).
  final Map<String, String> headerParams;

  /// Mapping from path placeholder name to parameter name
  /// (`{name}` in path -> parameter name).
  final Map<String, String> pathParams;

  // ========================== Parser config ==========================

  /// Parsing config used to generate return statements from [Response.data].
  final ParserGeneratorConfig parserConfig;

  static const _httpMethodNames = {'Get', 'Post', 'Put', 'Delete'};

  /// Builds a normalized type name from [InterfaceType].element.name and
  /// typeArguments to avoid spacing artifacts from [getDisplayString].
  static String _returnTypeNameFromType(DartType type) {
    DartType t = type;
    if (t is InterfaceType) {
      final it = t;
      final name = it.element.name ?? '';
      if ((name == 'Future' || name == 'Stream') &&
          it.typeArguments.length == 1) {
        return _returnTypeNameFromType(it.typeArguments.first);
      }
      if (it.typeArguments.isEmpty) return name;
      final args = it.typeArguments.map(_returnTypeNameFromType).join(', ');
      return '$name<$args>';
    }
    return t.getDisplayString();
  }

  /// Builds [MethodGeneratorConfig] from method and class-level [NetApi]
  /// annotations.
  factory MethodGeneratorConfig.generateMethodGeneratorConfig(
    MethodElement method,
    ConstantReader netApiAnnotation,
  ) {
    final clientKey = netApiAnnotation.peek('client')?.stringValue;
    final effectiveClientKey =
        (clientKey != null && clientKey.isNotEmpty) ? clientKey : null;

    String path = '';
    HttpMethod httpMethod = HttpMethod.get;
    ContentType? contentType;
    bool stream = false;
    String? dataPath;

    for (final ann in method.metadata.annotations) {
      final name = ann.element?.enclosingElement?.name;
      if (name == null) continue;
      final obj = ann.computeConstantValue();
      if (obj == null) continue;
      final reader = ConstantReader(obj);
      if (_httpMethodNames.contains(name)) {
        path = reader.peek('path')?.stringValue ?? '';
        final ct = reader.peek('contentType');
        if (ct != null && !ct.isNull && ct.isInt) {
          final idx = ct.intValue;
          if (idx >= 0 && idx < ContentType.values.length) {
            contentType = ContentType.values[idx];
          }
        }
        switch (name) {
          case 'Get':
            httpMethod = HttpMethod.get;
            break;
          case 'Post':
            httpMethod = HttpMethod.post;
            break;
          case 'Put':
            httpMethod = HttpMethod.put;
            break;
          case 'Delete':
            httpMethod = HttpMethod.delete;
            break;
        }
      } else if (name == 'StreamResponse') {
        stream = true;
      } else if (name == 'DataPath') {
        dataPath = reader.peek('path')?.stringValue;
      }
    }

    Map<String, String> queryKeyParams = {};
    Map<String, String> partParams = {};
    Map<String, String> headerParams = {};
    Map<String, String> pathParams = {};
    String? queryParam;
    String? bodyParam;

    for (final p in method.formalParameters) {
      for (final ann in p.metadata.annotations) {
        final n = ann.element?.enclosingElement?.name;
        if (n == null) continue;
        final obj = ann.computeConstantValue();
        if (obj == null) continue;
        final reader = ConstantReader(obj);
        final paramName = p.name ?? p.displayName;
        switch (n) {
          case 'Query':
            queryParam = paramName;
            break;
          case 'QueryKey':
            final key = reader.peek('name')?.stringValue;
            if (key != null) queryKeyParams[key] = paramName;
            break;
          case 'Body':
            bodyParam = paramName;
            break;
          case 'Part':
            final partName = reader.peek('name')?.stringValue;
            if (partName != null) partParams[partName] = paramName;
            break;
          case 'Header':
            final headerName = reader.peek('name')?.stringValue;
            if (headerName != null) headerParams[headerName] = paramName;
            break;
          case 'Path':
            final pathName = reader.peek('name')?.stringValue;
            if (pathName != null) pathParams[pathName] = paramName;
            break;
        }
      }
    }

    final returnTypeName = _returnTypeNameFromType(method.returnType);

    return MethodGeneratorConfig(
      path: path,
      method: httpMethod,
      contentType: contentType,
      clientKey: effectiveClientKey,
      stream: stream,
      queryParam: queryParam,
      queryKeyParams: queryKeyParams,
      bodyParam: bodyParam,
      partParams: partParams,
      headerParams: headerParams,
      pathParams: pathParams,
      parserConfig: ParserGeneratorConfig(
        dataPath: dataPath,
        returnTypeName: returnTypeName,
      ),
    );
  }
}

/// Parser generation config from method-level [DataPath] and method return type.
class ParserGeneratorConfig {
  const ParserGeneratorConfig({
    this.dataPath,
    required this.returnTypeName,
  });

  /// Parse from `response.data` map key. Null means whole [Response.data].
  final String? dataPath;

  /// Method return type (e.g. `UserModel` from `Future<UserModel>`).
  final String returnTypeName;
}
