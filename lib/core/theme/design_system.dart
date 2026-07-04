import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PathSaathi AI — Premium Design System
/// Contains all tokens, typography, shadows, and spacing for the application.

class AppColors {
  // Brand Palette
  static const Color primary = Color(0xFF6C63FF); // Modern Indigo
  static const Color primaryDark = Color(0xFF5046E5);
  static const Color primaryLight = Color(0xFFE2E1FF);
  
  static const Color secondary = Color(0xFF00C9B1); // Mint Green
  static const Color secondaryDark = Color(0xFF009688);
  static const Color secondaryLight = Color(0xFFE0F7FA);

  static const Color accent = Color(0xFFFF6584); // Soft Pink/Coral
  static const Color warning = Color(0xFFFFB74D); // Soft Orange

  // Neutrals - Light Mode
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color divider = Color(0xFFE2E8F0); // Slate 200

  // Neutrals - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color dividerDark = Color(0xFF334155); // Slate 700

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8A84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF4EE6D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradientLight = LinearGradient(
    colors: [
      Color(0x99FFFFFF),
      Color(0x33FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradientDark = LinearGradient(
    colors: [
      Color(0x4D1E293B),
      Color(0x1A1E293B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double round = 100.0;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
}

class AppShadows {
  static const List<BoxShadow> light = [
    BoxShadow(
      color: Color(0x0A000000), // Very subtle 4% black
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x4D6C63FF), // 30% primary
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

class AppTypography {
  static TextTheme getLightTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displaySmall: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  static TextTheme getDarkTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
      displayMedium: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
      displaySmall: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      titleLarge: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimaryDark),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondaryDark),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
    );
  }
}
