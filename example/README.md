# 示例

演示根线路 + `upload` 线路、`build_runner` 生成的多种请求（含流式与 multipart），对接 `https://httpbin.org`。

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 修改过 lib/server/*.dart 时
flutter run
```

```bash
flutter test
```
