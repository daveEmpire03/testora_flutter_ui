import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for managing application theme mode (System, Light, Dark).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // System theme is default as specified.
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.system:
        state = ThemeMode.dark;
      case ThemeMode.dark:
        state = ThemeMode.light;
      case ThemeMode.light:
        state = ThemeMode.system;
    }
  }
}
