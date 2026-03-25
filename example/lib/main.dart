import 'package:flutter/material.dart';
import 'package:net_retrofit_dio/net_retrofit_dio.dart';
import 'package:net_retrofit_dio_example/pages/examples_list_page.dart';
import 'package:net_retrofit_dio_example/pages/stream_request_page.dart';
import 'package:net_retrofit_dio_example/server/demo_server.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const timeout = Duration(seconds: 15);
  const uploadTimeout = Duration(seconds: 60);

  NetRequest.prime(
    const NetOptions(
      baseUrl: 'https://httpbin.org',
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    ),
  );

  NetRequest.open(
    'upload',
    const NetOptions(
      baseUrl: 'https://httpbin.org',
      connectTimeout: timeout,
      receiveTimeout: uploadTimeout,
      sendTimeout: uploadTimeout,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'net_retrofit_dio Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status =
      '打开「全部示例」浏览各注解组合，或使用下方快捷按钮。';
  bool _loading = false;
  final _repository = DemoRepository.instance;

  Future<void> _doLogin() async {
    setState(() {
      _loading = true;
      _status = '请求中… login(mobile)';
    });
    final result = await _repository.login('13800138000', 'demo_google_token');
    setState(() {
      _status = result ? '登录成功' : '登录失败';
      _loading = false;
    });
  }

  Future<void> _doGetUserInfo() async {
    setState(() {
      _loading = true;
      _status = '请求中… getUserInfo()';
    });
    try {
      final result = await _repository.getUserInfo();
      setState(() {
        _status = result != null
            ? '用户信息: ${result.userId} / ${result.mobile} (DemoModel)'
            : 'getUserInfo 返回 null';
      });
    } catch (e, st) {
      setState(() => _status = '失败: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _doSaveArchives() async {
    setState(() {
      _loading = true;
      _status = '请求中… saveArchives(body)';
    });
    try {
      final map = await _repository.saveArchives({
        'key': 'net_retrofit_dio_example',
        'time': DateTime.now().toIso8601String(),
      });
      setState(() => _status =
          'saveArchives: ${map != null ? "成功 (Map)" : "失败或 null"}');
    } catch (e, st) {
      setState(() => _status = '失败: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('net_retrofit_dio Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExamplesListPage()),
                  ),
                  icon: const Icon(Icons.list),
                  label: const Text('全部示例'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _loading ? null : _doLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('login(mobile)'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _loading ? null : _doGetUserInfo,
                  icon: const Icon(Icons.person),
                  label: const Text('getUserInfo()'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: _loading ? null : _doLogin,
                  child: const Text('googleLogin(token)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading ? null : _doSaveArchives,
                  child: const Text('saveArchives(body)'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StreamRequestPage(),
                    ),
                  ),
                  icon: const Icon(Icons.stream),
                  label: const Text('流式请求示例'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
