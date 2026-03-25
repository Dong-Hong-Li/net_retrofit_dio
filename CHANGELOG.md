# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-03-26

### Breaking changes

- **`INetClient`**: must implement **`applyNetOptions(NetOptions spec)`**.  
  Used when **`NetRequest.open(id, spec)`** is called while lane `id` already has a client (same instance is reconfigured instead of throwing).

### Migration

1. On every **`implements INetClient`** type, add:
   ```dart
   @override
   void applyNetOptions(NetOptions spec) {
     // Update backing config and transport (e.g. _options = spec; dio.options.baseUrl = …).
   }
   ```
2. **`DioNetClient`** already implements it (updates `BaseOptions`; does not rebuild the interceptor list from `NetOptions.interceptors` — use **`cut` + `open` / `plug`** to change that).
3. To **replace** the whole client for a lane (not just update config), **`NetRequest.cut(id)`** then **`plug` / `open`** as before.

### Changed

- **`NetRequest.open`**: if `id` is already registered, always calls **`existing.applyNetOptions(spec)`** (no longer limited to `DioNetClient`).

## [0.1.2] - 2025-03-25

### Fixed

- **pub.dev / pana**: `analyzer` lower bound `>=8.1.1` so minimum-resolution APIs match the generator (`metadata.annotations`, `formalParameters`). Widen `build`, `dio` (`>=5.2.1` for `DioException`), `meta`, `source_gen` for current stables.
- **Dev**: `build_runner: ^2.13.1` for `analyzer` 8+ / `build` 4+.

### Note

- Push `pubspec.yaml` with `version:` to the `repository` URL so pub.dev can verify the package.

## [0.1.1] - 2025-03-25

### Added

- **Open-source packaging**: MIT `LICENSE`, `topics` in `pubspec.yaml`, README + `CONTRIBUTING.md`, CI, tests.
- **CI**: GitHub Actions workflow (`analyze`, `dart test`, `example` `flutter test`).
- **Tests**: `test/parser_and_return_test.dart` for `stripReturnTypeName` and `buildReturnStatementFromResponse`.
- **`.gitignore`**: stop ignoring `*.lock` so `pubspec.lock` can be committed for reproducible CI.

### Changed

- Documentation now describes the current API (`NetRequest.prime` / `open` / `plug`, `INetClient` + `NetOptions`) and migration notes from `net_retrofit_kit`.

## [0.1.0] - 2025-03-25

### Added

- Initial release: annotations (`@NetApi`, HTTP verbs, `@Body`, `@Query`, `@DataPath`, `@StreamResponse`, …), `NetRetrofitGenerator`, `NetRequest` + `DioNetClient`, example app under `example/`.
