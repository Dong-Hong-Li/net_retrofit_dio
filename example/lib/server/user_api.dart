// 示例 2：@QueryKey、@Path、@Header、@Query。

import 'package:net_retrofit_dio/net_retrofit_dio.dart';

import 'user_model.dart';

part 'user_api.g.dart';

@NetApi()
abstract class UserApi {
  @Get('/get')
  Future<UserModel?> getList(
    @QueryKey('page') int page,
    @QueryKey('size') int size,
  );

  @Get('/anything/{id}')
  Future<UserModel?> getById(@Path('id') String id);

  @Get('/get')
  Future<UserModel?> getWithAuth(@Header('Authorization') String token);

  @Get('/get')
  Future<UserModel?> getByQuery(@Query() Map<String, dynamic> query);
}
