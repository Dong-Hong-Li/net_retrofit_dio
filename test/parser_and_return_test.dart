import 'package:net_retrofit_dio/src/generate/parser_expression.dart';
import 'package:net_retrofit_dio/src/generate/return_type_name.dart';
import 'package:test/test.dart';

void main() {
  group('stripReturnTypeName', () {
    test('Future<Response<String>> extracts to Response<String>', () {
      expect(
        stripReturnTypeName('Future<Response<String>>'),
        equals('Response<String>'),
      );
    });

    test('keeps generic closing when analyzer returns single >', () {
      expect(
        stripReturnTypeName('Future<Response < String>'),
        equals('Response < String>'),
      );
    });

    test('extracts correctly when double > has spaces', () {
      expect(
        stripReturnTypeName('Future<Response < String >>'),
        equals('Response < String >'),
      );
    });

    test('removes nullable suffix ?', () {
      expect(
        stripReturnTypeName('Future<Response<String>>?'),
        equals('Response<String>'),
      );
    });

    test('returns non-Future input as-is', () {
      expect(
        stripReturnTypeName('Response<String>'),
        equals('Response<String>'),
      );
    });
  });

  group('buildReturnStatementFromResponse', () {
    test('primitives use as-cast on response.data', () {
      expect(
        buildReturnStatementFromResponse('String', null),
        equals('return response.data as String;'),
      );
      expect(
        buildReturnStatementFromResponse('int', null),
        equals('return response.data as int;'),
      );
      expect(
        buildReturnStatementFromResponse('bool', null),
        equals('return response.data as bool;'),
      );
    });

    test('Map uses as-cast without fromJson', () {
      expect(
        buildReturnStatementFromResponse('Map<String, dynamic>', null),
        equals('return response.data as Map<String, dynamic>;'),
      );
    });

    test('model type uses fromJson on response.data', () {
      expect(
        buildReturnStatementFromResponse('UserModel', null),
        equals(
          'return UserModel.fromJson(response.data as Map<String, dynamic>);',
        ),
      );
    });

    test('spaced generic model wraps type for fromJson call', () {
      expect(
        buildReturnStatementFromResponse('UserModel < String >', null),
        contains('(UserModel < String >).fromJson'),
      );
    });

    test('dataPath reads nested field before parse', () {
      expect(
        buildReturnStatementFromResponse('UserModel', 'data'),
        equals(
          'return UserModel.fromJson((response.data as Map<String, dynamic>)["data"] as Map<String, dynamic>);',
        ),
      );
    });

    test('dataPath + primitive casts field', () {
      expect(
        buildReturnStatementFromResponse('String', 'code'),
        equals(
          'return (response.data as Map<String, dynamic>)["code"] as String;',
        ),
      );
    });
  });
}
