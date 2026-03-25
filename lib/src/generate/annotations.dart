// Aligned with lib/src/network [NetRequest.request] / [INetClient.request].
//
// Parameter mapping:
// url=baseUrl+path, method, queryParameters, body, headers, contentType,
// clientKey, and parser are generated from annotations and return type.
// cancelToken: from optional CancelToken? cancelToken, or from CallOptions? options.
// [CallOptions? options]: prefer optional positional so not confused with API params in {}.
// When method has other named params, use {CallOptions? options} (Dart disallows []+{} in one method).

import '../network/net_content_type.dart';

// ========================== Class-level ==========================

/// Applied to abstract classes to declare a Retrofit-style API interface.
///
/// The generator creates an implementation and calls [NetRequest.request]
/// (or [INetClient.request]); [@StreamResponse] passes
/// `responseType: ResponseType.stream`. Return values come from [Response.data].
/// Parameter mapping:
/// - [client] -> [clientKey] and [NetRequest.resolveBaseUrl]. If omitted, uses
///   [NetRequest.rootSpec] after [NetRequest.prime]. Other hosts: same [id] as
///   [NetRequest.plug] / [NetRequest.open] (runtime match).
class NetApi {
  const NetApi({this.client});

  /// Lane id: matched at runtime against [NetRequest.plug] / [NetRequest.open]
  /// (or [NetRequest.defaultLaneId]).
  /// Same value is passed to [NetRequest.resolveBaseUrl] and [NetRequest.request] as [clientKey].
  final String? client;
}

/// **Annotation mapping** (see `lib/src/generate/annotations.dart`):
/// | Interface parameter | Annotation / convention |
/// |------------|-------------|
/// | [url] | path from @Get/@Post/@Put/@Delete, concatenated with baseUrl |
/// | [method] | @Get -> get, @Post -> post, @Put -> put, @Delete -> delete |
/// | [queryParameters] | full @Query() map, merged with @QueryKey(name) entries |
/// | [body] | @Body() argument (toJson or Map) |
/// | [contentType] | from annotations such as @Get(..., contentType: ...) |
/// | [headers] | merged @Header(name) arguments |
/// | [extra] | no annotation, generator may omit |
/// | [enableLogging] | no annotation, generator defaults to false |
/// | [cancelToken] | optional CancelToken? cancelToken, or [CallOptions? options] (positional or named 'options') |
/// | [parser] | generated from return type + @DataPath |
/// | formData / file upload | [contentType]=formData, [body]=FormData/Map (file values use MultipartFile); @Part(name) can be merged into FormData |

/// ========================== Method-level: HTTP method + path ==========================

/// Base annotation for HTTP methods.
/// The generator uses [path] to build [url] and chooses [HttpMethod].
abstract class HttpMethodAnnotation {
  const HttpMethodAnnotation(this.path, {this.contentType});

  /// Relative path. Concatenated with baseUrl to build [NetRequest.request]
  /// [url].
  final String path;

  /// Maps to [NetRequest.request] [contentType].
  /// Null means default ContentType.json.
  final ContentType? contentType;
}

/// GET request -> method: HttpMethod.get, url: baseUrl + path.
class Get extends HttpMethodAnnotation {
  const Get(super.path, {super.contentType});
}

/// POST request -> method: HttpMethod.post, body maps to [NetRequest.request] [body].
class Post extends HttpMethodAnnotation {
  const Post(super.path, {super.contentType});
}

/// PUT request.
class Put extends HttpMethodAnnotation {
  const Put(super.path, {super.contentType});
}

/// DELETE request.
class Delete extends HttpMethodAnnotation {
  const Delete(super.path, {super.contentType});
}

// ========================== Method-level: response parsing ==========================

/// Parse model from response.data[path] instead of response.data.
///
/// The generator reads `(response.data as Map)[path]` before `T.fromJson`.
class DataPath {
  const DataPath(this.path);
  final String path;
}

/// Use for streaming backend responses (SSE/Stream): the generator should call
/// [NetRequest.request] with `responseType: ResponseType.stream`, then return stream
/// or convention.
///
/// Typical generation strategy:
/// - `Future<Stream<String>>`: use [SseStreamParser.parse](response.data!.stream)
///   for SSE, or utf8.decoder + LineSplitter for line-by-line parsing.
/// - `Future<Stream<List<int>>>`: return `response.data?.stream` directly.
/// Optional [CallOptions? options] (positional or named) is forwarded (cancelToken, clientKey).
///
/// ```dart
/// @Get('/stream')
/// @StreamResponse()
/// Future<Stream<String>> getStream([CallOptions? options]);
/// ```
///
/// The API library must import `dart:convert` (generated code uses [utf8] /
/// [LineSplitter]).
class StreamResponse {
  const StreamResponse();
}

// ========================== Parameter-level: body/query ==========================

/// Marks this parameter as request body -> [NetRequest.request] [body].
///
/// Can be [Map<String, dynamic>] or any class model.
/// If type is not Map, generator emits `param.toJson()`, so models must
/// implement [toJson].
class Body {
  const Body();
}

/// Marks one multipart/form-data field or file.
///
/// Works with [ContentType.formData], for example
/// @Post(path, contentType: ContentType.formData).
/// Multiple [Part] arguments are merged into [FormData] as [body].
/// If an argument type is File, generator should convert it to
/// [MultipartFile] before inserting into FormData.
/// You can also skip [Part] and pass [body] as Map or FormData directly.
///
/// ```dart
/// @Post('/upload', contentType: ContentType.formData)
/// Future<Result?> upload(@Part('file') File file, @Part('name') String name);
///
/// ```
class Part {
  const Part(this.name);
  final String name;
}

/// Marks this parameter as full query map -> [NetRequest.request] [queryParameters].
///
/// ```dart
/// @Get('/user')
/// Future<UserModel?> getUser(@Query() Map<String, dynamic> query);
///
/// request:
/// ?id=1&name=user1
/// ```
class Query {
  const Query();
}

/// Maps one parameter to one query key, merged into [NetRequest.request]
/// [queryParameters][name].
///
/// ```dart
/// @Get('/user')
/// Future<UserModel?> getUser(@QueryKey('id') int id);
///
/// request:
/// ?id=1&name=user1
/// ```
class QueryKey {
  const QueryKey(this.name);
  final String name;
}

// ========================== Parameter-level: optional extensions ==========================

/// Maps this parameter to one request header key -> [NetRequest.request] [headers][name].
///
/// ```dart
/// @Get('/user')
/// Future<UserModel?> getUser(@Header('Authorization') String token);
/// ```
class Header {
  const Header(this.name);
  final String name;
}

/// Path placeholder mapping:
/// `{name}` in method path is replaced by this argument, e.g.
/// @Get('/user/{id}') + @Path('id') int id.
///
/// ```dart
/// @Get('/user/{id}')
/// Future<UserModel?> getUser(@Path('id') int id);
/// ```
class Path {
  const Path(this.name);
  final String name;
}
