abstract class AppLogger {
  void info(String message, {Map<String, Object?> context = const <String, Object?>{}});
  void warning(String message, {Map<String, Object?> context = const <String, Object?>{}});
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, Object?> context = const <String, Object?>{}});
}

class DebugAppLogger implements AppLogger {
  const DebugAppLogger();

  @override
  void info(String message, {Map<String, Object?> context = const <String, Object?>{}}) {
    _log('INFO', message, context);
  }

  @override
  void warning(String message, {Map<String, Object?> context = const <String, Object?>{}}) {
    _log('WARN', message, context);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    _log('ERROR', message, <String, Object?>{
      ...context,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stack': stackTrace.toString(),
    });
  }

  void _log(String level, String message, Map<String, Object?> context) {
    // Intentionally simple until a production logger is added by platform setup.
    // ignore: avoid_print
    print('[$level] $message ${context.isEmpty ? "" : context}');
  }
}
