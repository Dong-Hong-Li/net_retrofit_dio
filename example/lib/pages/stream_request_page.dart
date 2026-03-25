// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:net_retrofit_dio/net_retrofit_dio.dart';
import 'package:net_retrofit_dio_example/server/demo_server.dart';

class StreamRequestPage extends StatefulWidget {
  const StreamRequestPage({super.key});

  @override
  State<StreamRequestPage> createState() => _StreamRequestPageState();
}

class _StreamRequestPageState extends State<StreamRequestPage> {
  List<String> _lines = [];
  bool _loading = false;
  String _error = '';
  CancelToken? _cancelToken;
  final _repository = DemoRepository.instance;

  Future<void> _startStream() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = '';
      _lines = ['开始请求…'];
    });
    _cancelToken = CancelToken();

    try {
      final result = await _repository
          .fetchStreamLines(CallOptions(cancelToken: _cancelToken));
      setState(() {
        _lines = ['开始请求…', ...result, '--- 流结束 ---'];
        _loading = false;
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        setState(() {
          _lines = [..._lines, '已取消'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = e.message ?? e.type.name;
          _loading = false;
        });
      }
    } catch (e, st) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      debugPrintStack(stackTrace: st);
    }
  }

  void _cancelStream() {
    _cancelToken?.cancel('用户取消');
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流式请求'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '由 DemoRepository.fetchStreamLines 消费流；本页仅等待并展示结果。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _loading ? null : _startStream,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('开始流式请求'),
                ),
                const SizedBox(width: 8),
                if (_loading)
                  OutlinedButton.icon(
                    onPressed: _cancelStream,
                    icon: const Icon(Icons.cancel),
                    label: const Text('取消'),
                  ),
              ],
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _lines.isEmpty
                    ? const Center(
                        child: Text('暂无数据，点击上方按钮开始。'),
                      )
                    : ListView.builder(
                        itemCount: _lines.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: SelectableText(
                            _lines[i],
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
