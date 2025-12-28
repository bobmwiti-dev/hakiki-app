import 'dart:developer' as developer;

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static const String _appName = 'Hakiki';
  static bool _isDebugMode = true;

  static void setDebugMode(bool isDebug) {
    _isDebugMode = isDebug;
  }

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_isDebugMode && level == LogLevel.debug) {
      return;
    }

    final String logTag = tag ?? _getCallerInfo();
    final String timestamp = DateTime.now().toIso8601String();
    final String levelStr = level.name.toUpperCase();
    
    String logMessage = '[$timestamp] [$levelStr] [$_appName:$logTag] $message';
    
    if (error != null) {
      logMessage += '\nError: $error';
    }
    
    if (stackTrace != null) {
      logMessage += '\nStackTrace: $stackTrace';
    }

    // Use developer.log for better debugging in Flutter
    developer.log(
      message,
      name: '$_appName:$logTag',
      level: _getLevelValue(level),
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );

    // Also print to console for immediate visibility in debug mode only
    if (_isDebugMode) {
      // ignore: avoid_print
      print(logMessage);
    }
  }

  static String _getCallerInfo() {
    try {
      final stackTrace = StackTrace.current;
      final frames = stackTrace.toString().split('\n');
      
      // Skip the first few frames (this method, _log method, and the public log method)
      for (int i = 3; i < frames.length && i < 10; i++) {
        final frame = frames[i];
        if (frame.contains('.dart') && !frame.contains('logger.dart')) {
          // Extract class and method name from the stack frame
          final match = RegExp(r'#\d+\s+(.+?)\s+\((.+?):(\d+):\d+\)').firstMatch(frame);
          if (match != null) {
            final method = match.group(1) ?? '';
            final file = match.group(2)?.split('/').last ?? '';
            return '$file:$method';
          }
        }
      }
    } catch (e) {
      // Fallback if stack trace parsing fails
    }
    
    return 'Unknown';
  }

  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  // Convenience methods for common use cases
  static void logApiCall(String endpoint, {Map<String, dynamic>? params}) {
    info('API Call: $endpoint', tag: 'API', error: params);
  }

  static void logApiResponse(String endpoint, {int? statusCode, dynamic response}) {
    info('API Response: $endpoint (Status: $statusCode)', tag: 'API', error: response);
  }

  static void logApiError(String endpoint, Object error, [StackTrace? stackTrace]) {
    Logger.error('API Error: $endpoint', tag: 'API', error: error, stackTrace: stackTrace);
  }

  static void logNavigation(String route, {Map<String, dynamic>? arguments}) {
    info('Navigation: $route', tag: 'Navigation', error: arguments);
  }

  static void logUserAction(String action, {Map<String, dynamic>? context}) {
    info('User Action: $action', tag: 'UserAction', error: context);
  }

  static void logFirebaseEvent(String event, {Map<String, dynamic>? parameters}) {
    info('Firebase Event: $event', tag: 'Firebase', error: parameters);
  }

  static void logCacheOperation(String operation, String key, {dynamic value}) {
    debug('Cache $operation: $key', tag: 'Cache', error: value);
  }

  static void logAuthEvent(String event, {String? userId}) {
    info('Auth Event: $event${userId != null ? ' (User: $userId)' : ''}', tag: 'Auth');
  }
}
