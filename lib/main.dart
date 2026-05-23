import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/app_logger.dart';

void main() async {
  // ensureInitialized DOIT être dans la même zone que runApp.
  // runZonedGuarded crée une zone différente → incompatible avec supabase_flutter.
  // On utilise PlatformDispatcher.onError pour capturer les erreurs async.
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.startup('main() — Démarrage CVify avec Supabase.');

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'FlutterError',
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('PlatformDispatcher error', error, stack);
    return true;
  };

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: false,
    );
    AppLogger.startup('Supabase initialisé avec succès.');
  } catch (e, st) {
    AppLogger.error('Échec initialisation Supabase', e, st);
  }

  runApp(const MyApp());
}
