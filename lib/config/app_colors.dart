import 'package:flutter/material.dart';

/// PathSaathi AI — Design System Color Tokens
class AppColors {
  AppColors._();

  // ── Primary Brand ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4A6CF7);
  static const Color primaryDark = Color(0xFF3A5BD9);
  static const Color primaryLight = Color(0xFF7B96FF);

  // ── Secondary (Purple) ────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryDark = Color(0xFF6D28D9);
  static const Color secondaryLight = Color(0xFFA78BFA);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFF59E0B);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A6CF7), Color(0xFF7C3AED)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F3A), Color(0xFF2D1B69), Color(0xFF0F3460)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
  );

  // ── Light Theme Backgrounds ───────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2FF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ── Dark Theme Backgrounds ─────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B27);
  static const Color darkCard = Color(0xFF1E2535);
  static const Color darkBorder = Color(0xFF2A3245);

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDarkPrimary = Color(0xFFE2E8F0);
  static const Color textDarkSecondary = Color(0xFF94A3B8);

  // ── Glassmorphism ─────────────────────────────────────────────────────────
  static Color glassBg = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static Color glassDarkBg = Colors.black.withValues(alpha: 0.25);

  // ── Subject Colors ────────────────────────────────────────────────────────
  static const Color mathColor = Color(0xFF6C5CE7);
  static const Color scienceColor = Color(0xFF00B894);
  static const Color englishColor = Color(0xFF0984E3);
  static const Color historyColor = Color(0xFFE17055);
  static const Color geographyColor = Color(0xFF00CEC9);
  static const Color computerColor = Color(0xFFA29BFE);
  static const Color reasoningColor = Color(0xFFFF7675);
  static const Color gkColor = Color(0xFFFDCB6E);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.4),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
}

