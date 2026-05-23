import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/app_logger.dart';

void main() {
  // Les handlers d'erreur doivent être définis avant runZonedGuarded
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

  // ensureInitialized ET runApp doivent être dans la MÊME zone
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger.startup('main() — Démarrage CVify avec Supabase.');

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
    },
    (error, stack) {
      AppLogger.error('runZonedGuarded uncaught', error, stack);
    },
  );
}
