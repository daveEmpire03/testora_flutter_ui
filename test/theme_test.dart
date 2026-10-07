import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testora_flutter_ui/core/theme/app_colors.dart';
import 'package:testora_flutter_ui/core/theme/app_theme.dart';
import 'package:testora_flutter_ui/core/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Testora Theme & Tokens Tests', () {
    test('Light theme tokens have valid academic neutral values', () {
      final light = AppTheme.buildLight(useGoogleFonts: false);
      final tokens = light.extension<TestoraTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.background, equals(AppColors.backgroundLight));
      expect(tokens.surface, equals(AppColors.surfaceLight));
      expect(tokens.card, equals(AppColors.cardLight));
      expect(tokens.textPrimary, equals(AppColors.textPrimaryLight));
      expect(tokens.success, equals(AppColors.success));
      expect(tokens.correctAnswer, equals(AppColors.correctAnswer));
    });

    test('Dark theme tokens have valid semantic dark values', () {
      final dark = AppTheme.buildDark(useGoogleFonts: false);
      final tokens = dark.extension<TestoraTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.background, equals(AppColors.backgroundDark));
      expect(tokens.surface, equals(AppColors.surfaceDark));
      expect(tokens.card, equals(AppColors.cardDark));
      expect(tokens.textPrimary, equals(AppColors.textPrimaryDark));
      expect(tokens.error, equals(AppColors.error));
      expect(tokens.incorrectAnswer, equals(AppColors.incorrectAnswer));
    });

    test('ThemeModeNotifier defaults to system and toggles correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), equals(ThemeMode.system));

      container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
      expect(container.read(themeModeProvider), equals(ThemeMode.system));
    });
  });
}
