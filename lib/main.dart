import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.startup('main() — Démarrage CVify avec Supabase.');

  // Initialisation Supabase avant tout le reste
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: false,
    );
    AppLogger.startup('Supabase initialisé avec succès.');
  } catch (e, st) {
    AppLogger.error('Échec initialisation Supabase', e, st);
    // L'app continue en mode dégradé si Supabase échoue
  }

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

  runZonedGuarded(
    () async {
      runApp(const MyApp());
    },
    (error, stack) {
      AppLogger.error('runZonedGuarded uncaught', error, stack);
    },
  );
}
