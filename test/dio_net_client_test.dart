import 'package:dio/dio.dart';
import 'package:net_retrofit_dio/src/network/http_method.dart';
import 'package:net_retrofit_dio/src/network/inet_client.dart';
import 'package:net_retrofit_dio/src/network/net_options.dart';
import 'package:test/test.dart';

/// Short-circuits outbound calls and records the last [RequestOptions].
class _CaptureInterceptor extends Interceptor {
  RequestOptions? last;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    last = options;
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: options.method == 'HEAD' ? null : const {'ok': true},
      ),
    );
  }
}

DioNetClient _clientWithCapture(_CaptureInterceptor capture) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  dio.interceptors.add(capture);
  return DioNetClient.fromDio(
    const NetOptions(baseUrl: 'https://example.com'),
    dio,
  );
}

void main() {
  group('DioNetClient.request', () {
    late _CaptureInterceptor capture;
    late DioNetClient client;

    setUp(() {
      capture = _CaptureInterceptor();
      client = _clientWithCapture(capture);
    });

    test('PATCH dispatches dio.patch with body', () async {
      await client.request<dynamic>(
        url: '/patch',
        method: HttpMethod.patch,
        body: {'title': 'patched'},
      );

      expect(capture.last?.method, 'PATCH');
      expect(capture.last?.path, '/patch');
      expect(capture.last?.data, {'title': 'patched'});
    });

    test('HEAD dispatches dio.head without requiring a body', () async {
      final response = await client.request<dynamic>(
        url: '/anything/1',
        method: HttpMethod.head,
        queryParameters: {'check': '1'},
      );

      expect(capture.last?.method, 'HEAD');
      expect(capture.last?.path, '/anything/1');
      expect(capture.last?.queryParameters, {'check': '1'});
      expect(response.statusCode, 200);
      expect(response.data, isNull);
    });

    test('GET POST PUT DELETE still dispatch correctly', () async {
      const cases = <(HttpMethod, String)>[
        (HttpMethod.get, 'GET'),
        (HttpMethod.post, 'POST'),
        (HttpMethod.put, 'PUT'),
        (HttpMethod.delete, 'DELETE'),
      ];
      for (final (method, verb) in cases) {
        await client.request<dynamic>(
          url: '/x',
          method: method,
          body: {'k': 'v'},
        );
        expect(capture.last?.method, verb, reason: '$method');
      }
    });
  });
}
