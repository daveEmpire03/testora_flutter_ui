import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testora_flutter_ui/core/theme/app_theme.dart';
import 'package:testora_flutter_ui/shared/testora_forms.dart';

Widget _wrap(Widget child, {bool isDark = false}) {
  return MaterialApp(
    theme:
        isDark
            ? AppTheme.buildDark(useGoogleFonts: false)
            : AppTheme.buildLight(useGoogleFonts: false),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Testora Form System Tests', () {
    testWidgets('TestoraTextField renders and accepts input in Light mode', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        _wrap(
          TestoraTextField(
            controller: controller,
            label: 'Full Name',
            hint: 'Enter your name',
          ),
        ),
      );

      expect(find.textContaining('Full Name'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Ada Lovelace');
      expect(controller.text, equals('Ada Lovelace'));
    });

    testWidgets('TestoraPasswordField toggles visibility on icon tap', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'secret123');

      await tester.pumpWidget(
        _wrap(TestoraPasswordField(controller: controller, label: 'Password')),
      );

      TextField textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      // Tap visibility toggle
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });

    testWidgets(
      'TestoraSearchField shows clear button and clears text on tap',
      (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          _wrap(
            TestoraSearchField(controller: controller, hint: 'Search subjects'),
          ),
        );

        expect(find.byIcon(Icons.cancel_rounded), findsNothing);

        await tester.enterText(find.byType(TextField), 'Math');
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.cancel_rounded));
        await tester.pumpAndSettle();

        expect(controller.text, isEmpty);
        expect(find.byIcon(Icons.cancel_rounded), findsNothing);
      },
    );

    testWidgets('TestoraCheckbox triggers onChanged when tapped', (
      tester,
    ) async {
      bool checked = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              TestoraCheckbox(
                value: checked,
                labelText: 'Accept Terms',
                onChanged: (val) {
                  setState(() => checked = val);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Accept Terms'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.text('Accept Terms'));
      await tester.pumpAndSettle();

      expect(checked, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('TestoraFormLabel renders required asterisk', (tester) async {
      await tester.pumpWidget(
        _wrap(const TestoraFormLabel(label: 'Email', isRequired: true)),
      );

      expect(find.byType(RichText), findsOneWidget);
    });
  });
}
