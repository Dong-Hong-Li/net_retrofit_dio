import 'package:build/build.dart';
import 'generator.dart';
import 'package:source_gen/source_gen.dart';

/// Creates the builder from the given options.
Builder netRetrofitDioBuilder(BuilderOptions options) {
  return SharedPartBuilder([
    NetRetrofitGenerator(),
  ], 'net_retrofit_dio');
}
