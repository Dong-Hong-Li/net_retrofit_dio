/// Retrofit-style networking annotations and codegen contract.
///
/// Usage:
/// 1. [NetRequest.prime](NetOptions); optional [NetRequest.plug] / [NetRequest.open] per lane id.
/// 2. Annotate abstract classes with [NetApi] and methods with
///    [Get]/[Post]/[Put]/[Delete].
/// 3. Run build_runner to generate implementations (`*_impl.dart` or `.g.dart`).
/// 4. Generated code calls [NetRequest.request] and maps [Response.data].
library;

export 'package:dio/dio.dart' show Response, ResponseType;

export 'src/network/net_content_type.dart';
export 'src/network/http_error.dart';
export 'src/network/http_method.dart';
export 'src/network/inet_client.dart';
export 'src/network/call_options.dart';
export 'src/network/net_options.dart';
export 'src/network/net_request.dart';
export 'src/network/net_interceptor.dart';

//// ========================== Generator ==========================
export 'src/generate/annotations.dart';
