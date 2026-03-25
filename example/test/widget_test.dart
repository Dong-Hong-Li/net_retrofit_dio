import 'package:flutter_test/flutter_test.dart';
import 'package:net_retrofit_dio/net_retrofit_dio.dart';
import 'package:net_retrofit_dio_example/main.dart';

void main() {
  setUpAll(() {
    NetRequest.prime(
      const NetOptions(
        baseUrl: 'https://example.invalid',
        connectTimeout: Duration(seconds: 1),
        receiveTimeout: Duration(seconds: 1),
        sendTimeout: Duration(seconds: 1),
      ),
    );
    NetRequest.open(
      'upload',
      const NetOptions(
        baseUrl: 'https://example.invalid',
        connectTimeout: Duration(seconds: 1),
        receiveTimeout: Duration(seconds: 1),
        sendTimeout: Duration(seconds: 1),
      ),
    );
  });

  testWidgets('首页可渲染', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('net_retrofit_dio'), findsWidgets);
    expect(find.text('全部示例'), findsOneWidget);
  });
}
