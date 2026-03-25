// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nested_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class NestedApiImpl implements NestedApi {
  @override
  Future<NestedModel?> postNested(Map<String, dynamic> body) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/post',
      method: HttpMethod.post,
      body: body,
    );
    return NestedModel.fromJson((response.data as Map<String, dynamic>)["json"]
        as Map<String, dynamic>);
  }
}
