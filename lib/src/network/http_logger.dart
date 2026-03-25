import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Logging verbosity (aligned with a typical [LogInterceptor] layout: request line
/// → headers → body; plus optional cURL for copy-paste).
enum LogLevel {
  /// No logs.
  none,

  /// `*** Request/Response ***` lines + compact cURL (method + URL only).
  basic,

  /// Adds request/response headers blocks.
  headers,

  /// Adds request/response body (formatted JSON when possible), full cURL, error stack.
  body,
}

/// HTTP logging for [HttpLoggingInterceptor].
///
/// Design reference: Dio [LogInterceptor] sections + path filtering like
/// `FilteredLogInterceptor`, plus cURL output (similar to adding a curl logger).
///
/// Per-request [Options.extra]\['enableLogging'\] overrides [defaultEnableLogging]
/// when present (same semantics as before).
class HttpLogger {
  /// Substrings matched against [Uri.path] and [RequestOptions.path]; if any
  /// match, the request/response/error is not logged (reference: excluded paths).
  static final List<String> excludedPathSubstrings = [];

  /// Current logging level.
  static LogLevel logLevel = kDebugMode ? LogLevel.body : LogLevel.none;

  /// Whether logging is enabled when [Options.extra] has no `enableLogging` key.
  static bool defaultEnableLogging = kDebugMode;

  /// When true, also print a single-line cURL after the multi-line block.
  static bool curlSingleLineCopy = true;

  static void setLogLevel(LogLevel level) {
    logLevel = level;
  }

  /// Sets whether logging is enabled when [Options.extra] has no `enableLogging` key.
  static void setDefaultEnableLogging(bool enable) {
    defaultEnableLogging = enable;
  }

  /// Clears and replaces [excludedPathSubstrings].
  static void setExcludedPathSubstrings(List<String> paths) {
    excludedPathSubstrings
      ..clear()
      ..addAll(paths);
  }

  /// `extra['enableLogging'] == true` wins; otherwise [defaultEnableLogging].
  static bool shouldLog(Map<String, dynamic>? extra) {
    if (extra != null && extra.containsKey('enableLogging')) {
      return extra['enableLogging'] == true;
    }
    return defaultEnableLogging;
  }

  /// Whether this request should produce logs (level + enable flag + path filter).
  static bool shouldLogRequest(
    Map<String, dynamic>? extra,
    Uri uri,
    String pathOption,
  ) {
    if (logLevel == LogLevel.none || !shouldLog(extra)) return false;
    return !_isPathExcluded(uri.path, pathOption);
  }

  static bool _isPathExcluded(String uriPath, String pathOption) {
    if (excludedPathSubstrings.isEmpty) return false;
    return excludedPathSubstrings.any(
      (excluded) => uriPath.contains(excluded) || pathOption.contains(excluded),
    );
  }

  // ─── Request ─────────────────────────────────────────

  static void logRequest(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? extra,
  ) {
    if (logLevel == LogLevel.none || !shouldLog(extra)) return;

    debugPrint('*** Request ***');
    debugPrint('$method $url');

    if (logLevel == LogLevel.headers || logLevel == LogLevel.body) {
      _printHeaderMap('headers', headers);
    }

    if (logLevel == LogLevel.body) {
      _printDataBlock('data', body);
    }

    _printCurlBlock(url, method, headers, body);
  }

  static void _printCurlBlock(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    final curlLines = _buildCurlLines(url, method, headers, body);
    debugPrint('---------- cURL ----------');
    for (final line in curlLines) {
      debugPrint(line);
    }
    if (curlSingleLineCopy) {
      final oneLine = _buildCurlSingleLine(url, method, headers, body);
      if (oneLine != null && oneLine.isNotEmpty) {
        debugPrint('--- one line ---');
        debugPrint(oneLine);
      }
    }
    debugPrint('--------------------------');
  }

  static void _printHeaderMap(String title, Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) {
      debugPrint('$title:');
      return;
    }
    debugPrint('$title:');
    headers.forEach((k, v) {
      debugPrint(' $k: ${v?.toString() ?? ''}');
    });
  }

  static void _printDataBlock(String title, dynamic data) {
    debugPrint('$title:');
    _printFormatted(data, prefix: ' ');
  }

  // ─── Response ─────────────────────────────────────────

  static void logResponse(
    String url,
    int statusCode,
    Map<String, dynamic>? headers,
    dynamic body,
    int? timeInMillis,
    Map<String, dynamic>? extra,
  ) {
    if (logLevel == LogLevel.none || !shouldLog(extra)) return;

    final timeStr = timeInMillis != null ? ' (${timeInMillis}ms)' : '';
    debugPrint('*** Response ***');
    debugPrint('$statusCode$timeStr $url');

    if (logLevel == LogLevel.headers || logLevel == LogLevel.body) {
      _printHeaderMap('headers', headers);
    }

    if (logLevel == LogLevel.body) {
      _printDataBlock('body', body);
    }
  }

  // ─── Error ─────────────────────────────────────────

  static void logError(
    String url,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  ) {
    if (logLevel == LogLevel.none || !shouldLog(extra)) return;

    debugPrint('*** DioException ***');
    debugPrint('uri: $url');
    if (error is DioException) {
      debugPrint('type: ${error.type}');
      debugPrint('message: ${error.message ?? ''}');
      if (error.response != null) {
        final r = error.response!;
        debugPrint('statusCode: ${r.statusCode}');
        if (logLevel == LogLevel.headers || logLevel == LogLevel.body) {
          final hm = <String, dynamic>{};
          r.headers.map.forEach((k, v) {
            hm[k] = v.join(', ');
          });
          _printHeaderMap('response headers', hm);
        }
        if (logLevel == LogLevel.body) {
          _printDataBlock('response data', r.data);
        }
      }
    } else {
      debugPrint('error: $error');
    }
    if (logLevel == LogLevel.body && stackTrace != null) {
      debugPrint('stackTrace:');
      for (final line in stackTrace.toString().split('\n')) {
        debugPrint(' $line');
      }
    }
  }

  // ─── cURL builders (same rules as before; gated by [logLevel]) ─────────────────

  static List<String> _buildCurlLines(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    final methodUpper = method.toUpperCase();
    final isGet = methodUpper == 'GET';

    String fullUrl = url;
    String? dataPiece;
    if (body != null && body is Map<String, dynamic> && body.isNotEmpty) {
      if (isGet) {
        final query = body.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key.toString())}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
            )
            .join('&');
        fullUrl = url.contains('?') ? '$url&$query' : '$url?$query';
      } else {
        final jsonStr = jsonEncode(body);
        dataPiece = _escapeSingleQuotes(jsonStr);
      }
    } else if (body != null && body is String && body.isNotEmpty && !isGet) {
      dataPiece = _escapeSingleQuotes(body);
    }

    final lines = <String>[];
    lines.add('curl \\');
    lines.add('  -X $methodUpper \\');
    lines.add('  ${_escapeUrl(fullUrl)} \\');

    if (logLevel == LogLevel.headers || logLevel == LogLevel.body) {
      if (headers != null && headers.isNotEmpty) {
        for (final e in headers.entries) {
          final v = e.value?.toString() ?? '';
          lines.add("  -H ${_escapeHeader('${e.key}: $v')} \\");
        }
      }
    }
    if (logLevel == LogLevel.body && dataPiece != null) {
      lines.add('  -d \'$dataPiece\'');
    }

    if (lines.isNotEmpty && lines.last.endsWith(' \\')) {
      lines[lines.length - 1] = lines.last.substring(0, lines.last.length - 2);
    }
    return lines;
  }

  static String? _buildCurlSingleLine(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    final lines = _buildCurlLines(url, method, headers, body);
    if (lines.isEmpty) return null;
    return lines
        .map((s) => s.endsWith(' \\') ? s.substring(0, s.length - 2) : s)
        .join(' ');
  }

  static String _escapeUrl(String s) {
    return "'${_escapeSingleQuotes(s)}'";
  }

  static String _escapeHeader(String s) {
    return "'${_escapeSingleQuotes(s)}'";
  }

  static String _escapeSingleQuotes(String s) {
    return s.replaceAll("'", r"'\''");
  }

  static void _printFormatted(dynamic data, {String prefix = ''}) {
    try {
      String formattedData;
      if (data is ResponseBody) {
        debugPrint('$prefix[ResponseBody stream]');
        return;
      }
      if (data is String) {
        try {
          formattedData = const JsonEncoder.withIndent('  ')
              .convert(json.decode(data) as Object);
        } catch (_) {
          formattedData = data;
        }
      } else if (data is Map || data is List) {
        formattedData = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        formattedData = data.toString();
      }
      for (final line in formattedData.split('\n')) {
        debugPrint('$prefix$line');
      }
    } catch (_) {
      debugPrint('$prefix[Unformattable]: $data');
    }
  }
}
