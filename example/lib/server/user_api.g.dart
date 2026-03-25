// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class UserApiImpl implements UserApi {
  @override
  Future<UserModel?> getList(int page, int size) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/get',
      method: HttpMethod.get,
      queryParameters: {'page': page, 'size': size},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel?> getById(String id) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/anything/$id',
      method: HttpMethod.get,
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel?> getWithAuth(String token) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/get',
      method: HttpMethod.get,
      headers: {'Authorization': token},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel?> getByQuery(Map<String, dynamic> query) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/get',
      method: HttpMethod.get,
      queryParameters: query,
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
