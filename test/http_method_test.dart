import 'package:net_retrofit_dio/src/network/http_method.dart';
import 'package:test/test.dart';

void main() {
  group('HttpMethod', () {
    test('exposes six verbs aligned with Dio convenience APIs', () {
      expect(HttpMethod.values, hasLength(6));
      expect(HttpMethod.values, contains(HttpMethod.patch));
      expect(HttpMethod.values, contains(HttpMethod.head));
    });

    test('string maps to HTTP verb names', () {
      const expected = {
        HttpMethod.get: 'GET',
        HttpMethod.post: 'POST',
        HttpMethod.put: 'PUT',
        HttpMethod.patch: 'PATCH',
        HttpMethod.delete: 'DELETE',
        HttpMethod.head: 'HEAD',
      };
      for (final entry in expected.entries) {
        expect(entry.key.string, entry.value);
      }
    });
  });
}
