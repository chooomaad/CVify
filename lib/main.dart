import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint(error.toString());
    debugPrint(stack.toString());
    return true;
  };

  runZonedGuarded(() async {
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint(error.toString());
    debugPrint(stack.toString());
  });
}
