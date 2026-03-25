// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_server.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class DemoServerImpl implements DemoServer {
  @override
  Future<DemoModel?> login(Map<String, dynamic> body,
      [CallOptions? options]) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/post',
      method: HttpMethod.post,
      body: body,
      clientKey: options?.clientKey,
      cancelToken: options?.cancelToken,
    );
    return DemoModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DemoModel?> getUserInfo([CallOptions? options]) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/get',
      method: HttpMethod.get,
      clientKey: options?.clientKey,
      cancelToken: options?.cancelToken,
    );
    return DemoModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DemoModel?> googleLogin(Map<String, dynamic> body,
      [CallOptions? options]) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/post',
      method: HttpMethod.post,
      body: body,
      clientKey: options?.clientKey,
      cancelToken: options?.cancelToken,
    );
    return DemoModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>?> saveArchives(Map<String, dynamic> body,
      [CallOptions? options]) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/post',
      method: HttpMethod.post,
      body: body,
      clientKey: options?.clientKey,
      cancelToken: options?.cancelToken,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Stream<String>> getStreamLines([CallOptions? options]) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/stream/3',
      method: HttpMethod.get,
      responseType: ResponseType.stream,
      clientKey: options?.clientKey,
      cancelToken: options?.cancelToken,
    );
    final stream = response.data?.stream;
    if (stream == null) return Stream.empty();
    return stream.transform(utf8.decoder).transform(const LineSplitter());
  }
}
