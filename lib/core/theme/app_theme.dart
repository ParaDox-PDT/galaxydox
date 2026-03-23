import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
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
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.outlineSoft,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final bodyTextTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final textTheme = bodyTextTheme.copyWith(
      displayLarge: _displayText(
        bodyTextTheme.displayLarge,
        size: 50,
        weight: FontWeight.w700,
        height: 0.94,
      ),
      displayMedium: _displayText(
        bodyTextTheme.displayMedium,
        size: 42,
        weight: FontWeight.w700,
        height: 0.98,
      ),
      headlineLarge: _displayText(
        bodyTextTheme.headlineLarge,
        size: 34,
        weight: FontWeight.w700,
        height: 1.05,
      ),
      headlineMedium: _displayText(
        bodyTextTheme.headlineMedium,
        size: 28,
        weight: FontWeight.w700,
        height: 1.1,
      ),
      headlineSmall: _displayText(
        bodyTextTheme.headlineSmall,
        size: 22,
        weight: FontWeight.w700,
        height: 1.16,
      ),
      titleLarge: _displayText(
        bodyTextTheme.titleLarge,
        size: 18,
        weight: FontWeight.w700,
        height: 1.22,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.titleMedium,
        fontWeight: FontWeight.w700,
        height: 1.22,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.titleSmall,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.bodyLarge,
        fontSize: 16,
        height: 1.62,
        color: AppColors.textSecondary,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.bodyMedium,
        fontSize: 14,
        height: 1.56,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.labelLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.24,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        textStyle: bodyTextTheme.labelMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.24,
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
        color: AppColors.surfaceElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceStrong,
        selectedColor: AppColors.surfaceSoft,
        disabledColor: AppColors.surface,
        secondarySelectedColor: AppColors.surfaceSoft,
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
          foregroundColor: AppColors.backgroundDeep,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.outline),
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surfaceStrong.withValues(alpha: 0.54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceStrong.withValues(alpha: 0.46),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.outlineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryStrong),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.surfaceSoft;
            }
            return AppColors.surfaceStrong.withValues(alpha: 0.46);
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.textPrimary),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.outlineSoft),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
          ),
          textStyle: WidgetStateProperty.all(textTheme.labelLarge),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSoft,
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceStrong,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryStrong,
        selectionColor: Color(0x664EA8FF),
        selectionHandleColor: AppColors.primaryStrong,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceStrong.withValues(alpha: 0.96),
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

  static TextStyle _displayText(
    TextStyle? base, {
    required double size,
    required FontWeight weight,
    required double height,
  }) {
    return GoogleFonts.sora(
      textStyle: base,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: -0.62,
    );
  }
}
