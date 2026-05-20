import 'package:cvify/app/app.dart';
import 'package:cvify/core/router/app_router.dart';
import 'package:cvify/shared/providers/cv_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and reaches the splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Material(
            child: Center(child: Text('Test Boot Screen')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
        ],
        child: const CVifyApp(),
      ),
    );

    expect(find.text('Test Boot Screen'), findsOneWidget);
  });

  test('corrupted saved CV payload does not crash the provider', () async {
    SharedPreferences.setMockInitialValues({
      'cv_list': 'not valid json',
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cvListProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(container.read(cvListProvider), isEmpty);
  });
}
