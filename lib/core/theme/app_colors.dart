import 'package:flutter/material.dart';

/// Centralized design tokens and color palette for Testora.
///
/// Implements a sophisticated Black / White / Neutral visual system
/// for a premium, academic, calm, modern mobile learning experience.
abstract final class AppColors {
  // ─── Neutral Surfaces & Backgrounds (Light) ───────────────────
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceSecondaryLight = Color(0xFFF7F7F8);
  static const surfaceElevatedLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardBorderLight = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFE5E7EB);
  static const dividerLight = Color(0xFFF0F0F2);

  // ─── Neutral Text (Light) ──────────────────────────────────────
  static const textPrimaryLight = Color(0xFF111111);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const textMutedLight = Color(0xFF9CA3AF);

  // ─── Neutral Surfaces & Backgrounds (Dark) ────────────────────
  static const backgroundDark = Color(0xFF090909);
  static const surfaceDark = Color(0xFF0B0B0C);
  static const surfaceSecondaryDark = Color(0xFF121214);
  static const surfaceElevatedDark = Color(0xFF171719);
  static const cardDark = Color(0xFF121214);
  static const cardBorderDark = Color(0xFF242428);
  static const borderDark = Color(0xFF242428);
  static const dividerDark = Color(0xFF1C1C20);

  // ─── Neutral Text (Dark) ───────────────────────────────────────
  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFF9CA3AF);
  static const textMutedDark = Color(0xFF6B7280);

  // ─── Academic Primary Accents (Black & White) ─────────────────
  static const primaryLight = Color(0xFF111111);
  static const primaryDark = Color(0xFFFFFFFF);
  static const onPrimaryLight = Color(0xFFFFFFFF);
  static const onPrimaryDark = Color(0xFF111111);

  // ─── Semantic Status Colors ───────────────────────────────────
  static const success = Color(0xFF10B981); // Emerald
  static const warning = Color(0xFFF59E0B); // Amber
  static const danger = Color(0xFFEF4444); // Crimson
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6); // Neutral blue
  static const disabled = Color(0xFF9CA3AF);

  // ─── Examination & CBT Answer State Colors ────────────────────
  static const correctAnswer = Color(0xFF10B981);
  static const incorrectAnswer = Color(0xFFEF4444);
  static const selectedAnswerLight = Color(0xFF111111);
  static const selectedAnswerDark = Color(0xFFFFFFFF);

  // ─── Legacy / Compatibility Bridges ───────────────────────────
  // Preserved so un-refactored screens compile safely until their phases.
  static const surface = surfaceSecondaryLight;
  static const purple = Color(0xFF111111);
  static const deepPurple = Color(0xFF1F2937);
  static const pink = Color(0xFF374151);
  static const magenta = Color(0xFF4B5563);
}

/// Standardized spacing scale: 4, 8, 12, 16, 20, 24, 32, 40
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double section = 32.0;
  static const double sp40 = 40.0;
}

/// Standardized corner radius scale:
/// Card radius: 14–18px (default 16px)
/// Button radius: 12–16px (default 14px)
abstract final class AppRadius {
  static const double sm = 8.0;
  static const double button = 14.0;
  static const double card = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double circle = 999.0;
}
