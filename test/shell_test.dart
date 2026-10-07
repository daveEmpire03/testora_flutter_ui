import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:testora_flutter_ui/core/shell/main_shell.dart';
import 'package:testora_flutter_ui/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'MainShell renders 4 tabs with icons and responds to navigation',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder:
                (context, state, navigationShell) =>
                    MainShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder:
                        (_, _) =>
                            const Scaffold(body: Text('Home Screen Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/exams',
                    builder:
                        (_, _) =>
                            const Scaffold(body: Text('Exams Screen Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/progress',
                    builder:
                        (_, _) => const Scaffold(
                          body: Text('Progress Screen Content'),
                        ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder:
                        (_, _) => const Scaffold(
                          body: Text('Profile Screen Content'),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildLight(useGoogleFonts: false),
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Verify 4 tabs exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Exams'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      expect(find.text('Home Screen Content'), findsOneWidget);

      // Switch to Exams
      await tester.tap(find.text('Exams'));
      await tester.pumpAndSettle();
      expect(find.text('Exams Screen Content'), findsOneWidget);

      // Switch to Progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.text('Progress Screen Content'), findsOneWidget);

      // Switch to Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile Screen Content'), findsOneWidget);
    },
  );
}
