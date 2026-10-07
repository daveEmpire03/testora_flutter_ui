import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Semantic design tokens extension accessible via `context.tokens`.
class TestoraTokens extends ThemeExtension<TestoraTokens> {
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color card;
  final Color cardBorder;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color disabled;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color correctAnswer;
  final Color incorrectAnswer;
  final Color selectedAnswer;

  const TestoraTokens({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.card,
    required this.cardBorder,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.disabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.correctAnswer,
    required this.incorrectAnswer,
    required this.selectedAnswer,
  });

  static const light = TestoraTokens(
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceSecondary: AppColors.surfaceSecondaryLight,
    surfaceElevated: AppColors.surfaceElevatedLight,
    card: AppColors.cardLight,
    cardBorder: AppColors.cardBorderLight,
    border: AppColors.borderLight,
    divider: AppColors.dividerLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textMuted: AppColors.textMutedLight,
    disabled: AppColors.disabled,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    correctAnswer: AppColors.correctAnswer,
    incorrectAnswer: AppColors.incorrectAnswer,
    selectedAnswer: AppColors.selectedAnswerLight,
  );

  static const dark = TestoraTokens(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceSecondary: AppColors.surfaceSecondaryDark,
    surfaceElevated: AppColors.surfaceElevatedDark,
    card: AppColors.cardDark,
    cardBorder: AppColors.cardBorderDark,
    border: AppColors.borderDark,
    divider: AppColors.dividerDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textMuted: AppColors.textMutedDark,
    disabled: AppColors.disabled,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    correctAnswer: AppColors.correctAnswer,
    incorrectAnswer: AppColors.incorrectAnswer,
    selectedAnswer: AppColors.selectedAnswerDark,
  );

  @override
  TestoraTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceElevated,
    Color? card,
    Color? cardBorder,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? disabled,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? correctAnswer,
    Color? incorrectAnswer,
    Color? selectedAnswer,
  }) {
    return TestoraTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      disabled: disabled ?? this.disabled,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      incorrectAnswer: incorrectAnswer ?? this.incorrectAnswer,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
    );
  }

  @override
  TestoraTokens lerp(ThemeExtension<TestoraTokens>? other, double t) {
    if (other is! TestoraTokens) return this;
    return TestoraTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      correctAnswer: Color.lerp(correctAnswer, other.correctAnswer, t)!,
      incorrectAnswer: Color.lerp(incorrectAnswer, other.incorrectAnswer, t)!,
      selectedAnswer: Color.lerp(selectedAnswer, other.selectedAnswer, t)!,
    );
  }
}

/// Convenience extension on [BuildContext] to access [TestoraTokens].
extension TestoraThemeContext on BuildContext {
  TestoraTokens get tokens =>
      Theme.of(this).extension<TestoraTokens>() ?? TestoraTokens.light;
}

/// Master Testora theme generator.
abstract final class AppTheme {
  // Legacy aliases to preserve compatibility
  static const radiusSm = AppRadius.sm;
  static const radiusMd = AppRadius.card;
  static const radiusLg = AppRadius.xl;

  // ─── Light Theme ─────────────────────────────────────────────
  static ThemeData buildLight({bool useGoogleFonts = true}) {
    const tokens = TestoraTokens.light;
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      secondary: AppColors.textSecondaryLight,
      onSecondary: AppColors.backgroundLight,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerLowest: AppColors.surfaceLight,
      surfaceContainerLow: AppColors.surfaceSecondaryLight,
      surfaceContainer: AppColors.surfaceSecondaryLight,
      surfaceContainerHigh: Color(0xFFEFEFF2),
      surfaceContainerHighest: AppColors.cardBorderLight,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.dividerLight,
    );

    return _buildTheme(
      scheme,
      tokens,
      useGoogleFonts: useGoogleFonts,
    ).copyWith(scaffoldBackgroundColor: tokens.background);
  }

  static ThemeData get light => buildLight();

  // ─── Dark Theme ──────────────────────────────────────────────
  static ThemeData buildDark({bool useGoogleFonts = true}) {
    const tokens = TestoraTokens.dark;
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      secondary: AppColors.textSecondaryDark,
      onSecondary: AppColors.backgroundDark,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerLowest: AppColors.backgroundDark,
      surfaceContainerLow: AppColors.surfaceSecondaryDark,
      surfaceContainer: AppColors.surfaceSecondaryDark,
      surfaceContainerHigh: AppColors.surfaceElevatedDark,
      surfaceContainerHighest: AppColors.cardBorderDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.dividerDark,
    );

    return _buildTheme(
      scheme,
      tokens,
      useGoogleFonts: useGoogleFonts,
    ).copyWith(scaffoldBackgroundColor: tokens.background);
  }

  static ThemeData get dark => buildDark();

  // ─── Shared Theme Builder ────────────────────────────────────
  static ThemeData _buildTheme(
    ColorScheme scheme,
    TestoraTokens tokens, {
    bool useGoogleFonts = true,
  }) {
    final text = _buildText(scheme, useGoogleFonts: useGoogleFonts);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      primaryTextTheme: text,
      extensions: [tokens],
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
        systemOverlayStyle:
            scheme.brightness == Brightness.light
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
      ),

      // Card Theme (subtle border, rounded corners, zero heavy shadows)
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: tokens.cardBorder, width: 1),
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          side: BorderSide(color: tokens.border, width: 1),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: _buildInputTheme(scheme, tokens),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        elevation: 0,
        indicatorColor:
            scheme.brightness == Brightness.light
                ? AppColors.primaryLight.withValues(alpha: 0.08)
                : AppColors.primaryDark.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? scheme.onSurface : tokens.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: isSelected ? scheme.onSurface : tokens.textSecondary,
          );
        }),
      ),

      // Dialog & Bottom Sheet Themes
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: tokens.border, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: tokens.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Divider & SnackBars
      dividerTheme: DividerThemeData(
        color: tokens.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            scheme.brightness == Brightness.light
                ? const Color(0xFF1E1E24)
                : const Color(0xFF26262B),
        contentTextStyle: text.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: tokens.border, width: 1),
        ),
        labelStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
      ),

      // Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Input Decoration ────────────────────────────────────────
  static InputDecorationTheme _buildInputTheme(
    ColorScheme scheme,
    TestoraTokens tokens,
  ) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: tokens.surfaceSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: TextStyle(
        color: tokens.textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      border: border(tokens.border),
      enabledBorder: border(tokens.border),
      focusedBorder: border(scheme.onSurface, 1.5),
      errorBorder: border(tokens.error),
      focusedErrorBorder: border(tokens.error, 1.5),
      errorStyle: TextStyle(
        color: tokens.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ─── Typography ──────────────────────────────────────────────
  static TextTheme _buildText(
    ColorScheme scheme, {
    bool useGoogleFonts = true,
  }) {
    final defaultBase = ThemeData(brightness: scheme.brightness).textTheme;
    final base =
        useGoogleFonts
            ? GoogleFonts.poppinsTextTheme(defaultBase)
            : defaultBase;

    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          bodyLarge: base.bodyLarge?.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: base.bodySmall?.copyWith(
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}
