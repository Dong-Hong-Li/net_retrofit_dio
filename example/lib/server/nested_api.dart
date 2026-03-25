// 示例 5：@DataPath — 从回显的 `json` 字段解析模型。

import 'package:net_retrofit_dio/net_retrofit_dio.dart';

import 'nested_model.dart';

part 'nested_api.g.dart';

@NetApi()
abstract class NestedApi {
  @Post('/post')
  @DataPath('json')
  Future<NestedModel?> postNested(@Body() Map<String, dynamic> body);
}
