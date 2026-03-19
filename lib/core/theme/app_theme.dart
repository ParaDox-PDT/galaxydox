import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.surface,
      error: AppColors.error,
      onSurface: AppColors.textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      dividerColor: AppColors.outlineSoft,
    );

    final bodyTextTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final textTheme = bodyTextTheme.copyWith(
      displayLarge: _spaceText(
        bodyTextTheme.displayLarge,
        size: 48,
        weight: FontWeight.w700,
        height: 0.96,
      ),
      displayMedium: _spaceText(
        bodyTextTheme.displayMedium,
        size: 40,
        weight: FontWeight.w700,
        height: 1,
      ),
      headlineLarge: _spaceText(
        bodyTextTheme.headlineLarge,
        size: 32,
        weight: FontWeight.w700,
        height: 1.1,
      ),
      headlineMedium: _spaceText(
        bodyTextTheme.headlineMedium,
        size: 26,
        weight: FontWeight.w700,
        height: 1.12,
      ),
      headlineSmall: _spaceText(
        bodyTextTheme.headlineSmall,
        size: 22,
        weight: FontWeight.w700,
        height: 1.15,
      ),
      titleLarge: _spaceText(
        bodyTextTheme.titleLarge,
        size: 18,
        weight: FontWeight.w700,
        height: 1.2,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.titleMedium,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.titleSmall,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.bodyLarge,
        fontSize: 16,
        height: 1.6,
        color: AppColors.textSecondary,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.bodyMedium,
        fontSize: 14,
        height: 1.55,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.labelLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.labelMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    return base.copyWith(
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceStrong,
        selectedColor: AppColors.surfaceStrong,
        disabledColor: AppColors.surfaceSoft,
        secondarySelectedColor: AppColors.surfaceStrong,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: AppColors.outlineSoft),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle:
            textTheme.labelMedium?.copyWith(color: AppColors.textPrimary) ??
            const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: AppColors.textPrimary) ??
            const TextStyle(color: AppColors.textPrimary),
        brightness: Brightness.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSoft,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceStrong.withValues(alpha: 0.94),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextStyle _spaceText(
    TextStyle? base, {
    required double size,
    required FontWeight weight,
    required double height,
  }) {
    return GoogleFonts.spaceGrotesk(
      textStyle: base,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: -0.45,
    );
  }
}
