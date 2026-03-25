// 示例 3：POST/PUT/DELETE、@Body（Map / 模型）、@Path。
// httpbin 回显在 `json` 字段，用 @DataPath('json') 解析。

import 'package:net_retrofit_dio/net_retrofit_dio.dart';

import 'article_model.dart';

part 'article_api.g.dart';

@NetApi()
abstract class ArticleApi {
  @Post('/post')
  @DataPath('json')
  Future<ArticleModel?> create(@Body() Map<String, dynamic> body);

  @Post('/post')
  @DataPath('json')
  Future<ArticleModel?> createWithModel(@Body() CreateArticleRequest body);

  @Post('/post')
  @DataPath('json')
  Future<ArticleModel?> createWithModelOptional(
      @Body() CreateArticleRequest? body);

  @Put('/put')
  @DataPath('json')
  Future<ArticleModel?> update(@Body() Map<String, dynamic> body);

  @Put('/put')
  @DataPath('json')
  Future<ArticleModel?> updateWithModel(@Body() UpdateArticleRequest body);

  /// httpbin 返回 JSON Map，不用 bool 强转。
  @Delete('/anything/{id}')
  Future<Map<String, dynamic>?> delete(@Path('id') String id);
}
