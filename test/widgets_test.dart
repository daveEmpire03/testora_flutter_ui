import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testora_flutter_ui/core/theme/app_theme.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

Widget _wrap(Widget child, {bool isDark = false}) {
  return MaterialApp(
    theme:
        isDark
            ? AppTheme.buildDark(useGoogleFonts: false)
            : AppTheme.buildLight(useGoogleFonts: false),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Testora Common Widgets Tests', () {
    testWidgets('TestoraCard renders child and fires onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          TestoraCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('TestoraGridCard renders icon, title, subtitle, and badge', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          TestoraGridCard(
            title: 'Mathematics',
            subtitle: '40 Questions',
            icon: Icons.functions_rounded,
            badge: const TestoraBadge(label: 'UTME'),
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('40 Questions'), findsOneWidget);
      expect(find.byIcon(Icons.functions_rounded), findsOneWidget);
      expect(find.text('UTME'), findsOneWidget);

      await tester.tap(find.text('Mathematics'));
      expect(tapped, isTrue);
    });

    testWidgets('TestoraButton primary handles tap and shows label', (
      tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        _wrap(TestoraButton(label: 'Continue', onTap: () => pressed = true)),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      expect(pressed, isTrue);
    });

    testWidgets(
      'TestoraButton displays loading spinner when isLoading is true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const TestoraButton(label: 'Submit', isLoading: true)),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Submit'), findsNothing);
      },
    );

    testWidgets(
      'Legacy adapters GradientButton and GlassCard render seamlessly',
      (tester) async {
        bool btnPressed = false;

        await tester.pumpWidget(
          _wrap(
            Column(
              children: [
                const GlassCard(child: Text('Glass Card Content')),
                GradientButton(
                  label: 'Legacy Button',
                  onTap: () => btnPressed = true,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Glass Card Content'), findsOneWidget);
        expect(find.text('Legacy Button'), findsOneWidget);

        await tester.tap(find.text('Legacy Button'));
        expect(btnPressed, isTrue);
      },
    );
  });
}
