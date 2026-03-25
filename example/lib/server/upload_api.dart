// 示例 4：multipart + @Part，独立 lane `upload`（见 main 中 NetRequest.open）。

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:net_retrofit_dio/net_retrofit_dio.dart';

part 'upload_api.g.dart';

@NetApi(client: 'upload')
abstract class UploadApi {
  @Post('/post', contentType: ContentType.formData)
  Future<Map<String, dynamic>?> upload(
    @Part('file') File file,
    @Part('name') String name,
  );
}
