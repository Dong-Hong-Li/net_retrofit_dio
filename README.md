# net_retrofit_dio

基于 [Dio](https://pub.dev/packages/dio) 的 Retrofit 风格声明式 HTTP 客户端：**注解 + `build_runner` 生成实现**。

当前为**工程壳子**：已接通 `source_gen` / `build.yaml`，生成器仅输出占位注释，后续再补全方法与 Dio 调用生成逻辑。

## 布局

| 路径 | 说明 |
|------|------|
| `lib/net_retrofit_dio.dart` | 对外导出 |
| `lib/src/annotations.dart` | `@NetRetrofitDioApi` 等注解（会扩展） |
| `lib/src/generate/` | Builder 与代码生成器 |
| `build.yaml` | 注册 builder，产物为 `.g.dart`（经 combining） |

## 下游使用（预览）

在依赖此包的项目中：

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  net_retrofit_dio:
    path: ../net_retrofit_dio  # 或 git / pub 版本
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

## License

待定（与主仓库策略一致即可）。
