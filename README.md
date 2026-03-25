# net_retrofit_dio

[![GitHub](https://img.shields.io/badge/repo-Dong--Hong--Li%2Fnet__retrofit__dio-181717?logo=github)](https://github.com/Dong-Hong-Li/net_retrofit_dio)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

用 **注解描述接口**，用 **build_runner** 生成 `*Impl`，底层走 [Dio](https://pub.dev/packages/dio)。适合想把 HTTP 声明从业务里抽出去、又希望生成代码尽量直白的项目。

---

**English (short):** Annotation-driven HTTP client for Flutter: abstract API classes → generated implementations calling `NetRequest` + Dio. Multi-base-URL lanes via `NetRequest.open` / `@NetApi(client: …)`.

---

## 依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.0.0
  net_retrofit_dio: ^0.2.0   # 或 git / path

dev_dependencies:
  build_runner: ^2.4.0
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

入口：`import 'package:net_retrofit_dio/net_retrofit_dio.dart';`

## 一次初始化

```dart
NetRequest.prime(
  const NetOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ),
);
// 其它 Host / 超时（可选）
NetRequest.open('upload', const NetOptions(baseUrl: 'https://upload.example.com'));
```

`INetClient` 与 `NetOptions` 绑定在同一条线路里；具名线路在 `@NetApi(client: 'upload')` 里与 `open` / `plug` 的 id 对应。

## 声明与调用

```dart
part 'user_api.g.dart';

@NetApi()
abstract class UserApi {
  @Get('/user/info')
  Future<UserModel?> getUserInfo();

  @Post('/login')
  Future<AuthModel?> login(@Body() LoginRequest body);
}
```

```dart
final api = UserApiImpl();
await api.getUserInfo();
```

更完整的组合（query、path、header、multipart、流式等）见 [`example/`](example/)。

## 注解速览

| 标注 | 作用 |
|------|------|
| `@NetApi()` / `@NetApi(client: 'id')` | 抽象类；`client` 对应 `NetRequest.open` 的线路 id |
| `@Get` `@Post` `@Put` `@Delete` | 路径；可带 `contentType:`（如 `ContentType.formData`） |
| `@Body()` | 体；`Map` 直发，其它类型用 `toJson()` / `?.toJson()` |
| `@Query()` / `@QueryKey('k')` | 整表 query / 单个参数 |
| `@Path('id')` | 替换路径里的 `{id}` |
| `@Header('Name')` | 单个请求头 |
| `@Part('name')` | multipart 字段（常配合 formData）；`File` 会转成 `MultipartFile` |
| `@DataPath('key')` | 从 `response.data['key']` 再解析返回值 |
| `@StreamResponse()` | 流式响应（生成侧按行 `Stream<String>`） |
| `[CallOptions? options]` | 单次 `cancelToken` / `clientKey`；若方法已有命名参数则用 `{CallOptions? options}` |

`Future<List<T>>` 且 `T` 有 `fromJson` 时，生成器会按元素映射列表。

细节源码：`lib/src/generate/annotations.dart`、`lib/src/network/net_request.dart`。


## License

[MIT](LICENSE).
