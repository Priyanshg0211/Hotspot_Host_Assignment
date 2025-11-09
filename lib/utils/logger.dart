import 'package:flutter/foundation.dart';

class AppLogger {
  static const bool _enableLogging = kDebugMode;

  /// Log information messages
  static void info(String message, {Map<String, dynamic>? data}) {
    if (!_enableLogging) return;
    
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('ℹ[$timestamp] INFO: $message');
    
    if (data != null && data.isNotEmpty) {
      debugPrint('   Data: ${_formatData(data)}');
    }
  }

  /// Log error messages
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_enableLogging) return;
    
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] ERROR: $message');
    
    if (error != null) {
      debugPrint('   Error: $error');
    }
    
    if (stackTrace != null) {
      debugPrint('   Stack trace:\n$stackTrace');
    }
  }

  /// Log warning messages
  static void warning(String message, {Map<String, dynamic>? data}) {
    if (!_enableLogging) return;
    
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] WARNING: $message');
    
    if (data != null && data.isNotEmpty) {
      debugPrint('Data: ${_formatData(data)}');
    }
  }

  /// Log debug messages (only in debug mode)
  static void debug(String message, {Map<String, dynamic>? data}) {
    if (!_enableLogging || !kDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] DEBUG: $message');
    
    if (data != null && data.isNotEmpty) {
      debugPrint('Data: ${_formatData(data)}');
    }
  }

  /// Log success messages
  static void success(String message, {Map<String, dynamic>? data}) {
    if (!_enableLogging) return;
    
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] SUCCESS: $message');
    
    if (data != null && data.isNotEmpty) {
      debugPrint('Data: ${_formatData(data)}');
    }
  }

  /// Format data for logging
  static String _formatData(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      buffer.write('$key: $value, ');
    });
    final result = buffer.toString();
    return result.substring(0, result.length - 2); 
  }
}