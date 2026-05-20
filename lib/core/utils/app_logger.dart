import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message) {
    _log('INFO', message);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log('WARN', message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, Object error, StackTrace stackTrace) {
    _log('ERROR', message, error: error, stackTrace: stackTrace);
  }

  static void startup(String message) {
    _log('STARTUP', message);
  }

  static void provider(String message) {
    _log('PROVIDER', message);
  }

  static void router(String message) {
    _log('ROUTER', message);
  }

  static void navigation(String message) {
    _log('NAV', message);
  }

  static void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer('[CVify][$level] $message');
    if (error != null) {
      buffer.write(' | error=$error');
    }

    final line = buffer.toString();
    debugPrint(line);
    developer.log(
      line,
      name: 'CVify',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
