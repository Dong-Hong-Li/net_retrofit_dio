# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


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
