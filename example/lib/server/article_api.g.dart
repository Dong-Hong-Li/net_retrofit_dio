// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class ArticleApiImpl implements ArticleApi {
  @override
  Future<ArticleModel?> create(Map<String, dynamic> body) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/post',
      method: HttpMethod.post,
      body: body,
    );
    return ArticleModel.fromJson((response.data as Map<String, dynamic>)["json"]
        as Map<String, dynamic>);
  }

  @override
  Future<ArticleModel?> createWithModel(CreateArticleRequest body) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/post',
      method: HttpMethod.post,
      body: body.toJson(),
    );
    return ArticleModel.fromJson((response.data as Map<String, dynamic>)["json"]
        as Map<String, dynamic>);
  }

  @override
  Future<ArticleModel?> createWithModelOptional(
      CreateArticleRequest? body) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/post',
      method: HttpMethod.post,
      body: body?.toJson(),
    );
    return ArticleModel.fromJson((response.data as Map<String, dynamic>)["json"]
        as Map<String, dynamic>);
  }

  @override
  Future<ArticleModel?> update(Map<String, dynamic> body) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/put',
      method: HttpMethod.put,
      body: body,
    );
    return ArticleModel.fromJson((response.data as Map<String, dynamic>)["json"]
        as Map<String, dynamic>);
  }

  @override
  Future<ArticleModel?> updateWithModel(UpdateArticleRequest body) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/put',
      method: HttpMethod.put,
      body: body.toJson(),
    );
    return ArticleModel.fromJson((response.data as Map<String, dynamic>)["json"]
        as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>?> delete(String id) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl()}/anything/$id',
      method: HttpMethod.delete,
    );
    return response.data as Map<String, dynamic>;
  }
}
