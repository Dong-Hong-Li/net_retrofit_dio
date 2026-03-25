// 示例 1：@Get / @Post、@Body、@StreamResponse、[CallOptions]。
// 运行 build_runner 生成 demo_server.g.dart。

import 'dart:convert';

import 'package:net_retrofit_dio/net_retrofit_dio.dart';

import 'demo_model.dart';

part 'demo_server.g.dart';

typedef OnStreamLine = void Function(String line);

@NetApi()
abstract class DemoServer {
  @Post('/post')
  Future<DemoModel?> login(
    @Body() Map<String, dynamic> body, [
    CallOptions? options,
  ]);

  @Get('/get')
  Future<DemoModel?> getUserInfo([CallOptions? options]);

  @Post('/post')
  Future<DemoModel?> googleLogin(
    @Body() Map<String, dynamic> body, [
    CallOptions? options,
  ]);

  /// httpbin 返回 Map，此处用 Map 承接便于演示。
  @Post('/post')
  Future<Map<String, dynamic>?> saveArchives(
    @Body() Map<String, dynamic> body, [
    CallOptions? options,
  ]);

  @Get('/stream/3')
  @StreamResponse()
  Future<Stream<String>> getStreamLines([CallOptions? options]);
}

class DemoRepository {
  static DemoRepository get instance => DemoRepository._();

  DemoRepository._();
  final _mapper = DemoServerImpl();

  Future<DemoModel?> getUserInfo([CallOptions? options]) async {
    try {
      return await _mapper.getUserInfo(options);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> saveArchives(
    Map<String, dynamic> body, [
    CallOptions? options,
  ]) async {
    try {
      return await _mapper.saveArchives(body, options);
    } catch (e) {
      return null;
    }
  }

  Future<bool> login(String mobile, String googleToken,
      [CallOptions? options]) async {
    try {
      await _mapper.login({'phone': mobile}, options);
      await _mapper.googleLogin({'google_token': googleToken}, options);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> fetchStreamLines([CallOptions? options]) async {
    final stream = await _mapper.getStreamLines(options);
    final lines = <String>[];
    await for (final line in stream) {
      if (line.trim().isNotEmpty) lines.add(line);
    }
    return lines;
  }

  Future<void> forEachStreamLine({
    CallOptions? options,
    required OnStreamLine onLine,
  }) async {
    final stream = await _mapper.getStreamLines(options);
    await for (final line in stream) {
      if (line.trim().isNotEmpty) onLine(line);
    }
  }
}
